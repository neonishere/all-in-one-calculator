import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';

import '../../core/history/history_store.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/calc_key_button.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../tool_menu/tool_menu_screen.dart';
import 'history_panel.dart';
import 'memory_panel.dart';

const _calculatorModes = ['Standard', 'Scientific', 'Graphing', 'Programmer'];

class BasicCalculatorScreen extends StatefulWidget {
  const BasicCalculatorScreen({super.key});

  @override
  State<BasicCalculatorScreen> createState() => _BasicCalculatorScreenState();
}

class _BasicCalculatorScreenState extends State<BasicCalculatorScreen>
    with SingleTickerProviderStateMixin {
  String _expression = '';
  String _preview = '';
  double _memory = 0;
  int _nthRootN = 2;

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  double _revealDistance = 600;
  bool? _horizontalSwipe;

  static final _digitKeys = {
    LogicalKeyboardKey.digit0: '0',
    LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.digit1: '1',
    LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.digit2: '2',
    LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.digit3: '3',
    LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.digit4: '4',
    LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.digit5: '5',
    LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.digit6: '6',
    LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.digit7: '7',
    LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.digit8: '8',
    LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.digit9: '9',
    LogicalKeyboardKey.numpad9: '9',
    LogicalKeyboardKey.numpadAdd: '+',
    LogicalKeyboardKey.numpadSubtract: '−',
    LogicalKeyboardKey.numpadMultiply: '×',
    LogicalKeyboardKey.numpadDivide: '÷',
    LogicalKeyboardKey.numpadDecimal: '.',
  };

  static const _symbolKeys = {
    '+': '+',
    '-': '−',
    '*': '×',
    '/': '÷',
    '.': '.',
    ',': '.',
    '(': '(',
    ')': ')',
    '%': '%',
    '^': '^',
  };

  static const _keys = [
    'MC', 'MR', 'M+', 'M−',
    '^', 'nthroot', 'C', '⌫',
    '(', ')', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '+/−', '0', '.', '=',
  ];

  static const _memoryKeys = {'MC', 'MR', 'M+', 'M−'};
  static const _plainKeys = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '+/−'};

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handlePhysicalKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handlePhysicalKey);
    _reveal.dispose();
    super.dispose();
  }

  /// Global hardware-key handler (not focus-scoped, so clicking a keypad
  /// button can't steal focus and silently break further typing). Guarded
  /// on [ModalRoute.isCurrent] so it stays inert while another screen — with
  /// its own text fields — is pushed on top.
  bool _handlePhysicalKey(KeyEvent event) {
    if (!mounted) return false;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      _onKey('⌫');
      return true;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _onKey('=');
      return true;
    }
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.delete) {
      _onKey('C');
      return true;
    }

    final fromKey = _digitKeys[key];
    if (fromKey != null) {
      _onKey(fromKey);
      return true;
    }

    final char = event.character;
    if (char != null && _symbolKeys.containsKey(char)) {
      _onKey(_symbolKeys[char]!);
      return true;
    }
    return false;
  }

  void _onKey(String key) {
    switch (key) {
      case 'C':
        _setExpression('');
        return;
      case '⌫':
        _setExpression(_expression.isEmpty ? '' : _expression.substring(0, _expression.length - 1));
        return;
      case '=':
        _evaluate();
        return;
      case 'nthroot':
        _applyUnary((v) => v < 0 ? double.nan : math.pow(v, 1 / _nthRootN).toDouble());
        return;
      case '+/−':
        _applyUnary((v) => -v);
        return;
      case 'MC':
        setState(() => _memory = 0);
        return;
      case 'MR':
        _setExpression(_formatNumber(_memory));
        return;
      case 'M+':
        final v = _currentValue();
        if (v != null) setState(() => _memory += v);
        return;
      case 'M−':
        final v = _currentValue();
        if (v != null) setState(() => _memory -= v);
        return;
      default:
        _setExpression(_expression + key);
    }
  }

  void _setExpression(String value) {
    setState(() {
      _expression = value;
      _preview = _tryEvaluate(_expression) ?? '';
    });
  }

  double? _currentValue() => double.tryParse(_tryEvaluate(_expression) ?? '');

  void _applyUnary(double Function(double) fn) {
    final current = _currentValue();
    if (current == null) return;
    final result = fn(current);
    if (result.isNaN || result.isInfinite) return;
    _setExpression(_formatNumber(result));
  }

  Future<void> _askNthRoot() async {
    final controller = TextEditingController(text: _nthRootN.toString());
    final n = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Root degree'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. 3 for cube root'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(int.tryParse(controller.text)),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (n == null || n < 2 || n > 20) return;
    setState(() => _nthRootN = n);
    _applyUnary((v) => v < 0 ? double.nan : math.pow(v, 1 / n).toDouble());
  }

  void _openMemorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => MemoryPanel(
        value: _memory,
        formattedValue: _formatNumber(_memory),
        onRecall: () {
          Navigator.of(sheetContext).pop();
          _setExpression(_formatNumber(_memory));
        },
        onClear: () {
          Navigator.of(sheetContext).pop();
          setState(() => _memory = 0);
        },
      ),
    );
  }

  void _evaluate() {
    final result = _tryEvaluate(_expression);
    if (result != null && _expression.isNotEmpty && result != _expression) {
      context.read<HistoryStore>().add(_expression, result);
    }
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
      return _formatNumber(value);
    } catch (_) {
      return null;
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    var text = value.toStringAsFixed(8);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  void _openHistory() => _reveal.animateTo(1, curve: Curves.easeOutCubic);
  void _closeHistory() => _reveal.animateTo(0, curve: Curves.easeOutCubic);

  void _openToolMenu() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ToolMenuScreen()));
  }

  void _onPanStart(DragStartDetails details) {
    _horizontalSwipe = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _horizontalSwipe ??= details.delta.dx.abs() > details.delta.dy.abs() + 1.5
        ? true
        : (details.delta.dy.abs() > details.delta.dx.abs() + 1.5 ? false : null);
    if (_horizontalSwipe == false) {
      final next = _reveal.value + details.delta.dy / _revealDistance;
      _reveal.value = next.clamp(0.0, 1.0);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_horizontalSwipe == true) {
      final velocity = details.velocity.pixelsPerSecond.dx;
      if (velocity > 250) _openToolMenu();
    } else if (_horizontalSwipe == false) {
      if (_reveal.value > 0.35) {
        _openHistory();
      } else {
        _closeHistory();
      }
    }
    _horizontalSwipe = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.grid_view_rounded),
          tooltip: 'All tools',
          onPressed: _openToolMenu,
        ),
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Memory',
            onPressed: _openMemorySheet,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: _openHistory,
          ),
          PopupMenuButton<String>(
            tooltip: 'Calculator mode',
            icon: const Icon(Icons.calculate_outlined),
            onSelected: (mode) {
              if (mode != 'Standard') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ComingSoonScreen(title: mode)),
                );
              }
            },
            itemBuilder: (context) => [
              for (final mode in _calculatorModes)
                PopupMenuItem(value: mode, child: Text(mode)),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _revealDistance = constraints.maxHeight;
            return Stack(
              children: [
                Positioned.fill(child: HistoryPanel(onClose: _closeHistory)),
                AnimatedBuilder(
                  animation: _reveal,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _reveal.value * constraints.maxHeight),
                      child: child,
                    );
                  },
                  child: Material(
                    color: AppColors.background,
                    elevation: 6,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              alignment: Alignment.bottomRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.bottomRight,
                                child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (_preview.isNotEmpty)
                                    Text(
                                      _preview,
                                      style: TextStyle(fontSize: 22, color: AppColors.textSecondary),
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
                          ),
                        ),
                        Expanded(flex: 8, child: _buildKeypad()),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final rows = [for (var i = 0; i < _keys.length; i += 4) _keys.skip(i).take(4).toList()];
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          for (final row in rows)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    for (final key in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildKey(key),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key == '=') {
      return CalcKeyButton(label: '=', filled: true, fontSize: 22, onTap: () => _onKey('='));
    }
    final isMemory = _memoryKeys.contains(key);
    if (key == 'nthroot') {
      return CalcKeyButton(
        label: 'ˣ√',
        accented: true,
        onTap: () => _onKey('nthroot'),
        onLongPress: _askNthRoot,
      );
    }
    return CalcKeyButton(
      label: key,
      accented: !isMemory && !_plainKeys.contains(key),
      dimmed: isMemory,
      themed: isMemory,
      onTap: () => _onKey(key),
    );
  }
}
