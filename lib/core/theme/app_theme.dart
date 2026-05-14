import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const primary          = Color(0xFF005BBF);
  static const primaryContainer = Color(0xFF1A73E8);
  static const primaryFixed     = Color(0xFFD8E2FF);
  static const primaryFixedDim  = Color(0xFFADC7FF);
  static const onPrimary        = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFFFFFFF);

  static const secondary          = Color(0xFF5C5F60);
  static const secondaryContainer = Color(0xFFE1E3E4);
  static const onSecondaryContainer = Color(0xFF626566);

  static const tertiary          = Color(0xFF9E4300);
  static const tertiaryFixed     = Color(0xFFFFDBCB);
  static const tertiaryContainer = Color(0xFFC55500);
  static const onTertiaryFixedVariant = Color(0xFF783100);

  static const surface                  = Color(0xFFF9F9FF);
  static const surfaceContainerLowest   = Color(0xFFFFFFFF);
  static const surfaceContainerLow      = Color(0xFFF2F3FD);
  static const surfaceContainer         = Color(0xFFECEDF7);
  static const surfaceContainerHigh     = Color(0xFFE6E8F2);
  static const surfaceContainerHighest  = Color(0xFFE0E2EC);

  static const onSurface        = Color(0xFF191C23);
  static const onSurfaceVariant = Color(0xFF414754);
  static const outline          = Color(0xFF727785);
  static const outlineVariant   = Color(0xFFC1C6D6);

  static const error            = Color(0xFFBA1A1A);
  static const errorContainer   = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const inverseSurface   = Color(0xFF2D3038);
  static const inverseOnSurface = Color(0xFFEFF0FA);
  static const inversePrimary   = Color(0xFFADC7FF);

  // semantic
  static const success          = Color(0xFF1B8A4E);
  static const successContainer = Color(0xFFE8F5EE);
  static const warning          = Color(0xFFE88E1A);
  static const warningContainer = Color(0xFFFFF3E0);
}

// ─────────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.onSurface, letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.onSurfaceVariant, size: 22),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.outline),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineVariant, thickness: 0.5, space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.outline,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      titleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
      subtitleTextStyle: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primary : AppColors.outline),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primaryFixed : AppColors.surfaceContainerHigh),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    ),
  );
}
