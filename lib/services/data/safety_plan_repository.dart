import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/safety_plan.dart';

/// Offline safety-plan store (SharedPreferences) — one plan per patient.
class SafetyPlanRepository {
  static const _key = 'safety_plans';

  final Map<String, SafetyPlan> _byPatient = {};
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      _byPatient.clear();
      for (final s in raw) {
        final plan =
            SafetyPlan.fromJson(jsonDecode(s) as Map<String, dynamic>);
        _byPatient[plan.patientId] = plan;
      }
    } catch (_) {
      _byPatient.clear();
    }
    _loaded = true;
  }

  SafetyPlan? forPatient(String patientId) => _byPatient[patientId];

  Future<void> save(SafetyPlan plan) async {
    _byPatient[plan.patientId] = plan;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _key, _byPatient.values.map((p) => jsonEncode(p.toJson())).toList());
    } catch (_) {
      // best-effort
    }
  }
}
