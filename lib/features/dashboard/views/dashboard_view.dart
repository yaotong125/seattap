import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/features/dashboard/views/coming_soon_view.dart';
import 'package:seattap/features/dashboard/views/exam_officer_dashboard.dart';
import 'package:seattap/features/dashboard/views/invigilator_dashboard.dart';
import 'package:seattap/features/dashboard/views/student_dashboard.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';
import 'package:seattap/features/staff_approvals/viewmodels/approvals_view_model.dart';

/// Picks the dashboard for the signed-in role.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<SessionViewModel>().profile!;
    return switch (profile.role) {
      UserRole.invigilator => InvigilatorDashboard(profile: profile),
      UserRole.examOfficer => ChangeNotifierProvider(
          create: (c) => ApprovalsViewModel(c.read(), profile.uid),
          child: ExamOfficerDashboard(profile: profile),
        ),
      UserRole.student => StudentDashboard(profile: profile),
    };
  }
}

void openComingSoon(BuildContext context, String title) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ComingSoonView(title: title)));
