"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.paymentWebhook = exports.nombaWebhook = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const crypto = __importStar(require("crypto"));
admin.initializeApp();
const db = admin.firestore();
// ─── Nomba HMAC-SHA256 signature verifier ────────────────────────────────────
/**
 * Re-creates the Nomba signature.
 *
 * Hashing payload format (per official Nomba docs):
 *   event_type:requestId:userId:walletId:transactionId:type:time:responseCode:nomba-timestamp
 *
 * Algorithm: HMAC-SHA256 → Base64-encode the raw bytes.
 */
function generateNombaSignature(payload, secret, nombaTimestamp) {
    const merchant = payload.data?.merchant ?? {};
    const transaction = payload.data?.transaction ?? {};
    const eventType = payload.event_type ?? '';
    const requestId = payload.requestId ?? '';
    const userId = merchant.walletId ? (merchant.userId ?? '') : '';
    const walletId = merchant.walletId ?? '';
    const transactionId = transaction.transactionId ?? '';
    const transactionType = transaction.type ?? '';
    const transactionTime = transaction.time ?? '';
    let transactionRespCode = transaction.responseCode ?? '';
    // Nomba treats the literal string "null" as empty
    if (transactionRespCode === 'null')
        transactionRespCode = '';
    const hashingPayload = [
        eventType,
        requestId,
        userId,
        walletId,
        transactionId,
        transactionType,
        transactionTime,
        transactionRespCode,
        nombaTimestamp,
    ].join(':');
    console.log(`[nombaWebhook] hashing payload → ${hashingPayload}`);
    return crypto
        .createHmac('sha256', secret)
        .update(hashingPayload)
        .digest('base64');
}
// ─── Nomba Webhook Cloud Function ────────────────────────────────────────────
exports.nombaWebhook = functions
    .runWith({ timeoutSeconds: 30 })
    .https.onRequest(async (req, res) => {
    try {
        if (req.method !== 'POST') {
            res.status(405).send('Method Not Allowed');
            return;
        }
        // Read headers (HTTP header names are case-insensitive; Cloud Functions lowercases them)
        const receivedSignature = req.headers['nomba-signature'];
        const nombaTimestamp = req.headers['nomba-timestamp'];
        if (!receivedSignature || !nombaTimestamp) {
            console.warn('[nombaWebhook] Missing nomba-signature or nomba-timestamp header');
            res.status(400).send('Missing required Nomba headers');
            return;
        }
        // Secret key — loaded from .env.am-ka-ab-beetsave at deploy time
        const NOMBA_SIGNING_KEY = process.env.NOMBA_SIGNING_KEY ?? '';
        if (!NOMBA_SIGNING_KEY) {
            console.error('[nombaWebhook] NOMBA_SIGNING_KEY is not configured');
            res.status(500).send('Server configuration error');
            return;
        }
        const payload = req.body;
        // ── Verify signature ─────────────────────────────────────────────────────
        const expectedSignature = generateNombaSignature(payload, NOMBA_SIGNING_KEY, nombaTimestamp);
        // Case-insensitive comparison (Nomba docs use equalsIgnoreCase / toLowerCase)
        if (receivedSignature.toLowerCase() !== expectedSignature.toLowerCase()) {
            console.warn('[nombaWebhook] Signature mismatch', {
                received: receivedSignature,
                expected: expectedSignature,
            });
            res.status(403).send('Invalid signature');
            return;
        }
        console.log(`[nombaWebhook] Signature verified ✓  event_type=${payload.event_type}`);
        // ── Route by event type ──────────────────────────────────────────────────
        const eventType = payload.event_type;
        if (eventType === 'payment_success') {
            const userId = payload.data?.merchant?.userId;
            const amount = payload.data?.transaction?.transactionAmount;
            const txId = payload.data?.transaction?.transactionId;
            if (!userId || !amount || !txId) {
                console.warn('[nombaWebhook] payment_success missing required fields', { userId, amount, txId });
                res.status(400).send('Missing required fields');
                return;
            }
            await db.runTransaction(async (t) => {
                const userRef = db.collection('users').doc(userId);
                const userDoc = await t.get(userRef);
                if (!userDoc.exists) {
                    throw new Error(`[nombaWebhook] User ${userId} not found`);
                }
                // Atomic wallet credit
                t.update(userRef, {
                    walletBalanceNGN: admin.firestore.FieldValue.increment(amount),
                });
                // Record the transaction (idempotent via txId as document ID)
                t.set(db.collection('transactions').doc(txId), {
                    txId,
                    userId,
                    amount,
                    type: 'deposit',
                    provider: 'nomba',
                    narration: payload.data?.transaction?.narration ?? '',
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                }, { merge: false });
            });
            console.log(`[nombaWebhook] Credited ₦${amount} to user ${userId} (txId=${txId})`);
            res.status(200).send('OK');
            return;
        }
        // All other event types — acknowledge receipt but take no action
        console.log(`[nombaWebhook] Ignored event_type=${eventType}`);
        res.status(200).send('Ignored event');
    }
    catch (error) {
        console.error('[nombaWebhook] Unhandled error:', error);
        res.status(500).send('Internal server error');
    }
});
exports.paymentWebhook = functions.https.onRequest(async (req, res) => {
    try {
        const signature = (req.headers['paystack-signature'] || req.headers['x-paystack-signature']);
        const flutterwaveHash = (req.headers['verif-hash'] || req.headers['verif_hash']);
        const payload = req.body;
        // Verify Paystack webhook signature (HMAC SHA512)
        const PAYSTACK_SECRET = functions.config().paystack?.secret || process.env.PAYSTACK_SECRET || '';
        if (signature && PAYSTACK_SECRET) {
            const computed = crypto.createHmac('sha512', PAYSTACK_SECRET)
                .update(JSON.stringify(req.body))
                .digest('hex');
            if (computed !== signature) {
                console.warn('Invalid Paystack signature');
                res.status(403).send('Invalid signature');
                return;
            }
        }
        // Verify Flutterwave verif-hash header if present
        const FLUTTERWAVE_HASH = functions.config().flutterwave?.hash || process.env.FLUTTERWAVE_HASH || '';
        if (flutterwaveHash && FLUTTERWAVE_HASH) {
            if (flutterwaveHash !== FLUTTERWAVE_HASH) {
                console.warn('Invalid Flutterwave verif-hash');
                res.status(403).send('Invalid signature');
                return;
            }
        }
        if (!payload?.data) {
            res.status(400).send('Invalid payload');
            return;
        }
        let userId = null;
        let amount = null;
        let txId = null;
        if (payload.event === 'charge.success' && signature) {
            amount = payload.data.amount ?? null;
            userId = payload.data.metadata?.userId ?? null;
            txId = payload.data.reference ?? payload.data.id ?? null;
        }
        else if (payload.data.status === 'successful' && flutterwaveHash) {
            amount = payload.data.amount ?? null;
            userId = payload.data.metadata?.userId ?? null;
            txId = payload.data.tx_ref ?? payload.data.id ?? null;
        }
        else {
            res.status(200).send('Ignored event');
            return;
        }
        if (!userId || !amount || !txId) {
            res.status(400).send('Missing required fields');
            return;
        }
        await db.runTransaction(async (t) => {
            const userRef = db.collection('users').doc(userId);
            const userDoc = await t.get(userRef);
            if (!userDoc.exists) {
                throw new Error('User not found');
            }
            // Use atomic increment to avoid race conditions
            t.update(userRef, {
                walletBalanceNGN: admin.firestore.FieldValue.increment(amount),
            });
            t.set(db.collection('transactions').doc(txId), {
                txId: txId,
                userId: userId,
                amount: amount,
                type: 'deposit',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
        });
        res.status(200).send('OK');
    }
    catch (error) {
        console.error('Webhook error:', error);
        res.status(500).send('Error processing webhook');
    }
});
