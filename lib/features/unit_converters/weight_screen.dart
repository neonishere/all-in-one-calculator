import 'package:flutter/material.dart';

import '../../shared/widgets/linear_unit_converter_screen.dart';

/// Base unit: kilogram.
class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  static const units = [
    LinearUnit('Milligrams (mg)', 0.000001),
    LinearUnit('Grams (g)', 0.001),
    LinearUnit('Kilograms (kg)', 1),
    LinearUnit('Metric tons (t)', 1000),
    LinearUnit('Ounces (oz)', 0.0283495),
    LinearUnit('Pounds (lb)', 0.453592),
    LinearUnit('Stone (st)', 6.35029),
  ];

  @override
  Widget build(BuildContext context) {
    return const LinearUnitConverterScreen(title: 'Weight', units: units);
  }
}
