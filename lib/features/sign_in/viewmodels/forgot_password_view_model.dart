import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/validation/utm_account_rules.dart';

/// Forgot password screen.
class ForgotPasswordViewModel extends BaseViewModel {
  ForgotPasswordViewModel(this._auth);

  final AuthService _auth;
  String? sentTo;

  Future<bool> send(String email) {
    final problem = validateUtmEmail(email);
    if (problem != null) {
      setError(problem);
      return Future.value(false);
    }
    return run(() async {
      await _auth.sendPasswordReset(email);
      sentTo = email.trim().toLowerCase();
    });
  }
}

/// "a•••••@utm.my" for showing where a link was sent.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at < 1) return email;
  return '${email[0]}•••••${email.substring(at)}';
}
