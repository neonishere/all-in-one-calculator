import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/method_picker.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/solution_button.dart';
import '../../shared/widgets/tool_scaffold.dart';

enum _Method { linear, quadratic, system }

class EquationsScreen extends StatefulWidget {
  const EquationsScreen({super.key});

  @override
  State<EquationsScreen> createState() => _EquationsScreenState();
}

class _EquationsScreenState extends State<EquationsScreen> {
  _Method _method = _Method.linear;
  int _systemSize = 2;
  final _controllers = {
    for (final k in ['a', 'b', 'c'])
      k: TextEditingController(),
    for (final row in [1, 2, 3])
      for (final col in ['a', 'b', 'c', 'd'])
        '$col$row': TextEditingController(),
  };

  static final _methodOptions = [
    const MethodOption(value: _Method.linear, title: 'Linear equation', subtitle: 'Ax + B = 0', icon: Icons.timeline),
    const MethodOption(value: _Method.quadratic, title: 'Quadratic equation', subtitle: 'Ax² + Bx + C = 0', icon: Icons.show_chart),
    const MethodOption(value: _Method.system, title: 'Equation system', subtitle: 'Two or more variables', icon: Icons.grid_on),
  ];

  static const _sizeOptions = [
    MethodOption(value: 2, title: 'Two variables', subtitle: 'Find x & y', icon: Icons.grid_view),
    MethodOption(value: 3, title: 'Three variables', subtitle: 'Find x, y & z', icon: Icons.apps),
  ];

