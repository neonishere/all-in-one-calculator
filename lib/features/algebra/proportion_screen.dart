import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/method_picker.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_value_card.dart';
import '../../shared/widgets/solution_button.dart';
import '../../shared/widgets/tool_scaffold.dart';

enum _Method { direct, inverse }

class ProportionScreen extends StatefulWidget {
  const ProportionScreen({super.key});

  @override
  State<ProportionScreen> createState() => _ProportionScreenState();
}

class _ProportionScreenState extends State<ProportionScreen> {
  _Method _method = _Method.direct;
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _xController = TextEditingController();

  static final _options = [
    const MethodOption(
      value: _Method.direct,
      title: 'Directly proportional',
      subtitle: 'a/b = x/y',
      icon: Icons.grid_view,
    ),
    const MethodOption(
      value: _Method.inverse,
      title: 'Inversely proportional',
      subtitle: 'a/y = x/b',
      icon: Icons.grid_view,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    final x = double.tryParse(_xController.text);

    double? y;
    final steps = <String>[];
    if (a != null && a != 0 && b != null && x != null) {
      if (_method == _Method.direct) {
        y = x * b / a;
        steps.addAll(['[[a/b]] = [[x/y]]', 'y = [[x × b/a]]', '= [[$x × $b/$a]]', '= ${y.toStringAsFixed(2)}']);
      } else {
        y = a * b / x;
        if (x == 0) {
          y = null;
        } else {
          steps.addAll(['[[a/y]] = [[x/b]]', 'y = [[a × b/x]]', '= [[$a × $b/$x]]', '= ${y.toStringAsFixed(2)}']);
        }
      }
    }

    return ToolScaffold(
      title: 'Proportion',
      children: [
        MethodPicker<_Method>(
          label: 'Method',
          options: _options,
          selected: _method,
          onChanged: (v) => setState(() => _method = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            _method == _Method.direct
                ? 'When the condition changes, the result changes at the same rate, in the same direction'
                : 'When the condition changes, the result changes at the same rate, in the opposite direction',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text('Condition', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: NumberField(label: 'A', controller: _aController, allowNegative: true, onChanged: (_) => setState(() {}))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward)),
            Expanded(child: NumberField(label: 'B', controller: _bController, allowNegative: true, onChanged: (_) => setState(() {}))),
          ],
        ),
        const SizedBox(height: 8),
        Text('Result', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: NumberField(label: 'X', controller: _xController, allowNegative: true, onChanged: (_) => setState(() {}))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward)),
            Expanded(child: ResultValueCard(value: y)),
          ],
        ),
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Proportion'),
      ],
    );
  }
}
