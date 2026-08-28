import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/method_picker.dart';
import '../../../shared/widgets/number_field.dart';
import '../../../shared/widgets/result_card.dart';
import '../../../shared/widgets/shape_icon.dart';
import '../../../shared/widgets/solution_button.dart';

enum _Input { side, area, perimeter }

/// Square, Pentagon, Hexagon — any regular polygon solved from a single
/// known dimension.
class RegularPolygonScreen extends StatefulWidget {
  const RegularPolygonScreen({super.key, required this.sides, required this.kind});

  final int sides;
  final ShapeKind kind;

  @override
  State<RegularPolygonScreen> createState() => _RegularPolygonScreenState();
}

class _RegularPolygonScreenState extends State<RegularPolygonScreen> {
  _Input _input = _Input.side;
  final _controller = TextEditingController();

  static final _options = [
    const MethodOption(value: _Input.side, title: 'Side', icon: Icons.straighten),
    const MethodOption(value: _Input.area, title: 'Area', icon: Icons.square),
    const MethodOption(value: _Input.perimeter, title: 'Perimeter', icon: Icons.crop_square),
  ];

  double get _tanFactor => 4 * math.tan(math.pi / widget.sides);

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(_controller.text);
    double? side;
    double? area;
    double? perimeter;
    final steps = <String>[];

    if (value != null && value > 0) {
      switch (_input) {
        case _Input.side:
          side = value;
          area = widget.sides * side * side / _tanFactor;
          perimeter = widget.sides * side;
          steps.addAll(['Area = [[n·s²/4·tan(π÷n)]]', '= [[${widget.sides}·$side²/${_tanFactor.toStringAsFixed(3)}]]', '= ${area.toStringAsFixed(2)}']);
        case _Input.area:
          area = value;
          side = math.sqrt(area * _tanFactor / widget.sides);
          perimeter = widget.sides * side;
          steps.addAll(['s = √[[4·A·tan(π÷n)/n]]', '= ${side.toStringAsFixed(2)}']);
        case _Input.perimeter:
          perimeter = value;
          side = perimeter / widget.sides;
          area = widget.sides * side * side / _tanFactor;
          steps.addAll(['s = [[P/n]] = ${side.toStringAsFixed(2)}', 'Area = [[n·s²/4·tan(π÷n)]] = ${area.toStringAsFixed(2)}']);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.kind.label)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: 180, child: Center(child: ShapeIcon(kind: widget.kind, size: 130, color: AppColors.textSecondary))),
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
              child: Row(
                children: [
                  Icon(Icons.subdirectory_arrow_right, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Solve a ${widget.kind.label.toLowerCase()} knowing one dimension', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            ResultCard(rows: [
              if (_input != _Input.area) ('Area', area == null ? '--' : area.toStringAsFixed(2)),
              if (_input != _Input.perimeter) ('Perimeter', perimeter == null ? '--' : perimeter.toStringAsFixed(2)),
            ]),
            SolutionButton(steps: steps.isEmpty ? null : steps, title: widget.kind.label),
          ],
        ),
      ),
    );
  }
}
