import 'package:firebase_auth/firebase_auth.dart';

/// The signed-in Firebase user, reduced to what the app needs.
class AppUser {
  const AppUser({required this.uid, required this.email, required this.emailVerified});

  final String uid;
  final String email;
  final bool emailVerified;
}

/// A sign-in problem with a message that can be shown on screen.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Account operations used by the ViewModels. [FirebaseAuthService] is the real one;
/// tests use a fake.
abstract class AuthService {
  Stream<AppUser?> userChanges();
  AppUser? get currentUser;
  Future<void> signIn(String email, String password);
  Future<void> createAccount(String email, String password);
  Future<void> sendEmailVerification();

  /// Reloads the user and refreshes the ID token, so security rules see a fresh
  /// email_verified. Returns whether the email is now verified.
  Future<bool> refreshVerification();
  Future<void> sendPasswordReset(String email);
  Future<void> reauthenticate(String currentPassword);
  Future<void> updatePassword(String newPassword);
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static AppUser? _map(User? u) =>
      u == null ? null : AppUser(uid: u.uid, email: (u.email ?? '').toLowerCase(), emailVerified: u.emailVerified);

  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<void> signIn(String email, String password) =>
      _guard(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  @override
  Future<void> createAccount(String email, String password) =>
      _guard(() => _auth.createUserWithEmailAndPassword(email: email.trim(), password: password));

  @override
  Future<void> sendEmailVerification() => _guard(() async => _auth.currentUser?.sendEmailVerification());

  @override
  Future<bool> refreshVerification() => _guard(() async {
        final user = _auth.currentUser;
        if (user == null) return false;
        await user.reload();
        final fresh = _auth.currentUser;
        if (fresh == null || !fresh.emailVerified) return false;
        await fresh.getIdToken(true);
        return true;
      });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> reauthenticate(String currentPassword) => _guard(() async {
        final user = _auth.currentUser;
        if (user == null || user.email == null) throw const AuthFailure('You are signed out. Sign in again.');
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: currentPassword),
        );
      });

  @override
  Future<void> updatePassword(String newPassword) => _guard(() async => _auth.currentUser?.updatePassword(newPassword));

  @override
  Future<void> signOut() => _auth.signOut();

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(messageFor(e.code));
    }
  }

  /// Plain-language messages for Firebase Auth error codes.
  static String messageFor(String code) => switch (code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' || 'invalid-login-credentials' =>
          'Email or password is incorrect.',
        'invalid-email' => 'Enter a valid email address.',
        'user-disabled' => 'This account has been turned off. Contact the Exam Office.',
        'email-already-in-use' => 'An account already uses this email. Sign in instead.',
        'weak-password' => 'Choose a stronger password.',
        'too-many-requests' => 'Too many attempts. Wait a few minutes and try again.',
        'network-request-failed' => 'No internet connection. Check your connection and try again.',
        'requires-recent-login' => 'For your security, sign in again and retry.',
        _ => 'Something went wrong ($code). Try again.',
      };
}
