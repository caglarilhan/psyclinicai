import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/beta_feedback.dart';

void main() {
  group('BetaFeedback', () {
    test('refuses empty body + over-2000-char body', () {
      expect(
        () => BetaFeedback(
            id: 'b-1',
            kind: BetaFeedbackKind.bug,
            body: '   ',
            route: '/dashboard',
            uid: 'u-1'),
        throwsArgumentError,
      );
      expect(
        () => BetaFeedback(
            id: 'b-1',
            kind: BetaFeedbackKind.bug,
            body: 'x' * 2001,
            route: '/dashboard',
            uid: 'u-1'),
        throwsArgumentError,
      );
    });

    test('severity defaults from kind (blocker → blocker)', () {
      final fb = BetaFeedback(
        id: 'b-1',
        kind: BetaFeedbackKind.blocker,
        body: 'Cannot sign session note',
        route: '/session',
        uid: 'u-1',
      );
      expect(fb.severity, BetaFeedbackSeverity.blocker);
      final praise = BetaFeedback(
        id: 'b-2',
        kind: BetaFeedbackKind.praise,
        body: 'AI co-pilot saved 40 min',
        route: '/session',
        uid: 'u-1',
      );
      expect(praise.severity, BetaFeedbackSeverity.low);
    });

    test('JSON round-trip preserves fields', () {
      final fb = BetaFeedback(
        id: 'b-1',
        kind: BetaFeedbackKind.bug,
        body: 'X happens when Y',
        route: '/superbill',
        uid: 'u-1',
        submittedAt: DateTime.utc(2026, 6, 3, 12),
      );
      final restored = BetaFeedback.fromJson(fb.toJson());
      expect(restored.id, fb.id);
      expect(restored.kind, fb.kind);
      expect(restored.severity, fb.severity);
      expect(restored.submittedAt, fb.submittedAt);
    });
  });

  group('InMemoryBetaFeedbackRepository', () {
    test('submit + readAll round-trip', () async {
      final repo = InMemoryBetaFeedbackRepository();
      await repo.submit(BetaFeedback(
          id: 'b-1',
          kind: BetaFeedbackKind.bug,
          body: 'Lost focus on TextField',
          route: '/intake',
          uid: 'u-1'));
      final all = await repo.readAll();
      expect(all.length, 1);
      expect(all.first.body, contains('focus'));
    });
  });
}
