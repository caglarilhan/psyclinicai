import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/homework_item.dart';

/// Offline homework store (SharedPreferences) — works on web + mobile.
/// Keyed list of [HomeworkItem]; filter by patient in the UI.
class HomeworkRepository {
  static const _key = 'homework_items';

  final List<HomeworkItem> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      _items
        ..clear()
        ..addAll(raw.map((s) =>
            HomeworkItem.fromJson(jsonDecode(s) as Map<String, dynamic>)));
    } catch (_) {
      _items.clear();
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _key, _items.map((i) => jsonEncode(i.toJson())).toList());
    } catch (_) {
      // best-effort
    }
  }

  /// All items across patients (read-only) — for caseload aggregation.
  List<HomeworkItem> get all => List.unmodifiable(_items);

  List<HomeworkItem> forPatient(String patientId) {
    final list = _items.where((i) => i.patientId == patientId).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  Future<void> add(HomeworkItem item) async {
    _items.add(item);
    await _save();
  }

  Future<void> toggleDone(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(done: !_items[i].done);
    await _save();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _save();
  }
}
