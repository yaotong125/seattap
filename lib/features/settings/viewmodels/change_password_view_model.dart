import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/validation/utm_account_rules.dart';

/// Change password: step 1 confirms the current password, step 2 sets the new one.
class ChangePasswordViewModel extends BaseViewModel {
  ChangePasswordViewModel(this._auth);

  final AuthService _auth;
  int step = 1;
  String password = '';
  String confirm = '';
  bool showPassword = false;
  bool done = false;

  PasswordChecks get checks => PasswordChecks(password, confirm);

  void toggleShowPassword() {
    showPassword = !showPassword;
    notify();
  }

  void onPasswordChanged(String pw, String confirmPw) {
    password = pw;
    confirm = confirmPw;
    notify();
  }

  Future<void> confirmCurrent(String current) async {
    if (current.isEmpty) return setError('Enter your current password.');
    final ok = await run(() => _auth.reauthenticate(current));
    if (ok) {
      step = 2;
      notify();
    }
  }

  Future<void> submitNew() async {
    if (!checks.allPass) return setError('Your new password doesn’t meet all the checks.');
    final ok = await run(() => _auth.updatePassword(password));
    if (ok) {
      done = true;
      notify();
    }
  }
}
