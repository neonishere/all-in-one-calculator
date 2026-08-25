import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  final DateTime _asOf = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    var years = _asOf.year - _birthDate.year;
    var months = _asOf.month - _birthDate.month;
    var days = _asOf.day - _birthDate.day;
    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(_asOf.year, _asOf.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    final totalDays = _asOf.difference(_birthDate).inDays;

    return ToolScaffold(
      title: 'Age calculator',
      children: [
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Birth date: ${_birthDate.toLocal().toString().substring(0, 10)}'),
                const Icon(Icons.calendar_today, color: AppColors.accent, size: 20),
              ],
            ),
          ),
        ),
        ResultCard(rows: [
          ('Age', '$years years, $months months, $days days'),
          ('Total days lived', '$totalDays'),
        ]),
      ],
    );
  }
}
