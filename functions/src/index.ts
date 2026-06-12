import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

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
    const signature = req.headers['paystack-signature'] as string | undefined;
    const flutterwaveHash = req.headers['verif-hash'] as string | undefined;
    
    const payload = req.body as PaymentWebhookPayload;
    
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

      const currentBalance = userDoc.data()?.walletBalanceNGN ?? 0;
      t.update(userRef, {
        walletBalanceNGN: currentBalance + amount!,
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