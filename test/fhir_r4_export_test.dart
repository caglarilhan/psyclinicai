/// Coverage for FhirR4Export — Patient + Observation + Bundle
/// serialisers. Asserts spec-mandated fields, LOINC codes for the
/// two surveys we ship today, and ISO-8601 UTC date formats.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/gad7_service.dart';
import 'package:psyclinicai/services/assessments/phq9_service.dart';
import 'package:psyclinicai/services/data/patient_repository.dart';
import 'package:psyclinicai/services/fhir/fhir_r4_export.dart';

PatientDoc _patient({
  String id = 'pat-001',
  String fullName = 'Jane Marie Doe',
  String email = 'jane@example.com',
  String phone = '+1-555-0100',
  DateTime? dob,
  String memberId = 'MEM-42',
  String insurer = 'BCBS',
  String addr1 = '123 Main St',
  String addr2 = 'Apt 4',
}) => PatientDoc(
  id: id,
  fullName: fullName,
  email: email,
  phone: phone,
  dob: dob ?? DateTime.utc(1990, 5, 12),
  memberId: memberId,
  insurer: insurer,
  addressLine1: addr1,
  addressLine2: addr2,
  notes: '',
);

void main() {
  group('FhirR4Export.patient', () {
    test('sets resourceType + id + active', () {
      final p = FhirR4Export.patient(_patient());
      expect(p['resourceType'], 'Patient');
      expect(p['id'], 'pat-001');
      expect(p['active'], true);
    });

    test('emits identifier with insurer as assigner', () {
      final p = FhirR4Export.patient(_patient());
      final ids = p['identifier'] as List<dynamic>;
      expect(ids, hasLength(1));
      final first = ids.first as Map<String, dynamic>;
      expect(first['value'], 'MEM-42');
      expect((first['assigner'] as Map<String, dynamic>)['display'], 'BCBS');
    });

    test('parses full name into family + given', () {
      final p = FhirR4Export.patient(_patient());
      final name = (p['name'] as List<dynamic>).first as Map<String, dynamic>;
      expect(name['text'], 'Jane Marie Doe');
      expect(name['family'], 'Doe');
      expect(name['given'], ['Jane', 'Marie']);
    });

    test('falls back to single given when only one name token', () {
      final p = FhirR4Export.patient(_patient(fullName: 'Aaron'));
      final name = (p['name'] as List<dynamic>).first as Map<String, dynamic>;
      expect(name['text'], 'Aaron');
      expect(name.containsKey('family'), isFalse);
      expect(name['given'], ['Aaron']);
    });

    test('birthDate uses ISO YYYY-MM-DD', () {
      final p = FhirR4Export.patient(_patient(dob: DateTime.utc(1985, 1, 7)));
      expect(p['birthDate'], '1985-01-07');
    });

    test('omits telecom / address keys when empty', () {
      final p = FhirR4Export.patient(
        _patient(email: '', phone: '', addr1: '', addr2: ''),
      );
      expect(p.containsKey('telecom'), isFalse);
      expect(p.containsKey('address'), isFalse);
    });

    test('encodes telecom email + phone with correct systems', () {
      final p = FhirR4Export.patient(_patient());
      final telecom = p['telecom'] as List<dynamic>;
      final systems = telecom
          .map((t) => (t as Map<String, dynamic>)['system'])
          .toSet();
      expect(systems, {'email', 'phone'});
    });

    test('serialises to JSON without throwing', () {
      final p = FhirR4Export.patient(_patient());
      expect(() => jsonEncode(p), returnsNormally);
    });
  });

  group('FhirR4Export.phq9Observation', () {
    final result = Phq9Result(
      total: 14,
      severity: Phq9Severity.moderate,
      selfHarmFlag: false,
      answers: const [1, 1, 2, 2, 2, 1, 2, 2, 1],
    );
    final at = DateTime.utc(2026, 6, 24, 14, 30);

    test('sets LOINC code 44249-1 for PHQ-9', () {
      final o = FhirR4Export.phq9Observation(
        observationId: 'obs-1',
        patientId: 'pat-1',
        result: result,
        effectiveAt: at,
      );
      final code = o['code'] as Map<String, dynamic>;
      final coding =
          (code['coding'] as List<dynamic>).first as Map<String, dynamic>;
      expect(coding['code'], FhirLoinc.phq9);
      expect(coding['system'], 'http://loinc.org');
    });

    test('valueQuantity carries the raw total + score unit', () {
      final o = FhirR4Export.phq9Observation(
        observationId: 'obs-1',
        patientId: 'pat-1',
        result: result,
        effectiveAt: at,
      );
      final v = o['valueQuantity'] as Map<String, dynamic>;
      expect(v['value'], 14);
      expect(v['unit'], 'score');
      expect(v['system'], 'http://unitsofmeasure.org');
    });

    test('subject references Patient/<id>', () {
      final o = FhirR4Export.phq9Observation(
        observationId: 'obs-1',
        patientId: 'pat-42',
        result: result,
        effectiveAt: at,
      );
      final s = o['subject'] as Map<String, dynamic>;
      expect(s['reference'], 'Patient/pat-42');
    });

    test('effectiveDateTime emits ISO-8601 with trailing Z', () {
      final o = FhirR4Export.phq9Observation(
        observationId: 'obs-1',
        patientId: 'pat-1',
        result: result,
        effectiveAt: at,
      );
      expect(o['effectiveDateTime'], '2026-06-24T14:30:00Z');
    });

    test('interpretation tag carries the severity label', () {
      final o = FhirR4Export.phq9Observation(
        observationId: 'obs-1',
        patientId: 'pat-1',
        result: result,
        effectiveAt: at,
      );
      final i =
          (o['interpretation'] as List<dynamic>).first as Map<String, dynamic>;
      expect(i['text'], 'moderate');
    });

    test('status is always final', () {
      final o = FhirR4Export.phq9Observation(
        observationId: 'obs-1',
        patientId: 'pat-1',
        result: result,
        effectiveAt: at,
      );
      expect(o['status'], 'final');
    });
  });

  group('FhirR4Export.gad7Observation', () {
    test('sets LOINC code 69737-5 for GAD-7', () {
      final result = Gad7Result(
        total: 12,
        severity: Gad7Severity.moderate,
        answers: const [2, 2, 2, 2, 2, 1, 1],
      );
      final o = FhirR4Export.gad7Observation(
        observationId: 'obs-2',
        patientId: 'pat-1',
        result: result,
        effectiveAt: DateTime.utc(2026, 6, 24, 14, 30),
      );
      final coding =
          ((o['code'] as Map<String, dynamic>)['coding'] as List<dynamic>).first
              as Map<String, dynamic>;
      expect(coding['code'], FhirLoinc.gad7);
    });
  });

  group('FhirR4Export.bundle', () {
    test('wraps Patient + Observations as a collection Bundle', () {
      final phq9 = FhirR4Export.phq9Observation(
        observationId: 'obs-1',
        patientId: 'pat-1',
        result: Phq9Result(
          total: 8,
          severity: Phq9Severity.mild,
          selfHarmFlag: false,
          answers: const [1, 1, 1, 1, 1, 1, 1, 1, 0],
        ),
        effectiveAt: DateTime.utc(2026, 6, 24, 14, 30),
      );
      final gad7 = FhirR4Export.gad7Observation(
        observationId: 'obs-2',
        patientId: 'pat-1',
        result: Gad7Result(
          total: 6,
          severity: Gad7Severity.mild,
          answers: const [1, 1, 1, 1, 1, 0, 1],
        ),
        effectiveAt: DateTime.utc(2026, 6, 24, 14, 30),
      );
      final bundle = FhirR4Export.bundle(
        patientDoc: _patient(id: 'pat-1'),
        observations: [phq9, gad7],
      );
      expect(bundle['resourceType'], 'Bundle');
      expect(bundle['type'], 'collection');
      final entries = bundle['entry'] as List<dynamic>;
      expect(entries, hasLength(3));
      final resources = entries
          .map(
            (e) =>
                (e as Map<String, dynamic>)['resource'] as Map<String, dynamic>,
          )
          .toList();
      expect(resources[0]['resourceType'], 'Patient');
      expect(resources[1]['resourceType'], 'Observation');
      expect(resources[2]['resourceType'], 'Observation');
    });

    test('Bundle is JSON-encodable end-to-end', () {
      final bundle = FhirR4Export.bundle(patientDoc: _patient());
      expect(() => jsonEncode(bundle), returnsNormally);
    });
  });
}
