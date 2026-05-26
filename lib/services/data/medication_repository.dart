import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/medication.dart';

/// Offline medication store (SharedPreferences) — works on web + mobile.
class MedicationRepository {
  static const _key = 'medications';

  final List<Medication> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      _items
        ..clear()
        ..addAll(raw.map(
            (s) => Medication.fromJson(jsonDecode(s) as Map<String, dynamic>)));
    } catch (_) {
      _items.clear();
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _key, _items.map((m) => jsonEncode(m.toJson())).toList());
    } catch (_) {
      // best-effort
    }
  }

  /// Active first, then by name.
  List<Medication> forPatient(String patientId) {
    final list = _items.where((m) => m.patientId == patientId).toList()
      ..sort((a, b) {
        if (a.active != b.active) return a.active ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return list;
  }

  Future<void> add(Medication m) async {
    _items.add(m);
    await _save();
  }

  Future<void> toggleActive(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(active: !_items[i].active);
    await _save();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _save();
  }
}
