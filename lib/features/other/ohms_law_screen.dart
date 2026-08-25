import 'package:flutter/material.dart';

import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({super.key});

  @override
  State<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends State<OhmsLawScreen> {
  final _voltage = TextEditingController();
  final _current = TextEditingController();
  final _resistance = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final v = double.tryParse(_voltage.text);
    final i = double.tryParse(_current.text);
    final r = double.tryParse(_resistance.text);

    double? outV = v, outI = i, outR = r, power;
    final provided = [v, i, r].where((x) => x != null).length;
    if (provided == 2) {
      if (v == null) outV = i! * r!;
      if (i == null) outI = v! / r!;
      if (r == null) outR = v! / i!;
    }
    if (outV != null && outI != null) power = outV * outI;

    return ToolScaffold(
      title: "Ohm's law",
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Fill in any two fields — the third is calculated.'),
        ),
        NumberField(label: 'Voltage', controller: _voltage, suffix: 'V', onChanged: (_) => setState(() {})),
        NumberField(label: 'Current', controller: _current, suffix: 'A', onChanged: (_) => setState(() {})),
        NumberField(label: 'Resistance', controller: _resistance, suffix: 'Ω', onChanged: (_) => setState(() {})),
        ResultCard(rows: [
          ('Voltage', outV == null ? '--' : '${outV.toStringAsFixed(3)} V'),
          ('Current', outI == null ? '--' : '${outI.toStringAsFixed(3)} A'),
          ('Resistance', outR == null ? '--' : '${outR.toStringAsFixed(3)} Ω'),
          ('Power', power == null ? '--' : '${power.toStringAsFixed(3)} W'),
        ]),
      ],
    );
  }
}
