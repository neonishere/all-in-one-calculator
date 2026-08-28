import 'package:flutter/material.dart';

import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/solution_button.dart';
import '../../shared/widgets/tool_scaffold.dart';
import '../../shared/widgets/value_list_editor.dart';

class GcfLcmScreen extends StatefulWidget {
  const GcfLcmScreen({super.key});

  @override
  State<GcfLcmScreen> createState() => _GcfLcmScreenState();
}

class _GcfLcmScreenState extends State<GcfLcmScreen> {
  List<int> _values = [];

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
  int _lcm(int a, int b) => a ~/ _gcd(a, b) * b;

  @override
  Widget build(BuildContext context) {
    int? gcf;
    int? lcm;
    final steps = <String>[];
    if (_values.length >= 2 && _values.every((v) => v != 0)) {
      gcf = _values.map((v) => v.abs()).reduce(_gcd);
      lcm = _values.map((v) => v.abs()).reduce(_lcm);
      steps.addAll([
        'Values: ${_values.join(', ')}',
        'GCF = ${_values.map((v) => v.abs()).join(' gcd ')} = $gcf',
        'LCM = ${_values.map((v) => v.abs()).join(' lcm ')} = $lcm',
      ]);
    }

    return ToolScaffold(
      title: 'GCF & LCM',
      children: [
        Text('Values', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ValueListEditor(
          onChanged: (values) => setState(
            () => _values = values.whereType<double>().map((v) => v.round()).toList(),
          ),
        ),
        ResultCard(rows: [
          ('GCF', gcf?.toString() ?? '--'),
          ('LCM', lcm?.toString() ?? '--'),
        ]),
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'GCF & LCM'),
      ],
    );
  }
}
