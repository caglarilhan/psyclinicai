/// SharedPreferences-backed log of FIT ratings (ORS + SRS).
/// Each row is one completed rating; the dropout-prediction
/// dashboard joins by patient + sorted timeline.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/feedback_rating.dart';
import 'telemetry_service.dart';

class FeedbackRatingRepository {
  FeedbackRatingRepository({String? storageKey})
    : _key = storageKey ?? _defaultKey;

  static const _defaultKey = 'feedback_ratings_v1';
  final String _key;

  final List<FeedbackRating> _items = [];
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
            FeedbackRating.fromJson(jsonDecode(s) as Map<String, dynamic>),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'feedback_rating_decode',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'feedback_rating_init',
        ),
      );
    }
    _loaded = true;
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(
        _key,
        _items.map((r) => jsonEncode(r.toJson())).toList(),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'feedback_rating_save',
        ),
      );
    }
  }

  List<FeedbackRating> get all => List.unmodifiable(_items);

  List<FeedbackRating> forPatient(String patientId, {FitKind? kind}) {
    final list =
        _items
            .where((r) => r.patientId == patientId)
            .where((r) => kind == null || r.kind == kind)
            .toList()
          ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return list;
  }

  Future<FeedbackRating> save(FeedbackRating rating) async {
    final i = _items.indexWhere((r) => r.id == rating.id);
    if (i < 0) {
      _items.add(rating);
    } else {
      _items[i] = rating;
    }
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'feedback_rating.saved',
        properties: {
          'kind': rating.kind.id,
          'total': rating.total,
          'below_cutoff': rating.isBelowCutoff,
        },
      ),
    );
    return rating;
  }

  /// Reliable-change index between consecutive ORS scores. Miller
  /// uses **5 points** as the clinically-meaningful change for
  /// adult ORS — a delta ≤ -5 across two sessions is a dropout
  /// risk signal.
  static const int orsReliableChange = 5;

  /// True when the patient's ORS total has dropped by 5+ points
  /// across their last two ORS sessions. Returns false if there
  /// aren't yet two ORS ratings on file.
  bool patientHasDropoutSignal(String patientId) {
    final orsList = forPatient(patientId, kind: FitKind.ors);
    if (orsList.length < 2) return false;
    final last = orsList[orsList.length - 1].total;
    final prev = orsList[orsList.length - 2].total;
    return (last - prev) <= -orsReliableChange;
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
