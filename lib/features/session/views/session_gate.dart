import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seattap/features/dashboard/views/dashboard_view.dart';
import 'package:seattap/features/onboarding/views/onboarding_view.dart';
import 'package:seattap/features/registration/views/awaiting_approval_view.dart';
import 'package:seattap/features/registration/views/complete_profile_view.dart';
import 'package:seattap/features/registration/views/verify_email_view.dart';
import 'package:seattap/features/session/viewmodels/session_view_model.dart';
import 'package:seattap/features/session/views/session_error_view.dart';
import 'package:seattap/features/session/views/splash_view.dart';
import 'package:seattap/features/sign_in/views/sign_in_view.dart';

/// Shows the screen for the current account stage. Pushed screens sit on top of it.
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final Widget screen = switch (session.stage) {
      SessionStage.loading => const SplashView(),
      SessionStage.signedOut => session.onboardingSeen ? const SignInView() : const OnboardingView(),
      SessionStage.verifyEmail => const VerifyEmailView(),
      SessionStage.completeProfile => const CompleteProfileView(),
      SessionStage.pending => const AwaitingApprovalView(rejected: false),
      SessionStage.rejected => const AwaitingApprovalView(rejected: true),
      SessionStage.active => const DashboardView(),
      SessionStage.error => const SessionErrorView(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(session.stage), child: screen),
    );
  }
}
