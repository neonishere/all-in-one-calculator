import 'package:flutter/material.dart';

import '../../shared/widgets/linear_unit_converter_screen.dart';

/// Base unit: meter.
class LengthScreen extends StatelessWidget {
  const LengthScreen({super.key});

  static const units = [
    LinearUnit('Millimeters (mm)', 0.001),
    LinearUnit('Centimeters (cm)', 0.01),
    LinearUnit('Meters (m)', 1),
    LinearUnit('Kilometers (km)', 1000),
    LinearUnit('Inches (in)', 0.0254),
    LinearUnit('Feet (ft)', 0.3048),
    LinearUnit('Yards (yd)', 0.9144),
    LinearUnit('Miles (mi)', 1609.344),
  ];

  @override
  Widget build(BuildContext context) {
    return const LinearUnitConverterScreen(title: 'Length', units: units);
  }
}
