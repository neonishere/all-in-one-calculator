import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/linear_unit_converter_screen.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/tool_scaffold.dart';

enum _TempUnit { celsius, fahrenheit, kelvin }

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  _TempUnit _from = _TempUnit.celsius;
  _TempUnit _to = _TempUnit.fahrenheit;
  final _valueController = TextEditingController(text: '0');

  double _toCelsius(double v, _TempUnit unit) => switch (unit) {
        _TempUnit.celsius => v,
        _TempUnit.fahrenheit => (v - 32) * 5 / 9,
        _TempUnit.kelvin => v - 273.15,
      };

  double _fromCelsius(double c, _TempUnit unit) => switch (unit) {
        _TempUnit.celsius => c,
        _TempUnit.fahrenheit => c * 9 / 5 + 32,
        _TempUnit.kelvin => c + 273.15,
      };

  String _label(_TempUnit unit) => switch (unit) {
        _TempUnit.celsius => 'Celsius (°C)',
        _TempUnit.fahrenheit => 'Fahrenheit (°F)',
        _TempUnit.kelvin => 'Kelvin (K)',
      };

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(_valueController.text);
    final result = value == null ? null : _fromCelsius(_toCelsius(value, _from), _to);

    return ToolScaffold(
      title: 'Temperature',
      children: [
        NumberField(label: 'Value', controller: _valueController, allowNegative: true, onChanged: (_) => setState(() {})),
        Row(
          children: [
            Expanded(child: _dropdown(_from, (u) => setState(() => _from = u))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: AppColors.textSecondary)),
            Expanded(child: _dropdown(_to, (u) => setState(() => _to = u))),
          ],
        ),
        ResultCardValue(value: result),
      ],
    );
  }

  Widget _dropdown(_TempUnit selected, ValueChanged<_TempUnit> onChanged) {
    return DropdownButtonFormField<_TempUnit>(
      initialValue: selected,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: [for (final u in _TempUnit.values) DropdownMenuItem(value: u, child: Text(_label(u), overflow: TextOverflow.ellipsis))],
      onChanged: (u) => onChanged(u!),
    );
  }
}
