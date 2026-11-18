import 'package:flutter_test/flutter_test.dart';
import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/data/local_prefs.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/features/registration/data/registration_repository.dart';
import 'package:seattap/features/registration/viewmodels/complete_profile_view_model.dart';
import 'package:seattap/features/registration/viewmodels/create_account_view_model.dart';

import '../../fakes.dart';

void main() {
  group('complete profile', () {
    late FakeBackend backend;
    late MemoryLocalPrefs prefs;

    CompleteProfileViewModel signedInAs(String email) {
      final auth = FakeAuthService(signedIn: AppUser(uid: 'uid-$email', email: email, emailVerified: true));
      return CompleteProfileViewModel(auth, backend, prefs);
    }

    setUp(() {
      backend = FakeBackend();
      prefs = MemoryLocalPrefs();
      backend.directory['ahmad@graduate.utm.my'] = const DirectoryEntry(
          email: 'ahmad@graduate.utm.my', idNumber: 'A24CS0123', role: UserRole.student, faculty: 'Faculty of Computing');
      backend.directory['hafiz@utm.my'] =
          const DirectoryEntry(email: 'hafiz@utm.my', idNumber: 'STF-0217', role: UserRole.examOfficer);
    });

    test('a listed student becomes an active student with the roster faculty', () async {
      final vm = signedInAs('ahmad@graduate.utm.my');
      expect(await vm.submit(name: 'Ahmad', idNumber: 'a24cs 0123'), isTrue);
      final p = backend.users['uid-ahmad@graduate.utm.my']!;
      expect((p.role, p.status, p.idNumber, p.faculty),
          (UserRole.student, ProfileStatus.active, 'A24CS0123', 'Faculty of Computing'));
    });

    test('a listed officer gets the roster role', () async {
      final vm = signedInAs('hafiz@utm.my');
      expect(await vm.submit(name: 'Hafiz', idNumber: 'STF-0217'), isTrue);
      expect(backend.users['uid-hafiz@utm.my']!.role, UserRole.examOfficer);
    });

    test('an ID that does not match the roster is refused', () async {
      final vm = signedInAs('ahmad@graduate.utm.my');
      expect(await vm.submit(name: 'Ahmad', idNumber: 'A24CS9999'), isFalse);
      expect(vm.error, contains('doesn’t match'));
      expect(backend.users, isEmpty);
    });

    test('unlisted staff wait as pending invigilators', () async {
      final vm = signedInAs('new@utm.my');
      expect(await vm.submit(name: 'New Staff', idNumber: 'STF-3000'), isTrue);
      final p = backend.users['uid-new@utm.my']!;
      expect((p.role, p.status), (UserRole.invigilator, ProfileStatus.pending));
    });

    test('unlisted students are told to contact the Exam Office', () async {
      final vm = signedInAs('nobody@graduate.utm.my');
      expect(await vm.submit(name: 'Nobody', idNumber: 'A24CS0002'), isFalse);
      expect(vm.error, contains('Exam Office'));
    });

    test('prefills from the Create account draft', () {
      prefs.draft = const RegistrationDraft(email: 'ahmad@graduate.utm.my', name: 'Ahmad', idNumber: 'A24CS0123');
      final vm = signedInAs('ahmad@graduate.utm.my');
      expect((vm.initialName, vm.initialId), ('Ahmad', 'A24CS0123'));
    });
  });

  test('create account saves a draft and sends the verification email', () async {
    final auth = FakeAuthService();
    final prefs = MemoryLocalPrefs();
    final vm = CreateAccountViewModel(auth, prefs)
      ..onEmailChanged('ahmad@graduate.utm.my')
      ..onPasswordChanged('Passw0rd', 'Passw0rd');
    expect(await vm.createAccount(name: 'Ahmad', idNumber: 'a24cs0123'), isTrue);
    expect(auth.verificationEmails, 1);
    expect(prefs.draft!.idNumber, 'A24CS0123');
    expect(auth.currentUser!.emailVerified, isFalse);
  });
}
