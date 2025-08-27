import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/prescription_ai_service.dart';
import 'package:psyclinicai/models/prescription_ai_models.dart';

void main() {
  group('PrescriptionAIService Tests', () {
    late PrescriptionAIService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = PrescriptionAIService();
    });

    group('Initialization Tests', () {
      test('should initialize successfully', () async {
        await service.initialize();
        
        expect(service.patientProfiles, isNotEmpty);
        expect(service.aiRecommendations, isNotEmpty);
        expect(service.dosageOptimizations, isNotEmpty);
        expect(service.advancedInteractions, isNotEmpty);
        expect(service.prescriptionHistory, isNotEmpty);
      });

      test('should load mock data', () async {
        await service.initialize();
        
        expect(service.patientProfiles.length, 1);
        expect(service.aiRecommendations.length, 1);
        expect(service.dosageOptimizations.length, 1);
        expect(service.advancedInteractions.length, 1);
        expect(service.prescriptionHistory.length, 1);
      });
    });

    group('AI Medication Recommendation Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should generate medication recommendation', () async {
        final recommendation = await service.generateMedicationRecommendation(
          patientId: 'patient_001',
          clinicianId: 'clinician_001',
          diagnoses: ['Major Depressive Disorder'],
          currentMedications: ['Sertraline'],
          patientData: {'age': 35, 'weight': 70},
        );

        expect(recommendation, isNotNull);
        expect(recommendation.patientId, 'patient_001');
        expect(recommendation.clinicianId, 'clinician_001');
        expect(recommendation.recommendedMedications, isNotEmpty);
        expect(recommendation.alternatives, isNotEmpty);
        expect(recommendation.confidenceScore, greaterThan(0.8));
        expect(recommendation.isReviewed, false);
      });

      test('should include clinical rationale', () async {
        final recommendation = await service.generateMedicationRecommendation(
          patientId: 'patient_002',
          clinicianId: 'clinician_001',
          diagnoses: ['Generalized Anxiety Disorder'],
          currentMedications: [],
          patientData: {'age': 28, 'weight': 65},
        );

        expect(recommendation.clinicalRationale, isNotEmpty);
        expect(recommendation.clinicalRationale, contains('AI analysis'));
      });

      test('should identify contraindications and warnings', () async {
        final recommendation = await service.generateMedicationRecommendation(
          patientId: 'patient_003',
          clinicianId: 'clinician_001',
          diagnoses: ['Major Depressive Disorder'],
          currentMedications: ['MAOI'],
          patientData: {'age': 45, 'weight': 80},
        );

        expect(recommendation.contraindications, isNotEmpty);
        expect(recommendation.warnings, isNotEmpty);
        expect(recommendation.monitoringRequirements, isNotEmpty);
      });

      test('should generate alternatives for medications', () async {
        final recommendation = await service.generateMedicationRecommendation(
          patientId: 'patient_004',
          clinicianId: 'clinician_001',
          diagnoses: ['Major Depressive Disorder'],
          currentMedications: [],
          patientData: {'age': 32, 'weight': 68},
        );

        expect(recommendation.alternatives, isNotEmpty);
        for (final alternative in recommendation.alternatives) {
          expect(alternative.medicationId, isNotEmpty);
          expect(alternative.medicationName, isNotEmpty);
          expect(alternative.similarityScore, greaterThan(0.5));
          expect(alternative.advantages, isNotEmpty);
          expect(alternative.disadvantages, isNotEmpty);
        }
      });
    });

    group('Smart Dosage Optimization Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should optimize dosage', () async {
        final optimization = await service.optimizeDosage(
          patientId: 'patient_001',
          medicationId: 'sertraline',
          currentDosage: '25mg',
          patientFactors: {'age': 35, 'weight': 70, 'liverFunction': 'Normal'},
        );

        expect(optimization, isNotNull);
        expect(optimization.patientId, 'patient_001');
        expect(optimization.medicationId, 'sertraline');
        expect(optimization.currentDosage, '25mg');
        expect(optimization.optimizedDosage, isNotEmpty);
        expect(optimization.titrationSchedule, isNotEmpty);
        expect(optimization.optimizationFactors, isNotEmpty);
        expect(optimization.expectedEfficacy, greaterThan(0.8));
        expect(optimization.expectedSafety, greaterThan(0.8));
        expect(optimization.monitoringPoints, isNotEmpty);
      });

      test('should include optimization factors', () async {
        final optimization = await service.optimizeDosage(
          patientId: 'patient_002',
          medicationId: 'escitalopram',
          currentDosage: '10mg',
          patientFactors: {'age': 65, 'weight': 75, 'renalFunction': 'Reduced'},
        );

        expect(optimization.optimizationFactors, isNotEmpty);
        expect(optimization.optimizationFactors, contains('Age'));
        expect(optimization.monitoringPoints, isNotEmpty);
      });
    });

    group('Advanced Drug Interaction Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should analyze advanced interaction', () async {
        final interaction = await service.analyzeAdvancedInteraction(
          medicationIds: ['sertraline', 'buspirone'],
          patientData: {'age': 40, 'weight': 70, 'liverFunction': 'Normal'},
        );

        expect(interaction, isNotNull);
        expect(interaction.medicationIds, contains('sertraline'));
        expect(interaction.medicationIds, contains('buspirone'));
        expect(interaction.medicationNames, isNotEmpty);
        expect(interaction.mechanism, isNotEmpty);
        expect(interaction.clinicalSignificance, isNotEmpty);
        expect(interaction.symptoms, isNotEmpty);
        expect(interaction.recommendations, isNotEmpty);
        expect(interaction.monitoringRequirements, isNotEmpty);
        expect(interaction.riskScore, greaterThan(0));
        expect(interaction.evidenceLevel, isNotEmpty);
        expect(interaction.references, isNotEmpty);
      });

      test('should assess interaction severity', () async {
        final interaction = await service.analyzeAdvancedInteraction(
          medicationIds: ['sertraline', 'MAOI'],
          patientData: {'age': 50, 'weight': 80, 'liverFunction': 'Elevated'},
        );

        expect(interaction.severity, isNotNull);
        expect(interaction.riskScore, greaterThan(0.2));
        expect(interaction.clinicalSignificance, contains('risk'));
      });
    });

    group('Patient Profile Management Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should create new patient profile', () async {
        final profile = await service.createOrUpdatePatientProfile(
          patientId: 'patient_new',
          profileData: {
            'diagnoses': ['Panic Disorder'],
            'medications': ['Alprazolam'],
            'allergies': ['Sulfa'],
            'comorbidities': ['Hypertension'],
          },
        );

        expect(profile, isNotNull);
        expect(profile.patientId, 'patient_new');
        expect(profile.currentDiagnoses, contains('Panic Disorder'));
        expect(profile.currentMedications, contains('Alprazolam'));
        expect(profile.allergies, contains('Sulfa'));
        expect(profile.comorbidities, contains('Hypertension'));
      });

      test('should update existing patient profile', () async {
        // First create a profile
        final originalProfile = await service.createOrUpdatePatientProfile(
          patientId: 'patient_update',
          profileData: {
            'diagnoses': ['Depression'],
            'medications': ['Sertraline'],
          },
        );

        // Then update it
        final updatedProfile = await service.createOrUpdatePatientProfile(
          patientId: 'patient_update',
          profileData: {
            'diagnoses': ['Depression', 'Anxiety'],
            'medications': ['Sertraline', 'Buspirone'],
            'allergies': ['Penicillin'],
          },
        );

        expect(updatedProfile.id, originalProfile.id);
        expect(updatedProfile.currentDiagnoses, contains('Anxiety'));
        expect(updatedProfile.currentMedications, contains('Buspirone'));
        expect(updatedProfile.allergies, contains('Penicillin'));
      });

      test('should get existing patient profile', () async {
        await service.createOrUpdatePatientProfile(
          patientId: 'patient_get',
          profileData: {
            'diagnoses': ['Bipolar Disorder'],
            'medications': ['Lithium'],
          },
        );

        final profile = service.getPatientProfile('patient_get');
        expect(profile, isNotNull);
        expect(profile!.currentDiagnoses, contains('Bipolar Disorder'));
        expect(profile.currentMedications, contains('Lithium'));
      });

      test('should return null for non-existent profile', () {
        final profile = service.getPatientProfile('non_existent');
        expect(profile, isNull);
      });
    });

    group('AI Prescription History Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should add prescription history', () async {
        final history = await service.addPrescriptionHistory(
          patientId: 'patient_001',
          clinicianId: 'clinician_001',
          medications: ['Sertraline 100mg daily'],
          diagnosis: 'Major Depressive Disorder',
          aiRecommendation: 'Sertraline is effective for MDD',
          aiConfidence: 0.92,
        );

        expect(history, isNotNull);
        expect(history.patientId, 'patient_001');
        expect(history.clinicianId, 'clinician_001');
        expect(history.medications, contains('Sertraline 100mg daily'));
        expect(history.diagnosis, 'Major Depressive Disorder');
        expect(history.aiRecommendation, 'Sertraline is effective for MDD');
        expect(history.aiConfidence, 0.92);
        expect(history.status, AIPrescriptionStatus.pending);
      });

      test('should update prescription status', () async {
        final history = await service.addPrescriptionHistory(
          patientId: 'patient_002',
          clinicianId: 'clinician_001',
          medications: ['Escitalopram 20mg daily'],
          diagnosis: 'Generalized Anxiety Disorder',
          aiRecommendation: 'Escitalopram for GAD',
          aiConfidence: 0.88,
        );

        await service.updatePrescriptionStatus(
          historyId: history.id,
          status: AIPrescriptionStatus.approved,
          modificationNotes: 'Dosage adjusted based on patient response',
        );

        final updatedHistory = service.prescriptionHistory.firstWhere((h) => h.id == history.id);
        expect(updatedHistory.status, AIPrescriptionStatus.approved);
        expect(updatedHistory.modificationNotes, 'Dosage adjusted based on patient response');
      });

      test('should handle rejection with reason', () async {
        final history = await service.addPrescriptionHistory(
          patientId: 'patient_003',
          clinicianId: 'clinician_001',
          medications: ['Venlafaxine 75mg daily'],
          diagnosis: 'Depression',
          aiRecommendation: 'Venlafaxine for depression',
          aiConfidence: 0.85,
        );

        await service.updatePrescriptionStatus(
          historyId: history.id,
          status: AIPrescriptionStatus.rejected,
          rejectionReason: 'Patient has contraindication',
        );

        final updatedHistory = service.prescriptionHistory.firstWhere((h) => h.id == history.id);
        expect(updatedHistory.status, AIPrescriptionStatus.rejected);
        expect(updatedHistory.rejectionReason, 'Patient has contraindication');
      });
    });

    group('Data Validation Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should validate AI recommendation data integrity', () async {
        final recommendation = await service.generateMedicationRecommendation(
          patientId: 'patient_001',
          clinicianId: 'clinician_001',
          diagnoses: ['Depression'],
          currentMedications: [],
          patientData: {'age': 30},
        );

        expect(recommendation.id, isNotEmpty);
        expect(recommendation.patientId, isNotEmpty);
        expect(recommendation.clinicianId, isNotEmpty);
        expect(recommendation.recommendationDate, isNotNull);
        expect(recommendation.aiModel, isNotEmpty);
        expect(recommendation.aiVersion, isNotEmpty);
        expect(recommendation.confidenceScore, greaterThan(0));
        expect(recommendation.confidenceScore, lessThanOrEqualTo(1));
        expect(recommendation.recommendedMedications, isNotEmpty);
        expect(recommendation.clinicalRationale, isNotEmpty);
        expect(recommendation.aiAnalysis, isNotEmpty);
      });

      test('should validate dosage optimization data integrity', () async {
        final optimization = await service.optimizeDosage(
          patientId: 'patient_001',
          medicationId: 'sertraline',
          currentDosage: '25mg',
          patientFactors: {'age': 35},
        );

        expect(optimization.id, isNotEmpty);
        expect(optimization.patientId, isNotEmpty);
        expect(optimization.medicationId, isNotEmpty);
        expect(optimization.currentDosage, isNotEmpty);
        expect(optimization.optimizedDosage, isNotEmpty);
        expect(optimization.titrationSchedule, isNotEmpty);
        expect(optimization.optimizationFactors, isNotEmpty);
        expect(optimization.expectedEfficacy, greaterThan(0));
        expect(optimization.expectedEfficacy, lessThanOrEqualTo(1));
        expect(optimization.expectedSafety, greaterThan(0));
        expect(optimization.expectedSafety, lessThanOrEqualTo(1));
        expect(optimization.monitoringPoints, isNotEmpty);
        expect(optimization.optimizationDate, isNotNull);
        expect(optimization.aiModel, isNotEmpty);
      });

      test('should validate advanced interaction data integrity', () async {
        final interaction = await service.analyzeAdvancedInteraction(
          medicationIds: ['sertraline', 'buspirone'],
          patientData: {'age': 40},
        );

        expect(interaction.id, isNotEmpty);
        expect(interaction.medicationIds, isNotEmpty);
        expect(interaction.medicationNames, isNotEmpty);
        expect(interaction.severity, isNotNull);
        expect(interaction.mechanism, isNotEmpty);
        expect(interaction.clinicalSignificance, isNotEmpty);
        expect(interaction.symptoms, isNotEmpty);
        expect(interaction.recommendations, isNotEmpty);
        expect(interaction.monitoringRequirements, isNotEmpty);
        expect(interaction.riskScore, greaterThan(0));
        expect(interaction.riskScore, lessThanOrEqualTo(1));
        expect(interaction.evidenceLevel, isNotEmpty);
        expect(interaction.references, isNotEmpty);
      });
    });

    group('Error Handling Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should handle invalid patient data gracefully', () async {
        try {
          await service.generateMedicationRecommendation(
            patientId: '',
            clinicianId: 'clinician_001',
            diagnoses: [],
            currentMedications: [],
            patientData: {},
          );
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('should handle empty diagnoses list', () async {
        try {
          await service.generateMedicationRecommendation(
            patientId: 'patient_001',
            clinicianId: 'clinician_001',
            diagnoses: [],
            currentMedications: [],
            patientData: {'age': 30},
          );
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });
    });

    group('Performance Tests', () {
      setUp(() async {
        await service.initialize();
      });

      test('should generate recommendation within reasonable time', () async {
        final stopwatch = Stopwatch()..start();
        
        await service.generateMedicationRecommendation(
          patientId: 'patient_perf',
          clinicianId: 'clinician_001',
          diagnoses: ['Depression'],
          currentMedications: [],
          patientData: {'age': 35},
        );
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should complete within 2 seconds
      });

      test('should optimize dosage within reasonable time', () async {
        final stopwatch = Stopwatch()..start();
        
        await service.optimizeDosage(
          patientId: 'patient_perf',
          medicationId: 'sertraline',
          currentDosage: '25mg',
          patientFactors: {'age': 35},
        );
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should complete within 1 second
      });
    });
  });
}
