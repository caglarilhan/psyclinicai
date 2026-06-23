/// Generates a payer-aware appeal letter from a denied claim. Reads
/// the existing `DenialRisk` (the risk service already understands
/// CPT + payer + reasons + fix sentences) and turns it into a
/// formal letter the clinician can edit and submit.
library;

import '../../models/denial_risk.dart';

/// Carrier of the generated letter — body plus structured pieces
/// the UI surfaces (subject line, attachments list, reasons
/// addressed).
class AppealLetter {
  const AppealLetter({
    required this.subject,
    required this.body,
    required this.payer,
    required this.cptCode,
    required this.reasonsAddressed,
    this.attachmentsList = const [],
  });

  final String subject;
  final String body;
  final Payer payer;
  final String cptCode;

  /// Denial reasons the letter explicitly counters. Surfaced as a
  /// checklist in the UI so the clinician confirms every driver
  /// got rebutted.
  final List<String> reasonsAddressed;

  /// Paper-trail items the clinician should attach (progress note,
  /// treatment plan, prior auth, etc.). Payer-specific.
  final List<String> attachmentsList;

  String get plainText => '$subject\n\n$body';
}

class AppealLetterService {
  const AppealLetterService();

  /// Template-driven draft. The clinician edits before sending.
  AppealLetter draftHeuristic({
    required DenialRisk risk,
    required String clinicianName,
    required String practiceName,
    required String patientInitials,
    required DateTime dateOfService,
    String? claimNumber,
    String? memberId,
  }) {
    final lines = <String>[
      _salutation(risk.payer),
      '',
      _openingParagraph(
        risk: risk,
        patientInitials: patientInitials,
        dateOfService: dateOfService,
        claimNumber: claimNumber,
        memberId: memberId,
      ),
      '',
    ];

    for (final r in risk.reasons) {
      lines.add('Regarding "${r.title}":');
      lines.add(r.detail);
      if (r.insertText != null) {
        lines.add('');
        lines.add(
          'Documentation reflecting this is included in the progress '
          'note as follows: "${r.insertText}"',
        );
      } else {
        lines.add(r.fixSentence);
      }
      lines.add('');
    }

    lines.add(_payerSpecificBlock(risk.payer));
    lines.add('');
    lines.add(
      _closing(clinicianName: clinicianName, practiceName: practiceName),
    );

    return AppealLetter(
      subject: _subjectLine(risk: risk, claimNumber: claimNumber),
      body: lines.join('\n'),
      payer: risk.payer,
      cptCode: risk.cptCode,
      reasonsAddressed: [for (final r in risk.reasons) r.title],
      attachmentsList: _attachmentsFor(risk.payer),
    );
  }

  String _subjectLine({required DenialRisk risk, String? claimNumber}) {
    final claim = claimNumber == null ? '' : ' (Claim $claimNumber)';
    return 'Appeal of denial — ${risk.cptCode} ${risk.cptLabel} · '
        '${risk.payer.short}$claim';
  }

  String _salutation(Payer p) => switch (p) {
    Payer.medicare => 'To: Medicare Administrative Contractor — Appeals Unit',
    Payer.medicaid => 'To: State Medicaid Agency — Appeals Department',
    Payer.bcbs => 'To: Blue Cross Blue Shield — Appeals & Grievances',
    Payer.uhcOptum => 'To: UnitedHealthcare / Optum — Provider Appeals',
    Payer.aetna => 'To: Aetna — Provider Appeals Department',
    Payer.cigna => 'To: Cigna — Provider Appeals',
  };

  String _openingParagraph({
    required DenialRisk risk,
    required String patientInitials,
    required DateTime dateOfService,
    required String? claimNumber,
    required String? memberId,
  }) {
    final dos =
        '${dateOfService.year}-${dateOfService.month.toString().padLeft(2, '0')}'
        '-${dateOfService.day.toString().padLeft(2, '0')}';
    final claimPart = claimNumber == null ? '' : ' (claim number $claimNumber)';
    final memberPart = memberId == null ? '' : ' (member id $memberId)';
    return 'I am writing to formally appeal the denial of CPT '
        '${risk.cptCode} (${risk.cptLabel}) billed for patient '
        '$patientInitials$memberPart for the date of service $dos$claimPart. '
        'The denial reason does not accurately reflect the medical '
        'necessity, documentation, or coding accuracy of this service, '
        'and we respectfully request that the claim be reprocessed for '
        'payment in full.';
  }

  String _payerSpecificBlock(Payer p) => switch (p) {
    Payer.medicare =>
      "This service met Medicare's reasonable-and-necessary criteria "
          'under §1862(a)(1)(A) and the applicable LCD. Start / stop times '
          'and modality are documented in the progress note.',
    Payer.medicaid =>
      'This service is consistent with the state Medicaid behavioural-'
          'health benefit and meets the medical-necessity criteria '
          'specified in the provider manual. The "golden thread" between '
          'presenting problem, treatment plan goal, and session '
          'intervention is documented.',
    Payer.bcbs =>
      'This service meets BCBS medical-necessity criteria under '
          'InterQual / MCG guidelines as applicable, with documentation '
          'supporting the CPT code level of service.',
    Payer.uhcOptum =>
      'This service meets Optum Level of Care Guidelines and the '
          'corresponding Outpatient Behavioural Health policy. The '
          'measurable goal, functional impairment, and intervention tie '
          'are explicit in the note.',
    Payer.aetna =>
      'This service meets Aetna Clinical Policy Bulletin criteria for '
          'outpatient behavioural health.',
    Payer.cigna =>
      'This service meets Cigna behavioural-health medical-necessity '
          "criteria with documentation tying intervention to the patient's "
          'measurable treatment plan goal.',
  };

  List<String> _attachmentsFor(Payer p) {
    final base = [
      'Original CMS-1500 / 837P claim',
      'Progress note for the date of service',
      'Current treatment plan with measurable goals',
    ];
    switch (p) {
      case Payer.medicare:
        return [...base, 'Local Coverage Determination (LCD) reference'];
      case Payer.medicaid:
        return [
          ...base,
          'Prior authorisation (if required)',
          'Functional-impairment / golden-thread excerpts',
        ];
      case Payer.uhcOptum:
        return [
          ...base,
          'Optum Level of Care Guideline mapping',
          'Outcomes measure (PHQ-9 / GAD-7 / PCL-5) if available',
        ];
      case Payer.bcbs:
      case Payer.aetna:
      case Payer.cigna:
        return [...base, 'Outcomes measure if available'];
    }
  }

  String _closing({
    required String clinicianName,
    required String practiceName,
  }) {
    return 'Please reprocess this claim for payment. I am available to '
        'provide additional clinical context if needed.\n\n'
        'Sincerely,\n$clinicianName\n$practiceName';
  }
}
