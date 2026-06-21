const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.dailyMaturityScanner = functions.pubsub.schedule('0 0 * * *')
  .timeZone('UTC') // Adjust time zone as needed
  .onRun(async (context) => {
    console.log('Starting daily maturity scanner...');
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    try {
      // Query all lock documents where isMatured == false and targetMaturityDate <= now
      const locksSnapshot = await db.collectionGroup('locks')
        .where('isMatured', '==', false)
        .where('targetMaturityDate', '<=', now)
        .get();

      if (locksSnapshot.empty) {
        console.log('No locks found for maturity update.');
        return null;
      }

      const batch = db.batch();
      locksSnapshot.forEach((doc) => {
        batch.update(doc.ref, { isMatured: true });
      });

      await batch.commit();
      console.log(`Successfully updated ${locksSnapshot.size} locks to matured.`);

      // Optional: Trigger a mock notification payload log
      locksSnapshot.forEach((doc) => {
        const lockData = doc.data();
        console.log(`Mock notification: Lock ${doc.id} for user ${doc.ref.parent.parent.id} is now liquid.`);
      });

      return null;
    } catch (error) {
      console.error('Error in dailyMaturityScanner:', error);
      throw error;
    }
  });