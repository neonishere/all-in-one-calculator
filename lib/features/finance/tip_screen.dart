import 'package:flutter/material.dart';

import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final _billController = TextEditingController();
  final _tipController = TextEditingController(text: '15');
  final _peopleController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final bill = double.tryParse(_billController.text);
    final tipPercent = double.tryParse(_tipController.text);
    final people = int.tryParse(_peopleController.text);

    double? tipAmount;
    double? total;
    double? perPerson;
    if (bill != null && tipPercent != null) {
      tipAmount = bill * tipPercent / 100;
      total = bill + tipAmount;
      if (people != null && people > 0) perPerson = total / people;
    }

    return ToolScaffold(
      title: 'Tip',
      children: [
        NumberField(label: 'Bill amount', controller: _billController, onChanged: (_) => setState(() {})),
        NumberField(label: 'Tip percentage', controller: _tipController, suffix: '%', onChanged: (_) => setState(() {})),
        NumberField(label: 'Split between', controller: _peopleController, onChanged: (_) => setState(() {})),
        ResultCard(rows: [
          ('Tip amount', tipAmount == null ? '--' : tipAmount.toStringAsFixed(2)),
          ('Total', total == null ? '--' : total.toStringAsFixed(2)),
          ('Per person', perPerson == null ? '--' : perPerson.toStringAsFixed(2)),
        ]),
      ],
    );
  }
}
