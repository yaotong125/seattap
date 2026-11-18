import 'package:flutter/material.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/utils/date_labels.dart';
import 'package:seattap/core/widgets/empty_card.dart';
import 'package:seattap/features/dashboard/views/dashboard_view.dart';
import 'package:seattap/features/dashboard/views/dashboard_widgets.dart';

/// Invigilator home: exam tools and today's duties.
class InvigilatorDashboard extends StatelessWidget {
  const InvigilatorDashboard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) => DashboardScaffold(
        profile: profile,
        subtitle: todayLabel(),
        destinations: const [
          (Icons.home_outlined, Icons.home, 'Home'),
          (Icons.assignment_outlined, Icons.assignment, 'Exams'),
        ],
        children: [
          const SectionTitle('Exam tools'),
          Row(children: [
            Expanded(child: ToolTile(icon: Icons.contactless_outlined, label: 'Scan', primary: true,
                onTap: () => openComingSoon(context, 'Scan'))),
            const SizedBox(width: 10),
            Expanded(child: ToolTile(icon: Icons.fact_check_outlined, label: 'Attendance',
                onTap: () => openComingSoon(context, 'Attendance'))),
            const SizedBox(width: 10),
            Expanded(child: ToolTile(icon: Icons.event_seat_outlined, label: 'View seats',
                onTap: () => openComingSoon(context, 'View seats'))),
          ]),
          const SectionTitle('Today’s duties'),
          const EmptyCard(
            icon: Icons.event_available_outlined,
            title: 'No duties assigned yet',
            body: 'Your exam sessions appear here once the Exam Office assigns you.',
          ),
        ],
      );
}
