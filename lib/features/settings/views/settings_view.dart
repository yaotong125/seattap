import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';
import 'package:seattap/features/settings/viewmodels/settings_view_model.dart';
import 'package:seattap/features/settings/views/change_password_view.dart';

const appVersion = '1.0.0';

/// Settings: change password, stay signed in, app version and log out.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final yes = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.sand,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Icon(Icons.logout, size: 40, color: AppColors.maroon),
            const SizedBox(height: 12),
            const Text('Log out of SeatTap?',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'You’ll need to sign in again next time. Check-ins not yet synced stay saved on this phone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirm')),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ]),
        ),
      ),
    );
    if (yes != true || !context.mounted) return;
    final session = context.read<SessionViewModel>();
    Navigator.of(context).popUntil((r) => r.isFirst);
    await session.signOut();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => SettingsViewModel(c.read()),
        child: Consumer<SettingsViewModel>(
          builder: (context, vm, _) => Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: SafeArea(
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
                const _GroupLabel('Security'),
                SoftCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppColors.maroon),
                      title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => const ChangePasswordView())),
                    ),
                    const Divider(indent: 56),
                    SwitchListTile(
                      secondary: const Icon(Icons.verified_user_outlined, color: AppColors.maroon),
                      title: const Text('Stay signed in', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Open straight to your dashboard'),
                      value: vm.keepSignedIn,
                      onChanged: vm.setKeepSignedIn,
                    ),
                  ]),
                ),
                const _GroupLabel('About'),
                const SoftCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: AppColors.maroon),
                    title: Text('App version', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(appVersion, style: TextStyle(color: AppColors.muted)),
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => _confirmSignOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                ),
              ]),
            ),
          ),
        ),
      );
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.muted)),
      );
}
