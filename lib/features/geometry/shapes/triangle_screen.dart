import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

class TriangleScreen extends StatefulWidget {
  const TriangleScreen({super.key});

  @override
  State<TriangleScreen> createState() => _TriangleScreenState();
}

class _TriangleScreenState extends State<TriangleScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _cController = TextEditingController();

  double _deg(double radians) => radians * 180 / math.pi;

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    final c = double.tryParse(_cController.text);

    double? area, perimeter, angleAB, angleBC, angleAC, heightA, heightB, heightC;
    final steps = <String>[];

    final valid = a != null && b != null && c != null && a + b > c && a + c > b && b + c > a;
    if (valid) {
      perimeter = a + b + c;
      final s = perimeter / 2;
      area = math.sqrt(s * (s - a) * (s - b) * (s - c));
      angleBC = _deg(math.acos((b * b + c * c - a * a) / (2 * b * c)));
      angleAC = _deg(math.acos((a * a + c * c - b * b) / (2 * a * c)));
      angleAB = _deg(math.acos((a * a + b * b - c * c) / (2 * a * b)));
      heightA = 2 * area / a;
      heightB = 2 * area / b;
      heightC = 2 * area / c;
      steps.addAll([
        's = [[A + B + C/2]] = ${s.toStringAsFixed(2)}',
        'Area = √(s(s-A)(s-B)(s-C))',
        '= ${area.toStringAsFixed(2)}',
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Triangle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Center(child: ShapeIcon(kind: ShapeKind.triangle, size: 130, color: AppColors.textSecondary))),
                Expanded(child: _labeled('Side', NumberField(label: '', controller: _cController, onChanged: (_) => setState(() {}), suffix: 'C'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _labeled('Side', NumberField(label: '', controller: _aController, onChanged: (_) => setState(() {}), suffix: 'A'))),
                const SizedBox(width: 10),
                Expanded(child: _labeled('Side', NumberField(label: '', controller: _bController, onChanged: (_) => setState(() {}), suffix: 'B'))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a triangle knowing its sides', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              ('Perimeter', perimeter == null ? '--' : perimeter.toStringAsFixed(2)),
              ('Angle: AB', angleAB == null ? '--' : '${angleAB.toStringAsFixed(2)}°'),
              ('Angle: BC', angleBC == null ? '--' : '${angleBC.toStringAsFixed(2)}°'),
              ('Angle: AC', angleAC == null ? '--' : '${angleAC.toStringAsFixed(2)}°'),
              ('Height: A', heightA == null ? '--' : heightA.toStringAsFixed(2)),
              ('Height: B', heightB == null ? '--' : heightB.toStringAsFixed(2)),
              ('Height: C', heightC == null ? '--' : heightC.toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Triangle'),
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
