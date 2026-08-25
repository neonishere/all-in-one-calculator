import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF14161C);
  static const surface = Color(0xFF1D2026);
  static const surfaceAlt = Color(0xFF262A32);
  static const accent = Color(0xFF4FD6C4);
  static const accentDim = Color(0xFF2F8377);
  static const textPrimary = Color(0xFFEDEFF3);
  static const textSecondary = Color(0xFF9198A6);
  static const divider = Color(0xFF2C3038);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.accent,
        secondary: AppColors.accentDim,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.divider,
      cardColor: AppColors.surface,
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.accent,
        textColor: AppColors.textPrimary,
      ),
    );
  }
}
