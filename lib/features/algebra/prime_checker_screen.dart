import 'package:flutter/material.dart';

import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class PrimeCheckerScreen extends StatefulWidget {
  const PrimeCheckerScreen({super.key});

  @override
  State<PrimeCheckerScreen> createState() => _PrimeCheckerScreenState();
}

class _PrimeCheckerScreenState extends State<PrimeCheckerScreen> {
  final _controller = TextEditingController();

  bool _isPrime(int n) {
    if (n < 2) return false;
    if (n % 2 == 0) return n == 2;
    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  List<int> _factors(int n) {
    final result = <int>[];
    var remaining = n;
    for (int i = 2; i * i <= remaining; i++) {
      while (remaining % i == 0) {
        result.add(i);
        remaining ~/= i;
      }
    }
    if (remaining > 1) result.add(remaining);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final n = int.tryParse(_controller.text);
    final isPrime = n == null ? null : _isPrime(n);
    final factors = (n != null && !(isPrime ?? false) && n > 1) ? _factors(n) : null;

    return ToolScaffold(
      title: 'Prime checker',
      children: [
        NumberField(label: 'Number', controller: _controller, onChanged: (_) => setState(() {})),
        ResultCard(rows: [
          ('Is prime', isPrime == null ? '--' : (isPrime ? 'Yes' : 'No')),
          if (factors != null && factors.isNotEmpty) ('Prime factors', factors.join(' × ')),
        ]),
      ],
    );
  }
}
