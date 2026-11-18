import 'package:flutter_test/flutter_test.dart';
import 'package:seattap/core/data/local_prefs.dart';
import 'package:seattap/features/sign_in/viewmodels/forgot_password_view_model.dart';
import 'package:seattap/features/sign_in/viewmodels/sign_in_view_model.dart';

import '../../fakes.dart';

void main() {
  test('signs in and remembers "keep me signed in"', () async {
    final auth = FakeAuthService()..passwords['hafiz@utm.my'] = 'Passw0rd';
    final prefs = MemoryLocalPrefs();
    final vm = SignInViewModel(auth, prefs)..toggleKeepSignedIn(false);
    expect(await vm.signIn('Hafiz@utm.my ', 'Passw0rd'), isTrue);
    expect(auth.currentUser!.email, 'hafiz@utm.my');
    expect(prefs.keepSignedIn, isFalse);
  });

  test('explains a wrong password', () async {
    final vm = SignInViewModel(FakeAuthService(), MemoryLocalPrefs());
    expect(await vm.signIn('hafiz@utm.my', 'nope'), isFalse);
    expect(vm.error, 'Email or password is incorrect.');
  });

  test('forgot password only accepts UTM emails and masks where it sent the link', () async {
    final vm = ForgotPasswordViewModel(FakeAuthService());
    expect(await vm.send('someone@gmail.com'), isFalse);
    expect(await vm.send('ahmad@utm.my'), isTrue);
    expect(maskEmail(vm.sentTo!), 'a•••••@utm.my');
  });
}
