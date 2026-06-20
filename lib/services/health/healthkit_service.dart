/// Sprint 33 P3 — Apple HealthKit integration scaffolding.
///
/// Talks to the platform via a Flutter `MethodChannel`. The native side
/// (iOS) implements two methods:
///
///   * `requestAuthorization(types: [String])` → bool
///   * `writePromScore({instrument, score, takenAtIso})` → bool
///
/// On Android / web / desktop the platform channel is unavailable so
/// every method returns `false` after logging once. We intentionally
/// keep this surface narrow:
///
///   - Read scope NOT exposed yet (Sprint 34 — chart trends).
///   - No raw audio, no transcript bytes — only PROM totals.
///   - No PHI in the channel arguments beyond `instrument` + `score`.
///
/// Skill-panel coverage: senior-frontend (channel surface), apple-hig-
/// expert (HealthKit idioms), healthcare-emr-patterns (LOINC mapping),
/// healthcare-phi-compliance (scope minimisation).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// LOINC mapping mirrored from `functions/src/ehr_bridge.ts` so the
/// Apple Health entry carries the same identifier the EHR Observation
/// will. Keep in sync if the table changes there.
const Map<String, String> kPromLoincMap = {
  'PHQ-9': '44261-6',
  'GAD-7': '70274-6',
};

@immutable
class PromScore {
  const PromScore({
    required this.instrument,
    required this.score,
    required this.takenAtIso,
  });

  final String instrument;
  final int score;
  final String takenAtIso;

  Map<String, Object?> toChannelArgs() => {
        'instrument': instrument,
        'score': score,
        'takenAtIso': takenAtIso,
        'loinc': kPromLoincMap[instrument],
      };
}

/// Validation rules — pure, exported for unit tests.
class PromValidation {
  const PromValidation._();

  static const Map<String, int> kMaxScoreByInstrument = {
    'PHQ-9': 27,
    'GAD-7': 21,
  };

  static String? validate(PromScore s) {
    if (!kPromLoincMap.containsKey(s.instrument)) {
      return 'unsupported_instrument';
    }
    final max = kMaxScoreByInstrument[s.instrument];
    if (max == null) return 'unsupported_instrument';
    if (s.score < 0) return 'score_negative';
    if (s.score > max) return 'score_above_max';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')
        .hasMatch(s.takenAtIso)) {
      return 'taken_at_not_iso';
    }
    return null;
  }
}

class HealthKitService {
  HealthKitService({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('psyclinicai.health/healthkit');

  final MethodChannel _channel;
  bool _platformLoggedAsUnavailable = false;

  /// Request the minimum HealthKit scope the app needs. Returns true
  /// when the user granted at least the write scope for any of the
  /// requested types.
  Future<bool> requestAuthorization({
    List<String> types = const ['PHQ-9', 'GAD-7'],
  }) async {
    try {
      final granted = await _channel.invokeMethod<bool>(
        'requestAuthorization',
        {'types': types},
      );
      return granted == true;
    } on MissingPluginException {
      _logUnavailable();
      return false;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[healthkit] auth error: ${e.code}');
      return false;
    }
  }

  /// Write a single PROM score. Returns true on success.
  Future<bool> writePromScore(PromScore score) async {
    final reason = PromValidation.validate(score);
    if (reason != null) {
      if (kDebugMode) debugPrint('[healthkit] reject — $reason');
      return false;
    }
    try {
      final ok = await _channel.invokeMethod<bool>(
        'writePromScore',
        score.toChannelArgs(),
      );
      return ok == true;
    } on MissingPluginException {
      _logUnavailable();
      return false;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[healthkit] write error: ${e.code}');
      return false;
    }
  }

  void _logUnavailable() {
    if (_platformLoggedAsUnavailable) return;
    _platformLoggedAsUnavailable = true;
    if (kDebugMode) {
      debugPrint(
          '[healthkit] platform channel unavailable — no-op for this build.');
    }
  }
}
