import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/auth/auth_service.dart';
import 'core/data/local_prefs.dart';
import 'core/data/profile_repository.dart';
import 'features/profile/data/edit_profile_repository.dart';
import 'features/registration/data/registration_repository.dart';
import 'features/staff_approvals/data/staff_approvals_repository.dart';
import 'firebase_options.dart';

/// Run against the local Firebase emulators with:
///   flutter run --dart-define=USE_EMULATORS=true
/// The Android emulator reaches this computer at 10.0.2.2; set EMULATOR_HOST for a
/// real phone on the same Wi-Fi (this computer's IP address).
const useEmulators = bool.fromEnvironment('USE_EMULATORS');
const emulatorHostOverride = String.fromEnvironment('EMULATOR_HOST');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (useEmulators) {
    final host = emulatorHostOverride.isNotEmpty
        ? emulatorHostOverride
        : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost');
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
  runApp(SeatTapApp(
    services: AppServices(
      auth: FirebaseAuthService(),
      profiles: FirestoreProfileRepository(),
      prefs: await SharedLocalPrefs.load(),
      registration: FirestoreRegistrationRepository(),
      staffApprovals: FirestoreStaffApprovalsRepository(),
      editProfile: FirestoreEditProfileRepository(),
    ),
  ));
}
