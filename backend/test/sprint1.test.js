// Sprint 1 backend tests (Spark plan: the Firestore rules are the backend).
// Runs against the Auth and Firestore emulators:
//   npm run test:emulators
//
// `register` and `review` below do what the Flutter app's services do, so these tests
// cover the real sign-up and approval flows as well as direct attempts to cheat the rules.
const assert = require('node:assert/strict');
const { initializeApp: initAdmin } = require('firebase-admin/app');
const { getAuth: adminAuthOf } = require('firebase-admin/auth');
const { getFirestore: adminDbOf } = require('firebase-admin/firestore');
const { initializeApp, deleteApp } = require('firebase/app');
const { getAuth, connectAuthEmulator, createUserWithEmailAndPassword } = require('firebase/auth');
const {
  getFirestore, connectFirestoreEmulator, doc, getDoc, setDoc, updateDoc, writeBatch,
  collection, query, where, orderBy, getDocs, serverTimestamp,
} = require('firebase/firestore');
const { accountKind, normaliseId } = require('../src/registration');

const PROJECT = 'demo-seattap';
const admin = initAdmin({ projectId: PROJECT }, 'admin');
const adminAuth = adminAuthOf(admin);
const adminDb = adminDbOf(admin);
const apps = [];

async function clearEmulators() {
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJECT}/databases/(default)/documents`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJECT}/accounts`, { method: 'DELETE' });
}

async function seedDirectory(entries) {
  for (const e of entries) await adminDb.collection('directory').doc(e.email).set(e);
}

/** A signed-in app user (client SDK, so security rules apply). */
async function signUp(email, { verified = true } = {}) {
  const app = initializeApp({ projectId: PROJECT, apiKey: 'demo-key' }, `client-${apps.length}`);
  apps.push(app);
  const auth = getAuth(app);
  connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
  const db = getFirestore(app);
  connectFirestoreEmulator(db, '127.0.0.1', 8080);

  const { user } = await createUserWithEmailAndPassword(auth, email, 'Passw0rd!');
  if (verified) {
    await adminAuth.updateUser(user.uid, { emailVerified: true });
    await user.reload();
    await user.getIdToken(true);
  }
  return { uid: user.uid, email, db };
}

const profileRef = (u, uid = u.uid) => doc(u.db, 'users', uid);

