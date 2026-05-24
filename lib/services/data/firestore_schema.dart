/// Firestore collection / document paths for PsyClinicAI.
///
/// Single source of truth — both repositories AND security rules should
/// reference these constants to avoid drift.
class FirestoreSchema {
  FirestoreSchema._();

  // --- Top-level collections ---
  static const String clinics = 'clinics';

  // --- Sub-paths (relative) ---
  static const String clinicians = 'clinicians';
  static const String patients = 'patients';
  static const String sessions = 'sessions';
  static const String notes = 'notes';
  static const String assessments = 'assessments';
  static const String superbills = 'superbills';

  // --- Common field names ---
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldClinicId = 'clinicId';
  static const String fieldClinicianId = 'clinicianId';
  static const String fieldPatientId = 'patientId';

  // --- Clinician fields ---
  static const String fieldEmail = 'email';
  static const String fieldFullName = 'fullName';
  static const String fieldRole = 'role';
  static const String fieldCredentials = 'credentials';
  static const String fieldNpi = 'npi';
  static const String fieldTaxId = 'taxId';

  // --- Patient fields ---
  static const String fieldDob = 'dob';
  static const String fieldMemberId = 'memberId';
  static const String fieldInsurer = 'insurer';
  static const String fieldPhone = 'phone';
  static const String fieldAddressLine1 = 'addressLine1';
  static const String fieldAddressLine2 = 'addressLine2';
  static const String fieldNotes = 'notes';

  // --- Session / Note fields ---
  static const String fieldStartedAt = 'startedAt';
  static const String fieldEndedAt = 'endedAt';
  static const String fieldDurationMinutes = 'durationMinutes';
  static const String fieldFormat = 'format';
  static const String fieldMarkdown = 'markdown';
  static const String fieldTranscript = 'transcript';
  static const String fieldFlaggedRisk = 'flaggedRisk';
  static const String fieldGeneratedByAi = 'generatedByAi';

  // --- Assessment fields ---
  static const String fieldAssessmentType = 'type';
  static const String fieldAnswers = 'answers';
  static const String fieldScore = 'score';
  static const String fieldSeverity = 'severity';
  static const String fieldSelfHarmFlag = 'selfHarmFlag';
  static const String fieldCompletedAt = 'completedAt';

  // --- Superbill fields ---
  static const String fieldInvoiceNumber = 'invoiceNumber';
  static const String fieldServiceDate = 'serviceDate';
  static const String fieldTotalCharges = 'totalCharges';
  static const String fieldAmountPaid = 'amountPaid';
  static const String fieldBalanceDue = 'balanceDue';
  static const String fieldStatus = 'status';
  static const String fieldDiagnoses = 'diagnoses';
  static const String fieldServiceLines = 'serviceLines';
  static const String fieldPdfUrl = 'pdfUrl';

  // --- Path helpers ---
  static String clinicPath(String clinicId) => '$clinics/$clinicId';
  static String clinicianPath(String clinicId, String userId) =>
      '${clinicPath(clinicId)}/$clinicians/$userId';
  static String patientPath(String clinicId, String patientId) =>
      '${clinicPath(clinicId)}/$patients/$patientId';
  static String sessionPath(
          String clinicId, String patientId, String sessionId) =>
      '${patientPath(clinicId, patientId)}/$sessions/$sessionId';
  static String notePath(String clinicId, String patientId, String sessionId,
          String noteId) =>
      '${sessionPath(clinicId, patientId, sessionId)}/$notes/$noteId';
  static String assessmentPath(String clinicId, String patientId, String aId) =>
      '${patientPath(clinicId, patientId)}/$assessments/$aId';
  static String superbillPath(
          String clinicId, String patientId, String invoiceId) =>
      '${patientPath(clinicId, patientId)}/$superbills/$invoiceId';
}

/// Clinician roles for RBAC.
enum ClinicianRole {
  psychiatrist,
  psychologist,
  therapist,
  nurse,
  secretary,
  administrator,
}

extension ClinicianRoleX on ClinicianRole {
  String get id => name;
  String get label => switch (this) {
        ClinicianRole.psychiatrist => 'Psychiatrist',
        ClinicianRole.psychologist => 'Psychologist',
        ClinicianRole.therapist => 'Therapist',
        ClinicianRole.nurse => 'Nurse',
        ClinicianRole.secretary => 'Secretary',
        ClinicianRole.administrator => 'Administrator',
      };

  bool get canPrescribe => this == ClinicianRole.psychiatrist;
  bool get canSeeFinancials =>
      this == ClinicianRole.administrator || this == ClinicianRole.secretary;
}
