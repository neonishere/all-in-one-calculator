import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/method_picker.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/solution_button.dart';
import '../../shared/widgets/tool_scaffold.dart';

const _boolOptions = [
  MethodOption(value: false, title: 'No', icon: Icons.close),
  MethodOption(value: true, title: 'Yes', icon: Icons.check),
];

class CombinationsScreen extends StatefulWidget {
  const CombinationsScreen({super.key});

  @override
  State<CombinationsScreen> createState() => _CombinationsScreenState();
}

class _CombinationsScreenState extends State<CombinationsScreen> {
  final _nController = TextEditingController();
  final _rController = TextEditingController();
  bool _ordered = false;
  bool _repeatable = false;

  double _factorial(int v) {
    var result = 1.0;
    for (var i = 2; i <= v; i++) {
      result *= i;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final n = int.tryParse(_nController.text);
    final r = int.tryParse(_rController.text);

    double? result;
    final steps = <String>[];
    if (n != null && r != null && n >= 0 && r >= 0 && (_repeatable || r <= n)) {
      if (!_ordered && !_repeatable) {
        result = _factorial(n) / (_factorial(r) * _factorial(n - r));
        steps.add('C(n, r) = [[n!/r! × (n-r)!]]');
      } else if (_ordered && !_repeatable) {
        result = _factorial(n) / _factorial(n - r);
        steps.add('P(n, r) = [[n!/(n-r)!]]');
      } else if (!_ordered && _repeatable) {
        result = _factorial(n + r - 1) / (_factorial(r) * _factorial(n - 1));
        steps.add('C(n+r-1, r) = [[(n+r-1)!/r! × (n-1)!]]');
      } else {
        result = _pow(n, r);
        steps.add('n^r');
      }
      steps.add('= ${result.toStringAsFixed(0)}');
    }

    return ToolScaffold(
      title: 'Combinations',
      children: [
        Text('Total count', style: Theme.of(context).textTheme.labelLarge),
        Text('Options to choose from', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        NumberField(label: 'N', controller: _nController, onChanged: (_) => setState(() {})),
        Text('Set size', style: Theme.of(context).textTheme.labelLarge),
        Text('Amount chosen', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        NumberField(label: 'R', controller: _rController, onChanged: (_) => setState(() {})),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MethodPicker<bool>(
                label: 'Ordered',
                helperText: 'Is order important?',
                options: _boolOptions,
                selected: _ordered,
                onChanged: (v) => setState(() => _ordered = v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MethodPicker<bool>(
                label: 'Repeatable',
                helperText: 'Is repetition allowed?',
                options: _boolOptions,
                selected: _repeatable,
                onChanged: (v) => setState(() => _repeatable = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ResultCard(rows: [('Combinations', result == null ? '--' : result.toStringAsFixed(0))]),
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Combinations'),
      ],
    );
  }

  double _pow(int base, int exp) {
    var result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
