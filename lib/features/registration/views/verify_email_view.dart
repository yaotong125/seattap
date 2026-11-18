import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/registration/viewmodels/verify_email_view_model.dart';

/// Verify email: waits for the user to open the link we sent.
class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => VerifyEmailViewModel(c.read()),
        child: Consumer<VerifyEmailViewModel>(
          builder: (context, vm, _) => Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: StatusHero(
                          icon: Icons.mark_email_unread_outlined,
                          title: 'Verify your email',
                          body: 'We sent a link to',
                          children: [
                            const SizedBox(height: 8),
                            Text(vm.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            const Text(
                              'Open it to confirm this UTM email is yours, then come back and tap the button below. '
                              'Check your junk folder if you can’t see it.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
                            ),
                            if (vm.info != null) ...[
                              const SizedBox(height: 16),
                              Text(vm.info!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14, color: AppColors.success)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  ErrorBanner(vm.error),
                  if (vm.error != null) const SizedBox(height: 16),
                  BusyButton(label: 'I’ve verified my email', busy: vm.busy, onPressed: vm.checkVerified),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: vm.resendSeconds > 0 || vm.busy ? null : vm.resend,
                    child: Text(vm.resendSeconds > 0 ? 'Resend email (${vm.resendSeconds}s)' : 'Resend email'),
                  ),
                  TextButton(onPressed: vm.useAnotherAccount, child: const Text('Use a different account')),
                ]),
              ),
            ),
          ),
        ),
      );
}
