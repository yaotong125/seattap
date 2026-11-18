import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/data/local_prefs.dart';
import 'package:seattap/core/data/profile_repository.dart';
import 'package:seattap/core/models/user_profile.dart';

/// Where the signed-in person is in the account flow; decides the first screen.
enum SessionStage { loading, signedOut, verifyEmail, completeProfile, pending, rejected, active, error }

/// The stage for a user and their profile. Kept pure so it is easy to test.
SessionStage stageFor({
  required bool authKnown,
  required AppUser? user,
  required bool profileKnown,
  required UserProfile? profile,
  bool profileFailed = false,
}) {
  if (!authKnown) return SessionStage.loading;
  if (user == null) return SessionStage.signedOut;
  if (!user.emailVerified) return SessionStage.verifyEmail;
  if (profileFailed) return SessionStage.error;
  if (!profileKnown) return SessionStage.loading;
  if (profile == null) return SessionStage.completeProfile;
  return switch (profile.status) {
    ProfileStatus.pending => SessionStage.pending,
    ProfileStatus.rejected => SessionStage.rejected,
    ProfileStatus.active => SessionStage.active,
  };
}

/// App-wide session: the Firebase user, their SeatTap profile and first-run state.
class SessionViewModel extends ChangeNotifier {
  SessionViewModel({required this.auth, required this.profiles, required this.prefs}) {
    _authSub = auth.userChanges().listen(_onUser);
  }

  final AuthService auth;
  final ProfileRepository profiles;
  final LocalPrefs prefs;

  StreamSubscription<AppUser?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;

  AppUser? _user;
  UserProfile? _profile;
  bool _authKnown = false;
  bool _profileKnown = false;
  bool _profileFailed = false;
  bool _firstEvent = true;

  AppUser? get user => _user;
  UserProfile? get profile => _profile;
  bool get onboardingSeen => prefs.onboardingSeen;

  SessionStage get stage => stageFor(
        authKnown: _authKnown,
        user: _user,
        profileKnown: _profileKnown,
        profile: _profile,
        profileFailed: _profileFailed,
      );

  Future<void> _onUser(AppUser? u) async {
    if (_firstEvent) {
      _firstEvent = false;
      // "Keep me signed in" was off: a restored session ends when the app restarts.
      if (u != null && !prefs.keepSignedIn) {
        await auth.signOut();
        return;
      }
    }
    final restartProfile = u?.uid != _user?.uid || u?.emailVerified != _user?.emailVerified;
    _user = u;
    _authKnown = true;
    if (restartProfile) _watchProfile();
    notifyListeners();
  }

  void _watchProfile() {
    _profileSub?.cancel();
    _profileSub = null;
    _profile = null;
    _profileKnown = false;
    _profileFailed = false;
    final u = _user;
    if (u == null || !u.emailVerified) return;
    _profileSub = profiles.watchProfile(u.uid).listen(
      (p) {
        _profile = p;
        _profileKnown = true;
        _profileFailed = false;
        notifyListeners();
      },
      onError: (Object _) {
        _profileFailed = true;
        notifyListeners();
      },
    );
  }

  /// Try loading the profile again after an error.
  void retry() {
    _watchProfile();
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    await prefs.setOnboardingSeen();
    notifyListeners();
  }

  Future<void> signOut() => auth.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
