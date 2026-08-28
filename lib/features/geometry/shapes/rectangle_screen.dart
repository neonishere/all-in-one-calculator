import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

class RectangleScreen extends StatefulWidget {
  const RectangleScreen({super.key});

  @override
  State<RectangleScreen> createState() => _RectangleScreenState();
}

class _RectangleScreenState extends State<RectangleScreen> {
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
      area = a * b;
      perimeter = 2 * (a + b);
      steps.addAll(['Area = A × B = $a × $b = ${area.toStringAsFixed(2)}', 'Perimeter = 2(A + B) = ${perimeter.toStringAsFixed(2)}']);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rectangle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 180, child: Center(child: ShapeIcon(kind: ShapeKind.rectangle, size: 160, color: AppColors.textSecondary))),
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
              child: Text("Solve a rectangle knowing its dimensions", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              ('Perimeter', perimeter == null ? '--' : perimeter.toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Rectangle'),
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