/** Complete profile: what the app's registration service does. */
async function register(u, { name, idNumber, phone }) {
  const existing = await getDoc(profileRef(u));
  if (existing.exists()) return existing.data();

  const entry = await getDoc(doc(u.db, 'directory', u.email));
  const kind = accountKind(u.email);
  let profile;
  if (entry.exists()) {
    profile = {
      role: entry.data().role,
      status: 'active',
      ...(entry.data().faculty ? { faculty: entry.data().faculty } : {}),
    };
  } else if (kind === 'staff') {
    profile = { role: 'invigilator', status: 'pending' };
  } else {
    throw Object.assign(new Error('Not on the roster'), { code: 'not-found' });
  }
  const data = {
    email: u.email,
    name,
    idNumber: normaliseId(idNumber),
    ...(phone ? { phone } : {}),
    ...profile,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
  await setDoc(profileRef(u), data);
  return (await getDoc(profileRef(u))).data();
}

/** Pending staff approvals: what the app's approval service does. */
async function review(officer, staff, decision) {
  const batch = writeBatch(officer.db);
  batch.update(profileRef(officer, staff.uid), {
    status: decision === 'approve' ? 'active' : 'rejected',
    reviewedBy: officer.uid,
    reviewedAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  if (decision === 'approve') {
    const p = (await getDoc(profileRef(officer, staff.uid))).data();
    batch.set(doc(officer.db, 'directory', p.email), {
      email: p.email, idNumber: p.idNumber, name: p.name, role: 'invigilator',
      addedBy: officer.uid, addedAt: serverTimestamp(),
    });
  }
  await batch.commit();
}

/** A raw profile write, for trying to get round the rules. */
function rawProfile(u, overrides) {
  return {
    email: u.email, name: 'Someone', idNumber: 'A24CS0001', role: 'student', status: 'active',
    createdAt: serverTimestamp(), updatedAt: serverTimestamp(), ...overrides,
  };
}

async function denied(promise) {
  await assert.rejects(promise, (err) => {
    assert.equal(err.code, 'permission-denied', err.message);
    return true;
  });
}

describe('SeatTap Sprint 1 backend (Firestore rules)', function () {
  let student, officer, pendingStaff, otherPending;

  before(async () => {
    await clearEmulators();
    await seedDirectory([
      { email: 'ahmad.danial@graduate.utm.my', idNumber: 'A24CS0123', name: 'Ahmad Danial', role: 'student', faculty: 'Faculty of Computing' },
      { email: 'siti.aminah@graduate.utm.my', idNumber: 'A24CS0999', name: 'Siti Aminah', role: 'student', faculty: 'Faculty of Computing' },
      { email: 'hafiz.rahman@utm.my', idNumber: 'STF-0217', name: 'Hafiz Rahman', role: 'examOfficer', faculty: 'Faculty of Computing' },
    ]);
  });

  after(async () => {
    await Promise.all(apps.map((a) => deleteApp(a)));
  });

  describe('registration', () => {
    it('makes a student on the roster an active student', async () => {
      student = await signUp('ahmad.danial@graduate.utm.my');
      const p = await register(student, { name: 'Ahmad Danial', idNumber: 'a24cs 0123', phone: '011-2345 6789' });
      assert.equal(p.role, 'student');
      assert.equal(p.status, 'active');
      assert.equal(p.idNumber, 'A24CS0123');
      assert.equal(p.faculty, 'Faculty of Computing');
    });

    it('is safe to run again (Check again / double tap)', async () => {
      const p = await register(student, { name: 'x', idNumber: 'x' });
      assert.equal(p.name, 'Ahmad Danial');
    });

    it('makes an Exam Officer on the roster active', async () => {
      officer = await signUp('hafiz.rahman@utm.my');
      const p = await register(officer, { name: 'Hafiz Rahman', idNumber: 'STF-0217' });
      assert.equal(p.role, 'examOfficer');
      assert.equal(p.status, 'active');
    });

    it('puts UTM staff who are not on the roster on hold as invigilators', async () => {
      pendingStaff = await signUp('farah.hanim@utm.my');
      const p = await register(pendingStaff, { name: 'Dr. Farah Hanim', idNumber: 'STF-1042' });
      assert.equal(p.role, 'invigilator');
      assert.equal(p.status, 'pending');
      otherPending = await signUp('lim.weijie@utm.my');
      await register(otherPending, { name: 'Lim Wei Jie', idNumber: 'STF-2001' });
    });

    it('refuses an unverified email', async () => {
      const u = await signUp('unverified@graduate.utm.my', { verified: false });
      await denied(setDoc(profileRef(u), rawProfile(u)));
    });

    it('refuses a non-UTM email', async () => {
      const u = await signUp('someone@gmail.com');
      await denied(setDoc(profileRef(u), rawProfile(u)));
      await denied(setDoc(profileRef(u), rawProfile(u, { role: 'invigilator', status: 'pending', idNumber: 'STF-0001' })));
    });

    it('refuses a matric number that does not match the roster', async () => {
      const u = await signUp('siti.aminah@graduate.utm.my');
      await denied(setDoc(profileRef(u), rawProfile(u, { idNumber: 'A24CS0111' })));
    });

    it('refuses a student who is not on the roster, even as a pending invigilator', async () => {
      const u = await signUp('not.listed@graduate.utm.my');
      await assert.rejects(register(u, { name: 'Nobody', idNumber: 'A24CS0002' }), { code: 'not-found' });
      await denied(setDoc(profileRef(u), rawProfile(u)));
      await denied(setDoc(profileRef(u), rawProfile(u, { role: 'invigilator', status: 'pending' })));
    });

    it('refuses a badly formed matric number', async () => {
      const u = await signUp('bad.id@graduate.utm.my');
      await adminDb.doc('directory/bad.id@graduate.utm.my').set({ email: 'bad.id@graduate.utm.my', idNumber: '12345', name: 'Bad', role: 'student' });
      await denied(setDoc(profileRef(u), rawProfile(u, { idNumber: '12345' })));
    });

    it('does not let unlisted staff make themselves active or an Exam Officer', async () => {
      const u = await signUp('sneaky@utm.my');
      await denied(setDoc(profileRef(u), rawProfile(u, { role: 'invigilator', status: 'active', idNumber: 'STF-9999' })));
      await denied(setDoc(profileRef(u), rawProfile(u, { role: 'examOfficer', status: 'pending', idNumber: 'STF-9999' })));
    });

    it('does not let anyone create a profile for another account', async () => {
      const u = await signUp('siti.aminah2@graduate.utm.my');
      await denied(setDoc(profileRef(u, 'someone-else'), rawProfile(u)));
    });
  });

  describe('staff approval', () => {
    it('only lets Exam Officers review', async () => {
      await denied(review(student, pendingStaff, 'approve'));
      await denied(updateDoc(profileRef(pendingStaff), { status: 'active', reviewedBy: pendingStaff.uid, reviewedAt: serverTimestamp(), updatedAt: serverTimestamp() }));
    });

    it('approves a pending invigilator and adds them to the roster', async () => {
      await review(officer, pendingStaff, 'approve');
      const p = (await adminDb.doc(`users/${pendingStaff.uid}`).get()).data();
      assert.equal(p.status, 'active');
      assert.equal(p.reviewedBy, officer.uid);
      const entry = (await adminDb.doc('directory/farah.hanim@utm.my').get()).data();
      assert.equal(entry.role, 'invigilator');
      assert.equal(entry.idNumber, 'STF-1042');
    });

    it('will not review the same request twice', async () => {
      await denied(review(officer, pendingStaff, 'reject'));
    });

    it('rejects a pending request', async () => {
      await review(officer, otherPending, 'reject');
      const p = (await adminDb.doc(`users/${otherPending.uid}`).get()).data();
      assert.equal(p.status, 'rejected');
    });

    it('does not let an Exam Officer change anything else while reviewing', async () => {
      const u = await signUp('third.staff@utm.my');
      await register(u, { name: 'Third Staff', idNumber: 'STF-3001' });
      await denied(updateDoc(profileRef(officer, u.uid), {
        status: 'active', role: 'examOfficer', reviewedBy: officer.uid, reviewedAt: serverTimestamp(), updatedAt: serverTimestamp(),
      }));
    });
  });

  describe('reading and editing', () => {
    it('lets a user read their own profile but not someone else\'s', async () => {
      const own = await getDoc(profileRef(student));
      assert.equal(own.data().name, 'Ahmad Danial');
      await denied(getDoc(profileRef(student, officer.uid)));
    });

    it('lets an Exam Officer list pending staff, and nobody else', async () => {
      const q = (db) => query(collection(db, 'users'), where('status', '==', 'pending'), orderBy('createdAt'));
      const snap = await getDocs(q(officer.db));
      assert.deepEqual(snap.docs.map((d) => d.data().email), ['third.staff@utm.my']);
      await denied(getDocs(q(student.db)));
      await denied(getDocs(q(pendingStaff.db)));
    });

    it('lets a user edit their name, phone, faculty and photo', async () => {
      await updateDoc(profileRef(student), {
        phone: '012-000 1111', faculty: 'Faculty of Computing',
        photoUrl: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==', updatedAt: serverTimestamp(),
      });
      const after = (await adminDb.doc(`users/${student.uid}`).get()).data();
      assert.equal(after.phone, '012-000 1111');
    });

    it('refuses a photo that is not a small image', async () => {
      await denied(updateDoc(profileRef(student), { photoUrl: 'https://evil.example/x.png', updatedAt: serverTimestamp() }));
      await denied(updateDoc(profileRef(student), { photoUrl: `data:image/png;base64,${'A'.repeat(200001)}`, updatedAt: serverTimestamp() }));
    });

    it('does not let a user change their role, status, ID or email', async () => {
      for (const change of [{ role: 'examOfficer' }, { status: 'pending' }, { idNumber: 'A24CS9999' }, { email: 'x@utm.my' }]) {
        await denied(updateDoc(profileRef(student), { ...change, updatedAt: serverTimestamp() }));
      }
    });

    it('lets a user read only their own roster entry', async () => {
      const own = await getDoc(doc(student.db, 'directory', 'ahmad.danial@graduate.utm.my'));
      assert.equal(own.data().idNumber, 'A24CS0123');
      await denied(getDoc(doc(student.db, 'directory', 'siti.aminah@graduate.utm.my')));
      await denied(getDocs(collection(student.db, 'directory')));
    });

    it('lets only Exam Officers add to the roster', async () => {
      const entry = (u) => ({ email: 'new.student@graduate.utm.my', idNumber: 'A24CS0500', name: 'New Student', role: 'student', addedBy: u.uid, addedAt: serverTimestamp() });
      await denied(setDoc(doc(student.db, 'directory', 'new.student@graduate.utm.my'), entry(student)));
      await setDoc(doc(officer.db, 'directory', 'new.student@graduate.utm.my'), entry(officer));
      await denied(setDoc(doc(officer.db, 'directory', 'wrong@graduate.utm.my'), { ...entry(officer), role: 'examOfficer' }));
    });

    it('does not let a pending invigilator act as staff', async () => {
      const u = await signUp('waiting@utm.my');
      await register(u, { name: 'Waiting Staff', idNumber: 'STF-4000' });
      await denied(getDocs(collection(u.db, 'users')));
      await denied(getDoc(doc(u.db, 'directory', 'hafiz.rahman@utm.my')));
    });
  });
});
