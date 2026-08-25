import 'package:flutter/material.dart';

import '../../shared/converters/converter_unit.dart';
import '../../shared/widgets/block_unit_converter_screen.dart';

/// Base unit: kilogram.
class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  static final units = [
    ConverterUnit.linear(id: 'mg', label: 'Milligrams', shortLabel: 'mg', factor: 0.000001),
    ConverterUnit.linear(id: 'g', label: 'Grams', shortLabel: 'g', factor: 0.001),
    ConverterUnit.linear(id: 'kg', label: 'Kilograms', shortLabel: 'kg', factor: 1),
    ConverterUnit.linear(id: 't', label: 'Metric tons', shortLabel: 't', factor: 1000),
    ConverterUnit.linear(id: 'oz', label: 'Ounces', shortLabel: 'oz', factor: 0.0283495),
    ConverterUnit.linear(id: 'lb', label: 'Pounds', shortLabel: 'lb', factor: 0.453592),
    ConverterUnit.linear(id: 'st', label: 'Stone', shortLabel: 'st', factor: 6.35029),
  ];

  @override
  Widget build(BuildContext context) {
    return BlockUnitConverterScreen(
      title: 'Weight',
      units: units,
      defaultUnitIds: const ['kg', 'g', 'lb'],
    );
  }
}
