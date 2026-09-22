import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/clear_screen_action.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_value_field.dart';
import '../../../shared/widgets/solution_button.dart';
import '../../../shared/widgets/unresolvable_card.dart';
import 'triangle/triangle_diagram.dart';
import 'triangle/triangle_glyph.dart';

class TriangleScreen extends StatefulWidget {
  const TriangleScreen({super.key});

  @override
  State<TriangleScreen> createState() => _TriangleScreenState();
}

class _TriangleScreenState extends State<TriangleScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _cController = TextEditingController();

  double _deg(double radians) => radians * 180 / math.pi;

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  /// The full law-of-cosines derivation for the angle between sides
  /// [xLabel]/[yLabel] (opposite [zLabel]), matching a textbook step chain:
  /// formula, substitution, arithmetic, decimal cosine, radians/π, then
  /// the bold final degree value.
  List<String> _angleSteps(String xyLabel, String xLabel, double x, String yLabel, double y, String zLabel, double z, double angleDeg) {
    final sumSq = x * x + y * y - z * z;
    final denom = 2 * x * y;
    final cosVal = sumSq / denom;
    final radians = math.acos(cosVal);
    return [
      '\\text{Angle } $xyLabel = \\frac{\\arccos\\left(\\frac{$xLabel^2+$yLabel^2-$zLabel^2}{2$xLabel$yLabel}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arccos\\left(\\frac{${_fmt(x)}^2+${_fmt(y)}^2-${_fmt(z)}^2}{2\\times ${_fmt(x)}\\times ${_fmt(y)}}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arccos\\left(\\frac{${_fmt(x * x)}+${_fmt(y * y)}-${_fmt(z * z)}}{${_fmt(denom)}}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arccos\\left(\\frac{${_fmt(sumSq)}}{${_fmt(denom)}}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arccos(${cosVal.toStringAsFixed(2)})}{\\pi}\\times 180',
      '= \\frac{${radians.toStringAsFixed(2)}}{\\pi}\\times 180',
      '= ${(radians / math.pi).toStringAsFixed(2)}\\times 180',
      '{{= ${_fmt(angleDeg)}}}',
    ];
  }

  /// The height-from-area derivation for [sideLabel]: formula, substitution,
  /// simplified numerator, then the bold final value.
  List<String> _heightSteps(String sideLabel, double area, double side, double height) {
    return [
      '\\text{Height } $sideLabel = \\frac{2\\times \\text{Area}}{$sideLabel}',
      '= \\frac{2\\times ${_fmt(area)}}{${_fmt(side)}}',
      '= \\frac{${_fmt(2 * area)}}{${_fmt(side)}}',
      '{{= ${_fmt(height)}}}',
    ];
  }

  bool get _hasAnyValue =>
      _aController.text.isNotEmpty || _bController.text.isNotEmpty || _cController.text.isNotEmpty;

  void _clearAll() {
    setState(() {
      _aController.clear();
      _bController.clear();
      _cController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    final c = double.tryParse(_cController.text);

    double? area, perimeter, angleAB, angleBC, angleAC, heightA, heightB, heightC;
    final steps = <String>[];

    final hasAllInputs = a != null && b != null && c != null;
    final valid = hasAllInputs && a + b > c && a + c > b && b + c > a;
    final unresolved = hasAllInputs && !valid;
    if (valid) {
      perimeter = a + b + c;
      final s = perimeter / 2;
      area = math.sqrt(s * (s - a) * (s - b) * (s - c));
      angleBC = _deg(math.acos((b * b + c * c - a * a) / (2 * b * c)));
      angleAC = _deg(math.acos((a * a + c * c - b * b) / (2 * a * c)));
      angleAB = _deg(math.acos((a * a + b * b - c * c) / (2 * a * b)));
      heightA = 2 * area / a;
      heightB = 2 * area / b;
      heightC = 2 * area / c;

      steps.addAll([
        '\\text{Side } A = ${_fmt(a)}',
        '\\text{Side } B = ${_fmt(b)}',
        '\\text{Side } C = ${_fmt(c)}',
        '',
        'S = \\frac{A+B+C}{2}',
        '= \\frac{${_fmt(a)}+${_fmt(b)}+${_fmt(c)}}{2}',
        '= \\frac{${_fmt(a + b + c)}}{2}',
        '{{= ${_fmt(s)}}}',
        '',
        '\\text{Area} = \\sqrt{S(S-A)(S-B)(S-C)}',
        '= \\sqrt{${_fmt(s)}(${_fmt(s)}-${_fmt(a)})(${_fmt(s)}-${_fmt(b)})(${_fmt(s)}-${_fmt(c)})}',
        '= \\sqrt{${_fmt(s)}\\times ${_fmt(s - a)}\\times ${_fmt(s - b)}\\times ${_fmt(s - c)}}',
        '= \\sqrt{${_fmt(s * (s - a) * (s - b) * (s - c))}}',
        '{{= ${_fmt(area)}}}',
        '',
        '\\text{Perimeter} = A+B+C',
        '= ${_fmt(a)}+${_fmt(b)}+${_fmt(c)}',
        '{{= ${_fmt(perimeter)}}}',
        '',
        ..._angleSteps('BC', 'B', b, 'C', c, 'A', a, angleBC),
        '',
        ..._angleSteps('AC', 'A', a, 'C', c, 'B', b, angleAC),
        '',
        ..._angleSteps('AB', 'A', a, 'B', b, 'C', c, angleAB),
        '',
        ..._heightSteps('A', area, a, heightA),
        '',
        ..._heightSteps('B', area, b, heightB),
        '',
        ..._heightSteps('C', area, c, heightC),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triangle'),
        actions: [ClearScreenAction(visible: _hasAnyValue, onConfirmed: _clearAll)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: Align(alignment: Alignment(0, -0.35), child: TriangleDiagram(size: 132))),
                const SizedBox(width: 10),
                Expanded(
                  child: ShapeValueField(
                    controller: _cController,
                    placeholder: 'C',
                    popupTitle: 'Side: C',
                    glyph: const TriangleGlyph(highlightSide: TriSide.c),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ShapeValueField(
                    controller: _aController,
                    placeholder: 'A',
                    popupTitle: 'Side: A',
                    glyph: const TriangleGlyph(highlightSide: TriSide.a),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ShapeValueField(
                    controller: _bController,
                    placeholder: 'B',
                    popupTitle: 'Side: B',
                    glyph: const TriangleGlyph(highlightSide: TriSide.b),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Solve a triangle knowing its sides', style: TextStyle(color: AppColors.textSecondary)),
            ),
            if (unresolved)
              const UnresolvableCard(message: "Can't resolve triangle")
            else
              ResultCard(
                rows: [
                  ('Area', area == null ? '--' : area.toStringAsFixed(2)),
                  ('Perimeter', perimeter == null ? '--' : perimeter.toStringAsFixed(2)),
                  ('Angle: AB', angleAB == null ? '--' : '${angleAB.toStringAsFixed(2)}°'),
                  ('Angle: BC', angleBC == null ? '--' : '${angleBC.toStringAsFixed(2)}°'),
                  ('Angle: AC', angleAC == null ? '--' : '${angleAC.toStringAsFixed(2)}°'),
                  ('Height: A', heightA == null ? '--' : heightA.toStringAsFixed(2)),
                  ('Height: B', heightB == null ? '--' : heightB.toStringAsFixed(2)),
                  ('Height: C', heightC == null ? '--' : heightC.toStringAsFixed(2)),
                ],
                leadingIcons: const [
                  TriangleGlyph(size: 24, filled: true),
                  TriangleGlyph(size: 24, allAccent: true),
                  TriangleGlyph(size: 24, angleVertex: TriVertex.l),
                  TriangleGlyph(size: 24, angleVertex: TriVertex.r),
                  TriangleGlyph(size: 24, angleVertex: TriVertex.t),
                  TriangleGlyph(size: 24, heightSide: TriSide.a),
                  TriangleGlyph(size: 24, heightSide: TriSide.b),
                  TriangleGlyph(size: 24, heightSide: TriSide.c),
                ],
              ),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Triangle'),
          ],
        ),
      ),
    );
  }
}
