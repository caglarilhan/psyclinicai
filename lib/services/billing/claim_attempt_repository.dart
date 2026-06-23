/// SharedPreferences-backed log of `ClaimAttempt` rows. One row
/// per submission attempt for an insurance claim — original 837P,
/// each subsequent corrected resubmission, and each appeal-driven
/// resubmission.
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/claim_attempt.dart';
import '../data/telemetry_service.dart';

class ClaimAttemptRepository {
  ClaimAttemptRepository({String? storageBucket})
    : _bucket = storageBucket ?? _storageId;

  // SharedPreferences bucket id for this repo — not a credential.
  static const _storageId = 'claim_attempts_v1';
  final String _bucket;

  final List<ClaimAttempt> _items = [];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    _items.clear();
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getStringList(_bucket) ?? [];
      for (final s in raw) {
        try {
          _items.add(
            ClaimAttempt.fromJson(jsonDecode(s) as Map<String, dynamic>),
          );
        } catch (err, st) {
          unawaited(
            TelemetryService.instance.captureError(
              err,
              st,
              hint: 'claim_attempt_decode_record',
            ),
          );
        }
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'claim_attempt_init',
        ),
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
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'claim_attempt_save',
        ),
      );
    }
  }

  List<ClaimAttempt> get all => List.unmodifiable(_items);

  /// History for one claim id, oldest attempt first.
  ClaimAttemptHistory historyFor(String claimId) {
    final list = _items.where((a) => a.claimId == claimId).toList()
      ..sort((a, b) => a.attemptNumber.compareTo(b.attemptNumber));
    return ClaimAttemptHistory(claimId: claimId, attempts: list);
  }

  /// Record a brand-new submission. Auto-increments `attemptNumber`
  /// based on the existing history.
  Future<ClaimAttempt> recordAttempt({
    required String claimId,
    required DateTime submittedAt,
    String? refNumber,
    String? appealLetterId,
    String notes = '',
  }) async {
    final prior = historyFor(claimId).attempts;
    final next = ClaimAttempt(
      id: 'attempt-${submittedAt.microsecondsSinceEpoch}-$claimId',
      claimId: claimId,
      attemptNumber: prior.length + 1,
      submittedAt: submittedAt,
      refNumber: refNumber,
      appealLetterId: appealLetterId,
      notes: notes,
    );
    _items.add(next);
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'claim_attempt.recorded',
        properties: {
          'attempt': next.attemptNumber,
          'has_appeal': appealLetterId != null,
        },
      ),
    );
    return next;
  }

  /// Mark an attempt's outcome (accepted / denied / paid / upheld /
  /// overturned). Used when the X12 277 or EOB comes back.
  Future<ClaimAttempt> recordOutcome({
    required String attemptId,
    required ClaimAttemptOutcome outcome,
    String? denialReasonCode,
    DateTime? adjudicatedAt,
    String? notes,
  }) async {
    final i = _items.indexWhere((a) => a.id == attemptId);
    if (i < 0) {
      throw StateError('ClaimAttempt not found: $attemptId');
    }
    final updated = _items[i].copyWith(
      outcome: outcome,
      denialReasonCode: denialReasonCode,
      adjudicatedAt: adjudicatedAt ?? DateTime.now().toUtc(),
      notes: notes,
    );
    _items[i] = updated;
    await _save();
    unawaited(
      TelemetryService.instance.capture(
        'claim_attempt.outcome',
        properties: {
          'outcome': outcome.id,
          'attempt': updated.attemptNumber,
          'has_appeal': updated.isAppealResubmission,
          'has_denial_code': denialReasonCode != null,
        },
      ),
    );
    return updated;
  }

  /// Caseload-wide recovery rate — fraction of denied claims that
  /// later resolved to paid / overturned via a later attempt.
  /// Returns 0 when there are no denials.
  double recoveryRate() {
    final byClaim = <String, List<ClaimAttempt>>{};
    for (final a in _items) {
      byClaim.putIfAbsent(a.claimId, () => []).add(a);
    }
    var denied = 0;
    var recovered = 0;
    for (final list in byClaim.values) {
      final history = ClaimAttemptHistory(
        claimId: list.first.claimId,
        attempts: list,
      );
      if (history.attempts.any(
        (a) => a.outcome == ClaimAttemptOutcome.denied,
      )) {
        denied++;
        if (history.recoveredAfterDenial) recovered++;
      }
    }
    if (denied == 0) return 0;
    return recovered / denied;
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
