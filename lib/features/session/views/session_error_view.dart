import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';

/// The profile couldn't be loaded (usually no connection on first sign-in).
class SessionErrorView extends StatelessWidget {
  const SessionErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Expanded(
              child: Center(
                child: StatusHero(
                  icon: Icons.cloud_off_outlined,
                  iconColor: AppColors.error,
                  background: AppColors.errorSoft,
                  title: 'Couldn’t load your account',
                  body: 'Check your internet connection and try again.',
                ),
              ),
            ),
            FilledButton(onPressed: session.retry, child: const Text('Try Again')),
            const SizedBox(height: 8),
            TextButton(onPressed: session.signOut, child: const Text('Sign out')),
          ]),
        ),
      ),
    );
  }
}
