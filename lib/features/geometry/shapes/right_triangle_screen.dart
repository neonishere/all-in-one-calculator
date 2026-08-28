import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/method_picker.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

class RightTriangleScreen extends StatefulWidget {
  const RightTriangleScreen({super.key});

  @override
  State<RightTriangleScreen> createState() => _RightTriangleScreenState();
}

class _RightTriangleScreenState extends State<RightTriangleScreen> {
  String _kind1 = 'sideA';
  String _kind2 = 'sideB';
  final _value1 = TextEditingController();
  final _value2 = TextEditingController();

  static final _options = [
    const MethodOption(value: 'sideA', title: 'Side', subtitle: 'A', icon: Icons.change_history),
    const MethodOption(value: 'sideB', title: 'Side', subtitle: 'B', icon: Icons.change_history),
    const MethodOption(value: 'hyp', title: 'Hypotenuse', icon: Icons.change_history),
    const MethodOption(value: 'angleA', title: 'Angle', subtitle: 'A', icon: Icons.architecture),
    const MethodOption(value: 'angleB', title: 'Angle', subtitle: 'B', icon: Icons.architecture),
  ];

  double _deg(double radians) => radians * 180 / math.pi;
  double _rad(double degrees) => degrees * math.pi / 180;

  Map<String, double>? _solve() {
    final v1 = double.tryParse(_value1.text);
    final v2 = double.tryParse(_value2.text);
    if (v1 == null || v2 == null || _kind1 == _kind2) return null;

    double? a, b, hyp, angleADeg;
    void apply(String kind, double v) {
      switch (kind) {
        case 'sideA':
          a = v;
        case 'sideB':
          b = v;
        case 'hyp':
          hyp = v;
        case 'angleA':
          angleADeg = v;
        case 'angleB':
          angleADeg = 90 - v;
      }
    }

    apply(_kind1, v1);
    apply(_kind2, v2);
    final angleA = angleADeg != null ? _rad(angleADeg!) : null;

    if (a != null && b != null) {
      hyp = math.sqrt(a! * a! + b! * b!);
      angleADeg = _deg(math.atan2(a!, b!));
    } else if (a != null && hyp != null) {
      if (hyp! <= a!) return null;
      b = math.sqrt(hyp! * hyp! - a! * a!);
      angleADeg = _deg(math.asin(a! / hyp!));
    } else if (b != null && hyp != null) {
      if (hyp! <= b!) return null;
      a = math.sqrt(hyp! * hyp! - b! * b!);
      angleADeg = _deg(math.asin(a! / hyp!));
    } else if (a != null && angleA != null) {
      b = a! / math.tan(angleA);
      hyp = a! / math.sin(angleA);
    } else if (b != null && angleA != null) {
      a = b! * math.tan(angleA);
      hyp = b! / math.cos(angleA);
    } else if (hyp != null && angleA != null) {
      a = hyp! * math.sin(angleA);
      b = hyp! * math.cos(angleA);
    } else {
      return null;
    }

    angleADeg ??= _deg(math.atan2(a!, b!));
    if (a! <= 0 || b! <= 0 || hyp! <= 0) return null;
    return {'sideA': a!, 'sideB': b!, 'hyp': hyp!, 'angleA': angleADeg!, 'angleB': 90 - angleADeg!};
  }

  @override
  Widget build(BuildContext context) {
    final result = _solve();
    final steps = result == null
        ? <String>[]
        : [
            'Hypotenuse = √(A² + B²) = ${result['hyp']!.toStringAsFixed(2)}',
            'Angle A = ${result['angleA']!.toStringAsFixed(2)}°, Angle B = ${result['angleB']!.toStringAsFixed(2)}°',
          ];

    return Scaffold(
      appBar: AppBar(title: const Text('Right triangle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 180, child: Center(child: ShapeIcon(kind: ShapeKind.rightTriangle, size: 130, color: AppColors.textSecondary))),
            const SizedBox(height: 12),
            _inputRow(_kind1, _value1, (v) => setState(() => _kind1 = v)),
            const SizedBox(height: 12),
            _inputRow(_kind2, _value2, (v) => setState(() => _kind2 = v)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a right triangle knowing two dimensions', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ResultCard(rows: [
              ('Hypotenuse', result == null ? '--' : result['hyp']!.toStringAsFixed(2)),
              ('Angle: A', result == null ? '--' : '${result['angleA']!.toStringAsFixed(2)}°'),
              ('Angle: B', result == null ? '--' : '${result['angleB']!.toStringAsFixed(2)}°'),
              ('Area', result == null ? '--' : (result['sideA']! * result['sideB']! / 2).toStringAsFixed(2)),
              ('Perimeter', result == null ? '--' : (result['sideA']! + result['sideB']! + result['hyp']!).toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps, title: 'Right triangle'),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(String kind, TextEditingController controller, ValueChanged<String> onKindChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: MethodPicker<String>(label: '', options: _options, selected: kind, onChanged: onKindChanged, style: MethodPickerStyle.menu)),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: NumberField(label: '', controller: controller, allowNegative: false, onChanged: (_) => setState(() {}))),
      ],
    );
  }
}
