import 'dart:async';

import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/data/profile_repository.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/features/profile/data/edit_profile_repository.dart';
import 'package:seattap/features/registration/data/registration_repository.dart';
import 'package:seattap/features/staff_approvals/data/staff_approvals_repository.dart';

/// In-memory Firebase Auth for tests.
class FakeAuthService implements AuthService {
  FakeAuthService({AppUser? signedIn}) : _user = signedIn;

  AppUser? _user;
  final _changes = StreamController<AppUser?>.broadcast();
  final Map<String, String> passwords = {};
  bool verifyOnRefresh = false;
  int verificationEmails = 0;

  void _emit(AppUser? u) {
    _user = u;
    _changes.add(u);
  }

  @override
  Stream<AppUser?> userChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Future<void> signIn(String email, String password) async {
    final e = email.trim().toLowerCase();
    if (passwords[e] != password) throw const AuthFailure('Email or password is incorrect.');
    _emit(AppUser(uid: 'uid-$e', email: e, emailVerified: true));
  }

  @override
  Future<void> createAccount(String email, String password) async {
    final e = email.trim().toLowerCase();
    if (passwords.containsKey(e)) throw const AuthFailure('An account already uses this email. Sign in instead.');
    passwords[e] = password;
    _emit(AppUser(uid: 'uid-$e', email: e, emailVerified: false));
  }

  @override
  Future<void> sendEmailVerification() async => verificationEmails++;

  @override
  Future<bool> refreshVerification() async {
    final u = _user;
    if (u == null || !verifyOnRefresh) return false;
    _emit(AppUser(uid: u.uid, email: u.email, emailVerified: true));
    return true;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> reauthenticate(String currentPassword) async {
    if (passwords[_user?.email] != currentPassword) throw const AuthFailure('Email or password is incorrect.');
  }

  @override
  Future<void> updatePassword(String newPassword) async => passwords[_user!.email] = newPassword;

  @override
  Future<void> signOut() async => _emit(null);
}

/// In-memory Firestore for every feature's repository (no security rules: those have
/// their own emulator tests in backend/).
class FakeBackend
    implements ProfileRepository, RegistrationRepository, StaffApprovalsRepository, EditProfileRepository {
  final Map<String, UserProfile> users = {};
  final Map<String, DirectoryEntry> directory = {};
  final _changes = StreamController<void>.broadcast();

  void put(UserProfile p) {
    users[p.uid] = p;
    _changes.add(null);
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) async* {
    yield users[uid];
    yield* _changes.stream.map((_) => users[uid]);
  }

  @override
  Future<DirectoryEntry?> getOwnDirectoryEntry(String email) async => directory[email.toLowerCase()];

  @override
  Future<void> createProfile(String uid, NewProfile p) async => put(UserProfile(
        uid: uid,
        email: p.email,
        name: p.name,
        idNumber: p.idNumber,
        role: p.role,
        status: p.status,
        phone: p.phone,
        faculty: p.faculty,
        createdAt: DateTime(2026, 11, 18),
      ));

  @override
  Future<void> updateProfile(String uid,
      {required String name, String? phone, String? faculty, String? photoUrl}) async {
    final o = users[uid]!;
    put(UserProfile(
      uid: uid,
      email: o.email,
      name: name,
      idNumber: o.idNumber,
      role: o.role,
      status: o.status,
      phone: phone,
      faculty: faculty,
      photoUrl: photoUrl,
      createdAt: o.createdAt,
    ));
  }

  @override
  Stream<List<UserProfile>> watchPendingStaff() async* {
    List<UserProfile> pending() => users.values.where((u) => u.status == ProfileStatus.pending).toList();
    yield pending();
    yield* _changes.stream.map((_) => pending());
  }

  @override
  Future<void> reviewStaff({required String reviewerUid, required UserProfile staff, required bool approve}) async {
    final o = users[staff.uid]!;
    put(UserProfile(
      uid: o.uid,
      email: o.email,
      name: o.name,
      idNumber: o.idNumber,
      role: o.role,
      status: approve ? ProfileStatus.active : ProfileStatus.rejected,
      createdAt: o.createdAt,
    ));
  }
}

UserProfile profileOf({
  required String email,
  required UserRole role,
  ProfileStatus status = ProfileStatus.active,
  String name = 'Test User',
  String idNumber = 'STF-0001',
}) =>
    UserProfile(
      uid: 'uid-$email',
      email: email,
      name: name,
      idNumber: idNumber,
      role: role,
      status: status,
      createdAt: DateTime(2026, 11, 18),
    );
