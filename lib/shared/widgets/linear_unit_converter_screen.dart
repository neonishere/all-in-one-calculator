import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'number_field.dart';
import 'tool_scaffold.dart';

/// A unit whose value converts to the family's base unit by multiplication.
class LinearUnit {
  const LinearUnit(this.label, this.toBaseFactor);

  final String label;
  final double toBaseFactor;
}

/// Reusable converter for any unit family that's a simple linear scale
/// against a base unit (length, weight, speed, area, volume, ...).
class LinearUnitConverterScreen extends StatefulWidget {
  const LinearUnitConverterScreen({
    super.key,
    required this.title,
    required this.units,
  });

  final String title;
  final List<LinearUnit> units;

  @override
  State<LinearUnitConverterScreen> createState() => _LinearUnitConverterScreenState();
}

class _LinearUnitConverterScreenState extends State<LinearUnitConverterScreen> {
  late LinearUnit _from = widget.units.first;
  late LinearUnit _to = widget.units.length > 1 ? widget.units[1] : widget.units.first;
  final _valueController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(_valueController.text);
    final result = value == null ? null : value * _from.toBaseFactor / _to.toBaseFactor;

    return ToolScaffold(
      title: widget.title,
      children: [
        NumberField(label: 'Value', controller: _valueController, allowNegative: true, onChanged: (_) => setState(() {})),
        Row(
          children: [
            Expanded(child: _unitDropdown(_from, (u) => setState(() => _from = u))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: AppColors.textSecondary)),
            Expanded(child: _unitDropdown(_to, (u) => setState(() => _to = u))),
          ],
        ),
        ResultCardValue(value: result),
      ],
    );
  }

  Widget _unitDropdown(LinearUnit selected, ValueChanged<LinearUnit> onChanged) {
    return DropdownButtonFormField<LinearUnit>(
      initialValue: selected,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: [
        for (final unit in widget.units) DropdownMenuItem(value: unit, child: Text(unit.label, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (u) => onChanged(u!),
    );
  }
}

class ResultCardValue extends StatelessWidget {
  const ResultCardValue({super.key, required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value == null ? '--' : _format(value!),
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _format(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
    return v.toStringAsPrecision(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
