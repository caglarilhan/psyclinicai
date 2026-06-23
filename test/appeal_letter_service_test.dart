/// Coverage for AppealLetterService — subject line, payer-specific
/// salutation, reasons-addressed list, attachments per payer,
/// claim/member id substitution.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/denial_risk.dart';
import 'package:psyclinicai/services/billing/appeal_letter_service.dart';

DenialRisk _risk({
  Payer payer = Payer.uhcOptum,
  String cpt = '90837',
  String cptLabel = 'Psychotherapy, 60 min',
  List<DenialReason> reasons = const [],
}) => DenialRisk(
  level: DenialLevel.medium,
  payer: payer,
  cptCode: cpt,
  cptLabel: cptLabel,
  reasons: reasons,
);

DenialReason _reason({
  String title = 'Functional impairment not documented',
  String detail =
      'UHC/Optum require explicit functional-impairment documentation '
      'for outpatient psychotherapy claims.',
  String fix = 'Add a functional-impairment line.',
  String? insertText,
}) => DenialReason(
  title: title,
  detail: detail,
  fixSentence: fix,
  insertText: insertText,
);

void main() {
  const svc = AppealLetterService();

  test('subject line contains CPT, label, payer, and claim number', () {
    final letter = svc.draftHeuristic(
      risk: _risk(reasons: [_reason()]),
      clinicianName: 'Dr. Alex Doe',
      practiceName: 'PsyClinicAI',
      patientInitials: 'JD',
      dateOfService: DateTime.utc(2026, 6, 23),
      claimNumber: 'CLM-12345',
    );
    expect(letter.subject, contains('90837'));
    expect(letter.subject, contains('UHC/Optum'));
    expect(letter.subject, contains('CLM-12345'));
  });

  test('salutation is payer-specific', () {
    expect(
      svc
          .draftHeuristic(
            risk: _risk(payer: Payer.medicare, reasons: [_reason()]),
            clinicianName: 'a',
            practiceName: 'b',
            patientInitials: 'c',
            dateOfService: DateTime.utc(2026, 6, 23),
          )
          .body,
      startsWith('To: Medicare Administrative Contractor'),
    );
    expect(
      svc
          .draftHeuristic(
            risk: _risk(payer: Payer.medicaid, reasons: [_reason()]),
            clinicianName: 'a',
            practiceName: 'b',
            patientInitials: 'c',
            dateOfService: DateTime.utc(2026, 6, 23),
          )
          .body,
      startsWith('To: State Medicaid Agency'),
    );
  });

  test('reasonsAddressed mirrors every denial reason title', () {
    final letter = svc.draftHeuristic(
      risk: _risk(
        reasons: [
          _reason(),
          _reason(title: 'Start/stop time missing'),
        ],
      ),
      clinicianName: 'a',
      practiceName: 'b',
      patientInitials: 'c',
      dateOfService: DateTime.utc(2026, 6, 23),
    );
    expect(letter.reasonsAddressed, [
      'Functional impairment not documented',
      'Start/stop time missing',
    ]);
  });

  test('body uses insertText when present, fix sentence otherwise', () {
    final letter = svc.draftHeuristic(
      risk: _risk(
        reasons: [
          _reason(
            insertText: 'Patient reports a 30% productivity decline at work.',
          ),
          _reason(
            title: 'No fix sentence available',
            fix: 'Use a fallback fix sentence.',
          ),
        ],
      ),
      clinicianName: 'a',
      practiceName: 'b',
      patientInitials: 'c',
      dateOfService: DateTime.utc(2026, 6, 23),
    );
    expect(letter.body, contains('Patient reports a 30% productivity'));
    expect(letter.body, contains('Use a fallback fix sentence.'));
  });

  test('attachments differ per payer', () {
    final medicare = svc.draftHeuristic(
      risk: _risk(payer: Payer.medicare, reasons: [_reason()]),
      clinicianName: 'a',
      practiceName: 'b',
      patientInitials: 'c',
      dateOfService: DateTime.utc(2026, 6, 23),
    );
    expect(
      medicare.attachmentsList,
      contains('Local Coverage Determination (LCD) reference'),
    );

    final optum = svc.draftHeuristic(
      risk: _risk(reasons: [_reason()]),
      clinicianName: 'a',
      practiceName: 'b',
      patientInitials: 'c',
      dateOfService: DateTime.utc(2026, 6, 23),
    );
    expect(
      optum.attachmentsList,
      contains('Optum Level of Care Guideline mapping'),
    );
  });

  test('plainText concatenates subject + body', () {
    final letter = svc.draftHeuristic(
      risk: _risk(reasons: [_reason()]),
      clinicianName: 'Dr. Doe',
      practiceName: 'Clinic',
      patientInitials: 'XY',
      dateOfService: DateTime.utc(2026, 6, 23),
    );
    expect(letter.plainText, startsWith(letter.subject));
    expect(letter.plainText, contains(letter.body));
  });

  test('omitting claim + member ids does not break the letter', () {
    final letter = svc.draftHeuristic(
      risk: _risk(reasons: [_reason()]),
      clinicianName: 'a',
      practiceName: 'b',
      patientInitials: 'JD',
      dateOfService: DateTime.utc(2026, 6, 23),
    );
    expect(letter.body, contains('patient JD'));
    expect(letter.body, isNot(contains('claim number')));
    expect(letter.body, isNot(contains('member id')));
  });
}
