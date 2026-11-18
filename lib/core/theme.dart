import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SeatTap brand colours (UTM maroon and gold on a warm sand background).
class AppColors {
  AppColors._();

  static const maroon = Color(0xFF5C001F);
  static const maroonDark = Color(0xFF3D0014);
  static const gold = Color(0xFFF8A617);
  static const goldSoft = Color(0xFFFDEBC4);
  static const sand = Color(0xFFFBF7F0);
  static const ink = Color(0xFF1F1A17);
  static const body = Color(0xFF4A433D);
  static const muted = Color(0xFF6B625A);
  static const border = Color(0xFFD9CFC2);
  static const line = Color(0xFFE3DACE);
  static const surfaceMuted = Color(0xFFF1EBE2);
  static const roseSoft = Color(0xFFF6E8EC);
  static const roseText = Color(0xFFF3D9E0);
  static const error = Color(0xFFB42318);
  static const errorSoft = Color(0xFFFDE7E5);
  static const success = Color(0xFF1E6B3D);
  static const successSoft = Color(0xFFE3F2E8);
}

/// The app theme. [useGoogleFonts] is off in widget tests, which have no network.
ThemeData buildTheme({bool useGoogleFonts = true}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.maroon,
      primary: AppColors.maroon,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.maroon,
      surface: AppColors.sand,
      onSurface: AppColors.ink,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.sand,
    // google_fonts 9 builds on the separate material_ui package, so take only the
    // family name from it; calling inter() also starts loading the font.
    fontFamily: useGoogleFonts ? GoogleFonts.inter().fontFamily : null,
  );
  final textTheme = base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.sand,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.maroon, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
      disabledBorder: border(AppColors.line),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.maroon.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.maroon,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.maroon : null,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.maroon : null,
      ),
    ),
  );
}
