import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tool ids the user has starred, shown in a "Favorites" section at the
/// top of the all-tools menu. Persisted so it survives app restarts.
class FavoritesStore extends ChangeNotifier {
  static const _key = 'favorite_tool_ids_v1';

  final Set<String> _ids = {};

  Set<String> get ids => _ids;

  bool isFavorite(String toolId) => _ids.contains(toolId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_key) ?? const []);
    notifyListeners();
  }

  Future<void> toggle(String toolId) async {
    if (!_ids.add(toolId)) _ids.remove(toolId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
  }
}
