import 'package:flutter/material.dart';

import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class GcfLcmScreen extends StatefulWidget {
  const GcfLcmScreen({super.key});

  @override
  State<GcfLcmScreen> createState() => _GcfLcmScreenState();
}

class _GcfLcmScreenState extends State<GcfLcmScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  @override
  Widget build(BuildContext context) {
    final a = int.tryParse(_aController.text);
    final b = int.tryParse(_bController.text);
    int? gcf;
    int? lcm;
    if (a != null && b != null && a != 0 && b != 0) {
      gcf = _gcd(a.abs(), b.abs());
      lcm = (a.abs() ~/ gcf) * b.abs();
    }

    return ToolScaffold(
      title: 'GCF & LCM',
      children: [
        NumberField(label: 'First number', controller: _aController, onChanged: (_) => setState(() {})),
        NumberField(label: 'Second number', controller: _bController, onChanged: (_) => setState(() {})),
        ResultCard(rows: [
          ('Greatest common factor', gcf?.toString() ?? '--'),
          ('Least common multiple', lcm?.toString() ?? '--'),
        ]),
      ],
    );
  }
}
