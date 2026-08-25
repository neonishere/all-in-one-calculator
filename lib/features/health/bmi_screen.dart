import 'package:flutter/material.dart';

import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _category(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final weightKg = double.tryParse(_weightController.text);
    final heightCm = double.tryParse(_heightController.text);
    double? bmi;
    if (weightKg != null && heightCm != null && heightCm > 0) {
      final heightM = heightCm / 100;
      bmi = weightKg / (heightM * heightM);
    }

    return ToolScaffold(
      title: 'Body mass index',
      children: [
        NumberField(label: 'Weight', controller: _weightController, suffix: 'kg', onChanged: (_) => setState(() {})),
        NumberField(label: 'Height', controller: _heightController, suffix: 'cm', onChanged: (_) => setState(() {})),
        ResultCard(rows: [
          ('BMI', bmi == null ? '--' : bmi.toStringAsFixed(1)),
          ('Category', bmi == null ? '--' : _category(bmi)),
        ]),
      ],
    );
  }
}
