import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/validation/utm_account_rules.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/registration/viewmodels/complete_profile_view_model.dart';

/// Complete profile: saves the profile once the email is verified.
class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => CompleteProfileViewModel(c.read(), c.read(), c.read()),
        child: const _CompleteProfileBody(),
      );
}

class _CompleteProfileBody extends StatefulWidget {
  const _CompleteProfileBody();

  @override
  State<_CompleteProfileBody> createState() => _CompleteProfileBodyState();
}

class _CompleteProfileBodyState extends State<_CompleteProfileBody> {
  final _form = GlobalKey<FormState>();
  late final CompleteProfileViewModel _vm = context.read<CompleteProfileViewModel>();
  late final _name = TextEditingController(text: _vm.initialName);
  late final _id = TextEditingController(text: _vm.initialId);
  late final _phone = TextEditingController(text: _vm.initialPhone);

  @override
  void dispose() {
    _name.dispose();
    _id.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    await _vm.submit(name: _name.text, idNumber: _id.text, phone: _phone.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompleteProfileViewModel>();
    final kind = vm.kind;
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 40, 24, 32), children: [
            const Icon(Icons.verified_outlined, color: AppColors.success, size: 40),
            const SizedBox(height: 16),
            ScreenHeading(
              eyebrow: 'Email verified',
              title: 'Complete your profile',
              subtitle: 'We’ll check these against the Exam Office list for ${vm.email}.',
            ),
            const SizedBox(height: 24),
            LabeledField(
              label: 'Full name',
              controller: _name,
              icon: Icons.person_outline,
              validator: validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: kind?.idLabel ?? 'ID',
              controller: _id,
              hint: kind?.idHint,
              icon: Icons.badge_outlined,
              validator: vm.validateId,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Phone (optional)',
              controller: _phone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: validatePhone,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            ErrorBanner(vm.error),
            if (vm.error != null) const SizedBox(height: 16),
            BusyButton(label: 'Finish Setup', busy: vm.busy, onPressed: _submit),
            const SizedBox(height: 8),
            TextButton(onPressed: vm.signOut, child: const Text('Sign out')),
          ]),
        ),
      ),
    );
  }
}
