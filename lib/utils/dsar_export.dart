/// GDPR Article 15 + 20 portable export bundle for a single patient.
///
/// Pure function — collects the JSON of every record we hold for the
/// patient and packages it under a stable schema the patient (or their
/// downstream provider) can ingest. The repository code calls this
/// after reading each store; the I/O wrapper writes the bundle to disk
/// or streams it as a download.
///
/// Schema versioned via [dsarSchemaVersion] so a downstream importer can
/// detect breaking changes.
library;

import '../models/consent_record.dart';
import '../models/patient_intake.dart';
import '../models/safety_plan.dart';
import '../models/session_note.dart';

const String dsarSchemaVersion = '2026-06';

/// Build the JSON bundle. `null` values are simply omitted — they are
/// records the platform genuinely does not hold.
Map<String, dynamic> buildPatientExport({
  required String patientId,
  required DateTime generatedAt,
  PatientIntake? intake,
  ConsentRecord? consent,
  SafetyPlan? safetyPlan,
  List<SessionNote> sessionNotes = const [],
  List<Map<String, dynamic>> assessments = const [],
  Map<String, dynamic>? clinicianProfile,
}) {
  // Consent might live inside the intake too; prefer the explicit one,
  // fall back to intake.consent so DSAR responses never miss a signature.
  final effectiveConsent = consent ?? intake?.consent;

  return {
    'schema_version': dsarSchemaVersion,
    'patient_id': patientId,
    'generated_at': generatedAt.toUtc().toIso8601String(),
    'source': 'psyclinicai',
    'gdpr': {
      'article_15': 'right of access',
      'article_20': 'right to data portability',
    },
    if (clinicianProfile != null) 'clinician': clinicianProfile,
    if (intake != null) 'intake': intake.toJson(),
    if (effectiveConsent != null) 'consent': effectiveConsent.toJson(),
    if (safetyPlan != null) 'safety_plan': safetyPlan.toJson(),
    'session_notes':
        sessionNotes.map((n) => n.toJson()).toList(growable: false),
    'assessments': assessments,
  };
}

/// True when the bundle has no patient-supplied content — useful for
/// surfacing an "this account has no records yet" message instead of
/// downloading an empty file.
bool isExportEmpty(Map<String, dynamic> bundle) {
  final intake = bundle['intake'];
  final consent = bundle['consent'];
  final plan = bundle['safety_plan'];
  final notes = bundle['session_notes'] as List<dynamic>?;
  final assessments = bundle['assessments'] as List<dynamic>?;
  return intake == null &&
      consent == null &&
      plan == null &&
      (notes == null || notes.isEmpty) &&
      (assessments == null || assessments.isEmpty);
}
