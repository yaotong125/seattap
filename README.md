# SeatTap

Evolutionary UTM Exam Management Prototype

Offline-first NFC exam check-in for Universiti Teknologi Malaysia.
SECJ3623 Mobile Application Programming, group IMAP.

Invigilators tap a student's matric card to check them in, SeatTap verifies the
course and section, assigns a random free seat and records attendance, even in
halls with no signal.

## Sprint 1: accounts, profiles and role dashboards

- Sign in, create account, email verification and forgot password
- Registration checked against the Exam Office roster (UTM email + matric number or staff ID)
- UTM staff not on the roster wait for an Exam Officer to approve them
- Separate dashboards for invigilators, Exam Officers and students
- Profile, edit profile (with photo), settings and change password

Features for later sprints (scanning, attendance, seating, exam sessions, hall
layouts) open a "Coming soon" screen.

## Architecture

Flutter with MVVM (`provider`), organised as vertical slices: each feature has
its own data access, ViewModels and Views.

```
lib/
  core/                shared: theme, widgets, auth, profile reading, validation
  features/
    session/           decides the first screen
    onboarding/        welcome slides
    sign_in/           sign in, forgot password
    registration/      create account, verify email, complete profile, awaiting approval
    staff_approvals/   Exam Officer approves or rejects staff
    dashboard/         invigilator, Exam Officer and student dashboards
    profile/           profile, edit profile, photo
    settings/          settings, change password, log out
      <feature>/data/        Firestore access for the feature
      <feature>/viewmodels/  state and logic
      <feature>/views/       screens
```

Backend: Firebase Authentication and Cloud Firestore on the free Spark plan.
`firestore.rules` enforces each feature's checks on the server (registration
against the roster, staff approval, profile edits). `backend/` contains the
rules tests and seed scripts.

## Running

```bash
flutter pub get
flutter run
```

Tests:

```bash
flutter test
cd backend && npm install && npm run test:emulators
```

To use the local Firebase emulators instead of the live project, start them with
`npm run serve` in `backend/`, then run the app with
`flutter run --dart-define=USE_EMULATORS=true`.
