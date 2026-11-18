import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/theme.dart';
import 'package:seattap/core/utils/date_labels.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/core/widgets/empty_card.dart';
import 'package:seattap/features/staff_approvals/viewmodels/approvals_view_model.dart';

/// Pending staff approvals list for Exam Officers.
class ApprovalsView extends StatelessWidget {
  const ApprovalsView({super.key});

  Future<void> _review(BuildContext context, UserProfile staff, bool approve) async {
    final vm = context.read<ApprovalsViewModel>();
    if (!approve) {
      final sure = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Reject ${staff.name}?'),
          content: const Text('They won’t be able to use SeatTap with this account.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      if (sure != true) return;
    }
    final message = await vm.review(staff, approve: approve);
    if (context.mounted) showMessage(context, message ?? vm.error ?? 'That didn’t work. Try again.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApprovalsViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Pending approvals')),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
          const Text(
            'These accounts verified a UTM email but aren’t on your staff list. '
            'Approve only people you know are invigilators.',
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          if (vm.loading)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
          else if (vm.loadFailed)
            const ErrorBanner('Couldn’t load pending requests. Check your connection.')
          else if (vm.pending.isEmpty)
            const EmptyCard(
              icon: Icons.how_to_reg_outlined,
              title: 'All caught up',
              body: 'New staff sign-ups that need your approval appear here.',
            )
          else
            for (final staff in vm.pending) ...[
              _PendingCard(
                staff: staff,
                busy: vm.reviewing.contains(staff.uid),
                onApprove: () => _review(context, staff, true),
                onReject: () => _review(context, staff, false),
              ),
              const SizedBox(height: 12),
            ],
        ]),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.staff, required this.busy, required this.onApprove, required this.onReject});

  final UserProfile staff;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => SoftCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            ProfileAvatar(profile: staff, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(staff.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(staff.email, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            [
              'Staff ID ${staff.idNumber}',
              if (staff.createdAt != null) 'requested ${shortDate(staff.createdAt!)}',
            ].join(' · '),
            style: const TextStyle(fontSize: 13, color: AppColors.body),
          ),
          const SizedBox(height: 14),
          if (busy)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
              ),
            ]),
        ]),
      );
}
