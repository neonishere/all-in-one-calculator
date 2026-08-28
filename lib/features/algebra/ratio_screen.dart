import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/method_picker.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_value_card.dart';
import '../../shared/widgets/solution_button.dart';
import '../../shared/widgets/tool_scaffold.dart';

enum _Method { reduction, deduction }

class RatioScreen extends StatefulWidget {
  const RatioScreen({super.key});

  @override
  State<RatioScreen> createState() => _RatioScreenState();
}

class _RatioScreenState extends State<RatioScreen> {
  _Method _method = _Method.reduction;
  final _xController = TextEditingController();
  final _yController = TextEditingController();
  final _aController = TextEditingController();
  final _bController = TextEditingController();

  static final _options = [
    const MethodOption(value: _Method.reduction, title: 'Reduction', subtitle: 'a/b → x/y', icon: Icons.call_received),
    const MethodOption(value: _Method.deduction, title: 'Deduction', subtitle: 'x/y → a/b', icon: Icons.call_made),
  ];

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  void _onValueChanged(TextEditingController edited, TextEditingController other) {
    final x = double.tryParse(_xController.text);
    final y = double.tryParse(_yController.text);
    final value = double.tryParse(edited.text);
    if (x == null || y == null || x == 0 || value == null) {
      setState(() {});
      return;
    }
    final isA = identical(edited, _aController);
    other.text = (isA ? value * y / x : value * x / y).toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    final steps = <String>[];

    Widget valuesFields;
    if (_method == _Method.reduction) {
      String? simplified;
      if (a != null && b != null && a != 0 && b != 0 && a == a.roundToDouble() && b == b.roundToDouble()) {
        final g = _gcd(a.abs().round(), b.abs().round());
        final x = a.round() ~/ g;
        final y = b.round() ~/ g;
        simplified = '$x : $y';
        steps.addAll(['GCF($a, $b) = $g', '[[${a.round()}/$g]] : [[${b.round()}/$g]]', '= $simplified']);
        _xController.text = x.toString();
        _yController.text = y.toString();
      } else {
        _xController.clear();
        _yController.clear();
      }
      valuesFields = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Values', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: NumberField(label: 'A', controller: _aController, allowNegative: true, onChanged: (_) => setState(() {}))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(':')),
              Expanded(child: NumberField(label: 'B', controller: _bController, allowNegative: true, onChanged: (_) => setState(() {}))),
            ],
          ),
        ],
      );
    } else {
      valuesFields = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Values', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: NumberField(label: 'A', controller: _aController, allowNegative: true, onChanged: (_) => _onValueChanged(_aController, _bController))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(':')),
              Expanded(child: NumberField(label: 'B', controller: _bController, allowNegative: true, onChanged: (_) => _onValueChanged(_bController, _aController))),
            ],
          ),
        ],
      );
      final x = double.tryParse(_xController.text);
      final y = double.tryParse(_yController.text);
      if (x != null && y != null && x != 0 && a != null) {
        steps.addAll(['[[x/y]] → [[a/b]]', 'b = [[a × y/x]]', '= [[$a × $y/$x]]', '= ${(a * y / x).toStringAsFixed(2)}']);
      }
    }

    final ratioFields = _labeledPair('Ratio', _xController, 'X', _yController, 'Y', enabled: _method == _Method.deduction);

    return ToolScaffold(
      title: 'Ratio',
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
            _method == _Method.reduction ? 'Find the ratio of two values' : 'Find the missing value based on a ratio',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        if (_method == _Method.deduction) ...[ratioFields, const SizedBox(height: 16), valuesFields] else ...[valuesFields, const SizedBox(height: 16), ratioFields],
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Ratio'),
      ],
    );
  }

  Widget _labeledPair(
    String label,
    TextEditingController first,
    String firstLabel,
    TextEditingController second,
    String secondLabel, {
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: enabled
                  ? NumberField(label: firstLabel, controller: first, allowNegative: true, onChanged: (_) => setState(() {}))
                  : ResultValueCard(value: double.tryParse(first.text)),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text(':')),
            Expanded(
              child: enabled
                  ? NumberField(label: secondLabel, controller: second, allowNegative: true, onChanged: (_) => setState(() {}))
                  : ResultValueCard(value: double.tryParse(second.text)),
            ),
          ],
        ),
      ],
    );
  }
}
