import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../calc/calc_engine.dart';
import 'calc_key_button.dart';

/// Opens the popup calculator over the current screen, dimming the
/// background slightly. Returns the evaluated value the user confirmed, or
/// `null` if they backed out (tapping the arrow or outside the popup)
/// without saving anything.
Future<String?> showMiniCalculatorPopup(
  BuildContext context, {
  required String title,
  String initialValue = '',
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => MiniCalculatorPopup(title: title, initialValue: initialValue),
  );
}

class MiniCalculatorPopup extends StatefulWidget {
  const MiniCalculatorPopup({super.key, required this.title, this.initialValue = ''});

  final String title;
  final String initialValue;

  @override
  State<MiniCalculatorPopup> createState() => _MiniCalculatorPopupState();
}

class _MiniCalculatorPopupState extends State<MiniCalculatorPopup> {
  late String _expression = widget.initialValue;
  String _preview = '';
  final int _nthRootN = 2;

  /// True until the user's first keypress. The popup opens pre-filled with
  /// the field's existing value; typing a fresh number should replace it
  /// rather than append to it, like landing on a calculator result screen.
  bool _freshStart = true;

  static const _keys = [
    '^', 'nthroot', 'C', '⌫',
    '(', ')', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '+/−', '0', '.', '✓',
  ];

  static const _plainKeys = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '+/−'};

  void _onKey(String key) {
    if (_freshStart && key != 'C' && key != '⌫' && key != '✓' && key != '+/−') {
      _freshStart = false;
      _expression = '';
    } else {
      _freshStart = false;
    }
    switch (key) {
      case 'C':
        _setExpression('');
        return;
      case '⌫':
        _setExpression(_expression.isEmpty ? '' : _expression.substring(0, _expression.length - 1));
        return;
      case '✓':
        _confirm();
        return;
      case 'nthroot':
        _setExpression(_expression + (_nthRootN == 2 ? '√' : '${CalcEngine.toSuperscript(_nthRootN)}√'));
        return;
      case '+/−':
        _applyUnary((v) => -v);
        return;
      default:
        _setExpression(_expression + key);
    }
  }

  void _setExpression(String value) {
    setState(() {
      _expression = value;
      _preview = CalcEngine.tryEvaluate(_expression) ?? '';
    });
  }

  void _applyUnary(double Function(double) fn) {
    final current = double.tryParse(CalcEngine.tryEvaluate(_expression) ?? '');
    if (current == null) return;
    final result = fn(current);
    if (result.isNaN || result.isInfinite) return;
    _setExpression(CalcEngine.formatNumber(result));
  }

  void _confirm() {
    final result = CalcEngine.tryEvaluate(_expression);
    Navigator.of(context).pop(result ?? (_expression.isEmpty ? null : _expression));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = (media.size.width * 0.9).clamp(0.0, 380.0);
    final height = (media.size.height * 0.72).clamp(0.0, 560.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                            CalcEngine.formatDisplay(_preview),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _expression.isEmpty ? '0' : CalcEngine.formatDisplay(_expression),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(flex: 7, child: _buildKeypad()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final rows = [for (var i = 0; i < _keys.length; i += 4) _keys.skip(i).take(4).toList()];
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          for (final row in rows)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    for (final key in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
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
    if (key == '✓') {
      return CalcKeyButton(label: '✓', filled: true, fontSize: 26, onTap: () => _onKey('✓'));
    }
    if (key == 'nthroot') {
      return CalcKeyButton(
        label: _nthRootN == 2 ? '√' : '$_nthRootN√',
        accented: true,
        onTap: () => _onKey('nthroot'),
      );
    }
    return CalcKeyButton(
      label: key,
      accented: !_plainKeys.contains(key),
      onTap: () => _onKey(key),
    );
  }
}
