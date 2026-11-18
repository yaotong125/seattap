import 'package:flutter_test/flutter_test.dart';
import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';

import '../../fakes.dart';

void main() {
  const verified = AppUser(uid: 'u', email: 'a@utm.my', emailVerified: true);
  const unverified = AppUser(uid: 'u', email: 'a@utm.my', emailVerified: false);
  SessionStage stage(AppUser? u, UserProfile? p, {bool known = true}) =>
      stageFor(authKnown: true, user: u, profileKnown: known, profile: p);

  test('follows the account flow', () {
    expect(stageFor(authKnown: false, user: null, profileKnown: false, profile: null), SessionStage.loading);
    expect(stage(null, null), SessionStage.signedOut);
    expect(stage(unverified, null), SessionStage.verifyEmail);
    expect(stage(verified, null, known: false), SessionStage.loading);
    expect(stage(verified, null), SessionStage.completeProfile);
    expect(stage(verified, profileOf(email: 'a@utm.my', role: UserRole.invigilator, status: ProfileStatus.pending)),
        SessionStage.pending);
    expect(stage(verified, profileOf(email: 'a@utm.my', role: UserRole.invigilator, status: ProfileStatus.rejected)),
        SessionStage.rejected);
    expect(stage(verified, profileOf(email: 'a@utm.my', role: UserRole.examOfficer)), SessionStage.active);
  });
}
