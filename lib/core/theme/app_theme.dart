import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const primary = Color(0xFF005BBF);
  static const primaryContainer = Color(0xFF1A73E8);
  static const primaryFixed = Color(0xFFD8E2FF);
  static const primaryFixedDim = Color(0xFFADC7FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFFFFFFF);

  static const secondary = Color(0xFF5C5F60);
  static const secondaryContainer = Color(0xFFE1E3E4);
  static const onSecondaryContainer = Color(0xFF626566);

  static const tertiary = Color(0xFF9E4300);
  static const tertiaryFixed = Color(0xFFFFDBCB);
  static const tertiaryContainer = Color(0xFFC55500);
  static const onTertiaryFixedVariant = Color(0xFF783100);

  static const surface = Color(0xFFF9F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F3FD);
  static const surfaceContainer = Color(0xFFECEDF7);
  static const surfaceContainerHigh = Color(0xFFE6E8F2);
  static const surfaceContainerHighest = Color(0xFFE0E2EC);

  static const onSurface = Color(0xFF191C23);
  static const onSurfaceVariant = Color(0xFF414754);
  static const outline = Color(0xFF727785);
  static const outlineVariant = Color(0xFFC1C6D6);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const inverseSurface = Color(0xFF2D3038);
  static const inverseOnSurface = Color(0xFFEFF0FA);
  static const inversePrimary = Color(0xFFADC7FF);

  // Semantic fallback constants (used as defaults when theme is not available)
  static const success = Color(0xFF1B8A4E);
  static const successContainer = Color(0xFFE8F5EE);
  static const warning = Color(0xFFE88E1A);
  static const warningContainer = Color(0xFFFFF3E0);
}

// ─────────────────────────────────────────────────────────────
// SEMANTIC COLORS THEME EXTENSION
// ─────────────────────────────────────────────────────────────
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  const SemanticColors({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  static const light = SemanticColors(
    success: Color(0xFF1B8A4E),
    successContainer: Color(0xFFE8F5EE),
    onSuccessContainer: Color(0xFF0F4B2A),
    warning: Color(0xFFE88E1A),
    warningContainer: Color(0xFFFFF3E0),
    onWarningContainer: Color(0xFF6B3B00),
  );

  static const dark = SemanticColors(
    success: Color(0xFF3CD070),
    successContainer: Color(0xFF113820),
    onSuccessContainer: Color(0xFFA6EFC1),
    warning: Color(0xFFFFB85F),
    warningContainer: Color(0xFF4B2A00),
    onWarningContainer: Color(0xFFFFDDB6),
  );

  static SemanticColors of(BuildContext context) {
    final ext = Theme.of(context).extension<SemanticColors>();
    if (ext != null) return ext;
    // Safe fallback based on brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }

  @override
  SemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SYSTEM THEME DEFINITION
// ─────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(ColorScheme colors, TextTheme base) {
    TextStyle _style(TextStyle style, double size, FontWeight weight, Color color) {
      return style.copyWith(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        color: color,
        inherit: true, // Crucial to prevent "Failed to interpolate TextStyles"
      );
    }

    return TextTheme(
      headlineLarge: _style(base.headlineLarge!, 30, FontWeight.w800, colors.onSurface).copyWith(letterSpacing: -0.8),
      headlineMedium: _style(base.headlineMedium!, 24, FontWeight.w700, colors.onSurface).copyWith(letterSpacing: -0.4),
      headlineSmall: _style(base.headlineSmall!, 20, FontWeight.w700, colors.onSurface).copyWith(letterSpacing: -0.2),
      titleLarge: _style(base.titleLarge!, 18, FontWeight.w700, colors.onSurface),
      titleMedium: _style(base.titleMedium!, 16, FontWeight.w600, colors.onSurface),
      titleSmall: _style(base.titleSmall!, 14, FontWeight.w600, colors.onSurface),
      bodyLarge: _style(base.bodyLarge!, 16, FontWeight.w400, colors.onSurface),
      bodyMedium: _style(base.bodyMedium!, 14, FontWeight.w400, colors.onSurface),
      bodySmall: _style(base.bodySmall!, 12, FontWeight.w400, colors.onSurfaceVariant),
      labelLarge: _style(base.labelLarge!, 13, FontWeight.w600, colors.onSurface),
      labelMedium: _style(base.labelMedium!, 12, FontWeight.w500, colors.outline),
      labelSmall: _style(base.labelSmall!, 10, FontWeight.w600, colors.outline).copyWith(letterSpacing: 0.5),
    );
  }

  static ThemeData get light {
    final colors = const ColorScheme(
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
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colors,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.surface,
      extensions: [SemanticColors.light],
      textTheme: _buildTextTheme(colors, base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
          letterSpacing: -0.3,
          inherit: true,
        ),
        iconTheme: IconThemeData(color: colors.onSurfaceVariant, size: 22),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, inherit: true),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, inherit: true),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, inherit: true),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, inherit: true),
        hintStyle: TextStyle(fontSize: 14, color: colors.outline, inherit: true),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 0.5,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.outline,
        selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, inherit: true),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, inherit: true),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        titleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: colors.onSurface, inherit: true),
        subtitleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.onSurfaceVariant, inherit: true),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? colors.primary : colors.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? colors.primaryContainer.withOpacity(0.3) : colors.surfaceContainerHigh,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.onInverseSurface, inherit: true),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get dark {
    // Elegant deep blue/grey color palette for dark mode
    final colors = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primaryContainer: const Color(0xFF003D82),
      onPrimaryContainer: const Color(0xFFD8E2FF),
      surface: const Color(0xFF111318),
      onSurface: const Color(0xFFE2E2E9),
      onSurfaceVariant: const Color(0xFFC4C6D0),
      outline: const Color(0xFF8E9099),
      outlineVariant: const Color(0xFF44474F),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.surface,
      extensions: [SemanticColors.dark],
      textTheme: _buildTextTheme(colors, base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
          letterSpacing: -0.3,
          inherit: true,
        ),
        iconTheme: IconThemeData(color: colors.onSurfaceVariant, size: 22),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, inherit: true),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, inherit: true),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, inherit: true),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, inherit: true),
        hintStyle: TextStyle(fontSize: 14, color: colors.outline, inherit: true),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 0.5,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.outline,
        selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, inherit: true),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, inherit: true),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        titleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: colors.onSurface, inherit: true),
        subtitleTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.onSurfaceVariant, inherit: true),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? colors.primary : colors.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? colors.primaryContainer.withOpacity(0.3) : colors.surfaceContainerHigh,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.onInverseSurface, inherit: true),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
