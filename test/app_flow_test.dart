import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seattap/app.dart';
import 'package:seattap/core/auth/auth_service.dart';
import 'package:seattap/core/data/local_prefs.dart';
import 'package:seattap/core/models/user_profile.dart';

import 'fakes.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {AppUser? user, FakeBackend? profiles, bool onboarded = true}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = FakeAuthService(signedIn: user)..passwords['hafiz@utm.my'] = 'Passw0rd';
    final backend = profiles ?? FakeBackend();
    await tester.pumpWidget(SeatTapApp(
      services: AppServices(
        auth: auth,
        profiles: backend,
        prefs: MemoryLocalPrefs(onboardingSeen: onboarded),
        registration: backend,
        staffApprovals: backend,
        editProfile: backend,
      ),
      useGoogleFonts: false,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('first launch shows the welcome slides, then sign in', (tester) async {
    await pumpApp(tester, onboarded: false);
    expect(find.text('Welcome to SeatTap'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('sign in asks for both fields, then reports a wrong password', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    expect(find.text('Enter your email and password.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'hafiz@utm.my');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
  });

  testWidgets('an Exam Officer signs in and sees pending approvals', (tester) async {
    final profiles = FakeBackend()
      ..put(profileOf(email: 'hafiz@utm.my', role: UserRole.examOfficer, name: 'Hafiz Rahman'))
      ..put(profileOf(
          email: 'farah@utm.my', role: UserRole.invigilator, status: ProfileStatus.pending, name: 'Farah Hanim'));
    await pumpApp(tester, profiles: profiles);

    await tester.enterText(find.byType(TextFormField).at(0), 'hafiz@utm.my');
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Hafiz Rahman'), findsOneWidget);
    expect(find.text('Exam Officer'), findsOneWidget);
    expect(find.text('Pending staff approvals'), findsOneWidget);

    await tester.tap(find.text('Pending staff approvals'));
    await tester.pumpAndSettle();
    expect(find.text('Farah Hanim'), findsOneWidget);
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(find.text('All caught up'), findsOneWidget);
  });

  testWidgets('a pending invigilator sees the waiting screen', (tester) async {
    const user = AppUser(uid: 'uid-farah@utm.my', email: 'farah@utm.my', emailVerified: true);
    final profiles = FakeBackend()
      ..put(profileOf(email: 'farah@utm.my', role: UserRole.invigilator, status: ProfileStatus.pending));
    await pumpApp(tester, user: user, profiles: profiles);
    expect(find.text('Waiting for approval'), findsOneWidget);
  });

  testWidgets('each role gets its own dashboard', (tester) async {
    for (final (role, expected) in [
      (UserRole.invigilator, 'Scan'),
      (UserRole.student, 'My attendance'),
    ]) {
      final email = '${role.name}@utm.my';
      final profiles = FakeBackend()..put(profileOf(email: email, role: role));
      await pumpApp(tester, user: AppUser(uid: 'uid-$email', email: email, emailVerified: true), profiles: profiles);
      expect(find.text(expected), findsOneWidget, reason: role.name);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('a new account goes to Verify email', (tester) async {
    const user = AppUser(uid: 'uid-new@utm.my', email: 'new@utm.my', emailVerified: false);
    await pumpApp(tester, user: user);
    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.text('new@utm.my'), findsOneWidget);
  });
}
