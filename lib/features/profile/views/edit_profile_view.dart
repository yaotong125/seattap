import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/models/user_profile.dart';
import 'package:seattap/core/theme.dart';
import 'package:seattap/core/validation/utm_account_rules.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/profile/viewmodels/edit_profile_view_model.dart';

/// Edit name, phone, faculty and photo. Email, ID and role belong to the Exam Office.
class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (c) => EditProfileViewModel(profile, c.read(), c.read()),
        child: const _EditProfileBody(),
      );
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody();

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  final _form = GlobalKey<FormState>();
  late final EditProfileViewModel _vm = context.read<EditProfileViewModel>();
  late final _name = TextEditingController(text: _vm.original.name);
  late final _phone = TextEditingController(text: _vm.original.phone ?? '');
  late final _id = TextEditingController(text: _vm.original.idNumber);
  late final _email = TextEditingController(text: _vm.original.email);

  @override
  void dispose() {
    for (final c in [_name, _phone, _id, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final ok = await _vm.save(name: _name.text, phone: _phone.text);
    if (ok && mounted) {
      showMessage(context, 'Profile saved.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditProfileViewModel>();
    final p = vm.original;
    return Scaffold(
      appBar: AppBar(leading: const CloseButton(), title: const Text('Edit Profile')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
            Center(
              child: Stack(clipBehavior: Clip.none, children: [
                ProfileAvatar(profile: p, size: 96, photoUrl: vm.photoUrl ?? ''),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Material(
                    color: AppColors.gold,
                    shape: const CircleBorder(side: BorderSide(color: AppColors.sand, width: 3)),
                    child: IconButton(
                      tooltip: 'Change photo',
                      onPressed: vm.busy ? null : vm.pickPhoto,
                      icon: const Icon(Icons.photo_camera_outlined, color: AppColors.maroon, size: 20),
                    ),
                  ),
                ),
              ]),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(onPressed: vm.busy ? null : vm.pickPhoto, child: const Text('Change photo')),
              if (vm.photoUrl != null)
                TextButton(
                  onPressed: vm.busy ? null : vm.removePhoto,
                  style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                  child: const Text('Remove'),
                ),
            ]),
            const SizedBox(height: 8),
            LabeledField(
              label: 'Full name',
              controller: _name,
              validator: validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Phone',
              controller: _phone,
              hint: '012-345 6789',
              keyboardType: TextInputType.phone,
              validator: validatePhone,
            ),
            const SizedBox(height: 14),
            const Text('Faculty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: vm.faculty,
              isExpanded: true,
              hint: const Text('Choose your faculty'),
              items: [for (final f in vm.facultyOptions) DropdownMenuItem(value: f, child: Text(f))],
              onChanged: vm.setFaculty,
            ),
            const SizedBox(height: 14),
            LabeledField(label: p.role.idLabel, controller: _id, readOnly: true),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Email',
              controller: _email,
              readOnly: true,
              helper: '${p.role.idLabel} and email can only be changed by the Exam Office.',
            ),
            const SizedBox(height: 20),
            ErrorBanner(vm.error),
            if (vm.error != null) const SizedBox(height: 16),
            BusyButton(label: 'Save Changes', busy: vm.busy, onPressed: _save),
          ]),
        ),
      ),
    );
  }
}
