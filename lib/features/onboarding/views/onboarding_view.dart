import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/core/theme.dart';
import 'package:seattap/core/widgets/common.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';

/// Welcome plus three onboarding slides, shown once per phone.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pages = PageController();
  int _index = 0;

  static const _slides = [
    (Icons.contactless_outlined, 'Tap to check in',
        'Tap a student’s matric card on your phone. Attendance is recorded in under a second.'),
    (Icons.event_seat_outlined, 'Verified and seated',
        'SeatTap checks the course and section, then draws a random free seat so friends can’t plan to sit together.'),
    (Icons.cloud_sync_outlined, 'Works with no signal',
        'Check-ins are saved on the phone in zero-signal halls and sync automatically once you’re back online.'),
  ];

  void _finish() => context.read<SessionViewModel>().finishOnboarding();

  void _next() {
    if (_index == _slides.length) return _finish();
    _pages.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _slides.length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(children: [
            Row(children: [
              if (_index > 0)
                Text('$_index of ${_slides.length}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.muted)),
              const Spacer(),
              TextButton(onPressed: _finish, child: const Text('Skip')),
            ]),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  const _OnboardingPage(
                    art: _WelcomeArt(),
                    title: 'Welcome to SeatTap',
                    body: 'Exam check-in in one tap. Verify each student, assign a random seat and log attendance, '
                        'even with no signal.',
                  ),
                  for (final s in _slides) _OnboardingPage(art: _SlideArt(s.$1), title: s.$2, body: s.$3),
                ],
              ),
            ),
            if (_index > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var k = 1; k <= _slides.length; k++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: k == _index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: k == _index ? AppColors.maroon : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
            ],
            FilledButton(onPressed: _next, child: Text(last ? 'Get Started' : 'Next')),
          ]),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.art, required this.title, required this.body});

  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          art,
          const SizedBox(height: 40),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.maroon)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 310),
            child: Text(body,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.muted)),
          ),
        ],
      );
}

class _WelcomeArt extends StatelessWidget {
  const _WelcomeArt();

  @override
  Widget build(BuildContext context) => Container(
        width: 220,
        height: 220,
        decoration: const BoxDecoration(color: AppColors.roseSoft, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const AppLogo(size: 128),
      );
}

class _SlideArt extends StatelessWidget {
  const _SlideArt(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(color: AppColors.maroon, borderRadius: BorderRadius.circular(40)),
        child: Icon(icon, size: 112, color: AppColors.gold),
      );
}
