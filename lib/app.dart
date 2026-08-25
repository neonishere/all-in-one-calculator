import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/settings/theme_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/basic_calculator/basic_calculator_screen.dart';

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeSettings = context.watch<ThemeSettings>();
    return MaterialApp(
      title: 'All-in-One Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(themeSettings.base, themeSettings.accentColor),
      home: const BasicCalculatorScreen(),
    );
  }
}
