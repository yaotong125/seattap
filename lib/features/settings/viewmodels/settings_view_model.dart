import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/data/local_prefs.dart';

/// Settings screen.
class SettingsViewModel extends BaseViewModel {
  SettingsViewModel(this._prefs) : keepSignedIn = _prefs.keepSignedIn;

  final LocalPrefs _prefs;
  bool keepSignedIn;

  Future<void> setKeepSignedIn(bool value) async {
    keepSignedIn = value;
    notify();
    await _prefs.setKeepSignedIn(value);
  }
}
