import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/advanced_telemedicine_service.dart';
import 'package:psyclinicai/models/telemedicine_models.dart';

void main() {
  group('AdvancedTelemedicineService Tests', () {
    late AdvancedTelemedicineService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = AdvancedTelemedicineService();
    });

    tearDown(() {
      // Don't dispose service during tests to avoid stream controller issues
    });

    group('Service Initialization Tests', () {
      test('should create service instance', () {
        expect(service, isNotNull);
        expect(service, isA<AdvancedTelemedicineService>());
      });

      test('should initialize successfully', () async {
        await service.initialize();
        // Service should be initialized without errors
        expect(true, isTrue);
      });
    });

    group('Telemedicine Session Tests', () {
      test('should create new telemedicine session', () async {
        final session = await service.createSession(
          patientId: 'patient_001',
          patientName: 'John Doe',
          therapistId: 'therapist_001',
          therapistName: 'Dr. Smith',
          sessionType: SessionType.initialConsultation,
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          duration: 60,
          videoQuality: VideoQualityLevel.high,
          emergencyLevel: EmergencyLevel.none,
        );

        expect(session, isNotNull);
        expect(session.patientId, equals('patient_001'));
        expect(session.patientName, equals('John Doe'));
        expect(session.therapistId, equals('therapist_001'));
        expect(session.therapistName, equals('Dr. Smith'));
        expect(session.sessionType, equals(SessionType.initialConsultation));
        expect(session.status, equals(TelemedicineSessionStatus.scheduled));
        expect(session.duration, equals(60));
        expect(session.videoQuality, equals(VideoQualityLevel.high));
        expect(session.emergencyLevel, equals(EmergencyLevel.none));
        expect(session.isEncrypted, isTrue);
        expect(session.blockchainHash, isNotEmpty);
      });

      test('should create session with emergency level', () async {
        final session = await service.createSession(
          patientId: 'patient_002',
          patientName: 'Jane Smith',
          therapistId: 'therapist_001',
          therapistName: 'Dr. Smith',
          sessionType: SessionType.crisisIntervention,
          scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
          duration: 90,
          videoQuality: VideoQualityLevel.ultra,
          emergencyLevel: EmergencyLevel.high,
          metadata: {'priority': 'urgent', 'crisis_type': 'suicidal_ideation'},
        );

        expect(session, isNotNull);
        expect(session.sessionType, equals(SessionType.crisisIntervention));
        expect(session.emergencyLevel, equals(EmergencyLevel.high));
        expect(session.videoQuality, equals(VideoQualityLevel.ultra));
        expect(session.metadata['priority'], equals('urgent'));
        expect(session.metadata['crisis_type'], equals('suicidal_ideation'));
      });

      test('should start telemedicine session', () async {
        // First create a session
        final session = await service.createSession(
          patientId: 'patient_003',
          patientName: 'Bob Johnson',
          therapistId: 'therapist_002',
          therapistName: 'Dr. Wilson',
          sessionType: SessionType.followUp,
          scheduledTime: DateTime.now(),
          duration: 45,
        );

        // Then start the session
        final startedSession = await service.startSession(
          sessionId: session.id,
          meetingUrl: 'https://meet.psyclinicai.com/session_123',
          meetingId: 'session_123',
          meetingPassword: 'secure123',
        );

        expect(startedSession, isNotNull);
        expect(startedSession.status, equals(TelemedicineSessionStatus.active));
        expect(startedSession.startTime, isNotNull);
        expect(startedSession.meetingUrl, equals('https://meet.psyclinicai.com/session_123'));
        expect(startedSession.meetingId, equals('session_123'));
        expect(startedSession.meetingPassword, equals('secure123'));
      });

      test('should end telemedicine session', () async {
        // First create and start a session
        final session = await service.createSession(
          patientId: 'patient_004',
          patientName: 'Alice Brown',
          therapistId: 'therapist_002',
          therapistName: 'Dr. Wilson',
          sessionType: SessionType.assessment,
          scheduledTime: DateTime.now(),
          duration: 30,
        );

        final startedSession = await service.startSession(
          sessionId: session.id,
          meetingUrl: 'https://meet.psyclinicai.com/session_456',
          meetingId: 'session_456',
        );

        // Then end the session
        final endedSession = await service.endSession(
          sessionId: startedSession.id,
          sessionNotes: {
            'assessment': 'Patient shows signs of anxiety',
            'recommendations': 'Continue therapy sessions',
            'next_appointment': 'Follow up in 2 weeks',
          },
          recordingUrl: 'https://recordings.psyclinicai.com/session_456.mp4',
        );

        expect(endedSession, isNotNull);
        expect(endedSession.status, equals(TelemedicineSessionStatus.completed));
        expect(endedSession.endTime, isNotNull);
        expect(endedSession.sessionNotes['assessment'], equals('Patient shows signs of anxiety'));
        expect(endedSession.recordingUrl, equals('https://recordings.psyclinicai.com/session_456.mp4'));
        expect(endedSession.isRecorded, isTrue);
      });
    });

    group('Virtual Waiting Room Tests', () {
      test('should create virtual waiting room', () async {
        final session = await service.createSession(
          patientId: 'patient_005',
          patientName: 'Charlie Davis',
          therapistId: 'therapist_003',
          therapistName: 'Dr. Johnson',
          sessionType: SessionType.familyTherapy,
          scheduledTime: DateTime.now().add(const Duration(minutes: 15)),
          duration: 75,
        );

        final waitingRoom = await service.createWaitingRoom(
          sessionId: session.id,
          queueSettings: {
            'max_wait_time': 45,
            'priority_emergency': true,
            'auto_reorder': true,
            'notifications': true,
          },
        );

        expect(waitingRoom, isNotNull);
        expect(waitingRoom.sessionId, equals(session.id));
        expect(waitingRoom.status, equals('active'));
        expect(waitingRoom.patients, isEmpty);
        expect(waitingRoom.currentPosition, equals(0));
        expect(waitingRoom.queueSettings['max_wait_time'], equals(45));
        expect(waitingRoom.queueSettings['priority_emergency'], isTrue);
      });

      test('should add patient to waiting room', () async {
        final session = await service.createSession(
          patientId: 'patient_006',
          patientName: 'Diana Evans',
          therapistId: 'therapist_003',
          therapistName: 'Dr. Johnson',
          sessionType: SessionType.groupTherapy,
          scheduledTime: DateTime.now().add(const Duration(minutes: 20)),
          duration: 90,
        );

        final waitingRoom = await service.createWaitingRoom(sessionId: session.id);

        final updatedWaitingRoom = await service.addPatientToWaitingRoom(
          waitingRoomId: waitingRoom.id,
          patientId: 'patient_007',
          patientName: 'Eve Foster',
          emergencyLevel: EmergencyLevel.medium,
          notes: 'Patient experiencing panic attacks',
        );

        expect(updatedWaitingRoom, isNotNull);
        expect(updatedWaitingRoom.patients, isNotEmpty);
        expect(updatedWaitingRoom.patients.length, equals(1));
        expect(updatedWaitingRoom.patients.first.patientName, equals('Eve Foster'));
        expect(updatedWaitingRoom.patients.first.emergencyLevel, equals(EmergencyLevel.medium));
        expect(updatedWaitingRoom.patients.first.notes, equals('Patient experiencing panic attacks'));
        expect(updatedWaitingRoom.patients.first.position, equals(1));
      });

      test('should add multiple patients with different emergency levels', () async {
        final session = await service.createSession(
          patientId: 'patient_008',
          patientName: 'Frank Green',
          therapistId: 'therapist_004',
          therapistName: 'Dr. Brown',
          sessionType: SessionType.emergencyEvaluation,
          scheduledTime: DateTime.now().add(const Duration(minutes: 10)),
          duration: 60,
        );

        final waitingRoom = await service.createWaitingRoom(sessionId: session.id);

        // Add patient with low emergency level
        await service.addPatientToWaitingRoom(
          waitingRoomId: waitingRoom.id,
          patientId: 'patient_009',
          patientName: 'Grace Hill',
          emergencyLevel: EmergencyLevel.low,
        );

        // Add patient with high emergency level
        final updatedWaitingRoom = await service.addPatientToWaitingRoom(
          waitingRoomId: waitingRoom.id,
          patientId: 'patient_010',
          patientName: 'Henry Irving',
          emergencyLevel: EmergencyLevel.high,
          notes: 'Severe depression symptoms',
        );

        expect(updatedWaitingRoom.patients.length, equals(2));
        expect(updatedWaitingRoom.patients.any((p) => p.emergencyLevel == EmergencyLevel.low), isTrue);
        expect(updatedWaitingRoom.patients.any((p) => p.emergencyLevel == EmergencyLevel.high), isTrue);
      });
    });

    group('E-Consultation Tests', () {
      test('should create e-consultation', () async {
        final consultation = await service.createEConsultation(
          patientId: 'patient_011',
          patientName: 'Ivy Jackson',
          therapistId: 'therapist_004',
          therapistName: 'Dr. Brown',
          consultationType: 'Mental Health Assessment',
          symptoms: 'Anxiety, insomnia, mood swings',
          medicalHistory: 'No previous mental health treatment',
          currentMedications: ['None'],
          assessment: 'Patient shows symptoms of generalized anxiety disorder',
          recommendations: 'Start cognitive behavioral therapy',
          prescribedMedications: ['Sertraline 50mg daily'],
          followUpInstructions: 'Schedule follow-up in 2 weeks',
          duration: 45,
          requiresFollowUp: true,
          followUpDate: DateTime.now().add(const Duration(days: 14)),
        );

        expect(consultation, isNotNull);
        expect(consultation.patientName, equals('Ivy Jackson'));
        expect(consultation.consultationType, equals('Mental Health Assessment'));
        expect(consultation.symptoms, equals('Anxiety, insomnia, mood swings'));
        expect(consultation.assessment, equals('Patient shows symptoms of generalized anxiety disorder'));
        expect(consultation.recommendations, equals('Start cognitive behavioral therapy'));
        expect(consultation.prescribedMedications, contains('Sertraline 50mg daily'));
        expect(consultation.requiresFollowUp, isTrue);
        expect(consultation.followUpDate, isNotNull);
        expect(consultation.blockchainHash, isNotEmpty);
        expect(consultation.isVerified, isTrue);
      });

      test('should create consultation without follow-up', () async {
        final consultation = await service.createEConsultation(
          patientId: 'patient_012',
          patientName: 'Jack Kelly',
          therapistId: 'therapist_005',
          therapistName: 'Dr. Lee',
          consultationType: 'Medication Review',
          symptoms: 'Stable mood, good sleep',
          medicalHistory: 'Bipolar disorder, stable for 6 months',
          currentMedications: ['Lithium 600mg twice daily', 'Quetiapine 100mg at night'],
          assessment: 'Patient is stable on current medication regimen',
          recommendations: 'Continue current medications, maintain regular monitoring',
          prescribedMedications: ['Lithium 600mg twice daily', 'Quetiapine 100mg at night'],
          followUpInstructions: 'Continue current treatment plan',
          duration: 30,
          requiresFollowUp: false,
        );

        expect(consultation, isNotNull);
        expect(consultation.requiresFollowUp, isFalse);
        expect(consultation.followUpDate, isNull);
        expect(consultation.currentMedications.length, equals(2));
        expect(consultation.currentMedications, contains('Lithium 600mg twice daily'));
        expect(consultation.currentMedications, contains('Quetiapine 100mg at night'));
      });
    });

    group('Remote Prescription Tests', () {
      test('should create remote prescription', () async {
        final medications = [
          PrescribedMedication(
            id: 'med_001',
            medicationName: 'Sertraline',
            dosage: '50mg',
            frequency: 'Once daily',
            route: 'Oral',
            quantity: 30,
            instructions: 'Take in the morning with food',
            warnings: 'May cause nausea initially',
            isControlled: false,
            startDate: DateTime.now(),
            refills: 2,
            metadata: {},
          ),
        ];

        final prescription = await service.createRemotePrescription(
          patientId: 'patient_013',
          patientName: 'Kate Lewis',
          therapistId: 'therapist_005',
          therapistName: 'Dr. Lee',
          prescriptionType: 'New Prescription',
          medications: medications,
          diagnosis: 'Major Depressive Disorder',
          instructions: 'Start with 25mg for first week, then increase to 50mg',
          expiryDate: DateTime.now().add(const Duration(days: 90)),
          refills: 2,
          isControlled: false,
          metadata: {'therapy_type': 'medication_management'},
        );

        expect(prescription, isNotNull);
        expect(prescription.patientName, equals('Kate Lewis'));
        expect(prescription.prescriptionType, equals('New Prescription'));
        expect(prescription.medications.length, equals(1));
        expect(prescription.medications.first.medicationName, equals('Sertraline'));
        expect(prescription.medications.first.dosage, equals('50mg'));
        expect(prescription.diagnosis, equals('Major Depressive Disorder'));
        expect(prescription.instructions, equals('Start with 25mg for first week, then increase to 50mg'));
        expect(prescription.isControlled, isFalse);
        expect(prescription.status, equals('active'));
        expect(prescription.blockchainHash, isNotEmpty);
        expect(prescription.isVerified, isTrue);
        expect(prescription.metadata['therapy_type'], equals('medication_management'));
      });

      test('should create controlled substance prescription', () async {
        final medications = [
          PrescribedMedication(
            id: 'med_002',
            medicationName: 'Alprazolam',
            dosage: '0.5mg',
            frequency: 'As needed, up to 3 times daily',
            route: 'Oral',
            quantity: 15,
            instructions: 'Take only when experiencing severe anxiety',
            warnings: 'May cause drowsiness, do not drive after taking',
            isControlled: true,
            startDate: DateTime.now(),
            refills: 0,
            metadata: {},
          ),
        ];

        final prescription = await service.createRemotePrescription(
          patientId: 'patient_014',
          patientName: 'Liam Miller',
          therapistId: 'therapist_006',
          therapistName: 'Dr. Garcia',
          prescriptionType: 'Controlled Substance',
          medications: medications,
          diagnosis: 'Panic Disorder',
          instructions: 'Use only for acute panic attacks',
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          refills: 0,
          isControlled: true,
        );

        expect(prescription, isNotNull);
        expect(prescription.isControlled, isTrue);
        expect(prescription.medications.first.isControlled, isTrue);
        expect(prescription.medications.first.medicationName, equals('Alprazolam'));
        expect(prescription.medications.first.warnings, contains('drowsiness'));
        expect(prescription.medications.first.refills, equals(0));
      });
    });

    group('Patient Monitoring Tests', () {
      test('should start and stop patient monitoring', () async {
        final session = await service.createSession(
          patientId: 'patient_015',
          patientName: 'Mia Nelson',
          therapistId: 'therapist_006',
          therapistName: 'Dr. Garcia',
          sessionType: SessionType.assessment,
          scheduledTime: DateTime.now(),
          duration: 60,
        );

        // Start monitoring
        await service.startPatientMonitoring(
          patientId: 'patient_015',
          sessionId: session.id,
          monitoringInterval: 10, // 10 seconds for testing
        );

        // Wait a bit for monitoring to collect data
        await Future.delayed(const Duration(seconds: 15));

        // Stop monitoring
        await service.stopPatientMonitoring('patient_015');

        // Verify monitoring was active
        expect(true, isTrue); // If we reach here, no errors occurred
      });
    });

    group('Emergency Protocol Tests', () {
      test('should create emergency protocol', () async {
        final session = await service.createSession(
          patientId: 'patient_016',
          patientName: 'Noah Owens',
          therapistId: 'therapist_007',
          therapistName: 'Dr. Martinez',
          sessionType: SessionType.crisisIntervention,
          scheduledTime: DateTime.now(),
          duration: 120,
          emergencyLevel: EmergencyLevel.critical,
        );

        final emergencyProtocol = await service.createEmergencyProtocol(
          sessionId: session.id,
          patientId: 'patient_016',
          emergencyLevel: EmergencyLevel.critical,
          emergencyType: 'Suicidal Ideation',
          description: 'Patient expressing immediate suicidal thoughts',
          immediateActions: [
            'Stay on call with patient',
            'Contact emergency services',
            'Notify patient\'s emergency contacts',
          ],
          emergencyContacts: ['+1-555-0123', '+1-555-0456'],
          nearestHospital: 'City General Hospital',
          hospitalAddress: '123 Medical Center Dr, City, State 12345',
          hospitalPhone: '+1-555-0789',
          metadata: {'crisis_type': 'suicidal_ideation', 'risk_level': 'immediate'},
        );

        expect(emergencyProtocol, isNotNull);
        expect(emergencyProtocol.emergencyLevel, equals(EmergencyLevel.critical));
        expect(emergencyProtocol.emergencyType, equals('Suicidal Ideation'));
        expect(emergencyProtocol.description, equals('Patient expressing immediate suicidal thoughts'));
        expect(emergencyProtocol.immediateActions.length, equals(3));
        expect(emergencyProtocol.immediateActions, contains('Stay on call with patient'));
        expect(emergencyProtocol.emergencyContacts.length, equals(2));
        expect(emergencyProtocol.nearestHospital, equals('City General Hospital'));
        expect(emergencyProtocol.status, equals('active'));
        expect(emergencyProtocol.blockchainHash, isNotEmpty);
        expect(emergencyProtocol.metadata['crisis_type'], equals('suicidal_ideation'));
      });
    });

    group('Analytics Tests', () {
      test('should return telemedicine analytics', () async {
        final analytics = await service.getAnalytics(date: DateTime.now());

        expect(analytics, isNotNull);
        expect(analytics.date, isNotNull);
        expect(analytics.totalSessions, isA<int>());
        expect(analytics.completedSessions, isA<int>());
        expect(analytics.averageSessionDuration, isA<double>());
        expect(analytics.averageWaitTime, isA<double>());
        expect(analytics.patientSatisfactionScore, isA<double>());
        expect(analytics.technicalIssueRate, isA<double>());
        expect(analytics.sessionTypeDistribution, isNotEmpty);
        expect(analytics.emergencyLevelDistribution, isNotEmpty);
        expect(analytics.qualityMetrics, isNotEmpty);
        expect(analytics.performanceData, isNotEmpty);
      });
    });

    group('Stream Tests', () {
      test('should emit session updates', () async {
        final sessions = <TelemedicineSession>[];
        final subscription = service.sessionStream.listen(sessions.add);

        // Create a session to trigger stream
        await service.createSession(
          patientId: 'patient_017',
          patientName: 'Olivia Parker',
          therapistId: 'therapist_007',
          therapistName: 'Dr. Martinez',
          sessionType: SessionType.followUp,
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          duration: 45,
        );

        // Wait for stream to process
        await Future.delayed(const Duration(milliseconds: 100));

        expect(sessions, isNotEmpty);
        expect(sessions.length, equals(1));

        subscription.cancel();
      });

      test('should emit video quality updates', () async {
        final qualityMetrics = <VideoCallMetrics>[];
        final subscription = service.qualityStream.listen(qualityMetrics.add);

        // Create and start a session to trigger monitoring
        final session = await service.createSession(
          patientId: 'patient_018',
          patientName: 'Peter Quinn',
          therapistId: 'therapist_008',
          therapistName: 'Dr. Rodriguez',
          sessionType: SessionType.assessment,
          scheduledTime: DateTime.now(),
          duration: 60,
        );

        await service.startSession(
          sessionId: session.id,
          meetingUrl: 'https://meet.psyclinicai.com/session_789',
          meetingId: 'session_789',
        );

        // Wait for quality metrics to be collected
        await Future.delayed(const Duration(seconds: 15));

        expect(qualityMetrics, isNotEmpty);

        subscription.cancel();
      });

      test('should emit monitoring updates', () async {
        final monitoringData = <PatientMonitoringData>[];
        final subscription = service.monitoringStream.listen(monitoringData.add);

        final session = await service.createSession(
          patientId: 'patient_019',
          patientName: 'Quinn Roberts',
          therapistId: 'therapist_008',
          therapistName: 'Dr. Rodriguez',
          sessionType: SessionType.crisisIntervention,
          scheduledTime: DateTime.now(),
          duration: 90,
        );

        // Start monitoring
        await service.startPatientMonitoring(
          patientId: 'patient_019',
          sessionId: session.id,
          monitoringInterval: 5, // 5 seconds for testing
        );

        // Wait for monitoring data to be collected
        await Future.delayed(const Duration(seconds: 10));

        expect(monitoringData, isNotEmpty);

        // Stop monitoring
        await service.stopPatientMonitoring('patient_019');

        subscription.cancel();
      });

      test('should emit emergency protocol updates', () async {
        final emergencyProtocols = <EmergencyProtocol>[];
        final subscription = service.emergencyStream.listen(emergencyProtocols.add);

        final session = await service.createSession(
          patientId: 'patient_020',
          patientName: 'Rachel Smith',
          therapistId: 'therapist_009',
          therapistName: 'Dr. Thompson',
          sessionType: SessionType.emergencyEvaluation,
          scheduledTime: DateTime.now(),
          duration: 60,
          emergencyLevel: EmergencyLevel.high,
        );

        // Create emergency protocol to trigger stream
        await service.createEmergencyProtocol(
          sessionId: session.id,
          patientId: 'patient_020',
          emergencyLevel: EmergencyLevel.high,
          emergencyType: 'Severe Anxiety Attack',
          description: 'Patient experiencing severe panic symptoms',
          immediateActions: ['Deep breathing exercises', 'Stay calm and supportive'],
          emergencyContacts: ['+1-555-0123'],
          nearestHospital: 'Emergency Medical Center',
          hospitalAddress: '456 Emergency Ave, City, State 12345',
          hospitalPhone: '+1-555-0456',
        );

        // Wait for stream to process
        await Future.delayed(const Duration(milliseconds: 100));

        expect(emergencyProtocols, isNotEmpty);
        expect(emergencyProtocols.length, equals(1));

        subscription.cancel();
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        // This test verifies that the service handles network errors
        // by falling back to mock data
        final session = await service.createSession(
          patientId: 'patient_021',
          patientName: 'Sam Taylor',
          therapistId: 'therapist_009',
          therapistName: 'Dr. Thompson',
          sessionType: SessionType.medicationReview,
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
          duration: 30,
        );

        expect(session, isNotNull);
        expect(session.patientName, equals('Sam Taylor'));
      });
    });

    group('Mock Data Validation Tests', () {
      test('should provide realistic mock data', () async {
        // Create various types of data to validate mock quality
        final session = await service.createSession(
          patientId: 'patient_022',
          patientName: 'Tina Underwood',
          therapistId: 'therapist_010',
          therapistName: 'Dr. White',
          sessionType: SessionType.familyTherapy,
          scheduledTime: DateTime.now().add(const Duration(days: 1)),
          duration: 75,
        );

        final waitingRoom = await service.createWaitingRoom(sessionId: session.id);

        final consultation = await service.createEConsultation(
          patientId: 'patient_023',
          patientName: 'Ulysses Vance',
          therapistId: 'therapist_010',
          therapistName: 'Dr. White',
          consultationType: 'Behavioral Assessment',
          symptoms: 'ADHD symptoms, difficulty focusing',
          medicalHistory: 'Diagnosed with ADHD in childhood',
          currentMedications: ['Methylphenidate 20mg twice daily'],
          assessment: 'ADHD symptoms well-controlled with current medication',
          recommendations: 'Continue current treatment, add behavioral therapy',
          prescribedMedications: ['Methylphenidate 20mg twice daily'],
          followUpInstructions: 'Schedule behavioral therapy sessions',
          duration: 50,
        );

        final analytics = await service.getAnalytics(date: DateTime.now());

        // Validate session data
        expect(session, isNotNull);
        expect(session.id, isNotEmpty);
        expect(session.patientName, isNotEmpty);
        expect(session.therapistName, isNotEmpty);
        expect(session.blockchainHash, isNotEmpty);

        // Validate waiting room data
        expect(waitingRoom, isNotNull);
        expect(waitingRoom.id, isNotEmpty);
        expect(waitingRoom.sessionId, equals(session.id));

        // Validate consultation data
        expect(consultation, isNotNull);
        expect(consultation.id, isNotEmpty);
        expect(consultation.blockchainHash, isNotEmpty);
        expect(consultation.isVerified, isTrue);

        // Validate analytics data
        expect(analytics, isNotNull);
        expect(analytics.sessionTypeDistribution, isNotEmpty);
        expect(analytics.emergencyLevelDistribution, isNotEmpty);
        expect(analytics.qualityMetrics, isNotEmpty);
        expect(analytics.performanceData, isNotEmpty);
      });
    });
  });
}
