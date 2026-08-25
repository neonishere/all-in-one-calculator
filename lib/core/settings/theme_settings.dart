import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class ThemeSettings extends ChangeNotifier {
  static const _baseKey = 'theme_base_v1';
  static const _accentKey = 'theme_accent_v1';

  AppBaseTheme _base = AppBaseTheme.slate;
  AppAccentColor _accentColor = AppAccentColor.teal;

  AppBaseTheme get base => _base;
  AppAccentColor get accentColor => _accentColor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final baseIndex = prefs.getInt(_baseKey);
    if (baseIndex != null && baseIndex < AppBaseTheme.values.length) {
      _base = AppBaseTheme.values[baseIndex];
    }
    final accentIndex = prefs.getInt(_accentKey);
    if (accentIndex != null && accentIndex < AppAccentColor.values.length) {
      _accentColor = AppAccentColor.values[accentIndex];
    }
    notifyListeners();
  }

  Future<void> setBase(AppBaseTheme value) async {
    _base = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_baseKey, value.index);
  }

  Future<void> setAccent(AppAccentColor value) async {
    _accentColor = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, value.index);
  }
}
