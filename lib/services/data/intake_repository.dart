import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/patient_intake.dart';
import 'telemetry_service.dart';

/// Offline patient-intake store — one intake per patient.
///
/// Captures PHI (demographics, allergies, meds, signed consent), so the
/// payload is held in [FlutterSecureStorage] (iOS Keychain / Android
/// encrypted prefs). Failures bubble up to the caller so we never report
/// a false "intake saved" message while the consent record was lost.
class IntakeRepository {
  IntakeRepository({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions:
                  AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  static const _key = 'patient_intakes';
  final FlutterSecureStorage _storage;

  final Map<String, PatientIntake> _byPatient = {};
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _byPatient.clear();
    try {
      final raw = await _storage.read(key: _key);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        var dropped = 0;
        for (final e in list) {
          // Per-record resilience: one corrupt intake must not wipe the rest.
          try {
            final intake =
                PatientIntake.fromJson(e as Map<String, dynamic>);
            _byPatient[intake.patientId] = intake;
          } catch (err, st) {
            dropped++;
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'intake_decode_record',
            );
          }
        }
        if (dropped > 0) {
          TelemetryService.instance.captureError(
            StateError('Dropped $dropped corrupt intake record(s) on load'),
            StackTrace.current,
            hint: 'intake_init',
          );
        }
      }
    } catch (e, st) {
      TelemetryService.instance.captureError(e, st, hint: 'intake_init');
    }
    _loaded = true;
  }

  PatientIntake? forPatient(String patientId) => _byPatient[patientId];

  /// All intakes (read-only) — useful for the caseload dashboard.
  List<PatientIntake> get all => _byPatient.values.toList(growable: false);

  /// Persists [intake]. Throws on storage failure so the caller can tell
  /// the clinician the consent record was NOT saved.
  Future<void> save(PatientIntake intake) async {
    _byPatient[intake.patientId] = intake;
    try {
      final raw = jsonEncode(
        _byPatient.values.map((p) => p.toJson()).toList(growable: false),
      );
      await _storage.write(key: _key, value: raw);
    } catch (e, st) {
      TelemetryService.instance.captureError(e, st, hint: 'intake_save');
      rethrow;
    }
  }

  /// Test helper — wipes the cached snapshot without touching disk.
  /// Real production code should not call this.
  void resetForTesting() {
    _byPatient.clear();
    _loaded = false;
  }
}
