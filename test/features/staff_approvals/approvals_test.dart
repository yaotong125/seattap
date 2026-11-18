import 'package:flutter_test/flutter_test.dart';
import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/features/staff_approvals/viewmodels/approvals_view_model.dart';

import '../../fakes.dart';

void main() {
  test('an Exam Officer approves a pending invigilator', () async {
    final backend = FakeBackend()
      ..put(profileOf(email: 'farah@utm.my', role: UserRole.invigilator, status: ProfileStatus.pending, name: 'Farah'));
    final vm = ApprovalsViewModel(backend, 'officer');
    await Future<void>.delayed(Duration.zero);
    expect(vm.pending, hasLength(1));
    final message = await vm.review(vm.pending.single, approve: true);
    await Future<void>.delayed(Duration.zero);
    expect(message, contains('Farah'));
    expect(backend.users['uid-farah@utm.my']!.status, ProfileStatus.active);
    expect(vm.pending, isEmpty);
    vm.dispose();
  });

  test('a rejected request leaves the list', () async {
    final backend = FakeBackend()
      ..put(profileOf(email: 'lim@utm.my', role: UserRole.invigilator, status: ProfileStatus.pending, name: 'Lim'));
    final vm = ApprovalsViewModel(backend, 'officer');
    await Future<void>.delayed(Duration.zero);
    await vm.review(vm.pending.single, approve: false);
    await Future<void>.delayed(Duration.zero);
    expect(backend.users['uid-lim@utm.my']!.status, ProfileStatus.rejected);
    expect(vm.pending, isEmpty);
    vm.dispose();
  });
}
