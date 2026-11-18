import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';

/// Staff who aren't on the roster wait here until an Exam Officer reviews them.
class AwaitingApprovalView extends StatelessWidget {
  const AwaitingApprovalView({super.key, required this.rejected});

  final bool rejected;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final p = session.profile;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: rejected
                      ? StatusHero(
                          icon: Icons.block,
                          iconColor: AppColors.error,
                          background: AppColors.errorSoft,
                          title: 'Request not approved',
                          body: 'An Exam Officer didn’t approve SeatTap access for ${p?.email ?? 'this account'}. '
                              'If this is a mistake, contact the Exam Office.',
                        )
                      : StatusHero(
                          icon: Icons.hourglass_top_rounded,
                          title: 'Waiting for approval',
                          body: 'Your email is verified, but it isn’t on the Exam Office staff list yet. '
                              'An Exam Officer will review your request. This screen opens your dashboard as '
                              'soon as they approve it.',
                          children: [
                            if (p != null) ...[
                              const SizedBox(height: 24),
                              SoftCard(
                                child: Column(children: [
                                  _InfoRow(label: 'Name', value: p.name),
                                  _InfoRow(label: 'Staff ID', value: p.idNumber),
                                  _InfoRow(label: 'Email', value: p.email),
                                  const _InfoRow(label: 'Requested role', value: 'Invigilator'),
                                ]),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
            OutlinedButton(onPressed: session.signOut, child: const Text('Sign out')),
          ]),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.muted))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        ]),
      );
}
