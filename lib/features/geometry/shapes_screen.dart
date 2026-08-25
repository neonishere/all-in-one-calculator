import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

enum _Shape { rectangle, circle, triangle, trapezoid }

class ShapesScreen extends StatefulWidget {
  const ShapesScreen({super.key});

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {
  _Shape _shape = _Shape.rectangle;
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();

  double? _num(TextEditingController c) => double.tryParse(c.text);

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    super.dispose();
  }

  (double?, double?) _compute() {
    final a = _num(_a);
    final b = _num(_b);
    final c = _num(_c);
    switch (_shape) {
      case _Shape.rectangle:
        if (a == null || b == null) return (null, null);
        return (a * b, 2 * (a + b));
      case _Shape.circle:
        if (a == null) return (null, null);
        return (math.pi * a * a, 2 * math.pi * a);
      case _Shape.triangle:
        if (a == null || b == null) return (null, null);
        final area = 0.5 * a * b;
        final perimeter = c != null ? a + b + c : null;
        return (area, perimeter);
      case _Shape.trapezoid:
        if (a == null || b == null || c == null) return (null, null);
        return (0.5 * (a + b) * c, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (area, perimeter) = _compute();

    return ToolScaffold(
      title: 'Shapes',
      children: [
        DropdownButtonFormField<_Shape>(
          initialValue: _shape,
          dropdownColor: AppColors.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: const [
            DropdownMenuItem(value: _Shape.rectangle, child: Text('Rectangle')),
            DropdownMenuItem(value: _Shape.circle, child: Text('Circle')),
            DropdownMenuItem(value: _Shape.triangle, child: Text('Triangle')),
            DropdownMenuItem(value: _Shape.trapezoid, child: Text('Trapezoid')),
          ],
          onChanged: (v) => setState(() => _shape = v!),
        ),
        const SizedBox(height: 14),
        if (_shape == _Shape.rectangle) ...[
          NumberField(label: 'Width', controller: _a, onChanged: (_) => setState(() {})),
          NumberField(label: 'Height', controller: _b, onChanged: (_) => setState(() {})),
        ] else if (_shape == _Shape.circle) ...[
          NumberField(label: 'Radius', controller: _a, onChanged: (_) => setState(() {})),
        ] else if (_shape == _Shape.triangle) ...[
          NumberField(label: 'Base', controller: _a, onChanged: (_) => setState(() {})),
          NumberField(label: 'Height', controller: _b, onChanged: (_) => setState(() {})),
          NumberField(label: 'Third side (optional, for perimeter)', controller: _c, onChanged: (_) => setState(() {})),
        ] else ...[
          NumberField(label: 'Top', controller: _a, onChanged: (_) => setState(() {})),
          NumberField(label: 'Base', controller: _b, onChanged: (_) => setState(() {})),
          NumberField(label: 'Height', controller: _c, onChanged: (_) => setState(() {})),
        ],
        ResultCard(rows: [
          ('Area', area == null ? '--' : area.toStringAsFixed(2)),
          ('Perimeter', perimeter == null ? '--' : perimeter.toStringAsFixed(2)),
        ]),
      ],
    );
  }
}
