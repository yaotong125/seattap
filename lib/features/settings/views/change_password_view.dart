import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/settings/viewmodels/change_password_view_model.dart';

/// Change password in two steps, then "Password updated".
class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => ChangePasswordViewModel(c.read()),
        child: const _ChangePasswordBody(),
      );
}

class _ChangePasswordBody extends StatefulWidget {
  const _ChangePasswordBody();

  @override
  State<_ChangePasswordBody> createState() => _ChangePasswordBodyState();
}

class _ChangePasswordBodyState extends State<_ChangePasswordBody> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChangePasswordViewModel>();
    if (vm.done) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Expanded(
                child: Center(
                  child: StatusHero(
                    icon: Icons.check_rounded,
                    iconColor: AppColors.success,
                    background: AppColors.successSoft,
                    title: 'Password updated',
                    body: 'Your new password is active. Use it the next time you sign in.',
                  ),
                ),
              ),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back to Settings')),
            ]),
          ),
        ),
      );
    }
    final step1 = vm.step == 1;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), children: [
          ScreenHeading(
            eyebrow: 'Step ${vm.step} of 2',
            title: step1 ? 'Change password' : 'Create a new password',
            subtitle: step1
                ? 'First, confirm it’s you by entering your current password.'
                : 'Choose a password you haven’t used before.',
          ),
          const SizedBox(height: 24),
          if (step1)
            LabeledField(
              label: 'Current password',
              controller: _current,
              icon: Icons.lock_outline,
              obscure: !vm.showPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => vm.confirmCurrent(_current.text),
              suffix: PasswordToggle(visible: vm.showPassword, onPressed: vm.toggleShowPassword),
            )
          else ...[
            LabeledField(
              label: 'New password',
              controller: _new,
              icon: Icons.lock_outline,
              obscure: !vm.showPassword,
              onChanged: (_) => vm.onPasswordChanged(_new.text, _confirm.text),
              suffix: PasswordToggle(visible: vm.showPassword, onPressed: vm.toggleShowPassword),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Confirm new password',
              controller: _confirm,
              icon: Icons.lock_outline,
              obscure: !vm.showPassword,
              textInputAction: TextInputAction.done,
              onChanged: (_) => vm.onPasswordChanged(_new.text, _confirm.text),
            ),
            const SizedBox(height: 12),
            PasswordChecklist(checks: vm.checks),
          ],
          const SizedBox(height: 20),
          ErrorBanner(vm.error),
          if (vm.error != null) const SizedBox(height: 16),
          BusyButton(
            label: step1 ? 'Continue' : 'Submit',
            busy: vm.busy,
            onPressed: step1 ? () => vm.confirmCurrent(_current.text) : vm.submitNew,
          ),
        ]),
      ),
    );
  }
}
