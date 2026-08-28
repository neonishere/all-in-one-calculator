import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

class RhombusScreen extends StatefulWidget {
  const RhombusScreen({super.key});

  @override
  State<RhombusScreen> createState() => _RhombusScreenState();
}

class _RhombusScreenState extends State<RhombusScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    double? area;
    double? perimeter;
    final steps = <String>[];
    if (a != null && b != null) {
      area = a * b / 2;
      final side = math.sqrt((a / 2) * (a / 2) + (b / 2) * (b / 2));
      perimeter = 4 * side;
      steps.addAll(['Area = [[A × B/2]] = ${area.toStringAsFixed(2)}', 'Side = √([[A/2]]² + [[B/2]]²) = ${side.toStringAsFixed(2)}', 'Perimeter = 4 × side = ${perimeter.toStringAsFixed(2)}']);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rhombus')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 180, child: Center(child: ShapeIcon(kind: ShapeKind.rhombus, size: 150, color: AppColors.textSecondary))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _labeled('Length', NumberField(label: '', controller: _aController, onChanged: (_) => setState(() {}), suffix: 'A'))),
                const SizedBox(width: 10),
                Expanded(child: _labeled('Width', NumberField(label: '', controller: _bController, onChanged: (_) => setState(() {}), suffix: 'B'))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a rhombus knowing its dimensions', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              ('Perimeter', perimeter == null ? '--' : perimeter.toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Rhombus'),
          ],
        ),
      ),
    );
  }

  Widget _labeled(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
