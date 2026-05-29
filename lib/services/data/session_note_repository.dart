import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/session_note.dart';

/// Offline per-patient session-note store (SharedPreferences). Feeds the
/// Clinical Memory pre-session brief. On first run it seeds a couple of demo
/// notes for the demo patient so the brief has history to synthesize.
class SessionNoteRepository {
  static const _key = 'session_notes';

  final List<SessionNote> _notes = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key);
      if (raw == null) {
        _notes
          ..clear()
          ..addAll(_demoSeed());
        await _persist();
      } else {
        _notes
          ..clear()
          ..addAll(raw.map((s) =>
              SessionNote.fromJson(jsonDecode(s) as Map<String, dynamic>)));
      }
    } catch (_) {
      _notes.clear();
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _key, _notes.map((n) => jsonEncode(n.toJson())).toList());
    } catch (_) {
      // best-effort
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
        markdown: 'S: Reports persistent worry about work performance and '
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
        markdown: 'S: "Some days I feel like there is no point." Denies plan or '
            'intent. Breathing log done 3/7 days. O: Tearful early, brighter by '
            'end; alliance strong. A: GAD with transient hopelessness — risk '
            'reviewed, no active SI. P: Introduced cognitive restructuring; '
            'planned graded exposure to the upcoming job interview; revisit '
            'safety planning if hopelessness returns.',
      ),
    ];
  }
}
