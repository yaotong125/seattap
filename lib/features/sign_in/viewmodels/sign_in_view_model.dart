import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/data/local_prefs.dart';

/// Sign in screen.
class SignInViewModel extends BaseViewModel {
  SignInViewModel(this._auth, this._prefs) : keepSignedIn = _prefs.keepSignedIn;

  final AuthService _auth;
  final LocalPrefs _prefs;
  bool keepSignedIn;
  bool showPassword = false;

  void toggleKeepSignedIn(bool value) {
    keepSignedIn = value;
    notify();
  }

  void toggleShowPassword() {
    showPassword = !showPassword;
    notify();
  }

  Future<bool> signIn(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      setError('Enter your email and password.');
      return Future.value(false);
    }
    return run(() async {
      await _auth.signIn(email, password);
      await _prefs.setKeepSignedIn(keepSignedIn);
    });
  }
}
