import 'dart:async';

import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/base_view_model.dart';

/// Verify email screen.
class VerifyEmailViewModel extends BaseViewModel {
  VerifyEmailViewModel(this._auth);

  final AuthService _auth;
  int resendSeconds = 0;
  String? info;
  Timer? _timer;

  String get email => _auth.currentUser?.email ?? '';

  Future<void> resend() async {
    if (resendSeconds > 0) return;
    final ok = await run(_auth.sendEmailVerification);
    if (!ok) return;
    info = 'We sent another link to $email.';
    resendSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      resendSeconds--;
      if (resendSeconds <= 0) t.cancel();
      notify();
    });
    notify();
  }

  /// True once the email is verified; the session then moves on by itself.
  Future<bool> checkVerified() async {
    info = null;
    var verified = false;
    final ok = await run(() async => verified = await _auth.refreshVerification());
    if (ok && !verified) {
      setError('Not verified yet. Open the link in the email we sent, then tap this again.');
    }
    return verified;
  }

  Future<void> useAnotherAccount() => _auth.signOut();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
