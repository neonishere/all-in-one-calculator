import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/method_picker.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

enum _Input { radius, diameter, area, circumference }

class CircleScreen extends StatefulWidget {
  const CircleScreen({super.key});

  @override
  State<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends State<CircleScreen> {
  _Input _input = _Input.radius;
  final _controller = TextEditingController();

  static final _options = [
    const MethodOption(value: _Input.radius, title: 'Radius', icon: Icons.radio_button_unchecked),
    const MethodOption(value: _Input.diameter, title: 'Diameter', icon: Icons.remove_circle_outline),
    const MethodOption(value: _Input.area, title: 'Area', icon: Icons.circle),
    const MethodOption(value: _Input.circumference, title: 'Circumference', icon: Icons.circle_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(_controller.text);
    double? r;
    final steps = <String>[];

    if (value != null && value > 0) {
      switch (_input) {
        case _Input.radius:
          r = value;
          steps.add('r = $value');
        case _Input.diameter:
          r = value / 2;
          steps.add('r = [[d/2]] = ${r.toStringAsFixed(2)}');
        case _Input.area:
          r = math.sqrt(value / math.pi);
          steps.add('r = √[[A/π]] = ${r.toStringAsFixed(2)}');
        case _Input.circumference:
          r = value / (2 * math.pi);
          steps.add('r = [[C/2π]] = ${r.toStringAsFixed(2)}');
      }
    }

    final diameter = r == null ? null : r * 2;
    final area = r == null ? null : math.pi * r * r;
    final circumference = r == null ? null : 2 * math.pi * r;

    return Scaffold(
      appBar: AppBar(title: const Text('Circle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 180, child: Center(child: ShapeIcon(kind: ShapeKind.circle, size: 120, color: AppColors.textSecondary, showRadius: true))),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: MethodPicker<_Input>(label: 'Input', options: _options, selected: _input, onChanged: (v) => setState(() => _input = v), style: MethodPickerStyle.menu),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: NumberField(label: '', controller: _controller, onChanged: (_) => setState(() {})),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a circle knowing one dimension', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              if (_input != _Input.diameter) ('Diameter', diameter == null ? '--' : diameter.toStringAsFixed(2)),
              if (_input != _Input.area) ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              if (_input != _Input.circumference) ('Circumference', circumference == null ? '--' : circumference.toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Circle'),
          ],
        ),
      ),
    );
  }
}
