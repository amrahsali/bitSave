const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.executeVaultWithdrawal = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called while authenticated.'
    );
  }

  const userId = context.auth.uid;
  const { lockId, accountNumber, bankCode } = data;

  // Validate input
  if (!lockId || !accountNumber || !bankCode) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The function must be called with lockId, accountNumber, and bankCode.'
    );
  }

  const db = admin.firestore();
  const lockRef = db.collection('users').doc(userId).collection('locks').doc(lockId);

  // Run a transaction to ensure consistency
  try {
    await db.runTransaction(async (t) => {
      const lockDoc = await t.get(lockRef);
      if (!lockDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Lock document not found.');
      }

      const lockData = lockDoc.data();
      const now = admin.firestore.Timestamp.now();

      // Check if lock is matured and not already withdrawn
      if (!lockData.isMatured || lockData.targetMaturityDate.toMillis() > now.toMillis()) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Lock is not matured yet.'
        );
      }

      if (lockData.isWithdrawn === true) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Lock has already been withdrawn.'
        );
      }

      // Fetch live BTC price in NGN from CoinGecko API
      const btcPriceResponse = await fetch('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=ngn');
      if (!btcPriceResponse.ok) {
        throw new functions.https.HttpsError('internal', 'Failed to fetch BTC price.');
      }
      const btcPriceData = await btcPriceResponse.json();
      const btcPriceInNgn = btcPriceData.bitcoin.ngn;

      // Calculate fiat amount to pay in NGN
      // Use integer sats and perform safe conversion to avoid float rounding errors
      const satsAllocated = Number(lockData.satsAllocated || 0);
      const fiatAmountToPayNGN = (satsAllocated / 100000000) * Number(btcPriceInNgn);

      // TODO: Replace with actual Payment Gateway API call (e.g., Paystack or Flutterwave)
      // For now, we simulate a successful transfer
      // In production, you would make an HTTPS POST to the gateway API here
      // and handle the response.
      const transferResult = {
        status: 'success',
        // Assume the gateway returns a transaction ID or similar
        // We'll use a mock for now
        gatewayResponse: { success: true }
      };

      if (transferResult.status !== 'success') {
        throw new functions.https.HttpsError('internal', 'Payment gateway transfer failed.');
      }

      // Mark lock as withdrawn and completed atomically
      t.update(lockRef, {
        isWithdrawn: true,
        status: 'completed'
      });

      // Append payout ledger receipt to global transactions collection
      const transactionRef = db.collection('transactions').doc();
      t.set(transactionRef, {
        txId: transactionRef.id,
        userId: userId,
        amount: fiatAmountToPayNGN,
        type: 'withdrawal',
                        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
    });

    return { success: true };
  } catch (error) {
    console.error('Error in executeVaultWithdrawal:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Internal error occurred.');
  }
});