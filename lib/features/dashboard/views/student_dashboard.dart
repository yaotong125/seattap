import 'package:flutter/material.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/theme.dart';
import 'package:seattap/core/utils/date_labels.dart';
import 'package:seattap/core/widgets/empty_card.dart';
import 'package:seattap/features/dashboard/views/dashboard_view.dart';
import 'package:seattap/features/dashboard/views/dashboard_widgets.dart';

/// Student home: upcoming exams and own attendance.
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) => DashboardScaffold(
        profile: profile,
        subtitle: '${profile.idNumber} · ${todayLabel(short: true)}',
        destinations: const [
          (Icons.home_outlined, Icons.home, 'Home'),
          (Icons.assignment_outlined, Icons.assignment, 'Exams'),
          (Icons.fact_check_outlined, Icons.fact_check, 'Attendance'),
        ],
        children: [
          const SizedBox(height: 8),
          Material(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => openComingSoon(context, 'My attendance'),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('My attendance',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      SizedBox(height: 6),
                      Text('See every exam you were checked in to, with your seat.',
                          style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.roseText)),
                    ]),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.chevron_right, color: Colors.white),
                ]),
              ),
            ),
          ),
          const SectionTitle('Upcoming exams'),
          const EmptyCard(
            icon: Icons.event_note_outlined,
            title: 'No exams scheduled',
            body: 'Your exam sessions appear here once the Exam Office publishes the timetable.',
          ),
        ],
      );
}
