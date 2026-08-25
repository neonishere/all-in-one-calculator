import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NumberFormatStyle { us, euDot, euSpace }

extension NumberFormatStyleLabels on NumberFormatStyle {
  String get example => switch (this) {
        NumberFormatStyle.us => '1,234.56',
        NumberFormatStyle.euDot => '1.234,56',
        NumberFormatStyle.euSpace => '1 234,56',
      };

  String get decimalSeparator => switch (this) {
        NumberFormatStyle.us => '.',
        NumberFormatStyle.euDot => ',',
        NumberFormatStyle.euSpace => ',',
      };

  String get thousandsSeparator => switch (this) {
        NumberFormatStyle.us => ',',
        NumberFormatStyle.euDot => '.',
        NumberFormatStyle.euSpace => ' ',
      };
}

/// Global preferences for how numbers are displayed across the app's
/// converters: how many decimal places, and which separators to use.
class NumberFormatSettings extends ChangeNotifier {
  static const _decimalsKey = 'nf_decimals_v1';
  static const _styleKey = 'nf_style_v1';

  int _decimalPlaces = 2;
  NumberFormatStyle _style = NumberFormatStyle.us;

  int get decimalPlaces => _decimalPlaces;
  NumberFormatStyle get style => _style;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _decimalPlaces = prefs.getInt(_decimalsKey) ?? 2;
    final styleIndex = prefs.getInt(_styleKey);
    if (styleIndex != null && styleIndex < NumberFormatStyle.values.length) {
      _style = NumberFormatStyle.values[styleIndex];
    }
    notifyListeners();
  }

  Future<void> setDecimalPlaces(int value) async {
    _decimalPlaces = value.clamp(0, 8);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_decimalsKey, _decimalPlaces);
  }

  Future<void> setStyle(NumberFormatStyle value) async {
    _style = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_styleKey, value.index);
  }

  /// Renders [value] using the current decimal-place count and separators.
  String format(double value) {
    if (value.isNaN || value.isInfinite) return '--';
    final fixed = value.toStringAsFixed(_decimalPlaces);
    final negative = fixed.startsWith('-');
    final unsigned = negative ? fixed.substring(1) : fixed;
    final parts = unsigned.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(_style.thousandsSeparator);
      }
      buffer.write(intPart[i]);
    }

    var result = buffer.toString();
    if (fracPart.isNotEmpty) {
      result += _style.decimalSeparator + fracPart;
    }
    return negative ? '-$result' : result;
  }

  /// Reads a value that may have been rendered with [format] back into a
  /// plain double, undoing the current style's separators.
  double? parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    var cleaned = trimmed.replaceAll(_style.thousandsSeparator, '');
    if (_style.decimalSeparator != '.') {
      cleaned = cleaned.replaceAll(_style.decimalSeparator, '.');
    }
    return double.tryParse(cleaned);
  }
}
