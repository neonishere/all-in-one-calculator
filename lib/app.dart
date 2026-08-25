import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/basic_calculator/basic_calculator_screen.dart';

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All-in-One Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const BasicCalculatorScreen(),
    );
  }
}
