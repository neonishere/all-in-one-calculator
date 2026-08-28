import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

class EllipseScreen extends StatefulWidget {
  const EllipseScreen({super.key});

  @override
  State<EllipseScreen> createState() => _EllipseScreenState();
}

class _EllipseScreenState extends State<EllipseScreen> {
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
      area = math.pi * a * b;
      perimeter = math.pi * (3 * (a + b) - math.sqrt((3 * a + b) * (a + 3 * b)));
      steps.addAll([
        'Area = π × A × B = ${area.toStringAsFixed(2)}',
        'Perimeter ≈ π[3(A+B) - √((3A+B)(A+3B))]',
        '= ${perimeter.toStringAsFixed(2)}',
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ellipse')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 180, child: Center(child: ShapeIcon(kind: ShapeKind.ellipse, size: 160, color: AppColors.textSecondary))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _labeled('Radius', NumberField(label: '', controller: _aController, onChanged: (_) => setState(() {}), suffix: 'A'))),
                const SizedBox(width: 10),
                Expanded(child: _labeled('Radius', NumberField(label: '', controller: _bController, onChanged: (_) => setState(() {}), suffix: 'B'))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve an ellipse knowing its dimensions', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              ('Perimeter', perimeter == null ? '--' : perimeter.toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Ellipse'),
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
