import 'package:flutter/material.dart';

import '../routing/same_plane_transitions.dart';

enum AppBaseTheme { slate, midnightBlue, black, light }

extension AppBaseThemeLabels on AppBaseTheme {
  String get label => switch (this) {
        AppBaseTheme.slate => 'Slate',
        AppBaseTheme.midnightBlue => 'Midnight blue',
        AppBaseTheme.black => 'Black',
        AppBaseTheme.light => 'Light',
      };

  bool get isDark => this != AppBaseTheme.light;
}

enum AppAccentColor { teal, red, purple, blue, orange, green }

extension AppAccentColorLabels on AppAccentColor {
  String get label => switch (this) {
        AppAccentColor.teal => 'Teal',
        AppAccentColor.red => 'Red',
        AppAccentColor.purple => 'Purple',
        AppAccentColor.blue => 'Blue',
        AppAccentColor.orange => 'Orange',
        AppAccentColor.green => 'Green',
      };

  Color get color => switch (this) {
        AppAccentColor.teal => const Color(0xFF4FD6C4),
        AppAccentColor.red => const Color(0xFFEF5A5A),
        AppAccentColor.purple => const Color(0xFFA477F2),
        AppAccentColor.blue => const Color(0xFF5B9CF6),
        AppAccentColor.orange => const Color(0xFFF6A85B),
        AppAccentColor.green => const Color(0xFF62D08A),
      };
}

/// The app's current color palette. [apply] mutates these in place before
/// [AppTheme.build] hands back new `ThemeData`, so custom widgets that read
/// `AppColors.x` directly (instead of `Theme.of(context)`) stay in sync —
/// they're rebuilt as part of the same frame that calls [apply].
class AppColors {
  AppColors._();

  static Color background = const Color(0xFF14161C);
  static Color surface = const Color(0xFF1D2026);
  static Color surfaceAlt = const Color(0xFF262A32);
  static Color accent = const Color(0xFF4FD6C4);
  static Color accentDim = const Color(0xFF2F8377);
  static Color textPrimary = const Color(0xFFEDEFF3);
  static Color textSecondary = const Color(0xFF9198A6);
  static Color divider = const Color(0xFF2C3038);

  static void apply(AppBaseTheme base, AppAccentColor accentColor) {
    switch (base) {
      case AppBaseTheme.slate:
        background = const Color(0xFF14161C);
        surface = const Color(0xFF1D2026);
        surfaceAlt = const Color(0xFF262A32);
        textPrimary = const Color(0xFFEDEFF3);
        textSecondary = const Color(0xFF9198A6);
        divider = const Color(0xFF2C3038);
      case AppBaseTheme.midnightBlue:
        background = const Color(0xFF0B1220);
        surface = const Color(0xFF121B2E);
        surfaceAlt = const Color(0xFF1B2740);
        textPrimary = const Color(0xFFE7ECF7);
        textSecondary = const Color(0xFF8C9AB8);
        divider = const Color(0xFF223055);
      case AppBaseTheme.black:
        background = const Color(0xFF000000);
        surface = const Color(0xFF121212);
        surfaceAlt = const Color(0xFF1C1C1C);
        textPrimary = const Color(0xFFF2F2F2);
        textSecondary = const Color(0xFF9A9A9A);
        divider = const Color(0xFF262626);
      case AppBaseTheme.light:
        background = const Color(0xFFF5F6F8);
        surface = const Color(0xFFFFFFFF);
        surfaceAlt = const Color(0xFFEDEFF3);
        textPrimary = const Color(0xFF1B1D22);
        textSecondary = const Color(0xFF63687A);
        divider = const Color(0xFFDDE1E8);
    }
    accent = accentColor.color;
    accentDim = Color.lerp(accent, Colors.black, 0.35)!;
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData build(AppBaseTheme base, AppAccentColor accentColor) {
    AppColors.apply(base, accentColor);
    final brightness = base.isDark ? Brightness.dark : Brightness.light;
    final baseTheme = base.isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: baseTheme.colorScheme.copyWith(
        brightness: brightness,
        primary: AppColors.accent,
        secondary: AppColors.accentDim,
        surface: AppColors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.divider,
      cardColor: AppColors.surface,
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.accent,
        textColor: AppColors.textPrimary,
      ),
      popupMenuTheme: PopupMenuThemeData(color: AppColors.surface),
      pageTransitionsTheme: samePlanePageTransitionsTheme,
    );
  }
}
