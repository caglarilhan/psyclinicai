/// Per-device acknowledgement that the clinician has completed
/// the local TOTP enrolment wizard. Distinct from the Firestore-
/// backed [MfaEnrolment] in `mfa_enrolment_repository.dart` —
/// that one tracks the per-tenant recovery-code state; this one is
/// the local "did I finish the wizard on this device" signal that
/// drives the dashboard SetupChecklist `mfa` step (PR #68).
///
/// SharedPreferences-backed because the flag is per-device and
/// non-PHI: just a UTC timestamp of when the wizard finished.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telemetry_service.dart';

class MfaLocalRepository {
  MfaLocalRepository({String? storageKey}) : _key = storageKey ?? _storageId;

  /// SharedPreferences key id for this repo — not a credential.
  static const _storageId = 'mfa.local_acknowledged_at_v1';
  final String _key;

  final ValueNotifier<DateTime?> _at = ValueNotifier<DateTime?>(null);
  bool _loaded = false;

  ValueListenable<DateTime?> get listenable => _at;

  bool get isAcknowledged => _at.value != null;

  DateTime? get acknowledgedAt => _at.value;

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        _at.value = DateTime.tryParse(raw)?.toUtc();
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'mfa_local_init'),
      );
    }
    _loaded = true;
  }

  Future<void> markAcknowledged({DateTime? at}) async {
    final stamp = (at ?? DateTime.now()).toUtc();
    _at.value = stamp;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_key, stamp.toIso8601String());
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'mfa_local_save'),
      );
    }
    unawaited(TelemetryService.instance.capture('mfa.local_acknowledged'));
  }

  Future<void> markCleared() async {
    if (_at.value == null) return;
    _at.value = null;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'mfa_local_clear'),
      );
    }
    unawaited(TelemetryService.instance.capture('mfa.local_cleared'));
  }

  @visibleForTesting
  Future<void> debugReset() async {
    _at.value = null;
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (_) {}
  }
}
