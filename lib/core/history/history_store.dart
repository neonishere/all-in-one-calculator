import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history_entry.dart';

/// Persisted log of past calculations, newest first.
class HistoryStore extends ChangeNotifier {
  static const _key = 'calc_history_v1';

  final List<HistoryEntry> _entries = [];

  List<HistoryEntry> get entries => List.unmodifiable(_entries.reversed);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    _entries
      ..clear()
      ..addAll(raw.map((s) => HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>)));
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _entries.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> add(String expression, String result) async {
    _entries.add(HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> setNote(String id, String? note) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final old = _entries[index];
    _entries[index] = HistoryEntry(
      id: old.id,
      expression: old.expression,
      result: old.result,
      timestamp: old.timestamp,
      note: (note == null || note.isEmpty) ? null : note,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _entries.clear();
    notifyListeners();
    await _persist();
  }
}
