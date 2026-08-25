import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ResultValueCard extends StatelessWidget {
  const ResultValueCard({super.key, required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value == null ? '--' : _format(value!),
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _format(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
    return v.toStringAsPrecision(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
