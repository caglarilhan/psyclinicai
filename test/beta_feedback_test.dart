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
          uid: 'u-1',
          phiAttestation: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => BetaFeedback(
          id: 'b-1',
          kind: BetaFeedbackKind.bug,
          body: 'x' * 2001,
          route: '/dashboard',
          uid: 'u-1',
          phiAttestation: true,
        ),
        throwsArgumentError,
      );
    });

    test('severity defaults from kind (blocker → blocker)', () {
      final fb = BetaFeedback(
        id: 'b-1',
        kind: BetaFeedbackKind.blocker,
        body: 'Cannot sign the note',
        route: '/session',
        uid: 'u-1',
        phiAttestation: true,
      );
      expect(fb.severity, BetaFeedbackSeverity.blocker);
      final praise = BetaFeedback(
        id: 'b-2',
        kind: BetaFeedbackKind.praise,
        body: 'AI co-pilot saved 40 min',
        route: '/session',
        uid: 'u-1',
        phiAttestation: true,
      );
      expect(praise.severity, BetaFeedbackSeverity.low);
    });

    test(
      'rejects PHI-shaped content (SSN, MRN, ICD, C-SSRS, "session note")',
      () {
        const probes = [
          '123-45-6789',
          'MRN: 12345',
          'C-SSRS positive',
          'I pasted a session note here',
          'See ICD10 F33',
        ];
        for (final body in probes) {
          expect(
            () => BetaFeedback(
              id: 'b-x',
              kind: BetaFeedbackKind.bug,
              body: body,
              route: '/x',
              uid: 'u-1',
              phiAttestation: true,
            ),
            throwsArgumentError,
            reason: 'should refuse $body',
          );
        }
      },
    );

    test('requires phiAttestation == true', () {
      expect(
        () => BetaFeedback(
          id: 'b-1',
          kind: BetaFeedbackKind.bug,
          body: 'works for me',
          route: '/x',
          uid: 'u-1',
          phiAttestation: false,
        ),
        throwsArgumentError,
      );
    });

    test('JSON round-trip preserves fields including phi_attested', () {
      final fb = BetaFeedback(
        id: 'b-1',
        kind: BetaFeedbackKind.bug,
        body: 'X happens when Y',
        route: '/superbill',
        uid: 'u-1',
        phiAttestation: true,
        submittedAt: DateTime.utc(2026, 6, 3, 12),
      );
      final restored = BetaFeedback.fromJson(fb.toJson());
      expect(restored.id, fb.id);
      expect(restored.kind, fb.kind);
      expect(restored.severity, fb.severity);
      expect(restored.phiAttestation, isTrue);
      expect(restored.submittedAt, fb.submittedAt);
    });
  });

  group('InMemoryBetaFeedbackRepository', () {
    test('submit + readAll round-trip', () async {
      final repo = InMemoryBetaFeedbackRepository();
      await repo.submit(
        BetaFeedback(
          id: 'b-1',
          kind: BetaFeedbackKind.bug,
          body: 'Lost focus on TextField',
          route: '/intake',
          uid: 'u-1',
          phiAttestation: true,
        ),
      );
      final all = await repo.readAll();
      expect(all.length, 1);
      expect(all.first.body, contains('focus'));
    });
  });
}
