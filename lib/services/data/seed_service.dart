import 'package:cloud_firestore/cloud_firestore.dart';

import '../assessments/phq9_service.dart';
import '../billing/cpt_lookup_service.dart';
import '../billing/icd10_lookup_service.dart';
import '../billing/superbill_pdf_service.dart';
import '../copilot/soap_generator_service.dart';
import 'assessment_repository.dart';
import 'auth_service.dart';
import 'firebase_bootstrap.dart';
import 'patient_repository.dart';
import 'session_repository.dart';
import 'superbill_repository.dart';

/// One-shot demo seed for the onboarding wizard. When the clinician
/// answers "yes, give me a demo patient" we create a single synthetic
/// chart so the dashboard looks alive on day one. Every value is
/// obviously fake (`John Demo`, `BCBS-INS-001`).
///
/// Demo mode (Firebase off) → silent no-op; the on-screen demo cards
/// already cover that case.
class SeedService {
  SeedService._();
  static final SeedService instance = SeedService._();

  static const _patientId = 'john-demo';

  /// Returns true if anything was actually written; false in demo mode
  /// or on error (caller never blocks the wizard on the result).
  Future<bool> seedDemoChart() async {
    if (!PsyFirebase.isReady) return false;
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) return false;

    try {
      await _seed(profile.clinicId, profile.userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _seed(String clinicId, String clinicianId) async {
    await PatientRepository.instance.upsert(
      clinicId,
      _patientId,
      PatientDraft(
        fullName: 'John Demo',
        email: 'john.demo@example.com',
        phone: '+1 (555) 010-0123',
        memberId: 'BCBS-INS-001',
        insurer: 'Blue Cross Blue Shield',
        addressLine1: '500 Demo Ave, Suite 100',
        addressLine2: 'New York, NY 10001',
        notes:
            'Synthetic onboarding patient — safe to delete from the chart.',
        dob: DateTime(1989, 5, 14),
      ),
    );

    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final lastWeek = now.subtract(const Duration(days: 7));

    final session1 = await SessionRepository.instance.createSession(
      clinicId: clinicId,
      patientId: _patientId,
      clinicianId: clinicianId,
      startedAt: twoWeeksAgo,
    );
    await SessionRepository.instance.endSession(
      clinicId: clinicId,
      patientId: _patientId,
      sessionId: session1,
      endedAt: twoWeeksAgo.add(const Duration(minutes: 50)),
      durationMinutes: 50,
    );
    await SessionRepository.instance.saveNote(
      clinicId: clinicId,
      patientId: _patientId,
      sessionId: session1,
      note: SoapNote(
        rawMarkdown: _demoSoap1,
        format: SoapFormat.soap,
        generatedAt: twoWeeksAgo,
      ),
    );

    final session2 = await SessionRepository.instance.createSession(
      clinicId: clinicId,
      patientId: _patientId,
      clinicianId: clinicianId,
      startedAt: lastWeek,
    );
    await SessionRepository.instance.endSession(
      clinicId: clinicId,
      patientId: _patientId,
      sessionId: session2,
      endedAt: lastWeek.add(const Duration(minutes: 45)),
      durationMinutes: 45,
    );
    await SessionRepository.instance.saveNote(
      clinicId: clinicId,
      patientId: _patientId,
      sessionId: session2,
      note: SoapNote(
        rawMarkdown: _demoSoap2,
        format: SoapFormat.soap,
        generatedAt: lastWeek,
      ),
    );

    final phq9 = Phq9Service.instance;
    final earlier = phq9.score(const [3, 2, 2, 2, 2, 1, 2, 1, 1]);
    final recent = phq9.score(const [1, 1, 1, 1, 2, 1, 1, 1, 0]);
    await _writeAssessmentWithDate(
        clinicId, _patientId, clinicianId, earlier, twoWeeksAgo);
    await _writeAssessmentWithDate(
        clinicId, _patientId, clinicianId, recent, now);

    final cpt = CptLookupService.instance.byCode('90834')!;
    final icd = Icd10LookupService.instance.byCode('F32.1')!;
    await SuperbillRepository.instance.save(
      clinicId: clinicId,
      patientId: _patientId,
      clinicianId: clinicianId,
      data: SuperbillData(
        invoiceNumber: 'INV-DEMO-001',
        issuedAt: now,
        serviceDate: lastWeek,
        provider: ProviderInfo(
          fullName: 'Demo Clinician',
          credentials: 'LCSW',
          npi: '0000000000',
          taxId: '00-0000000',
          phone: '+1 (555) 010-0000',
          email: 'clinician@example.com',
          addressLine1: '1 Demo Plaza',
          addressLine2: 'New York, NY 10001',
        ),
        patient: PatientInfo(
          fullName: 'John Demo',
          dob: DateTime(1989, 5, 14),
          memberId: 'BCBS-INS-001',
          insurer: 'Blue Cross Blue Shield',
          addressLine1: '500 Demo Ave, Suite 100',
          addressLine2: 'New York, NY 10001',
        ),
        diagnoses: [icd],
        serviceLines: [
          ServiceLine(
            date: lastWeek,
            cpt: cpt,
            units: 1,
            chargePerUnit: cpt.nationalAverageUsd,
          ),
        ],
      ),
    );

    // Silence unused-import warning if AssessmentRepository ever
    // re-enters the seed path.
    AssessmentRepository.instance;
  }

  Future<void> _writeAssessmentWithDate(
    String clinicId,
    String patientId,
    String clinicianId,
    Phq9Result result,
    DateTime completedAt,
  ) async {
    await FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('patients')
        .doc(patientId)
        .collection('assessments')
        .add({
      'clinicianId': clinicianId,
      'type': 'phq9',
      'score': result.total,
      'severity': result.severity.label,
      'selfHarmFlag': result.selfHarmFlag,
      'answers': const <int>[],
      'completedAt': Timestamp.fromDate(completedAt),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

const _demoSoap1 = '''
**SOAP — Demo session, 2 weeks ago**

**Subjective:** Patient reports persistent low mood, sleep disruption
(4–5 h/night), and reduced engagement at work over the past 3 weeks.

**Objective:** Affect constricted, eye contact reduced. PHQ-9 = 16
(moderately severe). No suicidal ideation reported.

**Assessment:** Major depressive episode, moderate severity (F32.1).

**Plan:** Begin weekly CBT. Sleep hygiene psycho-education. PHQ-9 in
2 weeks. No medication change pending psychiatric review.
''';

const _demoSoap2 = '''
**SOAP — Demo session, last week**

**Subjective:** Improved sleep (6 h/night). Reports reduced rumination
since starting CBT homework. Worked one full day from office.

**Objective:** Affect more reactive, brighter. PHQ-9 = 9 (mild).

**Assessment:** Major depressive episode, mild — responding to CBT.

**Plan:** Continue weekly CBT. Behavioural activation goal: two
half-day outings this week. Re-screen PHQ-9 in 2 weeks.
''';
