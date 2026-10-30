//helper for creating collection in firebase


const admin = require('firebase-admin');
const data = require('./mock_data.json');

admin.initializeApp(); // uses GOOGLE_APPLICATION_CREDENTIALS
const db = admin.firestore();

async function main() {
  const batch = db.batch();
  for (const [collection, docs] of Object.entries(data)) {
    for (const [id, fields] of Object.entries(docs)) {
      const doc = { ...fields };
      if (collection === 'routes') {
        doc.last_verified = admin.firestore.Timestamp.now();
      }
      batch.set(db.collection(collection).doc(id), doc);
    }
  }
  await batch.commit();
  console.log('Seeded.');
}
main();