  double? _v(String key) => double.tryParse(_controllers[key]!.text);

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Equations',
      children: [
        MethodPicker<_Method>(
          label: 'Method',
          options: _methodOptions,
          selected: _method,
          onChanged: (v) => setState(() => _method = v),
          style: MethodPickerStyle.menu,
        ),
        const SizedBox(height: 16),
        switch (_method) {
          _Method.linear => _linear(),
          _Method.quadratic => _quadratic(),
          _Method.system => _system(),
        },
      ],
    );
  }

  Widget _field(String key, String label) {
    return Expanded(
      child: NumberField(label: label, controller: _controllers[key]!, allowNegative: true, onChanged: (_) => setState(() {})),
    );
  }

  Widget _linear() {
    final a = _v('a');
    final b = _v('b');
    double? x;
    final steps = <String>[];
    if (a != null && a != 0 && b != null) {
      x = -b / a;
      steps.addAll(['Ax + B = 0', 'x = [[-B/A]]', '= [[-$b/$a]]', '= ${x.toStringAsFixed(4)}']);
    }
    return Column(
      children: [
        Row(children: [_field('a', 'A'), const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('x +')), _field('b', 'B')]),
        ResultCard(rows: [('X', x == null ? '--' : x.toStringAsFixed(4))]),
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Linear equation'),
      ],
    );
  }

  Widget _quadratic() {
    final a = _v('a');
    final b = _v('b');
    final c = _v('c');
    String x1 = '--';
    String x2 = '--';
    final steps = <String>[];
    if (a != null && a != 0 && b != null && c != null) {
      final discriminant = b * b - 4 * a * c;
      steps.addAll(['Δ = B² - 4AC', '= ${b * b} - 4×$a×$c', '= ${discriminant.toStringAsFixed(2)}']);
      if (discriminant < 0) {
        x1 = x2 = 'No real roots';
      } else if (discriminant == 0) {
        final root = -b / (2 * a);
        x1 = x2 = root.toStringAsFixed(4);
        steps.add('x = [[-B/2A]] = ${root.toStringAsFixed(4)}');
      } else {
        final sqrtD = math.sqrt(discriminant);
        final r1 = (-b + sqrtD) / (2 * a);
        final r2 = (-b - sqrtD) / (2 * a);
        x1 = r1.toStringAsFixed(4);
        x2 = r2.toStringAsFixed(4);
        steps.add('x = [[-B ± √Δ/2A]] = $x1, $x2');
      }
    }
    return Column(
      children: [
        Row(children: [
          _field('a', 'A'),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('x² +')),
          _field('b', 'B'),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('x +')),
          _field('c', 'C'),
        ]),
        ResultCard(rows: [('X₁', x1), ('X₂', x2)]),
        SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Quadratic equation'),
      ],
    );
  }

  Widget _system() {
    return Column(
      children: [
        MethodPicker<int>(
          label: 'Size',
          options: _sizeOptions,
          selected: _systemSize,
          onChanged: (v) => setState(() => _systemSize = v),
        ),
        const SizedBox(height: 16),
        Text('Calculate', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (_systemSize == 2) ..._system2() else ..._system3(),
      ],
    );
  }

  List<Widget> _system2() {
    final a1 = _v('a1');
    final b1 = _v('b1');
    final d1 = _v('d1');
    final a2 = _v('a2');
    final b2 = _v('b2');
    final d2 = _v('d2');
    double? x;
    double? y;
    final steps = <String>[];
    if (a1 != null && b1 != null && d1 != null && a2 != null && b2 != null && d2 != null) {
      final det = a1 * b2 - a2 * b1;
      if (det != 0) {
        x = (d1 * b2 - d2 * b1) / det;
        y = (a1 * d2 - a2 * d1) / det;
        steps.addAll([
          'det = A₁B₂ - A₂B₁ = ${det.toStringAsFixed(4)}',
          'x = [[C₁B₂ - C₂B₁/det]] = ${x.toStringAsFixed(4)}',
          'y = [[A₁C₂ - A₂C₁/det]] = ${y.toStringAsFixed(4)}',
        ]);
      }
    }
    return [
      _systemRow(['a1', 'b1'], 'd1'),
      const SizedBox(height: 10),
      _systemRow(['a2', 'b2'], 'd2'),
      ResultCard(rows: [
        ('X', x == null ? '--' : x.toStringAsFixed(4)),
        ('Y', y == null ? '--' : y.toStringAsFixed(4)),
      ]),
      SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Equation system'),
    ];
  }

  List<Widget> _system3() {
    final rows = [
      [_v('a1'), _v('b1'), _v('c1'), _v('d1')],
      [_v('a2'), _v('b2'), _v('c2'), _v('d2')],
      [_v('a3'), _v('b3'), _v('c3'), _v('d3')],
    ];
    double? x, y, z;
    final steps = <String>[];
    if (rows.every((row) => row.every((v) => v != null))) {
      final m = rows.map((r) => r.sublist(0, 3).cast<double>()).toList();
      final d = rows.map((r) => r[3]!).toList();
      final det = _det3(m);
      if (det != 0) {
        final mx = [
          [d[0], m[0][1], m[0][2]],
          [d[1], m[1][1], m[1][2]],
          [d[2], m[2][1], m[2][2]],
        ];
        final my = [
          [m[0][0], d[0], m[0][2]],
          [m[1][0], d[1], m[1][2]],
          [m[2][0], d[2], m[2][2]],
        ];
        final mz = [
          [m[0][0], m[0][1], d[0]],
          [m[1][0], m[1][1], d[1]],
          [m[2][0], m[2][1], d[2]],
        ];
        x = _det3(mx) / det;
        y = _det3(my) / det;
        z = _det3(mz) / det;
        steps.addAll([
          'det = ${det.toStringAsFixed(4)}',
          'x = [[detX/det]] = ${x.toStringAsFixed(4)}',
          'y = [[detY/det]] = ${y.toStringAsFixed(4)}',
          'z = [[detZ/det]] = ${z.toStringAsFixed(4)}',
        ]);
      }
    }
    return [
      _systemRow(['a1', 'b1', 'c1'], 'd1'),
      const SizedBox(height: 10),
      _systemRow(['a2', 'b2', 'c2'], 'd2'),
      const SizedBox(height: 10),
      _systemRow(['a3', 'b3', 'c3'], 'd3'),
      ResultCard(rows: [
        ('X', x == null ? '--' : x.toStringAsFixed(4)),
        ('Y', y == null ? '--' : y.toStringAsFixed(4)),
        ('Z', z == null ? '--' : z.toStringAsFixed(4)),
      ]),
      SolutionButton(steps: steps.isEmpty ? null : steps, title: 'Equation system'),
    ];
  }

  Widget _systemRow(List<String> coefficientKeys, String resultKey) {
    const varNames = ['x', 'y', 'z'];
    final widgets = <Widget>[];
    for (var i = 0; i < coefficientKeys.length; i++) {
      widgets.add(_field(coefficientKeys[i], coefficientKeys[i][0].toUpperCase() + (i + 1).toString()));
      widgets.add(Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(i == coefficientKeys.length - 1 ? '${varNames[i]} =' : '${varNames[i]} +')));
    }
    widgets.add(_field(resultKey, resultKey[0].toUpperCase() + resultKey.substring(1, 2)));
    return Row(children: widgets);
  }

  double _det3(List<List<double>> m) {
    return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
        m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
        m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
  }
}
