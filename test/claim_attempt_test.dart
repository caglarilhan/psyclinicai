/// Coverage for ClaimAttempt model + repository. Attempt number
/// auto-increment, JSON round-trip, history ordering, recoveredAfterDenial
/// logic, recovery-rate math, corrupt-record drop.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/claim_attempt.dart';
import 'package:psyclinicai/services/billing/claim_attempt_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

ClaimAttempt _attempt({
  String id = 'a1',
  String claimId = 'c1',
  int n = 1,
  ClaimAttemptOutcome outcome = ClaimAttemptOutcome.pending,
  String? appealLetterId,
  String? denialReasonCode,
  DateTime? at,
}) => ClaimAttempt(
  id: id,
  claimId: claimId,
  attemptNumber: n,
  submittedAt: at ?? DateTime.utc(2026, 6, 23, 10),
  outcome: outcome,
  appealLetterId: appealLetterId,
  denialReasonCode: denialReasonCode,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ClaimAttempt model', () {
    test('outcome.isResolved fires on paid / upheld / overturned', () {
      expect(ClaimAttemptOutcome.paid.isResolved, isTrue);
      expect(ClaimAttemptOutcome.upheld.isResolved, isTrue);
      expect(ClaimAttemptOutcome.overturned.isResolved, isTrue);
      expect(ClaimAttemptOutcome.pending.isResolved, isFalse);
      expect(ClaimAttemptOutcome.denied.isResolved, isFalse);
    });

    test('isAppealResubmission tracks appealLetterId presence', () {
      expect(_attempt().isAppealResubmission, isFalse);
      expect(_attempt(appealLetterId: 'letter-1').isAppealResubmission, isTrue);
    });

    test('isOriginal fires on attempt 1 only', () {
      expect(_attempt().isOriginal, isTrue);
      expect(_attempt(n: 2).isOriginal, isFalse);
    });

    test('JSON round-trip preserves outcome + appealLetterId', () {
      final a = _attempt(
        outcome: ClaimAttemptOutcome.overturned,
        appealLetterId: 'letter-7',
        denialReasonCode: 'CO-50',
      );
      final back = ClaimAttempt.fromJson(a.toJson());
      expect(back.outcome, ClaimAttemptOutcome.overturned);
      expect(back.appealLetterId, 'letter-7');
      expect(back.denialReasonCode, 'CO-50');
    });
  });

  group('ClaimAttemptHistory', () {
    test('hasAppeal fires when any attempt was appeal-driven', () {
      final h = ClaimAttemptHistory(
        claimId: 'c1',
        attempts: [
          _attempt(outcome: ClaimAttemptOutcome.denied),
          _attempt(id: 'a2', n: 2, appealLetterId: 'letter-1'),
        ],
      );
      expect(h.hasAppeal, isTrue);
    });

    test('latest is the highest-numbered attempt', () {
      final h = ClaimAttemptHistory(
        claimId: 'c1',
        attempts: [
          _attempt(id: 'a3', n: 3, outcome: ClaimAttemptOutcome.paid),
          _attempt(outcome: ClaimAttemptOutcome.denied),
          _attempt(id: 'a2', n: 2, outcome: ClaimAttemptOutcome.denied),
        ],
      );
      expect(h.latest?.id, 'a3');
      expect(h.isResolved, isTrue);
    });

    test('recoveredAfterDenial fires when a paid attempt follows a denial', () {
      final h = ClaimAttemptHistory(
        claimId: 'c1',
        attempts: [
          _attempt(outcome: ClaimAttemptOutcome.denied),
          _attempt(
            id: 'a2',
            n: 2,
            outcome: ClaimAttemptOutcome.paid,
            appealLetterId: 'letter-1',
          ),
        ],
      );
      expect(h.recoveredAfterDenial, isTrue);
    });

    test('recoveredAfterDenial false when no denial happened', () {
      final h = ClaimAttemptHistory(
        claimId: 'c1',
        attempts: [_attempt(outcome: ClaimAttemptOutcome.paid)],
      );
      expect(h.recoveredAfterDenial, isFalse);
    });
  });

  group('ClaimAttemptRepository', () {
    test('recordAttempt auto-increments attemptNumber per claim', () async {
      final repo = ClaimAttemptRepository(storageBucket: 'ca_test_inc');
      await repo.initialize();
      final a = await repo.recordAttempt(
        claimId: 'c1',
        submittedAt: DateTime.utc(2026, 6, 22),
      );
      final b = await repo.recordAttempt(
        claimId: 'c1',
        submittedAt: DateTime.utc(2026, 6, 23),
      );
      final c = await repo.recordAttempt(
        claimId: 'c2',
        submittedAt: DateTime.utc(2026, 6, 23),
      );
      expect(a.attemptNumber, 1);
      expect(b.attemptNumber, 2);
      expect(c.attemptNumber, 1);
    });

    test('recordOutcome updates the attempt + sets adjudicatedAt', () async {
      final repo = ClaimAttemptRepository(storageBucket: 'ca_test_outcome');
      await repo.initialize();
      final a = await repo.recordAttempt(
        claimId: 'c1',
        submittedAt: DateTime.utc(2026, 6, 22),
      );
      final updated = await repo.recordOutcome(
        attemptId: a.id,
        outcome: ClaimAttemptOutcome.denied,
        denialReasonCode: 'CO-50',
      );
      expect(updated.outcome, ClaimAttemptOutcome.denied);
      expect(updated.denialReasonCode, 'CO-50');
      expect(updated.adjudicatedAt, isNotNull);
    });

    test('recoveryRate counts denied claims that later resolved', () async {
      final repo = ClaimAttemptRepository(storageBucket: 'ca_test_recovery');
      await repo.initialize();
      // Claim 1: denied → recovered via appeal.
      final c1a1 = await repo.recordAttempt(
        claimId: 'c1',
        submittedAt: DateTime.utc(2026, 6, 2),
      );
      await repo.recordOutcome(
        attemptId: c1a1.id,
        outcome: ClaimAttemptOutcome.denied,
      );
      final c1a2 = await repo.recordAttempt(
        claimId: 'c1',
        submittedAt: DateTime.utc(2026, 6, 15),
        appealLetterId: 'letter-1',
      );
      await repo.recordOutcome(
        attemptId: c1a2.id,
        outcome: ClaimAttemptOutcome.overturned,
      );

      // Claim 2: denied + still pending.
      final c2a1 = await repo.recordAttempt(
        claimId: 'c2',
        submittedAt: DateTime.utc(2026, 6, 5),
      );
      await repo.recordOutcome(
        attemptId: c2a1.id,
        outcome: ClaimAttemptOutcome.denied,
      );

      // Claim 3: clean pay on first attempt — not counted in denial pool.
      final c3a1 = await repo.recordAttempt(
        claimId: 'c3',
        submittedAt: DateTime.utc(2026, 6, 10),
      );
      await repo.recordOutcome(
        attemptId: c3a1.id,
        outcome: ClaimAttemptOutcome.paid,
      );

      expect(repo.recoveryRate(), 0.5);
    });

    test('initialize drops corrupt records', () async {
      SharedPreferences.setMockInitialValues({
        'ca_test_corrupt': <String>[
          '{"id":"good","claimId":"c1","attemptNumber":1,"submittedAt":"2026-06-23T10:00:00Z","outcome":"pending"}',
          'not valid json',
        ],
      });
      final repo = ClaimAttemptRepository(storageBucket: 'ca_test_corrupt');
      await repo.initialize();
      expect(repo.all, hasLength(1));
      expect(repo.all.first.id, 'good');
    });
  });
}
