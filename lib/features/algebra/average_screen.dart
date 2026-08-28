import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/solution_button.dart';
import '../../shared/widgets/tool_scaffold.dart';
import '../../shared/widgets/value_list_editor.dart';

class AverageScreen extends StatefulWidget {
  const AverageScreen({super.key});

  @override
  State<AverageScreen> createState() => _AverageScreenState();
}

class _AverageScreenState extends State<AverageScreen> {
  List<double> _values = [];

  @override
  Widget build(BuildContext context) {
    final n = _values.length;
    final steps = <String>[];

    double? arithmetic;
    double? geometric;
    double? harmonic;

    if (n > 0) {
      arithmetic = _values.reduce((a, b) => a + b) / n;
      steps.addAll([
        'Arithmetic = [[x₁ + x₂ + ... + xₙ/n]]',
        '= [[${_values.join(' + ')}/$n]]',
        '= ${arithmetic.toStringAsFixed(2)}',
      ]);

      if (_values.every((v) => v > 0)) {
        final product = _values.reduce((a, b) => a * b);
        geometric = product == 0 ? 0 : _nthRoot(product, n);
        steps.addAll([
          '',
          'Geometric = ⁿ√(x₁ × x₂ × ... × xₙ)',
          '= $n√(${_values.join(' × ')})',
          '= ${geometric.toStringAsFixed(2)}',
        ]);

        final reciprocalSum = _values.map((v) => 1 / v).reduce((a, b) => a + b);
        harmonic = n / reciprocalSum;
        steps.addAll([
          '',
          'Harmonic = n / (1/x₁ + 1/x₂ + ... + 1/xₙ)',
          '= [[$n/${reciprocalSum.toStringAsFixed(4)}]]',
          '= ${harmonic.toStringAsFixed(2)}',
        ]);
      }
    }

    return ToolScaffold(
      title: 'Average',
      children: [
        Text('Values', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ValueListEditor(
          onChanged: (values) => setState(() => _values = values.whereType<double>().toList()),
        ),
        ResultCard(rows: [
          ('Arithmetic', arithmetic == null ? '--' : arithmetic.toStringAsFixed(2)),
          ('Geometric', geometric == null ? '--' : geometric.toStringAsFixed(2)),
          ('Harmonic', harmonic == null ? '--' : harmonic.toStringAsFixed(2)),
        ]),
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Average'),
      ],
    );
  }

  double _nthRoot(double value, int n) => math.pow(value, 1 / n).toDouble();
}
