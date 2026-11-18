import 'dart:async';

import 'package:seattap/core/base_view_model.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/features/staff_approvals/data/staff_approvals_repository.dart';

/// Pending staff approvals, for the Exam Officer dashboard count and the review list.
class ApprovalsViewModel extends BaseViewModel {
  ApprovalsViewModel(this._profiles, this.reviewerUid) {
    _sub = _profiles.watchPendingStaff().listen(
      (list) {
        pending = list;
        loading = false;
        loadFailed = false;
        notify();
      },
      onError: (Object _) {
        loading = false;
        loadFailed = true;
        notify();
      },
    );
  }

  final StaffApprovalsRepository _profiles;
  final String reviewerUid;
  StreamSubscription<List<UserProfile>>? _sub;

  List<UserProfile> pending = const [];
  bool loading = true;
  bool loadFailed = false;
  final Set<String> reviewing = {};

  /// Approve or reject; returns a confirmation message, or null if it failed.
  Future<String?> review(UserProfile staff, {required bool approve}) async {
    reviewing.add(staff.uid);
    notify();
    final ok = await run(() => _profiles.reviewStaff(reviewerUid: reviewerUid, staff: staff, approve: approve));
    reviewing.remove(staff.uid);
    notify();
    if (!ok) return null;
    return approve ? '${staff.name} can now sign in as an invigilator.' : '${staff.name}’s request was rejected.';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
