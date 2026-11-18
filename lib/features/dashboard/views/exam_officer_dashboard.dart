import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/theme.dart';
import 'package:seattap/core/utils/date_labels.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/core/widgets/empty_card.dart';
import 'package:seattap/features/dashboard/views/dashboard_view.dart';
import 'package:seattap/features/dashboard/views/dashboard_widgets.dart';
import 'package:seattap/features/staff_approvals/viewmodels/approvals_view_model.dart';
import 'package:seattap/features/staff_approvals/views/approvals_view.dart';

/// Exam Officer home: staff approvals, exam sessions and hall layouts.
class ExamOfficerDashboard extends StatelessWidget {
  const ExamOfficerDashboard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final approvals = context.watch<ApprovalsViewModel>();
    final waiting = approvals.pending.length;
    return DashboardScaffold(
      profile: profile,
      subtitle: [if (profile.faculty != null) profile.faculty!, todayLabel(short: true)].join(' · '),
      destinations: const [
        (Icons.grid_view_outlined, Icons.grid_view, 'Dashboard'),
        (Icons.assignment_outlined, Icons.assignment, 'Exams'),
        (Icons.map_outlined, Icons.map, 'Halls'),
      ],
      children: [
        const SizedBox(height: 8),
        _ApprovalsCard(
          waiting: waiting,
          loading: approvals.loading,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => ChangeNotifierProvider.value(value: approvals, child: const ApprovalsView()),
          )),
        ),
        const SectionTitle('Manage'),
        SoftCard(
          onTap: () => openComingSoon(context, 'Exam sessions'),
          child: const ActionRow(
            icon: Icons.calendar_month_outlined,
            title: 'Exam sessions',
            body: 'Past, today’s and upcoming exams',
          ),
        ),
        const SizedBox(height: 10),
        SoftCard(
          onTap: () => openComingSoon(context, 'Hall layouts'),
          child: const ActionRow(
            icon: Icons.upload_file_outlined,
            title: 'Hall layouts',
            body: 'Upload and update seating plans',
          ),
        ),
        const SectionTitle('Today’s sessions'),
        const EmptyCard(
          icon: Icons.event_note_outlined,
          title: 'No sessions scheduled today',
          body: 'Exam sessions you add appear here with live check-in counts.',
        ),
      ],
    );
  }
}

class _ApprovalsCard extends StatelessWidget {
  const _ApprovalsCard({required this.waiting, required this.loading, required this.onTap});

  final int waiting;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = waiting > 0;
    final fg = highlight ? Colors.white : AppColors.ink;
    return Material(
      color: highlight ? AppColors.maroon : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: highlight ? BorderSide.none : const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Text(loading ? '–' : '$waiting',
                style: TextStyle(
                    fontSize: 34, fontWeight: FontWeight.w800, color: highlight ? AppColors.gold : AppColors.maroon)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pending staff approvals',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: fg)),
                const SizedBox(height: 4),
                Text(
                  highlight
                      ? 'UTM staff waiting to be approved as invigilators'
                      : 'Nobody is waiting for approval',
                  style: TextStyle(fontSize: 13, color: highlight ? AppColors.roseText : AppColors.muted),
                ),
              ]),
            ),
            Icon(Icons.chevron_right, color: fg),
          ]),
        ),
      ),
    );
  }
}
