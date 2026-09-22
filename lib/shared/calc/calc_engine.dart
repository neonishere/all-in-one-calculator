import 'package:math_expressions/math_expressions.dart';

/// Shared expression evaluation used by the main calculator and by the
/// mini calculator popup, so both parse/format numbers identically.
class CalcEngine {
  CalcEngine._();

  static String? tryEvaluate(String input) {
    if (input.isEmpty) return null;
    try {
      final sanitized = expandRoots(input)
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('%', '/100');
      final parser = Parser();
      final exp = parser.parse(sanitized);
      final value = exp.evaluate(EvaluationType.REAL, ContextModel());
      if (value.isNaN || value.isInfinite) return null;
      return formatNumber(value);
    } catch (_) {
      return null;
    }
  }

  static String formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    var text = value.toStringAsFixed(8);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  /// Inserts thousands commas into every run of digits in [raw] — for
  /// display only, so the underlying expression string stays parseable.
  /// Leaves decimal digits, operators, parens and root symbols untouched.
  static String formatDisplay(String raw) {
    final buffer = StringBuffer();
    var i = 0;
    while (i < raw.length) {
      if (_isAsciiDigit(raw[i])) {
        var j = i;
        while (j < raw.length && _isAsciiDigit(raw[j])) {
          j++;
        }
        buffer.write(_groupThousands(raw.substring(i, j)));
        i = j;
        if (i < raw.length && raw[i] == '.') {
          var k = i + 1;
          while (k < raw.length && _isAsciiDigit(raw[k])) {
            k++;
          }
          buffer.write(raw.substring(i, k));
          i = k;
        }
      } else {
        buffer.write(raw[i]);
        i++;
      }
    }
    return buffer.toString();
  }

  static bool _isAsciiDigit(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  static String _groupThousands(String digits) {
    final out = StringBuffer();
    final start = digits.length % 3 == 0 ? 3 : digits.length % 3;
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && (i - start) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }

  static const _superscriptDigits = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];

  /// Renders [n] as superscript digits, e.g. `3` -> `³`, used to prefix the
  /// root symbol (`³√`) so it can't be confused with a plain digit the user
  /// typed right before it.
  static String toSuperscript(int n) => n.toString().split('').map((d) => _superscriptDigits[int.parse(d)]).join();

  static int _fromSuperscript(String s) =>
      int.parse(s.split('').map((c) => _superscriptDigits.indexOf(c)).join());

  /// Rewrites the root symbol into `(...)^(1/N)` so the expression parser
  /// can evaluate it like a normal power.
  ///
  /// The root binds only to what directly follows it: a `(...)` group if
  /// the user explicitly opened one, otherwise just the next plain number
  /// (e.g. `√25` is the root of 25 alone). Anything typed before the root
  /// — like the `5` in `5√25` — is left untouched, with an explicit `*`
  /// inserted so it reads as `5 × √25` rather than a root degree.
  static String expandRoots(String input) {
    final buffer = StringBuffer();
    var i = 0;
    while (i < input.length) {
      final match = RegExp(r'^([⁰¹²³⁴⁵⁶⁷⁸⁹]*)√').firstMatch(input.substring(i));
      if (match != null) {
        final supDigits = match.group(1) ?? '';
        final n = supDigits.isEmpty ? 2 : _fromSuperscript(supDigits);
        final afterSymbol = i + match.end;

        String? radicand;
        int? nextIndex;
        if (afterSymbol < input.length && input[afterSymbol] == '(') {
          final closeIndex = _matchingParen(input, afterSymbol);
          if (closeIndex != -1) {
            radicand = expandRoots(input.substring(afterSymbol + 1, closeIndex));
            nextIndex = closeIndex + 1;
          }
        } else {
          final atomMatch = RegExp(r'^-?\d+(\.\d+)?').firstMatch(input.substring(afterSymbol));
          if (atomMatch != null) {
            radicand = atomMatch.group(0);
            nextIndex = afterSymbol + atomMatch.end;
          }
        }

        if (radicand == null || nextIndex == null) {
          buffer.write(input.substring(i, afterSymbol));
          i = afterSymbol;
          continue;
        }

        if (buffer.isNotEmpty && RegExp(r'[0-9)%]$').hasMatch(buffer.toString())) {
          buffer.write('*');
        }
        buffer.write('(($radicand)^(1/$n))');
        i = nextIndex;
      } else {
        buffer.write(input[i]);
        i++;
      }
    }
    return buffer.toString();
  }

  static int _matchingParen(String s, int openIndex) {
    var depth = 0;
    for (var j = openIndex; j < s.length; j++) {
      if (s[j] == '(') depth++;
      if (s[j] == ')') {
        depth--;
        if (depth == 0) return j;
      }
    }
    return -1;
  }
}
