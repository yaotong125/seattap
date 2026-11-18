import 'package:flutter/material.dart';

import '../validation/utm_account_rules.dart';
import '../theme.dart';
import '../models/user_profile.dart';

/// The SeatTap mark: a seat with an NFC wave on a gold tile.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'SeatTap logo',
        image: true,
        child: CustomPaint(size: Size.square(size), painter: _LogoPainter()),
      );
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64);
    final gold = Paint()..color = AppColors.gold;
    final maroon = Paint()..color = AppColors.maroon;
    final stroke = Paint()
      ..color = AppColors.maroon
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(RRect.fromLTRBR(0, 0, 64, 64, const Radius.circular(16)), gold);
    canvas.drawRRect(RRect.fromLTRBR(15, 14, 35, 36, const Radius.circular(4)), maroon);
    canvas.drawRRect(RRect.fromLTRBR(11, 34, 39, 42, const Radius.circular(3)), maroon);
    stroke.strokeWidth = 4;
    canvas.drawLine(const Offset(16, 42), const Offset(16, 51), stroke);
    canvas.drawLine(const Offset(34, 42), const Offset(34, 51), stroke);
    stroke.strokeWidth = 3.5;
    canvas.drawPath(
      Path()
        ..moveTo(44, 24)
        ..arcToPoint(const Offset(44, 38), radius: const Radius.circular(10)),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(49, 19)
        ..arcToPoint(const Offset(49, 43), radius: const Radius.circular(17)),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A form field with its label above it, as in the designs.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.helper,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? helper;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            readOnly: readOnly,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
            style: TextStyle(fontSize: 16, color: readOnly ? AppColors.body : AppColors.ink),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon == null ? null : Icon(icon, size: 20),
              suffixIcon: suffix,
              fillColor: readOnly ? AppColors.surfaceMuted : Colors.white,
              helperText: helper,
              helperMaxLines: 2,
              helperStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      );
}

/// Show/hide button for password fields.
class PasswordToggle extends StatelessWidget {
  const PasswordToggle({super.key, required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: visible ? 'Hide password' : 'Show password',
        icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
        onPressed: onPressed,
      );
}

/// The four password rules with a tick for each one that passes.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.checks});

  final PasswordChecks checks;

  @override
  Widget build(BuildContext context) {
    Widget row(String text, bool ok) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18, color: ok ? AppColors.success : AppColors.border),
            const SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 14, color: ok ? AppColors.ink : AppColors.muted)),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      row('At least 8 characters', checks.longEnough),
      row('Upper and lower case letters', checks.mixedCase),
      row('At least one number', checks.hasNumber),
      row('Both passwords match', checks.matches),
    ]);
  }
}

/// A red message box for errors that belong to the whole form.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message!, style: const TextStyle(color: AppColors.error, fontSize: 14, height: 1.4))),
        ]),
      ),
    );
  }
}

/// A filled button that shows a spinner while [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox(
                width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label),
      );
}

/// Round avatar: the profile photo, or initials.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.size = 48, this.photoUrl});

  final UserProfile profile;
  final double size;

  /// Overrides the profile's photo (Edit profile preview).
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final bytes = decodePhoto(photoUrl ?? profile.photoUrl);
    final officer = profile.role == UserRole.examOfficer;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, color: officer ? AppColors.gold : AppColors.maroon),
      alignment: Alignment.center,
      child: bytes != null
          ? Image.memory(bytes, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true)
          : Text(
              profile.initials,
              style: TextStyle(
                color: officer ? AppColors.maroon : AppColors.gold,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

/// "Invigilator", "Exam Officer" or "Student" pill.
class RoleChip extends StatelessWidget {
  const RoleChip(this.role, {super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: role == UserRole.examOfficer ? AppColors.goldSoft : AppColors.roseSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(role.label,
            style: const TextStyle(color: AppColors.maroon, fontSize: 13, fontWeight: FontWeight.w600)),
      );
}

/// Centered icon, title and text for status screens (email sent, awaiting approval…).
class StatusHero extends StatelessWidget {
  const StatusHero({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.iconColor = AppColors.maroon,
    this.background = AppColors.goldSoft,
    this.children = const [],
  });

  final IconData icon;
  final String title;
  final String? body;
  final Color iconColor;
  final Color background;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(icon, size: 56, color: iconColor),
          ),
          const SizedBox(height: 28),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.maroon)),
          if (body != null) ...[
            const SizedBox(height: 12),
            Text(body!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.muted)),
          ],
          ...children,
        ],
      );
}

/// White rounded card with a hairline border.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

/// Page heading used on form screens.
class ScreenHeading extends StatelessWidget {
  const ScreenHeading({super.key, required this.title, this.subtitle, this.eyebrow});

  final String title;
  final String? subtitle;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(eyebrow!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.muted)),
            const SizedBox(height: 8),
          ],
          Text(title,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.maroon)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.muted)),
          ],
        ],
      );
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
