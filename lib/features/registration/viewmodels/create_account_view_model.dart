import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/data/local_prefs.dart';
import 'package:seattap/core/validation/utm_account_rules.dart';

/// Create account screen: makes the sign-in, sends the verification email and keeps
/// the name and ID on the phone for the Complete profile step.
class CreateAccountViewModel extends BaseViewModel {
  CreateAccountViewModel(this._auth, this._prefs);

  final AuthService _auth;
  final LocalPrefs _prefs;
  String email = '';
  String password = '';
  String confirm = '';
  bool showPassword = false;

  AccountKind? get kind => accountKind(email);
  PasswordChecks get checks => PasswordChecks(password, confirm);

  void onEmailChanged(String v) {
    email = v;
    notify();
  }

  void onPasswordChanged(String pw, String confirmPw) {
    password = pw;
    confirm = confirmPw;
    notify();
  }

  void toggleShowPassword() {
    showPassword = !showPassword;
    notify();
  }

  /// The ID field's error, using this email's kind of account.
  String? validateId(String? value) {
    final k = kind;
    final id = normaliseId(value ?? '');
    if (id.isEmpty) return 'Enter your ${k?.idLabel.toLowerCase() ?? 'matric number or staff ID'}.';
    if (k != null && !isValidId(k, id)) return 'That doesn’t look like a ${k.idLabel.toLowerCase()} (${k.idHint}).';
    return null;
  }

  Future<bool> createAccount({required String name, required String idNumber, String? phone}) {
    if (!checks.allPass) {
      setError('Your password doesn’t meet all the checks below.');
      return Future.value(false);
    }
    return run(() async {
      await _prefs.saveDraft(RegistrationDraft(
        email: email.trim().toLowerCase(),
        name: name.trim(),
        idNumber: normaliseId(idNumber),
        phone: phone?.trim(),
      ));
      await _auth.createAccount(email, password);
      await _auth.sendEmailVerification();
    });
  }
}
