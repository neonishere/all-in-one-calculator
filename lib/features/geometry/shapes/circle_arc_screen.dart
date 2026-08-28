import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

class CircleArcScreen extends StatefulWidget {
  const CircleArcScreen({super.key});

  @override
  State<CircleArcScreen> createState() => _CircleArcScreenState();
}

class _CircleArcScreenState extends State<CircleArcScreen> {
  final _rController = TextEditingController();
  final _aController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final r = double.tryParse(_rController.text);
    final angleDeg = double.tryParse(_aController.text);
    double? area;
    double? length;
    final steps = <String>[];
    if (r != null && angleDeg != null) {
      final angleRad = angleDeg * math.pi / 180;
      area = 0.5 * r * r * angleRad;
      length = r * angleRad;
      steps.addAll(['Area = ½ × R² × θ (rad) = ${area.toStringAsFixed(2)}', 'Length = R × θ (rad) = ${length.toStringAsFixed(2)}']);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Circle arc')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 180, child: Center(child: ShapeIcon(kind: ShapeKind.circleArc, size: 140, color: AppColors.textSecondary))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _labeled('Radius', NumberField(label: '', controller: _rController, onChanged: (_) => setState(() {}), suffix: 'R'))),
                const SizedBox(width: 10),
                Expanded(child: _labeled('Angle', NumberField(label: '', controller: _aController, onChanged: (_) => setState(() {}), suffix: 'A'))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a circle arc knowing its dimensions', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              ('Length', length == null ? '--' : length.toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Circle arc'),
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
