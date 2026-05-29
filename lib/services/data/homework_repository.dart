import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/homework_item.dart';
import 'telemetry_service.dart';

/// Offline homework store (SharedPreferences) — works on web + mobile.
/// Keyed list of [HomeworkItem]; filter by patient in the UI.
class HomeworkRepository {
  static const _key = 'homework_items';

  final List<HomeworkItem> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      var dropped = 0;
      for (final s in raw) {
        // Per-record resilience: one corrupt entry must not wipe the list.
        try {
          _items.add(
              HomeworkItem.fromJson(jsonDecode(s) as Map<String, dynamic>));
        } catch (err, st) {
          dropped++;
          TelemetryService.instance
              .captureError(err, st, hint: 'homework_decode_record');
        }
      }
      if (dropped > 0) {
        TelemetryService.instance.captureError(
          StateError('Dropped $dropped corrupt homework record(s) on load'),
          StackTrace.current,
          hint: 'homework_init',
        );
      }
    } catch (e, st) {
      TelemetryService.instance.captureError(e, st, hint: 'homework_init');
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _key, _items.map((i) => jsonEncode(i.toJson())).toList());
    } catch (e, st) {
      TelemetryService.instance.captureError(e, st, hint: 'homework_save');
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
