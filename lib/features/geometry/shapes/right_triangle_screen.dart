import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/clear_screen_action.dart';
import '../../../shared/widgets/method_picker.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_value_field.dart';
import '../../../shared/widgets/solution_button.dart';
import '../../../shared/widgets/unresolvable_card.dart';
import 'right_triangle/right_triangle_diagram.dart';
import 'right_triangle/right_triangle_glyph.dart';

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
    const MethodOption(value: 'sideA', title: 'Side', subtitle: 'A'),
    const MethodOption(value: 'sideB', title: 'Side', subtitle: 'B'),
    const MethodOption(value: 'hyp', title: 'Hypotenuse'),
    const MethodOption(value: 'angleA', title: 'Angle', subtitle: 'A'),
    const MethodOption(value: 'angleB', title: 'Angle', subtitle: 'B'),
  ];

  static const _titles = {
    'sideA': 'Side: A',
    'sideB': 'Side: B',
    'hyp': 'Hypotenuse',
    'angleA': 'Angle: A',
    'angleB': 'Angle: B',
  };

  Widget _pickerGlyph(String value) {
    switch (value) {
      case 'sideA':
        return const RightTriangleGlyph(size: 26, highlightSide: RtSide.a);
      case 'sideB':
        return const RightTriangleGlyph(size: 26, highlightSide: RtSide.b);
      case 'hyp':
        return const RightTriangleGlyph(size: 26, highlightSide: RtSide.hyp);
      case 'angleA':
        return const RightTriangleGlyph(size: 26, angleVertex: RtVertex.t);
      case 'angleB':
      default:
        return const RightTriangleGlyph(size: 26, angleVertex: RtVertex.br);
    }
  }

  bool get _hasAnyValue => _value1.text.isNotEmpty || _value2.text.isNotEmpty;

  void _clearAll() {
    setState(() {
      _value1.clear();
      _value2.clear();
    });
  }

  double _deg(double radians) => radians * 180 / math.pi;
  double _rad(double degrees) => degrees * math.pi / 180;

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  /// The arctan derivation for the angle at [label]'s vertex, opposite
  /// [oppLabel] and adjacent to [adjLabel]: formula, substitution, decimal
  /// ratio, radians/π, then the bold final degree value.
  List<String> _angleSteps(String label, String oppLabel, double opp, String adjLabel, double adj, double angleDeg) {
    final radians = math.atan2(opp, adj);
    return [
      '\\text{Angle } $label = \\frac{\\arctan\\left(\\frac{$oppLabel}{$adjLabel}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arctan\\left(\\frac{${_fmt(opp)}}{${_fmt(adj)}}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arctan(${(opp / adj).toStringAsFixed(2)})}{\\pi}\\times 180',
      '= \\frac{${radians.toStringAsFixed(2)}}{\\pi}\\times 180',
      '= ${(radians / math.pi).toStringAsFixed(2)}\\times 180',
      '{{= ${_fmt(angleDeg)}}}',
    ];
  }

  List<String> _buildSteps(Map<String, double> result) {
    final a = result['sideA']!;
    final b = result['sideB']!;
    final hyp = result['hyp']!;
    final area = a * b / 2;
    final perimeter = a + b + hyp;
    return [
      '\\text{Side } A = ${_fmt(a)}',
      '\\text{Side } B = ${_fmt(b)}',
      '',
      '\\text{Hypotenuse} = \\sqrt{A^2+B^2}',
      '= \\sqrt{${_fmt(a)}^2+${_fmt(b)}^2}',
      '= \\sqrt{${_fmt(a * a)}+${_fmt(b * b)}}',
      '= \\sqrt{${_fmt(a * a + b * b)}}',
      '{{= ${_fmt(hyp)}}}',
      '',
      '\\text{Area} = \\frac{A\\times B}{2}',
      '= \\frac{${_fmt(a)}\\times ${_fmt(b)}}{2}',
      '= \\frac{${_fmt(a * b)}}{2}',
      '{{= ${_fmt(area)}}}',
      '',
      '\\text{Perimeter} = A+B+\\text{Hyp}',
      '= ${_fmt(a)}+${_fmt(b)}+${_fmt(hyp)}',
      '{{= ${_fmt(perimeter)}}}',
      '',
      ..._angleSteps('A', 'B', b, 'A', a, result['angleA']!),
      '',
      ..._angleSteps('B', 'A', a, 'B', b, result['angleB']!),
    ];
  }

  Map<String, double>? _solve() {
    final v1 = double.tryParse(_value1.text);
    final v2 = double.tryParse(_value2.text);
    if (v1 == null || v2 == null || _kind1 == _kind2) return null;

    // Internally, angleADeg is the angle at the bottom-right vertex (opposite
    // side A, adjacent to side B) — the shape's "Angle: B" per the diagram
    // (top vertex = Angle: A, bottom-right vertex = Angle: B), so the two
    // user-facing angle inputs map onto it in swapped form.
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
          angleADeg = 90 - v;
        case 'angleB':
          angleADeg = v;
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
    return {'sideA': a!, 'sideB': b!, 'hyp': hyp!, 'angleA': 90 - angleADeg!, 'angleB': angleADeg!};
  }

  @override
  Widget build(BuildContext context) {
    final result = _solve();
    final hasBothValues = double.tryParse(_value1.text) != null && double.tryParse(_value2.text) != null;
    final unresolved = hasBothValues && result == null;
    final steps = result == null ? <String>[] : _buildSteps(result);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Right triangle'),
        actions: [ClearScreenAction(visible: _hasAnyValue, onConfirmed: _clearAll)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(child: RightTriangleDiagram(size: 150)),
            const SizedBox(height: 12),
            _inputRow(_kind1, _value1, (v) => setState(() => _kind1 = v)),
            const SizedBox(height: 12),
            _inputRow(_kind2, _value2, (v) => setState(() => _kind2 = v)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a right triangle knowing two dimensions', style: TextStyle(color: AppColors.textSecondary)),
            ),
            if (unresolved)
              const UnresolvableCard(message: "Can't resolve triangle")
            else
              ResultCard(
                rows: [
                  ('Hypotenuse', result == null ? '--' : result['hyp']!.toStringAsFixed(2)),
                  ('Angle: A', result == null ? '--' : '${result['angleA']!.toStringAsFixed(2)}°'),
                  ('Angle: B', result == null ? '--' : '${result['angleB']!.toStringAsFixed(2)}°'),
                  ('Area', result == null ? '--' : (result['sideA']! * result['sideB']! / 2).toStringAsFixed(2)),
                  ('Perimeter', result == null ? '--' : (result['sideA']! + result['sideB']! + result['hyp']!).toStringAsFixed(2)),
                ],
                leadingIcons: const [
                  RightTriangleGlyph(size: 24, highlightSide: RtSide.hyp),
                  RightTriangleGlyph(size: 24, angleVertex: RtVertex.t),
                  RightTriangleGlyph(size: 24, angleVertex: RtVertex.br),
                  RightTriangleGlyph(size: 24, filled: true),
                  RightTriangleGlyph(size: 24, allAccent: true),
                ],
              ),
            SolutionButton(steps: steps, title: 'Right triangle'),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(String kind, TextEditingController controller, ValueChanged<String> onKindChanged) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: MethodPicker<String>(
              label: '',
              options: _options,
              selected: kind,
              onChanged: onKindChanged,
              style: MethodPickerStyle.menu,
              leadingBuilder: _pickerGlyph,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ShapeValueField(
              controller: controller,
              placeholder: '--',
              popupTitle: _titles[kind] ?? 'Value',
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}
