import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

class TrapezoidScreen extends StatefulWidget {
  const TrapezoidScreen({super.key});

  @override
  State<TrapezoidScreen> createState() => _TrapezoidScreenState();
}

class _TrapezoidScreenState extends State<TrapezoidScreen> {
  final _hController = TextEditingController();
  final _aController = TextEditingController();
  final _bController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final h = double.tryParse(_hController.text);
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    double? area;
    final steps = <String>[];
    if (h != null && a != null && b != null) {
      area = 0.5 * (a + b) * h;
      steps.addAll(['Area = ½ × (A + B) × H', '= ½ × ($a + $b) × $h', '= ${area.toStringAsFixed(2)}']);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trapezoid')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Center(child: ShapeIcon(kind: ShapeKind.trapezoid, size: 130, color: AppColors.textSecondary))),
                Expanded(child: _labeled('Height', NumberField(label: '', controller: _hController, onChanged: (_) => setState(() {}), suffix: 'H'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _labeled('Top', NumberField(label: '', controller: _aController, onChanged: (_) => setState(() {}), suffix: 'A'))),
                const SizedBox(width: 10),
                Expanded(child: _labeled('Base', NumberField(label: '', controller: _bController, onChanged: (_) => setState(() {}), suffix: 'B'))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a trapezoid knowing its dimensions', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              ('Perimeter', '--'),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Trapezoid'),
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
