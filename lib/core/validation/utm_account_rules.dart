// Registration rules shared by the screens. They mirror backend/src/registration.js
// and firestore.rules, so the app can explain a problem before the server refuses it.

const studentDomain = 'graduate.utm.my';
const staffDomain = 'utm.my';

/// Students use @graduate.utm.my; invigilators and Exam Officers use @utm.my.
enum AccountKind { student, staff }

extension AccountKindLabels on AccountKind {
  /// What the ID is called on this kind of account.
  String get idLabel => this == AccountKind.student ? 'Matric number' : 'Staff ID';
  String get idHint => this == AccountKind.student ? 'e.g. A24CS0123' : 'e.g. STF-1042';
}

/// [AccountKind.student] for @graduate.utm.my, [AccountKind.staff] for @utm.my, else null.
AccountKind? accountKind(String email) {
  final e = email.trim().toLowerCase();
  final at = e.lastIndexOf('@');
  if (at < 1) return null;
  final domain = e.substring(at + 1);
  if (domain == studentDomain) return AccountKind.student;
  if (domain == staffDomain) return AccountKind.staff;
  return null;
}

/// Upper case with no spaces: "a24 cs0123" becomes "A24CS0123".
String normaliseId(String raw) => raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');

/// Matric numbers look like A24CS0123; staff IDs are 3–20 letters, digits or dashes.
bool isValidId(AccountKind kind, String id) => kind == AccountKind.student
    ? RegExp(r'^[A-Z]\d{2}[A-Z]{2}\d{4}$').hasMatch(id)
    : RegExp(r'^[A-Z0-9-]{3,20}$').hasMatch(id);

String? validateUtmEmail(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter your UTM email.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(v)) return 'Enter a valid email address.';
  if (accountKind(v) == null) return 'Use your @utm.my or @graduate.utm.my email.';
  return null;
}

String? validateName(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Enter your full name.';
  if (v.length > 80) return 'Keep it under 80 characters.';
  return null;
}

String? validatePhone(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return null;
  if (v.length > 20 || !RegExp(r'^[0-9+\-\s()]+$').hasMatch(v)) return 'Enter a valid phone number.';
  return null;
}

/// The four password checks shown on the Create account and Change password screens.
class PasswordChecks {
  PasswordChecks(this.password, this.confirm);

  final String password;
  final String confirm;

  bool get longEnough => password.length >= 8;
  bool get mixedCase => RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password);
  bool get hasNumber => RegExp(r'\d').hasMatch(password);
  bool get matches => password.isNotEmpty && password == confirm;
  bool get allPass => longEnough && mixedCase && hasNumber && matches;
}
