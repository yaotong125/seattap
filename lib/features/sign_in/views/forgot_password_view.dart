import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/sign_in/viewmodels/forgot_password_view_model.dart';

/// Forgot password, then "Check your email".
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => ForgotPasswordViewModel(c.read()),
        child: _ForgotPasswordBody(initialEmail),
      );
}

class _ForgotPasswordBody extends StatefulWidget {
  const _ForgotPasswordBody(this.initialEmail);

  final String initialEmail;

  @override
  State<_ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<_ForgotPasswordBody> {
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final sent = vm.sentTo;
    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: sent != null
              ? Column(children: [
                  Expanded(
                    child: Center(
                      child: StatusHero(
                        icon: Icons.mail_outline,
                        title: 'Check your email',
                        body: 'We sent a password reset link to',
                        children: [
                          const SizedBox(height: 8),
                          Text(maskEmail(sent), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          const Text('Open the link on this phone to set a new password, then sign in again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ),
                  FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back to Login')),
                  TextButton(onPressed: vm.busy ? null : () => vm.send(sent), child: const Text('Resend link')),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: AppColors.roseSoft, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.lock_outline, color: AppColors.maroon, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const ScreenHeading(
                    title: 'Forgot your password?',
                    subtitle: 'Enter the email on your SeatTap account and we’ll send you a link to reset it.',
                  ),
                  const SizedBox(height: 24),
                  LabeledField(
                    label: 'Email',
                    controller: _email,
                    hint: 'name@utm.my',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (v) => vm.send(v),
                  ),
                  const SizedBox(height: 16),
                  ErrorBanner(vm.error),
                  const Spacer(),
                  BusyButton(label: 'Submit', busy: vm.busy, onPressed: () => vm.send(_email.text)),
                ]),
        ),
      ),
    );
  }
}
