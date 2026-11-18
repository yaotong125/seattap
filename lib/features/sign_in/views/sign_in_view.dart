import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/registration/views/create_account_view.dart';
import 'package:seattap/features/sign_in/viewmodels/sign_in_view_model.dart';
import 'package:seattap/features/sign_in/views/forgot_password_view.dart';

/// Sign in.
class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => SignInViewModel(c.read(), c.read()),
        child: const _SignInBody(),
      );
}

class _SignInBody extends StatefulWidget {
  const _SignInBody();

  @override
  State<_SignInBody> createState() => _SignInBodyState();
}

class _SignInBodyState extends State<_SignInBody> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await context.read<SignInViewModel>().signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignInViewModel>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: AutofillGroup(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Align(alignment: Alignment.centerLeft, child: AppLogo()),
              const SizedBox(height: 20),
              const ScreenHeading(title: 'Sign in', subtitle: 'Use your UTM staff or student account.'),
              const SizedBox(height: 28),
              LabeledField(
                label: 'Email',
                controller: _email,
                hint: 'name@utm.my',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Password',
                controller: _password,
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscure: !vm.showPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                suffix: PasswordToggle(visible: vm.showPassword, onPressed: vm.toggleShowPassword),
              ),
              const SizedBox(height: 8),
              // Wraps onto two lines on narrow screens or with large phone text sizes.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    onTap: () => vm.toggleKeepSignedIn(!vm.keepSignedIn),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Checkbox(value: vm.keepSignedIn, onChanged: (v) => vm.toggleKeepSignedIn(v ?? true)),
                      const Text('Keep me signed in', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                    ]),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => ForgotPasswordView(initialEmail: _email.text))),
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ErrorBanner(vm.error),
              if (vm.error != null) const SizedBox(height: 16),
              BusyButton(label: 'Sign In', busy: vm.busy, onPressed: _submit),
              const SizedBox(height: 24),
              const Row(children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('New to SeatTap?', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CreateAccountView())),
                child: const Text('Create account'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
