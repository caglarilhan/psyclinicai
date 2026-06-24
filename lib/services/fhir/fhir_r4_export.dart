/// HL7 FHIR R4 serializer for the resources we ship outside the
/// tenant: Patient (demographics + identifier) and Observation
/// (PHQ-9 + GAD-7 measurement-based-care scores). The output map is
/// JSON-encode-ready and conforms to the R4 spec.
///
/// Future PR replaces the ehr_sync stub with these resources;
/// today they are consumed by the DSAR export pipeline so a
/// patient's "give me my data" request returns an interoperable
/// Bundle rather than an opaque blob.
library;

import '../assessments/gad7_service.dart' show Gad7Result;
import '../assessments/phq9_service.dart' show Phq9Result;
import '../data/patient_repository.dart' show PatientDoc;

/// LOINC codes for the surveys we collect today.
class FhirLoinc {
  FhirLoinc._();

  /// PHQ-9 total score (Patient Health Questionnaire-9).
  static const String phq9 = '44249-1';

  /// GAD-7 total score (Generalized Anxiety Disorder 7-item scale).
  static const String gad7 = '69737-5';
}

class FhirR4Export {
  FhirR4Export._();

  /// FHIR R4 Patient resource for [doc]. Identifiers are populated
  /// from member-id + insurer; name is split into a single Human
  /// Name entry (the spec accepts a single `text` field plus
  /// optional `given`/`family` for parsed forms).
  static Map<String, dynamic> patient(PatientDoc doc) {
    final identifiers = <Map<String, dynamic>>[
      if (doc.memberId.isNotEmpty)
        {
          'use': 'usual',
          if (doc.insurer.isNotEmpty) 'assigner': {'display': doc.insurer},
          'value': doc.memberId,
        },
    ];

    final telecom = <Map<String, dynamic>>[
      if (doc.email.isNotEmpty)
        {'system': 'email', 'value': doc.email, 'use': 'home'},
      if (doc.phone.isNotEmpty)
        {'system': 'phone', 'value': doc.phone, 'use': 'mobile'},
    ];

    final parts = doc.fullName.trim().split(RegExp(r'\s+'));
    final name = <Map<String, dynamic>>[
      {
        'use': 'official',
        'text': doc.fullName,
        if (parts.length > 1) 'family': parts.last,
        if (parts.length > 1) 'given': parts.sublist(0, parts.length - 1),
        if (parts.length == 1 && parts.first.isNotEmpty) 'given': [parts.first],
      },
    ];

    final address = <Map<String, dynamic>>[
      if (doc.addressLine1.isNotEmpty || doc.addressLine2.isNotEmpty)
        {
          'use': 'home',
          'line': [
            if (doc.addressLine1.isNotEmpty) doc.addressLine1,
            if (doc.addressLine2.isNotEmpty) doc.addressLine2,
          ],
        },
    ];

    return <String, dynamic>{
      'resourceType': 'Patient',
      'id': doc.id,
      if (identifiers.isNotEmpty) 'identifier': identifiers,
      'name': name,
      if (telecom.isNotEmpty) 'telecom': telecom,
      if (doc.dob != null) 'birthDate': _isoDate(doc.dob!),
      if (address.isNotEmpty) 'address': address,
      'active': true,
    };
  }

  /// FHIR R4 Observation resource for a PHQ-9 score. [effectiveAt]
  /// is normalised to UTC; we always emit ISO 8601 with `Z` so payer
  /// + EHR systems see a single canonical timezone.
  static Map<String, dynamic> phq9Observation({
    required String observationId,
    required String patientId,
    required Phq9Result result,
    required DateTime effectiveAt,
  }) {
    return _surveyObservation(
      observationId: observationId,
      patientId: patientId,
      loinc: FhirLoinc.phq9,
      display: 'Patient Health Questionnaire 9 item (PHQ-9) total score',
      score: result.total,
      effectiveAt: effectiveAt,
      severityLabel: result.severity.name,
    );
  }

  /// FHIR R4 Observation resource for a GAD-7 score.
  static Map<String, dynamic> gad7Observation({
    required String observationId,
    required String patientId,
    required Gad7Result result,
    required DateTime effectiveAt,
  }) {
    return _surveyObservation(
      observationId: observationId,
      patientId: patientId,
      loinc: FhirLoinc.gad7,
      display:
          'Generalized anxiety disorder 7 item (GAD-7) total score [Reported]',
      score: result.total,
      effectiveAt: effectiveAt,
      severityLabel: result.severity.name,
    );
  }

  /// FHIR R4 Bundle wrapping a Patient + every survey Observation
  /// the caller hands in. Bundle.type is `collection` — the most
  /// permissive variant, fine for export and import.
  static Map<String, dynamic> bundle({
    required PatientDoc patientDoc,
    List<Map<String, dynamic>> observations = const [],
  }) {
    return <String, dynamic>{
      'resourceType': 'Bundle',
      'type': 'collection',
      'entry': [
        {'resource': patient(patientDoc)},
        for (final o in observations) {'resource': o},
      ],
    };
  }

  static Map<String, dynamic> _surveyObservation({
    required String observationId,
    required String patientId,
    required String loinc,
    required String display,
    required int score,
    required DateTime effectiveAt,
    required String severityLabel,
  }) {
    return <String, dynamic>{
      'resourceType': 'Observation',
      'id': observationId,
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'survey',
              'display': 'Survey',
            },
          ],
        },
      ],
      'code': {
        'coding': [
          {'system': 'http://loinc.org', 'code': loinc, 'display': display},
        ],
        'text': display,
      },
      'subject': {'reference': 'Patient/$patientId'},
      'effectiveDateTime': _isoInstant(effectiveAt.toUtc()),
      'valueQuantity': {
        'value': score,
        'unit': 'score',
        'system': 'http://unitsofmeasure.org',
        'code': '{score}',
      },
      'interpretation': [
        {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation',
              'code': severityLabel,
              'display': severityLabel,
            },
          ],
          'text': severityLabel,
        },
      ],
    };
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _isoInstant(DateTime d) {
    final u = d.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-'
        '${u.month.toString().padLeft(2, '0')}-'
        '${u.day.toString().padLeft(2, '0')}T'
        '${u.hour.toString().padLeft(2, '0')}:'
        '${u.minute.toString().padLeft(2, '0')}:'
        '${u.second.toString().padLeft(2, '0')}Z';
  }
}
