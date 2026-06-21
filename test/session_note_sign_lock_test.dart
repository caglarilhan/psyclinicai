import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/session_note.dart';

void main() {
  group('SessionNote sign + lock', () {
    test('default note is unsigned and not an addendum', () {
      final n = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: '## S — Subjective',
      );
      expect(n.signed, isFalse);
      expect(n.signedAt, isNull);
      expect(n.signedBy, isNull);
      expect(n.addendumOf, isNull);
      expect(n.isAddendum, isFalse);
    });

    test('sign() flips the bit + records who/when', () {
      final note = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: '## S — Subjective',
      );
      final signed = note.sign(
        by: 'clinician-uid-1',
        at: DateTime.utc(2026, 6, 21, 14, 30),
      );
      expect(signed.signed, isTrue);
      expect(signed.signedBy, 'clinician-uid-1');
      expect(signed.signedAt, DateTime.utc(2026, 6, 21, 14, 30));
      // Body + id preserved.
      expect(signed.id, 'n1');
      expect(signed.markdown, '## S — Subjective');
    });

    test('sign() is idempotent on already-signed notes', () {
      final signed = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: 'body',
        signed: true,
        signedAt: DateTime.utc(2026, 6, 20),
        signedBy: 'first-signer',
      );
      final reSigned = signed.sign(
        by: 'second-signer',
        at: DateTime.utc(2026, 6, 21),
      );
      // The second signature must NOT overwrite the original — the
      // chart needs a single canonical signature for the integrity
      // bit, and corrections happen via an addendum.
      expect(identical(reSigned, signed), isTrue);
      expect(reSigned.signedBy, 'first-signer');
    });

    test('addendum() throws when the parent is not yet signed', () {
      final draft = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: 'draft',
      );
      expect(
        () => draft.addendum(
          addendumId: 'a1',
          body: 'correction',
        ),
        throwsStateError,
      );
    });

    test('addendum() returns a child note referencing the parent', () {
      final signed = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: 'original',
      ).sign(by: 'c1', at: DateTime.utc(2026, 6, 21));
      final child = signed.addendum(
        addendumId: 'a1',
        body: 'forgot to log med refill request',
      );
      expect(child.addendumOf, 'n1');
      expect(child.isAddendum, isTrue);
      expect(child.signed, isFalse);
      expect(child.patientId, signed.patientId);
      expect(child.markdown, 'forgot to log med refill request');
    });

    test('toJson includes sign + addendum fields when present', () {
      final signed = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: 'body',
      ).sign(by: 'c1', at: DateTime.utc(2026, 6, 21, 14, 30));
      final json = signed.toJson();
      expect(json['signed'], isTrue);
      expect(json['signedAt'], '2026-06-21T14:30:00.000Z');
      expect(json['signedBy'], 'c1');
      // Unsigned note should not surface a null signedAt — keys are
      // conditional on presence so the audit log stays tight.
      final draft = SessionNote(
        id: 'n2',
        patientId: 'p1',
        markdown: 'draft',
      );
      final draftJson = draft.toJson();
      expect(draftJson.containsKey('signedAt'), isFalse);
      expect(draftJson.containsKey('signedBy'), isFalse);
      expect(draftJson.containsKey('addendumOf'), isFalse);
    });

    test('fromJson round-trip preserves every sign field', () {
      final source = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: 'body',
      ).sign(by: 'c1', at: DateTime.utc(2026, 6, 21));
      final round = SessionNote.fromJson(source.toJson());
      expect(round.signed, isTrue);
      expect(round.signedBy, 'c1');
      expect(round.signedAt, source.signedAt);
    });
  });
}
