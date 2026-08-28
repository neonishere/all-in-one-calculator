import 'package:flutter/material.dart';

import '../../shared/widgets/method_picker.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/solution_button.dart';
import '../../shared/widgets/tool_scaffold.dart';

enum _Method { discount, increase, fromAtoB, ofAfromB }

class PercentageScreen extends StatefulWidget {
  const PercentageScreen({super.key});

  @override
  State<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends State<PercentageScreen> {
  _Method _method = _Method.discount;
  final _aController = TextEditingController();
  final _bController = TextEditingController();

  double? get _a => double.tryParse(_aController.text);
  double? get _b => double.tryParse(_bController.text);

  static final _options = [
    const MethodOption(value: _Method.discount, title: 'Discount', subtitle: 'a - x% = b', icon: Icons.remove_circle_outline),
    const MethodOption(value: _Method.increase, title: 'Increase', subtitle: 'a + x% = b', icon: Icons.add_circle_outline),
    const MethodOption(value: _Method.fromAtoB, title: 'Percent from A to B', subtitle: 'a → b = x%', icon: Icons.trending_up),
    const MethodOption(value: _Method.ofAfromB, title: 'Percent of A from B', subtitle: 'a ← b = x%', icon: Icons.trending_down),
  ];

  @override
  Widget build(BuildContext context) {
    final a = _a;
    final b = _b;
    double? result;
    double? delta;
    final steps = <String>[];

    switch (_method) {
      case _Method.discount:
        if (a != null && b != null) {
          result = a - a * b / 100;
          delta = a - result;
          steps.addAll(['b = a - a × x%', '= $a - $a × $b%', '= ${result.toStringAsFixed(2)}']);
        }
      case _Method.increase:
        if (a != null && b != null) {
          result = a + a * b / 100;
          delta = result - a;
          steps.addAll(['b = a + a × x%', '= $a + $a × $b%', '= ${result.toStringAsFixed(2)}']);
        }
      case _Method.fromAtoB:
        if (a != null && a != 0 && b != null) {
          result = (b - a) / a * 100;
          steps.addAll(['x% = [[b - a/a]] × 100', '= [[$b - $a/$a]] × 100', '= ${result.toStringAsFixed(2)}%']);
        }
      case _Method.ofAfromB:
        if (a != null && b != null && b != 0) {
          result = a / b * 100;
          steps.addAll(['x% = [[a/b]] × 100', '= [[$a/$b]] × 100', '= ${result.toStringAsFixed(2)}%']);
        }
    }

    final (labelA, labelB) = switch (_method) {
      _Method.discount || _Method.increase => ('Value', 'Percent'),
      _Method.fromAtoB || _Method.ofAfromB => ('A', 'B'),
    };
    final suffixB = switch (_method) {
      _Method.discount || _Method.increase => '%',
      _ => null,
    };

    return ToolScaffold(
      title: 'Percentage',
      children: [
        MethodPicker<_Method>(
          label: 'Method',
          options: _options,
          selected: _method,
          onChanged: (v) => setState(() => _method = v),
          style: MethodPickerStyle.menu,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: NumberField(label: labelA, controller: _aController, allowNegative: true, onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(child: NumberField(label: labelB, controller: _bController, allowNegative: true, suffix: suffixB, onChanged: (_) => setState(() {}))),
          ],
        ),
        ResultCard(rows: [
          if (_method == _Method.discount || _Method.increase == _method) ...[
            ('Final value', result == null ? '--' : result.toStringAsFixed(2)),
            (_method == _Method.discount ? 'Discount' : 'Increase', delta == null ? '--' : delta.toStringAsFixed(2)),
          ] else
            ('Percent', result == null ? '--' : '${result.toStringAsFixed(2)}%'),
        ]),
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Percentage'),
      ],
    );
  }
}
