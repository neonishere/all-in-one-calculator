import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class AverageScreen extends StatefulWidget {
  const AverageScreen({super.key});

  @override
  State<AverageScreen> createState() => _AverageScreenState();
}

class _AverageScreenState extends State<AverageScreen> {
  final _controller = TextEditingController();

  List<double> get _numbers => _controller.text
      .split(RegExp(r'[,\s]+'))
      .map((s) => double.tryParse(s))
      .whereType<double>()
      .toList();

  @override
  Widget build(BuildContext context) {
    final numbers = _numbers;
    final mean = numbers.isEmpty ? null : numbers.reduce((a, b) => a + b) / numbers.length;
    final sorted = [...numbers]..sort();
    final median = sorted.isEmpty
        ? null
        : sorted.length.isOdd
            ? sorted[sorted.length ~/ 2]
            : (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;

    return ToolScaffold(
      title: 'Average',
      children: [
        TextField(
          controller: _controller,
          onChanged: (_) => setState(() {}),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Numbers (comma or space separated)',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),
        ResultCard(rows: [
          ('Count', '${numbers.length}'),
          ('Sum', numbers.isEmpty ? '--' : numbers.reduce((a, b) => a + b).toStringAsFixed(2)),
          ('Mean', mean == null ? '--' : mean.toStringAsFixed(2)),
          ('Median', median == null ? '--' : median.toStringAsFixed(2)),
        ]),
      ],
    );
  }
}
