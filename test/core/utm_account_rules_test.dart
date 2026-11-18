import 'package:flutter_test/flutter_test.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/validation/utm_account_rules.dart';

import '../fakes.dart';

void main() {
  test('tells student and staff emails apart', () {
    expect(accountKind('Ahmad@Graduate.UTM.my'), AccountKind.student);
    expect(accountKind('farah@utm.my'), AccountKind.staff);
    expect(accountKind('someone@gmail.com'), isNull);
    expect(accountKind('not-an-email'), isNull);
  });

  test('normalises and checks IDs', () {
    expect(normaliseId(' a24 cs0123 '), 'A24CS0123');
    expect(isValidId(AccountKind.student, 'A24CS0123'), isTrue);
    expect(isValidId(AccountKind.student, '12345'), isFalse);
    expect(isValidId(AccountKind.staff, 'STF-1042'), isTrue);
    expect(isValidId(AccountKind.staff, 'S!'), isFalse);
  });

  test('password checks', () {
    expect(PasswordChecks('Passw0rd', 'Passw0rd').allPass, isTrue);
    expect(PasswordChecks('password', 'password').mixedCase, isFalse);
    expect(PasswordChecks('Password', 'Password').hasNumber, isFalse);
    expect(PasswordChecks('Pass0', 'Pass0').longEnough, isFalse);
    expect(PasswordChecks('Passw0rd', 'Passw0rx').matches, isFalse);
  });

  test('initials skip titles', () {
    expect(profileOf(email: 'f@utm.my', role: UserRole.invigilator, name: 'Dr. Farah Hanim').initials, 'FH');
    expect(profileOf(email: 'a@utm.my', role: UserRole.student, name: 'Ahmad').initials, 'A');
  });
}
