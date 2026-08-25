import 'package:flutter/material.dart';

import '../../shared/converters/converter_unit.dart';
import '../../shared/widgets/block_unit_converter_screen.dart';

/// Base unit: meter.
class LengthScreen extends StatelessWidget {
  const LengthScreen({super.key});

  static final units = [
    ConverterUnit.linear(id: 'mm', label: 'Millimeters', shortLabel: 'mm', factor: 0.001),
    ConverterUnit.linear(id: 'cm', label: 'Centimeters', shortLabel: 'cm', factor: 0.01),
    ConverterUnit.linear(id: 'm', label: 'Meters', shortLabel: 'm', factor: 1),
    ConverterUnit.linear(id: 'km', label: 'Kilometers', shortLabel: 'km', factor: 1000),
    ConverterUnit.linear(id: 'in', label: 'Inches', shortLabel: 'in', factor: 0.0254),
    ConverterUnit.linear(id: 'ft', label: 'Feet', shortLabel: 'ft', factor: 0.3048),
    ConverterUnit.linear(id: 'yd', label: 'Yards', shortLabel: 'yd', factor: 0.9144),
    ConverterUnit.linear(id: 'mi', label: 'Miles', shortLabel: 'mi', factor: 1609.344),
  ];

  @override
  Widget build(BuildContext context) {
    return BlockUnitConverterScreen(
      title: 'Length',
      units: units,
      defaultUnitIds: const ['m', 'cm', 'ft'],
    );
  }
}
