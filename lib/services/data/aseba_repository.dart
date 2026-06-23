/// SharedPreferences-backed log of ASEBA score records. One row
/// per (patient, form, capture timestamp). Pairs with the
/// Vanderbilt repo (PR #15) for the child-market assessment
/// stack — Vanderbilt for ADHD-specific screening, ASEBA for
/// broad-band syndrome trending.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/aseba_score_record.dart';
import 'telemetry_service.dart';

class AsebaRepository {
  AsebaRepository({String? storageBucket})
    : _bucket = storageBucket ?? _storageId;

  // SharedPreferences bucket id for this repo — not a credential.
  static const _storageId = 'aseba_v1';
  final String _bucket;

  final List<AsebaScoreRecord> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_bucket) ?? [];
      for (final s in raw) {
        try {
          _items.add(
            AsebaScoreRecord.fromJson(jsonDecode(s) as Map<String, dynamic>),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'aseba_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'aseba_init'),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(
        _bucket,
        _items.map((a) => jsonEncode(a.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'aseba_save'),
      );
    }
  }

  List<AsebaScoreRecord> get all => List.unmodifiable(_items);

  /// All records for the patient, oldest first (so the outcomes
  /// chart can plot left-to-right).
  List<AsebaScoreRecord> forPatient(String patientId, {AsebaForm? form}) {
    final list =
        _items
            .where((a) => a.patientId == patientId)
            .where((a) => form == null || a.form == form)
            .toList()
          ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return list;
  }

  /// Latest record per form for this patient. Header card uses
  /// this to show the most recent CBCL + TRF side by side.
  Map<AsebaForm, AsebaScoreRecord> latestByForm(String patientId) {
    final out = <AsebaForm, AsebaScoreRecord>{};
    for (final a in forPatient(patientId)) {
      out[a.form] = a;
    }
    return out;
  }

  Future<AsebaScoreRecord> upsert(AsebaScoreRecord a) async {
    final i = _items.indexWhere((x) => x.id == a.id);
    if (i < 0) {
      _items.add(a);
    } else {
      _items[i] = a;
    }
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'aseba.upsert',
        properties: {
          'form': a.form.id,
          'syndrome_clinical': a.syndromeClinicalCount,
          'dsm_clinical': a.dsmClinicalCount,
          'total_problems_clinical': a.totalProblemsClinical,
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
      await sp.remove(_bucket);
    } catch (_) {}
  }
}
