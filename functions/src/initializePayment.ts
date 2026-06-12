import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const initializePayment = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const amount = data.amount;
  if (typeof amount !== 'number' || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
  }

  // TODO: Integrate with Paystack/Flutterwave SDK to create payment transaction
  // const payment = await paystack.Transactions.initialize({...});
  const checkoutUrl = `https://checkout.paystack.com/...`;

  return { checkoutUrl };
});