import 'package:flutter/material.dart';

import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class SalesTaxScreen extends StatefulWidget {
  const SalesTaxScreen({super.key});

  @override
  State<SalesTaxScreen> createState() => _SalesTaxScreenState();
}

class _SalesTaxScreenState extends State<SalesTaxScreen> {
  final _priceController = TextEditingController();
  final _rateController = TextEditingController(text: '8');

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(_priceController.text);
    final rate = double.tryParse(_rateController.text);
    final tax = (price != null && rate != null) ? price * rate / 100 : null;
    final total = (price != null && tax != null) ? price + tax : null;

    return ToolScaffold(
      title: 'Sales tax',
      children: [
        NumberField(label: 'Price before tax', controller: _priceController, onChanged: (_) => setState(() {})),
        NumberField(label: 'Tax rate', controller: _rateController, suffix: '%', onChanged: (_) => setState(() {})),
        ResultCard(rows: [
          ('Tax amount', tax == null ? '--' : tax.toStringAsFixed(2)),
          ('Total price', total == null ? '--' : total.toStringAsFixed(2)),
        ]),
      ],
    );
  }
}
