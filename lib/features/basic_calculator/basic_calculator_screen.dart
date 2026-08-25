import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../core/theme/app_theme.dart';
import '../tool_menu/tool_menu_screen.dart';

class BasicCalculatorScreen extends StatefulWidget {
  const BasicCalculatorScreen({super.key});

  @override
  State<BasicCalculatorScreen> createState() => _BasicCalculatorScreenState();
}

class _BasicCalculatorScreenState extends State<BasicCalculatorScreen> {
  String _expression = '';
  String _preview = '';

  static const _keys = [
    'C', '(', ')', '⌫',
    '7', '8', '9', '÷',
    '4', '5', '6', '×',
    '1', '2', '3', '−',
    '%', '0', '.', '+',
  ];

  void _onKey(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          break;
        case '=':
          _evaluate();
          return;
        default:
          _expression += key;
      }
      _preview = _tryEvaluate(_expression) ?? '';
    });
  }

  void _evaluate() {
    final result = _tryEvaluate(_expression);
    setState(() {
      if (result != null) {
        _expression = result;
      }
      _preview = '';
    });
  }

  String? _tryEvaluate(String input) {
    if (input.isEmpty) return null;
    try {
      final sanitized = input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('%', '/100');
      final parser = Parser();
      final exp = parser.parse(sanitized);
      final value = exp.evaluate(EvaluationType.REAL, ContextModel());
      if (value.isNaN || value.isInfinite) return null;
      final asString = value == value.roundToDouble()
          ? value.toInt().toString()
          : _trimTrailingZeros(value);
      return asString;
    } catch (_) {
      return null;
    }
  }

  String _trimTrailingZeros(double value) {
    var text = value.toStringAsFixed(8);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.grid_view_rounded),
          tooltip: 'All tools',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ToolMenuScreen()),
          ),
        ),
        title: const Text('Calculator'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_preview.isNotEmpty)
                      Text(
                        _preview,
                        style: const TextStyle(fontSize: 22, color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w300),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 5, child: _buildKeypad()),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final rows = [for (var i = 0; i < _keys.length; i += 4) _keys.skip(i).take(4).toList()];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (final row in rows)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        for (final key in row)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _buildKey(key),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _onKey('='),
                    child: const Text('=', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String key) {
    final isOperator = ['÷', '×', '−', '+', '%'].contains(key);
    final isAction = key == 'C' || key == '⌫';
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isOperator || isAction ? AppColors.surfaceAlt : AppColors.surface,
        foregroundColor: isOperator ? AppColors.accent : AppColors.textPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => _onKey(key),
      child: Text(key, style: const TextStyle(fontSize: 20)),
    );
  }
}
