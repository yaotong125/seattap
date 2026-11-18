import 'package:flutter/foundation.dart';

import 'auth/auth_service.dart';
import 'data/data_failure.dart';

/// Busy flag and a user-facing error message, shared by the form ViewModels.
abstract class BaseViewModel extends ChangeNotifier {
  bool _busy = false;
  String? _error;
  bool _disposed = false;

  bool get busy => _busy;
  String? get error => _error;

  @protected
  void setError(String? message) {
    _error = message;
    notify();
  }

  void clearError() {
    if (_error != null) setError(null);
  }

  @protected
  void notify() {
    if (!_disposed) notifyListeners();
  }

  /// Runs [action], showing [busy] meanwhile. Known failures become [error]; returns
  /// false if it failed.
  @protected
  Future<bool> run(Future<void> Function() action) async {
    if (_busy) return false;
    _busy = true;
    _error = null;
    notify();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      return false;
    } on DataFailure catch (e) {
      _error = e.message;
      return false;
    } on FormatException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _busy = false;
      notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
