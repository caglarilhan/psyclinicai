import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/claim_submission.dart';

void main() {
  ClaimSubmission base() => ClaimSubmission(
    id: 'CLM-1',
    superbillId: 'INV-1',
    payerId: 'BCBS',
    subjectPatientId: 'p-1',
    cptCodes: const ['90837'],
    icd10Codes: const ['F32.1'],
    amountCents: 14000,
    status: ClaimStatus.draft,
    createdAt: DateTime.utc(2026, 6, 1),
  );

  group('ClaimSubmission validation', () {
    test('refuses empty CPT, ICD, or negative amount', () {
      expect(
        () => ClaimSubmission(
          id: 'CLM-1',
          superbillId: 'INV-1',
          payerId: 'BCBS',
          subjectPatientId: 'p-1',
          cptCodes: const [],
          icd10Codes: const ['F32.1'],
          amountCents: 1000,
          status: ClaimStatus.draft,
          createdAt: DateTime.utc(2026, 6, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => ClaimSubmission(
          id: 'CLM-1',
          superbillId: 'INV-1',
          payerId: 'BCBS',
          subjectPatientId: 'p-1',
          cptCodes: const ['90837'],
          icd10Codes: const [],
          amountCents: 1000,
          status: ClaimStatus.draft,
          createdAt: DateTime.utc(2026, 6, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => ClaimSubmission(
          id: 'CLM-1',
          superbillId: 'INV-1',
          payerId: 'BCBS',
          subjectPatientId: 'p-1',
          cptCodes: const ['90837'],
          icd10Codes: const ['F32.1'],
          amountCents: -1,
          status: ClaimStatus.draft,
          createdAt: DateTime.utc(2026, 6, 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('ClaimSubmission lifecycle', () {
    test('draft → submitted records submittedAt', () {
      final c = base().advance(
        to: ClaimStatus.submitted,
        at: DateTime.utc(2026, 6, 2),
      );
      expect(c.status, ClaimStatus.submitted);
      expect(c.submittedAt, DateTime.utc(2026, 6, 2));
    });

    test('submitted → denied records adjudicatedAt + reason', () {
      final c = base()
          .advance(to: ClaimStatus.submitted)
          .advance(
            to: ClaimStatus.denied,
            at: DateTime.utc(2026, 6, 10),
            denialReasonCode: 'CO-50',
          );
      expect(c.status, ClaimStatus.denied);
      expect(c.adjudicatedAt, DateTime.utc(2026, 6, 10));
      expect(c.denialReasonCode, 'CO-50');
    });

    test('denied → appealing → accepted is allowed', () {
      final appeal = base()
          .advance(to: ClaimStatus.submitted)
          .advance(to: ClaimStatus.denied)
          .advance(to: ClaimStatus.appealing)
          .advance(to: ClaimStatus.accepted);
      expect(appeal.status, ClaimStatus.accepted);
    });

    test('paid is final — refuses further transitions', () {
      final c = base()
          .advance(to: ClaimStatus.submitted)
          .advance(to: ClaimStatus.accepted)
          .advance(to: ClaimStatus.paid);
      expect(c.status.isFinal, isTrue);
      expect(() => c.advance(to: ClaimStatus.denied), throwsStateError);
    });

    test('cannot skip submitted → paid', () {
      expect(
        () => base()
            .advance(to: ClaimStatus.submitted)
            .advance(to: ClaimStatus.paid),
        throwsStateError,
      );
    });

    test('JSON round-trip preserves fields', () {
      final c = base().advance(
        to: ClaimStatus.submitted,
        at: DateTime.utc(2026, 6, 2),
        refNumber: 'REF-99',
      );
      final restored = ClaimSubmission.fromJson(c.toJson());
      expect(restored.status, ClaimStatus.submitted);
      expect(restored.refNumber, 'REF-99');
      expect(restored.amountCents, 14000);
    });
  });
}
