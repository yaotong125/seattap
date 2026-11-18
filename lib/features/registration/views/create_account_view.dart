import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/validation/utm_account_rules.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/registration/viewmodels/create_account_view_model.dart';

/// Create account: name, UTM email, matric/staff ID, phone and password.
class CreateAccountView extends StatelessWidget {
  const CreateAccountView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => CreateAccountViewModel(c.read(), c.read()),
        child: const _CreateAccountBody(),
      );
}

class _CreateAccountBody extends StatefulWidget {
  const _CreateAccountBody();

  @override
  State<_CreateAccountBody> createState() => _CreateAccountBodyState();
}

class _CreateAccountBodyState extends State<_CreateAccountBody> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _id = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _id, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final vm = context.read<CreateAccountViewModel>();
    final ok = await vm.createAccount(name: _name.text, idNumber: _id.text, phone: _phone.text);
    // The session now shows Verify email underneath; close this screen.
    if (ok && mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateAccountViewModel>();
    final kind = vm.kind;
    void pwChanged(String _) => vm.onPasswordChanged(_password.text, _confirm.text);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), children: [
            const ScreenHeading(
              title: 'Create account',
              subtitle: 'Use your UTM email. Students use @graduate.utm.my; staff use @utm.my.',
            ),
            const SizedBox(height: 24),
            LabeledField(
              label: 'Full name',
              controller: _name,
              hint: 'As on your UTM card',
              icon: Icons.person_outline,
              validator: validateName,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'UTM email',
              controller: _email,
              hint: 'name@graduate.utm.my',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: validateUtmEmail,
              onChanged: vm.onEmailChanged,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: kind?.idLabel ?? 'Matric number or staff ID',
              controller: _id,
              hint: kind?.idHint ?? 'e.g. A24CS0123',
              icon: Icons.badge_outlined,
              validator: vm.validateId,
              textCapitalization: TextCapitalization.characters,
              helper: 'Must match the Exam Office record for your email.',
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Phone (optional)',
              controller: _phone,
              hint: '012-345 6789',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: validatePhone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Password',
              controller: _password,
              icon: Icons.lock_outline,
              obscure: !vm.showPassword,
              onChanged: pwChanged,
              suffix: PasswordToggle(visible: vm.showPassword, onPressed: vm.toggleShowPassword),
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Confirm password',
              controller: _confirm,
              icon: Icons.lock_outline,
              obscure: !vm.showPassword,
              onChanged: pwChanged,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            PasswordChecklist(checks: vm.checks),
            const SizedBox(height: 20),
            ErrorBanner(vm.error),
            if (vm.error != null) const SizedBox(height: 16),
            BusyButton(label: 'Create Account', busy: vm.busy, onPressed: _submit),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('I already have an account'),
            ),
          ]),
        ),
      ),
    );
  }
}
