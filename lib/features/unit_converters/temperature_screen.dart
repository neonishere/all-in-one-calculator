import 'package:flutter/material.dart';

import '../../shared/converters/converter_unit.dart';
import '../../shared/widgets/block_unit_converter_screen.dart';

/// Base unit: Celsius.
class TemperatureScreen extends StatelessWidget {
  const TemperatureScreen({super.key});

  static final units = [
    ConverterUnit(
      id: 'c',
      label: 'Celsius',
      shortLabel: '°C',
      toBase: (v) => v,
      fromBase: (v) => v,
    ),
    ConverterUnit(
      id: 'f',
      label: 'Fahrenheit',
      shortLabel: '°F',
      toBase: (v) => (v - 32) * 5 / 9,
      fromBase: (v) => v * 9 / 5 + 32,
    ),
    ConverterUnit(
      id: 'k',
      label: 'Kelvin',
      shortLabel: 'K',
      toBase: (v) => v - 273.15,
      fromBase: (v) => v + 273.15,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlockUnitConverterScreen(
      title: 'Temperature',
      units: units,
      defaultUnitIds: const ['c', 'f'],
    );
  }
}
