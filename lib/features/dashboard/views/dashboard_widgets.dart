import 'package:flutter/material.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/theme.dart';
import 'package:seattap/core/utils/date_labels.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/dashboard/views/dashboard_view.dart';
import 'package:seattap/features/profile/views/profile_view.dart';

class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({super.key, 
    required this.profile,
    required this.subtitle,
    required this.destinations,
    required this.children,
  });

  final UserProfile profile;
  final String subtitle;
  final List<(IconData, IconData, String)> destinations;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), children: [
            Row(children: [
              Semantics(
                button: true,
                label: 'Open profile',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => const ProfileView())),
                  child: ExcludeSemantics(child: ProfileAvatar(profile: profile)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${greeting()},', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  Text(profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ]),
              ),
              IconButton.outlined(
                tooltip: 'Notifications',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.line),
                ),
                onPressed: () => openComingSoon(context, 'Notifications'),
                icon: const Icon(Icons.notifications_none, color: AppColors.ink),
              ),
            ]),
            const SizedBox(height: 20),
            Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              RoleChip(profile.role),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
            ...children,
          ]),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.roseSoft,
          onDestinationSelected: (i) {
            if (i > 0) openComingSoon(context, destinations[i].$3);
          },
          destinations: [
            for (final d in destinations)
              NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2, color: AppColors.maroon), label: d.$3),
          ],
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      );
}

class ToolTile extends StatelessWidget {
  const ToolTile({super.key, required this.icon, required this.label, required this.onTap, this.primary = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) => Material(
        color: primary ? AppColors.maroon : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: primary ? BorderSide.none : const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Column(children: [
              Icon(icon, size: 30, color: primary ? AppColors.gold : AppColors.maroon),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: primary ? Colors.white : AppColors.ink)),
            ]),
          ),
        ),
      );
}

class ActionRow extends StatelessWidget {
  const ActionRow({super.key, required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppColors.maroon),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppColors.muted),
      ]);
}
