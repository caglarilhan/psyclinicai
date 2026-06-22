import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/account_deletion_request.dart';

void main() {
  final t0 = DateTime.utc(2026, 6, 1, 12);

  AccountDeletionRequest build({
    DateTime? cancelledAt,
    DateTime? completedAt,
  }) => AccountDeletionRequest(
    userId: 'u1',
    requestedAt: t0,
    cancelledAt: cancelledAt,
    completedAt: completedAt,
    reasonCode: 'switching-provider',
  );

  group('AccountDeletionRequest', () {
    test('graceEndsAt is requestedAt + 30 days by default', () {
      final req = build();
      expect(req.graceEndsAt, t0.add(accountDeletionGrace));
      expect(accountDeletionGrace, const Duration(days: 30));
    });

    test('statusAt is pendingGrace immediately after request', () {
      expect(
        build().statusAt(t0.add(const Duration(days: 1))),
        DeletionStatus.pendingGrace,
      );
    });

    test('isInGraceWindowAt is true inside the window and false outside', () {
      final req = build();
      expect(req.isInGraceWindowAt(t0.add(const Duration(days: 5))), isTrue);
      expect(req.isInGraceWindowAt(t0.add(const Duration(days: 40))), isFalse);
    });

    test('isReadyToPurgeAt only flips after the grace window ends', () {
      final req = build();
      expect(req.isReadyToPurgeAt(t0.add(const Duration(days: 29))), isFalse);
      expect(req.isReadyToPurgeAt(t0.add(const Duration(days: 31))), isTrue);
    });

    test('a cancelled request never becomes ready to purge', () {
      final req = build(cancelledAt: t0.add(const Duration(days: 2)));
      expect(
        req.statusAt(t0.add(const Duration(days: 90))),
        DeletionStatus.cancelled,
      );
      expect(req.isReadyToPurgeAt(t0.add(const Duration(days: 90))), isFalse);
    });

    test('a completed request reports the completed status', () {
      final req = build(completedAt: t0.add(const Duration(days: 31)));
      expect(
        req.statusAt(t0.add(const Duration(days: 32))),
        DeletionStatus.completed,
      );
    });

    test('JSON round-trip preserves the lifecycle fields', () {
      final req = build(cancelledAt: t0.add(const Duration(days: 3)));
      final back = AccountDeletionRequest.fromJson(req.toJson());
      expect(back.userId, req.userId);
      expect(back.requestedAt.toUtc(), req.requestedAt.toUtc());
      expect(back.graceEndsAt.toUtc(), req.graceEndsAt.toUtc());
      expect(back.cancelledAt!.toUtc(), req.cancelledAt!.toUtc());
      expect(back.reasonCode, 'switching-provider');
    });

    test('copyWith adds a cancelledAt without disturbing the rest', () {
      final base = build();
      final cancelled = base.copyWith(
        cancelledAt: t0.add(const Duration(days: 2)),
      );
      expect(cancelled.userId, base.userId);
      expect(cancelled.requestedAt, base.requestedAt);
      expect(cancelled.graceEndsAt, base.graceEndsAt);
      expect(cancelled.cancelledAt, isNotNull);
    });

    test('DeletionStatus.fromId round-trips and defaults to pendingGrace', () {
      for (final s in DeletionStatus.values) {
        expect(DeletionStatus.fromId(s.name), s);
      }
      expect(DeletionStatus.fromId('garbage'), DeletionStatus.pendingGrace);
      expect(DeletionStatus.fromId(null), DeletionStatus.pendingGrace);
    });
  });
}
