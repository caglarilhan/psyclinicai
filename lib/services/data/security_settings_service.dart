import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted per-user security flags surfaced by the MFA wizard and
/// the post-sign-in interceptor.
///
/// The demo build persists with [SharedPreferences] so a sign-in →
/// MFA enrol → sign-out → sign-in round trip keeps the enrolment
/// record. Production swaps this out for a Firestore-backed
/// repository keyed on Firebase Auth UID; the surface stays the same.
class SecuritySettingsService {
  SecuritySettingsService._({Future<SharedPreferences> Function()? prefs})
    : _prefsFactory = prefs;

  static SecuritySettingsService instance = SecuritySettingsService._();

  /// Test seam — swap in a synthetic backend before invoking the
  /// singleton. The previous static mutable field was a hazard; tests
  /// now wrap setup/teardown around this entry point.
  @visibleForTesting
  static void setTestInstance(Future<SharedPreferences> Function() prefs) {
    instance = SecuritySettingsService._(prefs: prefs);
  }

  @visibleForTesting
  static void resetTestInstance() {
    instance = SecuritySettingsService._();
  }

  final Future<SharedPreferences> Function()? _prefsFactory;

  String _mfaKey(String uid) => 'mfa_enrolled:$uid';

  Future<SharedPreferences> _prefs() =>
      _prefsFactory?.call() ?? SharedPreferences.getInstance();

  /// True if [uid] completed the TOTP wizard at any point.
  Future<bool> isMfaEnrolled(String uid) async {
    if (uid.isEmpty) return false;
    final prefs = await _prefs();
    return prefs.getBool(_mfaKey(uid)) ?? false;
  }

  /// Persist the enrolment marker. Called from the MFA wizard's
  /// "I saved them — finish" handler.
  Future<void> markMfaEnrolled(String uid) async {
    if (uid.isEmpty) return;
    final prefs = await _prefs();
    await prefs.setBool(_mfaKey(uid), true);
  }

  /// Clear the marker (re-enrol after device loss).
  Future<void> resetMfa(String uid) async {
    if (uid.isEmpty) return;
    final prefs = await _prefs();
    await prefs.remove(_mfaKey(uid));
  }
}
