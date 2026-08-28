import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/method_picker.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/tool_scaffold.dart';

const _boolOptions = [
  MethodOption(value: false, title: 'No', icon: Icons.close),
  MethodOption(value: true, title: 'Yes', icon: Icons.check),
];

class NumberGeneratorScreen extends StatefulWidget {
  const NumberGeneratorScreen({super.key});

  @override
  State<NumberGeneratorScreen> createState() => _NumberGeneratorScreenState();
}

class _NumberGeneratorScreenState extends State<NumberGeneratorScreen> {
  final _minController = TextEditingController(text: '1');
  final _maxController = TextEditingController(text: '100');
  final _countController = TextEditingController(text: '1');
  bool _unique = false;
  List<int> _results = [];

  void _generate() {
    final min = int.tryParse(_minController.text);
    final max = int.tryParse(_maxController.text);
    final count = int.tryParse(_countController.text);
    if (min == null || max == null || count == null || max < min || count < 1) return;

    final range = max - min + 1;
    if (_unique && count > range) return;

    final random = Random();
    final results = <int>[];
    if (_unique) {
      final pool = List<int>.generate(range, (i) => min + i)..shuffle(random);
      results.addAll(pool.take(count));
    } else {
      for (var i = 0; i < count; i++) {
        results.add(min + random.nextInt(range));
      }
    }
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Number generator',
      children: [
        Row(
          children: [
            Expanded(child: NumberField(label: 'Min', controller: _minController, allowNegative: true, onChanged: (_) {})),
            const SizedBox(width: 10),
            Expanded(child: NumberField(label: 'Max', controller: _maxController, allowNegative: true, onChanged: (_) {})),
          ],
        ),
        NumberField(label: 'Count', controller: _countController, onChanged: (_) {}),
        MethodPicker<bool>(
          label: 'Unique',
          helperText: 'No repeated values',
          options: _boolOptions,
          selected: _unique,
          onChanged: (v) => setState(() => _unique = v),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _generate,
            child: const Text('Generate'),
          ),
        ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final r in _results)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                    child: Text('$r', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
