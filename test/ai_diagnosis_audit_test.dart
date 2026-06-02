import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/ai_diagnosis_audit.dart';

void main() {
  AiDiagnosisAudit build({
    String candidateLabel = 'Recurrent MDD, moderate',
    String dsm5Code = '296.32',
    String icd10Code = 'F33.1',
    List<String> citations = const [
      'DSM-5-TR §296.32(A)',
      'DSM-5-TR §296.32(C)',
    ],
    AiSuggestionDisposition disposition = AiSuggestionDisposition.pending,
    String consentPolicyVersion = '2026-06',
  }) =>
      AiDiagnosisAudit(
        id: 'evt1',
        patientId: 'demo-1',
        clinicianId: 'usr_demo',
        model: 'claude-haiku-4-5-20251001',
        temperature: 0.2,
        candidateLabel: candidateLabel,
        dsm5Code: dsm5Code,
        icd10Code: icd10Code,
        criteriaMatched: 6,
        criteriaMissing: 1,
        citations: citations,
        disposition: disposition,
        consentPolicyVersion: consentPolicyVersion,
        createdAt: DateTime.utc(2026, 6, 1, 12),
      );

  group('AiDiagnosisAudit round-trip', () {
    test('toJson + fromJson preserve every field', () {
      final a = build();
      final back = AiDiagnosisAudit.fromJson(a.toJson());
      expect(back.id, a.id);
      expect(back.patientId, a.patientId);
      expect(back.clinicianId, a.clinicianId);
      expect(back.model, a.model);
      expect(back.temperature, a.temperature);
      expect(back.candidateLabel, a.candidateLabel);
      expect(back.dsm5Code, a.dsm5Code);
      expect(back.icd10Code, a.icd10Code);
      expect(back.criteriaMatched, a.criteriaMatched);
      expect(back.criteriaMissing, a.criteriaMissing);
      expect(back.citations, a.citations);
      expect(back.disposition, a.disposition);
      expect(back.createdAt, a.createdAt);
    });

    test('temperature is stored at 2-decimal precision on the wire', () {
      final a = AiDiagnosisAudit(
        id: 'e',
        patientId: 'p',
        clinicianId: 'c',
        model: 'm',
        temperature: 0.12345,
        candidateLabel: 'x',
        dsm5Code: 'F',
        icd10Code: 'I',
        criteriaMatched: 1,
        criteriaMissing: 0,
        citations: const ['DSM-5-TR §1'],
        disposition: AiSuggestionDisposition.pending,
        consentPolicyVersion: '2026-06',
      );
      expect(a.toJson()['temperature'], 0.12);
    });

    test('created_at is UTC ISO-8601 (ends with Z)', () {
      expect(build().toJson()['created_at'], endsWith('Z'));
    });
  });

  group('isWellFormed (provenance guard)', () {
    test('true when citations + candidate + at least one code are present',
        () {
      expect(build().isWellFormed, isTrue);
    });

    test('false when citations are empty', () {
      expect(build(citations: const []).isWellFormed, isFalse);
    });

    test('false when both DSM-5 and ICD-10 codes are empty', () {
      expect(build(dsm5Code: '', icd10Code: '').isWellFormed, isFalse);
    });

    test('false when candidateLabel is whitespace-only', () {
      expect(build(candidateLabel: '   ').isWellFormed, isFalse);
    });
  });

  group('copyWith / disposition', () {
    test('copyWith updates only disposition, leaves the rest unchanged',
        () {
      final a = build();
      final b = a.copyWith(disposition: AiSuggestionDisposition.accepted);
      expect(b.disposition, AiSuggestionDisposition.accepted);
      expect(b.id, a.id);
      expect(b.patientId, a.patientId);
      expect(b.candidateLabel, a.candidateLabel);
      expect(b.citations, a.citations);
    });

    test('AiSuggestionDisposition.fromId round-trips, defaults to pending',
        () {
      for (final d in AiSuggestionDisposition.values) {
        expect(AiSuggestionDisposition.fromId(d.name), d);
      }
      expect(
          AiSuggestionDisposition.fromId('garbage'),
          AiSuggestionDisposition.pending);
      expect(AiSuggestionDisposition.fromId(null),
          AiSuggestionDisposition.pending);
    });
  });

  group('PHI guard', () {
    test('a candidate label longer than 120 chars asserts in debug mode',
        () {
      final tooLong = 'x' * 121;
      expect(() => build(candidateLabel: tooLong), throwsA(isA<Error>()));
    });

    test('empty consentPolicyVersion asserts (GDPR Art. 7 trace)', () {
      expect(() => build(consentPolicyVersion: ''),
          throwsA(isA<AssertionError>()));
    });
  });

  group('consent policy version round-trip', () {
    test('survives JSON round-trip', () {
      final a = build(consentPolicyVersion: '2026-06');
      final back = AiDiagnosisAudit.fromJson(a.toJson());
      expect(back.consentPolicyVersion, '2026-06');
    });

    test('toJson exposes consent_policy_version', () {
      expect(build().toJson()['consent_policy_version'], '2026-06');
    });
  });
}
