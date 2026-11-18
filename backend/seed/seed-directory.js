// Load Exam Office roster entries into Firestore `directory/{email}`.
//
//   node seed/seed-directory.js seed/directory.sample.json --emulator   (local emulator)
//   node seed/seed-directory.js seed/directory.json                    (live project, needs
//        `gcloud auth application-default login` with an account that has access to seattap-imap-app)
//
// The first Exam Officer is created this way: add them with role "examOfficer", then they
// register in the app as normal and get the role from this entry.

const fs = require('fs');
const path = require('path');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { accountKind, normaliseId, isValidId, roleMatchesKind } = require('../src/registration');

const [file, flag] = process.argv.slice(2);
if (!file) {
  console.error('Usage: node seed/seed-directory.js <entries.json> [--emulator]');
  process.exit(1);
}

let projectId = 'seattap-imap-app';
if (flag === '--emulator') {
  process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
  projectId = 'demo-seattap';
}

initializeApp({ projectId });
const db = getFirestore();

async function main() {
  const entries = JSON.parse(fs.readFileSync(path.resolve(file), 'utf8'));
  const batch = db.batch();
  for (const e of entries) {
    const email = String(e.email).trim().toLowerCase();
    const kind = accountKind(email);
    const idNumber = normaliseId(e.idNumber);
    if (!kind || !isValidId(kind, idNumber) || !roleMatchesKind(e.role, kind)) {
      throw new Error(`Invalid entry: ${JSON.stringify(e)}`);
    }
    batch.set(db.collection('directory').doc(email), {
      email,
      idNumber,
      name: String(e.name || '').trim(),
      role: e.role,
      faculty: String(e.faculty || '').trim(),
      addedBy: 'seed',
      addedAt: FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  console.log(`Seeded ${entries.length} directory entries into ${projectId}.`);
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
