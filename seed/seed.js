// Seeds Firestore from mock_data.json.
// Usage (from the seed/ folder):
//   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
//   node seed.js
// Safe to re-run: fixed doc IDs mean documents are overwritten, not duplicated.

const { initializeApp } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const data = require('./mock_data.json');

initializeApp(); // reads GOOGLE_APPLICATION_CREDENTIALS
const db = getFirestore();

async function main() {
  const batch = db.batch();
  let count = 0;

  for (const [collection, docs] of Object.entries(data)) {
    for (const [id, fields] of Object.entries(docs)) {
      const doc = { ...fields };
      if (collection === 'routes') {
        doc.last_verified = Timestamp.now();
      }
      batch.set(db.collection(collection).doc(id), doc);
      count++;
    }
  }

  await batch.commit();
  console.log(`Seeded ${count} documents.`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
