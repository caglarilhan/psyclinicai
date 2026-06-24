/// Single-value store for the most recent release version the user
/// has already dismissed in the in-app "What's new" sheet. When
/// `lastSeen != ReleaseNotes.latest.version` the AppShell pops the
/// sheet on next dashboard mount.
///
/// SharedPreferences-backed because release-note read state is
/// non-PHI, ephemeral, and per-device by design.
library;

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'telemetry_service.dart';

class ReleaseNotesSeenRepository {
  ReleaseNotesSeenRepository({String? storageKey})
    : _key = storageKey ?? _storageId;

  /// SharedPreferences key id for this repo — not a credential.
  static const _storageId = 'release_notes.last_seen_v1';
  final String _key;

  Future<String?> lastSeen() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final v = sp.getString(_key);
      if (v == null || v.isEmpty) return null;
      return v;
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'release_notes_seen_read',
        ),
      );
      return null;
    }
  }

  Future<void> markSeen(String version) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_key, version);
      unawaited(
        TelemetryService.instance.capture(
          'release_notes.seen',
          properties: {'version': version},
        ),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'release_notes_seen_write',
        ),
      );
    }
  }

  Future<bool> shouldShow(String currentVersion) async {
    final seen = await lastSeen();
    return seen != currentVersion;
  }
}
