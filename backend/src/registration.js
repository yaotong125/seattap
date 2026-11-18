// Pure helpers for registration: which kind of UTM account an email is, and ID checks.
// Kept free of Firebase so they are easy to unit test.

const STUDENT_DOMAIN = 'graduate.utm.my';
const STAFF_DOMAIN = 'utm.my';

const ROLES = Object.freeze({
  student: 'student',
  invigilator: 'invigilator',
  examOfficer: 'examOfficer',
});

const STAFF_ROLES = [ROLES.invigilator, ROLES.examOfficer];

/** 'student' for @graduate.utm.my, 'staff' for @utm.my, otherwise null. */
function accountKind(email) {
  const domain = String(email || '').trim().toLowerCase().split('@')[1];
  if (domain === STUDENT_DOMAIN) return 'student';
  if (domain === STAFF_DOMAIN) return 'staff';
  return null;
}

/** Upper-case, no spaces: "a24 cs0123" -> "A24CS0123". */
function normaliseId(id) {
  return String(id || '').trim().toUpperCase().replace(/\s+/g, '');
}

/** Matric numbers look like A24CS0123; staff IDs are 3-20 letters, digits or dashes. */
function isValidId(kind, id) {
  if (kind === 'student') return /^[A-Z]\d{2}[A-Z]{2}\d{4}$/.test(id);
  if (kind === 'staff') return /^[A-Z0-9-]{3,20}$/.test(id);
  return false;
}

/** Does a roster role belong with this kind of email? */
function roleMatchesKind(role, kind) {
  if (kind === 'student') return role === ROLES.student;
  if (kind === 'staff') return STAFF_ROLES.includes(role);
  return false;
}

module.exports = { ROLES, accountKind, normaliseId, isValidId, roleMatchesKind };
