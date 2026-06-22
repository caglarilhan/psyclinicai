import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/session_note.dart';
import 'telemetry_service.dart';

/// Offline per-patient session-note store. Feeds the Clinical Memory
/// pre-session brief. Firestore is the authoritative store; this is a local
/// cache, but the notes are clinical text (PHI) so it persists to the device's
/// secure storage rather than plaintext SharedPreferences. On first run it
/// seeds a couple of demo notes for the demo patient so the brief has history.
class SessionNoteRepository {
  SessionNoteRepository({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  static const _key = 'session_notes';
  final FlutterSecureStorage _storage;

  final List<SessionNote> _notes = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _notes.clear();
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) {
        _notes.addAll(_demoSeed());
        await _persist();
      } else {
        final list = jsonDecode(raw) as List<dynamic>;
        var dropped = 0;
        for (final e in list) {
          // Per-record resilience: one corrupt note must not wipe history.
          try {
            _notes.add(SessionNote.fromJson(e as Map<String, dynamic>));
          } catch (err, st) {
            dropped++;
            unawaited(
              TelemetryService.instance.captureError(
                err,
                st,
                hint: 'session_note_decode_record',
              ),
            );
          }
        }
        if (dropped > 0) {
          unawaited(
            TelemetryService.instance.captureError(
              StateError('Dropped $dropped corrupt session note(s) on load'),
              StackTrace.current,
              hint: 'session_note_init',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'session_note_init',
        ),
      );
    }
    _loaded = true;
  }

  /// Notes for [patientId], most recent first.
  List<SessionNote> forPatient(String patientId) {
    final list = _notes.where((n) => n.patientId == patientId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> add(SessionNote note) async {
    _notes.add(note);
    await _persist();
  }

  Future<void> _persist() async {
    // Best-effort: Firestore is authoritative and the note is shown to the
    // clinician regardless, but a cache-write failure is still reported.
    try {
      final raw = jsonEncode(
        _notes.map((n) => n.toJson()).toList(growable: false),
      );
      await _storage.write(key: _key, value: raw);
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'session_note_persist',
        ),
      );
    }
  }

  // Demo history so the pre-session brief demonstrates well on the demo chart.
  List<SessionNote> _demoSeed() {
    final now = DateTime.now();
    return [
      SessionNote(
        id: 'seed-demo-1-a',
        patientId: 'demo-1',
        createdAt: now.subtract(const Duration(days: 14)),
        markdown:
            'S: Reports persistent worry about work performance and '
            'sleep-onset difficulty. O: Anxious affect, future-oriented '
            'rumination. A: GAD (F41.1), moderate. P: Began psychoeducation on '
            'the worry cycle; assigned a daily breathing log; goal — reduce '
            'GAD-7 below 10 over 8 weeks.',
      ),
      SessionNote(
        id: 'seed-demo-1-b',
        patientId: 'demo-1',
        flaggedRisk: true,
        createdAt: now.subtract(const Duration(days: 7)),
        markdown:
            'S: "Some days I feel like there is no point." Denies plan or '
            'intent. Breathing log done 3/7 days. O: Tearful early, brighter by '
            'end; alliance strong. A: GAD with transient hopelessness — risk '
            'reviewed, no active SI. P: Introduced cognitive restructuring; '
            'planned graded exposure to the upcoming job interview; revisit '
            'safety planning if hopelessness returns.',
      ),
    ];
  }
}
