import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/profile/views/edit_profile_view.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';
import 'package:seattap/features/settings/views/settings_view.dart';

/// The signed-in user's profile.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<SessionViewModel>().profile;
    if (profile == null) return const Scaffold();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsView())),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
          Center(child: ProfileAvatar(profile: profile, size: 96)),
          const SizedBox(height: 14),
          Text(profile.name,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Center(child: RoleChip(profile.role)),
          const SizedBox(height: 24),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              _DetailRow(icon: Icons.badge_outlined, label: profile.role.idLabel, value: profile.idNumber),
              const Divider(indent: 56),
              _DetailRow(icon: Icons.mail_outline, label: 'Email', value: profile.email),
              const Divider(indent: 56),
              _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: profile.phone ?? 'Not added'),
              const Divider(indent: 56),
              _DetailRow(icon: Icons.apartment_outlined, label: 'Faculty', value: profile.faculty ?? 'Not added'),
            ]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => EditProfileView(profile: profile))),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Profile'),
          ),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, color: AppColors.maroon, size: 22),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      );
}
