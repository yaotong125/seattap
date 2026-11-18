// Create ready-to-use test accounts: a verified sign-in, a roster entry and an active
// profile, so you can sign in to the app straight away as that role.
//
//   node seed/create-test-accounts.js seed/test-accounts.json --emulator
//       Local emulators (start them first with `npm run serve`). The passwords in
//       test-accounts.json are for the emulators only.
//
//   node seed/create-test-accounts.js seed/test-accounts.json
//       Live project seattap-imap-app. Needs an admin key: set GOOGLE_APPLICATION_CREDENTIALS
//       to a service-account JSON file (Firebase console > Project settings > Service accounts).
//       A fresh random password is made for each account and written to
//       seed/test-accounts.local.json (git-ignored), never the password from the input file.
//
// Safe to run again: existing accounts are updated, not duplicated.

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { accountKind, normaliseId, isValidId, roleMatchesKind } = require('../src/registration');

const [file, flag] = process.argv.slice(2);
if (!file) {
  console.error('Usage: node seed/create-test-accounts.js <accounts.json> [--emulator]');
  process.exit(1);
}

const emulator = flag === '--emulator';
let projectId = 'seattap-imap-app';
if (emulator) {
  process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
  process.env.FIREBASE_AUTH_EMULATOR_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';
  projectId = 'demo-seattap';
} else if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('Set GOOGLE_APPLICATION_CREDENTIALS to a service-account key for seattap-imap-app first.');
  process.exit(1);
}

initializeApp({ projectId });
const auth = getAuth();
const db = getFirestore();

async function upsertUser(email, password, name) {
  try {
    const existing = await auth.getUserByEmail(email);
    return auth.updateUser(existing.uid, { password, displayName: name, emailVerified: true, disabled: false });
  } catch (err) {
    if (err.code !== 'auth/user-not-found') throw err;
    return auth.createUser({ email, password, displayName: name, emailVerified: true });
  }
}

async function main() {
  const accounts = JSON.parse(fs.readFileSync(path.resolve(file), 'utf8'));
  const localFile = path.join(__dirname, 'test-accounts.local.json');
  // Live passwords made on an earlier run are kept, so re-running doesn't lock anyone out.
  const known = new Map();
  if (!emulator && fs.existsSync(localFile)) {
    for (const a of JSON.parse(fs.readFileSync(localFile, 'utf8'))) known.set(a.email, a.password);
  }
  const created = [];
  for (const a of accounts) {
    const email = String(a.email).trim().toLowerCase();
    const kind = accountKind(email);
    const idNumber = normaliseId(a.idNumber);
    if (!kind || !isValidId(kind, idNumber) || !roleMatchesKind(a.role, kind)) {
      throw new Error(`Invalid account: ${email}`);
    }
    const password = emulator ? a.password : (known.get(email) || crypto.randomBytes(12).toString('base64url'));
    const user = await upsertUser(email, password, a.name);

    const now = FieldValue.serverTimestamp();
    const batch = db.batch();
    batch.set(db.collection('directory').doc(email), {
      email, idNumber, name: a.name, role: a.role,
      ...(a.faculty ? { faculty: a.faculty } : {}),
      addedBy: 'seed', addedAt: now,
    });
    batch.set(db.collection('users').doc(user.uid), {
      email, name: a.name, idNumber, role: a.role, status: 'active',
      ...(a.faculty ? { faculty: a.faculty } : {}),
      ...(a.phone ? { phone: a.phone } : {}),
      createdAt: now, updatedAt: now,
    });
    await batch.commit();
    created.push({ email, password, role: a.role, uid: user.uid });
    console.log(`Ready: ${email} (${a.role})`);
  }

  if (!emulator) {
    fs.writeFileSync(localFile, JSON.stringify(created, null, 2) + '\n');
    console.log(`Passwords saved to ${localFile}`);
  }
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
