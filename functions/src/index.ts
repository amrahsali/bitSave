import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

admin.initializeApp();
const db = admin.firestore();

interface PaymentWebhookPayload {
  event?: string;
  data?: {
    reference?: string;
    amount?: number;
    metadata?: {
      userId?: string;
    };
    status?: string;
    tx_ref?: string;
    id?: string;
    created_at?: string;
  };
}

export const paymentWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const signature = (req.headers['paystack-signature'] || req.headers['x-paystack-signature']) as string | undefined;
    const flutterwaveHash = (req.headers['verif-hash'] || req.headers['verif_hash']) as string | undefined;

    const payload = req.body as PaymentWebhookPayload;

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

    let userId: string | null = null;
    let amount: number | null = null;
    let txId: string | null = null;

    if (payload.event === 'charge.success' && signature) {
      amount = payload.data.amount ?? null;
      userId = payload.data.metadata?.userId ?? null;
      txId = payload.data.reference ?? payload.data.id ?? null;
    } else if (payload.data.status === 'successful' && flutterwaveHash) {
      amount = payload.data.amount ?? null;
      userId = payload.data.metadata?.userId ?? null;
      txId = payload.data.tx_ref ?? payload.data.id ?? null;
    } else {
      res.status(200).send('Ignored event');
      return;
    }

    if (!userId || !amount || !txId) {
      res.status(400).send('Missing required fields');
      return;
    }

    await db.runTransaction(async (t) => {
      const userRef = db.collection('users').doc(userId!);
      const userDoc = await t.get(userRef);

      if (!userDoc.exists) {
        throw new Error('User not found');
      }

      // Use atomic increment to avoid race conditions
      t.update(userRef, {
        walletBalanceNGN: admin.firestore.FieldValue.increment(amount!),
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
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).send('Error processing webhook');
  }
});