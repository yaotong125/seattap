import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/auth/auth_service.dart';
import 'core/data/local_prefs.dart';
import 'core/data/profile_repository.dart';
import 'core/theme.dart';
import 'features/profile/data/edit_profile_repository.dart';
import 'features/profile/data/photo_service.dart';
import 'features/registration/data/registration_repository.dart';
import 'features/session/viewmodels/session_view_model.dart';
import 'features/session/views/session_gate.dart';
import 'features/staff_approvals/data/staff_approvals_repository.dart';

/// Each feature's data source, handed to the app so tests can swap in fakes.
class AppServices {
  const AppServices({
    required this.auth,
    required this.profiles,
    required this.prefs,
    required this.registration,
    required this.staffApprovals,
    required this.editProfile,
  });

  final AuthService auth;
  final ProfileRepository profiles;
  final LocalPrefs prefs;
  final RegistrationRepository registration;
  final StaffApprovalsRepository staffApprovals;
  final EditProfileRepository editProfile;
}

/// Root widget: services for the ViewModels, the theme, and the session gate.
class SeatTapApp extends StatelessWidget {
  const SeatTapApp({super.key, required this.services, this.useGoogleFonts = true});

  final AppServices services;
  final bool useGoogleFonts;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<AuthService>.value(value: services.auth),
          Provider<ProfileRepository>.value(value: services.profiles),
          Provider<LocalPrefs>.value(value: services.prefs),
          Provider<RegistrationRepository>.value(value: services.registration),
          Provider<StaffApprovalsRepository>.value(value: services.staffApprovals),
          Provider<EditProfileRepository>.value(value: services.editProfile),
          Provider<PhotoService>(create: (_) => PhotoService()),
          ChangeNotifierProvider(
            create: (_) =>
                SessionViewModel(auth: services.auth, profiles: services.profiles, prefs: services.prefs),
          ),
        ],
        child: MaterialApp(
          title: 'SeatTap',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(useGoogleFonts: useGoogleFonts),
          home: const SessionGate(),
        ),
      );
}
