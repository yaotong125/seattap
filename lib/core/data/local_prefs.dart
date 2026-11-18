import 'package:shared_preferences/shared_preferences.dart';

/// Name and ID typed on Create account, kept on the phone until the email is verified
/// and the profile is saved.
class RegistrationDraft {
  const RegistrationDraft({required this.email, required this.name, required this.idNumber, this.phone});

  final String email;
  final String name;
  final String idNumber;
  final String? phone;
}

/// Small settings kept on this phone only.
abstract class LocalPrefs {
  bool get onboardingSeen;
  Future<void> setOnboardingSeen();
  bool get keepSignedIn;
  Future<void> setKeepSignedIn(bool value);
  RegistrationDraft? draftFor(String email);
  Future<void> saveDraft(RegistrationDraft draft);
  Future<void> clearDraft();
}

class SharedLocalPrefs implements LocalPrefs {
  SharedLocalPrefs(this._prefs);

  static Future<SharedLocalPrefs> load() async => SharedLocalPrefs(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  @override
  bool get onboardingSeen => _prefs.getBool('onboardingSeen') ?? false;

  @override
  Future<void> setOnboardingSeen() => _prefs.setBool('onboardingSeen', true);

  @override
  bool get keepSignedIn => _prefs.getBool('keepSignedIn') ?? true;

  @override
  Future<void> setKeepSignedIn(bool value) => _prefs.setBool('keepSignedIn', value);

  @override
  RegistrationDraft? draftFor(String email) {
    if (_prefs.getString('draft.email') != email.toLowerCase()) return null;
    return RegistrationDraft(
      email: email.toLowerCase(),
      name: _prefs.getString('draft.name') ?? '',
      idNumber: _prefs.getString('draft.idNumber') ?? '',
      phone: _prefs.getString('draft.phone'),
    );
  }

  @override
  Future<void> saveDraft(RegistrationDraft d) async {
    await _prefs.setString('draft.email', d.email.toLowerCase());
    await _prefs.setString('draft.name', d.name);
    await _prefs.setString('draft.idNumber', d.idNumber);
    if (d.phone == null || d.phone!.isEmpty) {
      await _prefs.remove('draft.phone');
    } else {
      await _prefs.setString('draft.phone', d.phone!);
    }
  }

  @override
  Future<void> clearDraft() async {
    for (final k in ['draft.email', 'draft.name', 'draft.idNumber', 'draft.phone']) {
      await _prefs.remove(k);
    }
  }
}

/// In-memory prefs for tests.
class MemoryLocalPrefs implements LocalPrefs {
  MemoryLocalPrefs({this.onboardingSeen = false, this.keepSignedIn = true});

  @override
  bool onboardingSeen;
  @override
  bool keepSignedIn;
  RegistrationDraft? draft;

  @override
  Future<void> setOnboardingSeen() async => onboardingSeen = true;
  @override
  Future<void> setKeepSignedIn(bool value) async => keepSignedIn = value;
  @override
  RegistrationDraft? draftFor(String email) => draft?.email == email.toLowerCase() ? draft : null;
  @override
  Future<void> saveDraft(RegistrationDraft d) async => draft = d;
  @override
  Future<void> clearDraft() async => draft = null;
}
