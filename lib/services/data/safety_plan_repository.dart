import 'dart:async';
import 'dart:convert';

import '../../models/safety_plan.dart';
import 'secure_prefs.dart';
import 'telemetry_service.dart';

/// Offline safety-plan store — one plan per patient.
///
/// A Stanley-Brown crisis safety plan is PHI, so it persists to the
/// device's secure storage via [SecurePrefs] (iOS Keychain / Android
/// encrypted prefs under the centralised platform options), never
/// plaintext. Failures are reported to telemetry rather than silently
/// swallowed: an invisible "no crisis plan" state for an at-risk
/// patient is unacceptable.
class SafetyPlanRepository {
  SafetyPlanRepository({SecurePrefs? prefs})
    : _prefs = prefs ?? SecurePrefs.instance;

  static const _key = 'safety_plans';
  final SecurePrefs _prefs;

  final Map<String, SafetyPlan> _byPatient = {};
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _byPatient.clear();
    try {
      final raw = await _prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        var dropped = 0;
        for (final e in list) {
          // Per-record resilience: one corrupt plan must not wipe the rest.
          try {
            final plan = SafetyPlan.fromJson(e as Map<String, dynamic>);
            _byPatient[plan.patientId] = plan;
          } catch (err, st) {
            dropped++;
            unawaited(
              TelemetryService.instance.captureError(
                err,
                st,
                hint: 'safety_plan_decode_record',
              ),
            );
          }
        }
        if (dropped > 0) {
          unawaited(
            TelemetryService.instance.captureError(
              StateError('Dropped $dropped corrupt safety plan(s) on load'),
              StackTrace.current,
              hint: 'safety_plan_init',
            ),
          );
        }
      }
    } catch (e, st) {
      // Surface the read/decode failure; keep whatever parsed so far.
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'safety_plan_init'),
      );
    }
    _loaded = true;
  }

  SafetyPlan? forPatient(String patientId) => _byPatient[patientId];

  /// All plans across patients (read-only) — for caseload aggregation.
  List<SafetyPlan> get all => _byPatient.values.toList(growable: false);

  /// Persists [plan]. Throws on storage failure so the caller can tell the
  /// clinician the crisis plan was NOT saved — never report a false success.
  Future<void> save(SafetyPlan plan) async {
    _byPatient[plan.patientId] = plan;
    try {
      final raw = jsonEncode(
        _byPatient.values.map((p) => p.toJson()).toList(growable: false),
      );
      await _prefs.setString(_key, raw);
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'safety_plan_save'),
      );
      rethrow;
    }
  }
}
