const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.executeVaultLock = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const userId = context.auth.uid;
  const amount = Number(data?.amount);
  const durationInMonths = Number(data?.durationInMonths) || 0;

  if (!amount || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount provided.');
  }

  try {
    const userRef = admin.firestore().doc(`users/${userId}`);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'User document not found.');
    }

    const userData = userSnap.data() || {};
    const walletBalanceNGN = Number(userData.walletBalanceNGN || 0);
    if (walletBalanceNGN < amount) {
      throw new functions.https.HttpsError('invalid-argument', 'Insufficient wallet balance.');
    }

    // Fetch BTC price in NGN from CoinGecko
    const cgUrl = 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=ngn';
    const resp = await fetch(cgUrl);
    if (!resp.ok) {
      throw new functions.https.HttpsError('unavailable', 'Failed to fetch price from CoinGecko.');
    }
    const priceJson = await resp.json();
    const btcPriceInNgn = Number(priceJson?.bitcoin?.ngn);
    if (!btcPriceInNgn || btcPriceInNgn <= 0) {
      throw new functions.https.HttpsError('unavailable', 'Invalid price data from CoinGecko.');
    }

    const sats = Math.floor((amount / btcPriceInNgn) * 100000000);

    const result = await admin.firestore().runTransaction(async (tx) => {
      const uSnap = await tx.get(userRef);
      const currentBalance = Number(uSnap.data()?.walletBalanceNGN || 0);
      if (currentBalance < amount) {
        throw new functions.https.HttpsError('invalid-argument', 'Insufficient funds during transaction.');
      }

      tx.update(userRef, { walletBalanceNGN: admin.firestore.FieldValue.increment(-amount) });

      const locksCol = userRef.collection('locks');
      const lockRef = locksCol.doc();

      const now = admin.firestore.Timestamp.now();
      const maturityDate = new Date();
      maturityDate.setMonth(maturityDate.getMonth() + durationInMonths);

      const lockDoc = {
        lockId: lockRef.id,
        userId: userId,
        fiatAmountNGN: amount,
        satsAllocated: sats,
        btcPriceAtLock: btcPriceInNgn,
        createdAt: now,
        targetMaturityDate: admin.firestore.Timestamp.fromDate(maturityDate),
        isMatured: false,
      };

      tx.set(lockRef, lockDoc);
      return { lockId: lockRef.id, satsAllocated: sats };
    });

    return { success: true, ...result };
  } catch (err) {
    if (err instanceof functions.https.HttpsError) throw err;
    throw new functions.https.HttpsError('internal', err.message || String(err));
  }
});
