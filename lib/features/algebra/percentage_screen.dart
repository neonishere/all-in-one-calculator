import 'package:flutter/material.dart';

import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class PercentageScreen extends StatefulWidget {
  const PercentageScreen({super.key});

  @override
  State<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends State<PercentageScreen> {
  final _percentController = TextEditingController();
  final _ofController = TextEditingController();

  double? get _percent => double.tryParse(_percentController.text);
  double? get _of => double.tryParse(_ofController.text);

  @override
  Widget build(BuildContext context) {
    final percent = _percent;
    final of = _of;
    final result = (percent != null && of != null) ? of * percent / 100 : null;

    return ToolScaffold(
      title: 'Percentage',
      children: [
        NumberField(label: 'Percentage', controller: _percentController, suffix: '%', onChanged: (_) => setState(() {})),
        NumberField(label: 'Of value', controller: _ofController, onChanged: (_) => setState(() {})),
        ResultCard(rows: [
          ('Result', result == null ? '--' : result.toStringAsFixed(2)),
        ]),
      ],
    );
  }
}
