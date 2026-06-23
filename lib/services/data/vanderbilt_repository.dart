/// SharedPreferences-backed log of Vanderbilt ADHD screening
/// assessments. One row per (patient, respondent, capture
/// timestamp). The clinician usually orders both a parent + a
/// teacher form for the same child so both rows live side-by-side.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/vanderbilt_assessment.dart';
import 'telemetry_service.dart';

class VanderbiltRepository {
  VanderbiltRepository({String? storageKey}) : _key = storageKey ?? _defaultKey;

  // gitleaks:allow — SharedPreferences storage key, not a secret.
  static const _defaultKey = 'nichq_vanderbilt_v1';
  final String _key;

  final List<VanderbiltAssessment> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      for (final s in raw) {
        try {
          _items.add(
            VanderbiltAssessment.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'vanderbilt_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'vanderbilt_init'),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(
        _key,
        _items.map((a) => jsonEncode(a.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'vanderbilt_save'),
      );
    }
  }

  List<VanderbiltAssessment> get all => List.unmodifiable(_items);

  List<VanderbiltAssessment> forPatient(
    String patientId, {
    VanderbiltRespondent? respondent,
  }) {
    final list =
        _items
            .where((a) => a.patientId == patientId)
            .where((a) => respondent == null || a.respondent == respondent)
            .toList()
          ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return list;
  }

  /// Most recent parent + teacher pair for the child. Returns
  /// null entries when the corresponding form hasn't been
  /// captured yet — the clinician panel uses this to flag
  /// "teacher form pending" alongside the existing parent score.
  ({VanderbiltAssessment? parent, VanderbiltAssessment? teacher}) latestPair(
    String patientId,
  ) {
    final list = forPatient(patientId);
    VanderbiltAssessment? parent;
    VanderbiltAssessment? teacher;
    for (final a in list.reversed) {
      if (parent == null && a.respondent == VanderbiltRespondent.parent) {
        parent = a;
      }
      if (teacher == null && a.respondent == VanderbiltRespondent.teacher) {
        teacher = a;
      }
      if (parent != null && teacher != null) break;
    }
    return (parent: parent, teacher: teacher);
  }

  Future<VanderbiltAssessment> upsert(VanderbiltAssessment a) async {
    final i = _items.indexWhere((x) => x.id == a.id);
    if (i < 0) {
      _items.add(a);
    } else {
      _items[i] = a;
    }
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'vanderbilt.upsert',
        properties: {
          'respondent': a.respondent.id,
          'subtype': a.subtype.id,
          'inattn': a.inattentionSymptomCount,
          'hyper': a.hyperactivitySymptomCount,
          'odd_pos': a.oppositionalPositiveScreen,
          'conduct_pos': a.conductPositiveScreen,
        },
      ),
    );
    return a;
  }

  Future<void> debugReset() async {
    _items.clear();
    _loaded = false;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_key);
    } catch (_) {}
  }
}
