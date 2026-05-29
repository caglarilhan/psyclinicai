import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/medication.dart';
import 'telemetry_service.dart';

/// Offline medication store (SharedPreferences) — works on web + mobile.
class MedicationRepository {
  static const _key = 'medications';

  final List<Medication> _items = [];
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
          _items
              .add(Medication.fromJson(jsonDecode(s) as Map<String, dynamic>));
        } catch (err, st) {
          dropped++;
          TelemetryService.instance
              .captureError(err, st, hint: 'medication_decode_record');
        }
      }
      if (dropped > 0) {
        TelemetryService.instance.captureError(
          StateError('Dropped $dropped corrupt medication record(s) on load'),
          StackTrace.current,
          hint: 'medication_init',
        );
      }
    } catch (e, st) {
      TelemetryService.instance.captureError(e, st, hint: 'medication_init');
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _key, _items.map((m) => jsonEncode(m.toJson())).toList());
    } catch (e, st) {
      // Medication is clinical data — a lost write must be observable.
      TelemetryService.instance.captureError(e, st, hint: 'medication_save');
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
