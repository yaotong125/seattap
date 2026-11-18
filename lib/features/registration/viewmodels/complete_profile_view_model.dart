import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/data/data_failure.dart';
import 'package:seattap/core/data/local_prefs.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/validation/utm_account_rules.dart';
import 'package:seattap/features/registration/data/registration_repository.dart';

/// Complete profile screen: writes users/{uid} so it matches the Exam Office roster.
/// Firestore rules make the same checks; these give a clearer message first.
class CompleteProfileViewModel extends BaseViewModel {
  CompleteProfileViewModel(this._auth, this._profiles, this._prefs) {
    final draft = _prefs.draftFor(email);
    initialName = draft?.name ?? '';
    initialId = draft?.idNumber ?? '';
    initialPhone = draft?.phone ?? '';
  }

  final AuthService _auth;
  final RegistrationRepository _profiles;
  final LocalPrefs _prefs;
  late final String initialName;
  late final String initialId;
  late final String initialPhone;

  String get email => _auth.currentUser?.email ?? '';
  AccountKind? get kind => accountKind(email);

  String? validateId(String? value) {
    final k = kind;
    final id = normaliseId(value ?? '');
    if (k == null) return null;
    if (id.isEmpty) return 'Enter your ${k.idLabel.toLowerCase()}.';
    if (!isValidId(k, id)) return 'That doesn’t look like a ${k.idLabel.toLowerCase()} (${k.idHint}).';
    return null;
  }

  Future<bool> submit({required String name, required String idNumber, String? phone}) {
    final user = _auth.currentUser;
    final k = kind;
    if (user == null) return Future.value(false);
    if (k == null) {
      setError('SeatTap is for UTM accounts. Sign in with your @utm.my or @graduate.utm.my email.');
      return Future.value(false);
    }
    final id = normaliseId(idNumber);
    return run(() async {
      final entry = await _profiles.getOwnDirectoryEntry(user.email);
      final UserRole role;
      final ProfileStatus status;
      String? faculty;
      if (entry != null) {
        if (entry.idNumber != id) {
          throw DataFailure('That ${k.idLabel.toLowerCase()} doesn’t match the Exam Office record for ${user.email}.');
        }
        role = entry.role;
        status = ProfileStatus.active;
        faculty = entry.faculty;
      } else if (k == AccountKind.staff) {
        // UTM staff who aren't on the list wait for an Exam Officer.
        role = UserRole.invigilator;
        status = ProfileStatus.pending;
      } else {
        throw const DataFailure(
          'Your matric number isn’t on the Exam Office list yet. Contact the Exam Office, then try again.',
        );
      }
      await _profiles.createProfile(
        user.uid,
        NewProfile(
          email: user.email,
          name: name.trim(),
          idNumber: id,
          role: role,
          status: status,
          phone: phone?.trim(),
          faculty: faculty,
        ),
      );
      await _prefs.clearDraft();
    });
  }

  Future<void> signOut() => _auth.signOut();
}
