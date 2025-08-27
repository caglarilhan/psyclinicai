import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/flag_system_service.dart';
import 'package:psyclinicai/models/flag_system_models.dart';

void main() {
  group('FlagSystemService Tests', () {
    late FlagSystemService service;

    setUp(() {
      service = FlagSystemService();
    });

    group('Initialization Tests', () {
      test('should initialize successfully', () async {
        await service.initialize();
        
        expect(service, isNotNull);
        expect(service, isA<FlagSystemService>());
      });

      test('should load mock data', () async {
        await service.initialize();
        
        expect(service.crisisFlags, isNotEmpty);
        expect(service.suicideAssessments, isNotEmpty);
        expect(service.agitationAssessments, isNotEmpty);
        expect(service.safetyPlans, isNotEmpty);
        expect(service.interventionProtocols, isNotEmpty);
      });
    });

    group('Crisis Flag Management Tests', () {
      test('should create new crisis flag', () async {
        await service.initialize();
        
        final flag = await service.createCrisisFlag(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          type: CrisisType.suicidalIdeation,
          severity: CrisisSeverity.high,
          description: 'Test kriz durumu',
          symptoms: ['Test belirti'],
          riskFactors: ['Test risk faktörü'],
          immediateActions: ['Test eylem'],
        );

        expect(flag, isNotNull);
        expect(flag.patientId, 'patient_test');
        expect(flag.type, CrisisType.suicidalIdeation);
        expect(flag.severity, CrisisSeverity.high);
        expect(flag.status, FlagStatus.active);
      });

      test('should update flag status', () async {
        await service.initialize();
        
        final flag = await service.createCrisisFlag(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          type: CrisisType.suicidalIdeation,
          severity: CrisisSeverity.high,
          description: 'Test kriz durumu',
          symptoms: ['Test belirti'],
          riskFactors: ['Test risk faktörü'],
          immediateActions: ['Test eylem'],
        );

        await service.updateFlagStatus(flag.id, FlagStatus.resolved, 'Test çözüm');
        
        final updatedFlag = service.crisisFlags.firstWhere((f) => f.id == flag.id);
        expect(updatedFlag.status, FlagStatus.resolved);
        expect(updatedFlag.resolvedAt, isNotNull);
      });

      test('should get active flags', () async {
        await service.initialize();
        
        final activeFlags = service.getActiveFlags();
        expect(activeFlags, isNotEmpty);
        
        // Şiddet seviyesine göre sıralanmalı
        for (int i = 0; i < activeFlags.length - 1; i++) {
          final currentSeverity = activeFlags[i].severity;
          final nextSeverity = activeFlags[i + 1].severity;
          
          final severityOrder = {
            CrisisSeverity.emergency: 5,
            CrisisSeverity.critical: 4,
            CrisisSeverity.high: 3,
            CrisisSeverity.moderate: 2,
            CrisisSeverity.low: 1,
          };
          
          expect(severityOrder[currentSeverity]!, greaterThanOrEqualTo(severityOrder[nextSeverity]!));
        }
      });

      test('should get flags for specific patient', () async {
        await service.initialize();
        
        final patientFlags = service.getFlagsForPatient('patient_001');
        expect(patientFlags, isNotEmpty);
        expect(patientFlags.every((f) => f.patientId == 'patient_001'), isTrue);
      });

      test('should get flags for specific clinician', () async {
        await service.initialize();
        
        final clinicianFlags = service.getFlagsForClinician('clinician_001');
        expect(clinicianFlags, isNotEmpty);
        expect(clinicianFlags.every((f) => f.clinicianId == 'clinician_001'), isTrue);
      });
    });

    group('Suicide Risk Assessment Tests', () {
      test('should create suicide risk assessment', () async {
        await service.initialize();
        
        final assessment = await service.createSuicideRiskAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          suicidalIdeationScore: 3,
          suicidalBehaviorScore: 2,
          lethalityScore: 1,
          riskFactors: ['Depresyon', 'Madde kullanımı'],
          protectiveFactors: ['Aile desteği', 'Tedavi uyumu'],
          clinicalImpression: 'Test klinik izlenim',
        );

        expect(assessment, isNotNull);
        expect(assessment.patientId, 'patient_test');
        expect(assessment.suicidalIdeationScore, 3);
        expect(assessment.suicidalBehaviorScore, 2);
        expect(assessment.lethalityScore, 1);
        expect(assessment.riskLevel, 'Orta');
        expect(assessment.safetyPlan, isNotEmpty);
        expect(assessment.followUpActions, isNotEmpty);
      });

      test('should calculate correct risk level for low risk', () async {
        await service.initialize();
        
        final assessment = await service.createSuicideRiskAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          suicidalIdeationScore: 1,
          suicidalBehaviorScore: 0,
          lethalityScore: 1,
          riskFactors: ['Hafif depresyon'],
          protectiveFactors: ['Güçlü aile desteği'],
          clinicalImpression: 'Düşük risk',
        );

        expect(assessment.riskLevel, 'Düşük');
      });

      test('should calculate correct risk level for high risk', () async {
        await service.initialize();
        
        final assessment = await service.createSuicideRiskAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          suicidalIdeationScore: 4,
          suicidalBehaviorScore: 3,
          lethalityScore: 2,
          riskFactors: ['Şiddetli depresyon', 'Geçmiş girişim'],
          protectiveFactors: ['Sınırlı destek'],
          clinicalImpression: 'Yüksek risk',
        );

        expect(assessment.riskLevel, 'Yüksek');
      });

      test('should calculate correct risk level for critical risk', () async {
        await service.initialize();
        
        final assessment = await service.createSuicideRiskAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          suicidalIdeationScore: 5,
          suicidalBehaviorScore: 4,
          lethalityScore: 5,
          riskFactors: ['Kritik depresyon', 'Aktif plan'],
          protectiveFactors: ['Yok'],
          clinicalImpression: 'Kritik risk',
        );

        expect(assessment.riskLevel, 'Kritik');
      });

      test('should create crisis flag for high risk assessment', () async {
        await service.initialize();
        
        final initialFlagCount = service.crisisFlags.length;
        
        await service.createSuicideRiskAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          suicidalIdeationScore: 4,
          suicidalBehaviorScore: 3,
          lethalityScore: 2,
          riskFactors: ['Yüksek risk'],
          protectiveFactors: ['Sınırlı'],
          clinicalImpression: 'Yüksek risk',
        );

        final finalFlagCount = service.crisisFlags.length;
        expect(finalFlagCount, greaterThan(initialFlagCount));
        
        final newFlag = service.crisisFlags.last;
        expect(newFlag.type, CrisisType.suicidalIdeation);
        expect(newFlag.severity, CrisisSeverity.high);
      });
    });

    group('Agitation Assessment Tests', () {
      test('should create agitation assessment', () async {
        await service.initialize();
        
        final assessment = await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 2,
          verbalAgitationScore: 1,
          aggressiveBehaviorScore: 0,
          impulsivityScore: 1,
          triggers: ['Stres', 'Uyku yoksunluğu'],
        );

        expect(assessment, isNotNull);
        expect(assessment.patientId, 'patient_test');
        expect(assessment.motorAgitationScore, 2);
        expect(assessment.verbalAgitationScore, 1);
        expect(assessment.agitationLevel, 'Hafif');
        expect(assessment.calmingTechniques, isNotEmpty);
        expect(assessment.interventionPlan, isNotEmpty);
      });

      test('should calculate correct agitation level for mild', () async {
        await service.initialize();
        
        final assessment = await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 1,
          verbalAgitationScore: 1,
          aggressiveBehaviorScore: 0,
          impulsivityScore: 1,
          triggers: ['Hafif stres'],
        );

        expect(assessment.agitationLevel, 'Hafif');
      });

      test('should calculate correct agitation level for moderate', () async {
        await service.initialize();
        
        final assessment = await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 2,
          verbalAgitationScore: 2,
          aggressiveBehaviorScore: 1,
          impulsivityScore: 2,
          triggers: ['Orta stres'],
        );

        expect(assessment.agitationLevel, 'Orta');
      });

      test('should calculate correct agitation level for severe', () async {
        await service.initialize();
        
        final assessment = await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 3,
          verbalAgitationScore: 3,
          aggressiveBehaviorScore: 2,
          impulsivityScore: 3,
          triggers: ['Şiddetli stres'],
        );

        expect(assessment.agitationLevel, 'Şiddetli');
      });

      test('should calculate correct agitation level for critical', () async {
        await service.initialize();
        
        final assessment = await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 4,
          verbalAgitationScore: 4,
          aggressiveBehaviorScore: 3,
          impulsivityScore: 4,
          triggers: ['Kritik stres'],
        );

        expect(assessment.agitationLevel, 'Kritik');
      });

      test('should create crisis flag for severe agitation', () async {
        await service.initialize();
        
        final initialFlagCount = service.crisisFlags.length;
        
        await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 4,
          verbalAgitationScore: 3,
          aggressiveBehaviorScore: 2,
          impulsivityScore: 4,
          triggers: ['Şiddetli ajitasyon'],
        );

        final finalFlagCount = service.crisisFlags.length;
        expect(finalFlagCount, greaterThan(initialFlagCount));
        
        final newFlag = service.crisisFlags.last;
        expect(newFlag.type, CrisisType.severeAgitation);
        expect(newFlag.severity, CrisisSeverity.high);
      });
    });

    group('Safety Plan Tests', () {
      test('should create safety plan', () async {
        await service.initialize();
        
        final plan = await service.createSafetyPlan(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          warningSigns: ['İzolasyon', 'Umutsuzluk'],
          internalCopingStrategies: ['Derin nefes', 'Meditasyon'],
          socialSupport: ['Aile', 'Arkadaşlar'],
          emergencyContact: '911',
        );

        expect(plan, isNotNull);
        expect(plan.patientId, 'patient_test');
        expect(plan.warningSigns, contains('İzolasyon'));
        expect(plan.internalCopingStrategies, contains('Derin nefes'));
        expect(plan.socialSupport, contains('Aile'));
        expect(plan.emergencyContact, '911');
        expect(plan.isActive, isTrue);
        expect(plan.professionalHelp, isNotEmpty);
        expect(plan.environmentalSafety, isNotEmpty);
        expect(plan.crisisIntervention, isNotEmpty);
      });
    });

    group('Intervention Protocol Tests', () {
      test('should have intervention protocols for different crisis types', () async {
        await service.initialize();
        
        final protocols = service.interventionProtocols;
        expect(protocols, isNotEmpty);
        
        final suicidalProtocol = protocols.firstWhere((p) => p.crisisType == CrisisType.suicidalIdeation);
        expect(suicidalProtocol, isNotNull);
        expect(suicidalProtocol.steps, isNotEmpty);
        expect(suicidalProtocol.teamMembers, isNotEmpty);
        
        final agitationProtocol = protocols.firstWhere((p) => p.crisisType == CrisisType.severeAgitation);
        expect(agitationProtocol, isNotNull);
        expect(agitationProtocol.steps, isNotEmpty);
        expect(agitationProtocol.requiredResources, isNotEmpty);
      });

      test('should have proper intervention steps', () async {
        await service.initialize();
        
        final protocol = service.interventionProtocols.first;
        final steps = protocol.steps;
        
        expect(steps, isNotEmpty);
        
        for (int i = 0; i < steps.length; i++) {
          final step = steps[i];
          expect(step.stepNumber, i + 1);
          expect(step.description, isNotEmpty);
          expect(step.action, isNotEmpty);
          expect(step.responsiblePerson, isNotEmpty);
          expect(step.estimatedTime, greaterThan(0));
          expect(step.successIndicators, isNotEmpty);
          expect(step.failureIndicators, isNotEmpty);
        }
      });
    });

    group('Flag History Tests', () {
      test('should track flag status changes', () async {
        await service.initialize();
        
        final flag = await service.createCrisisFlag(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          type: CrisisType.suicidalIdeation,
          severity: CrisisSeverity.high,
          description: 'Test flag',
          symptoms: ['Test'],
          riskFactors: ['Test'],
          immediateActions: ['Test'],
        );

        await service.updateFlagStatus(flag.id, FlagStatus.resolved, 'Test çözüm');
        
        final history = service.flagHistory;
        expect(history, isNotEmpty);
        
        final flagHistory = history.where((h) => h.flagId == flag.id).toList();
        expect(flagHistory.length, 2); // Oluşturma + güncelleme
        
        final creationHistory = flagHistory.firstWhere((h) => h.previousStatus == FlagStatus.active);
        expect(creationHistory.newStatus, FlagStatus.active);
        expect(creationHistory.changeReason, 'Yeni kriz flag\'ı oluşturuldu');
        
        final updateHistory = flagHistory.firstWhere((h) => h.previousStatus == FlagStatus.active && h.newStatus == FlagStatus.resolved);
        expect(updateHistory.newStatus, FlagStatus.resolved);
        expect(updateHistory.changeReason, 'Test çözüm');
      });
    });

    group('Statistics Tests', () {
      test('should calculate flag statistics correctly', () async {
        await service.initialize();
        
        final stats = service.getFlagStatistics();
        
        expect(stats['totalFlags'], greaterThan(0));
        expect(stats['activeFlags'], greaterThan(0));
        expect(stats['resolvedFlags'], isNotNull);
        expect(stats['severityDistribution'], isNotNull);
        expect(stats['typeDistribution'], isNotNull);
        
        final totalFlags = stats['totalFlags'] as int;
        final activeFlags = stats['activeFlags'] as int;
        final resolvedFlags = stats['resolvedFlags'] as int;
        
        expect(totalFlags, equals(activeFlags + resolvedFlags));
      });
    });

    group('Stream Tests', () {
      test('should emit crisis flag updates', () async {
        await service.initialize();
        
        bool flagReceived = false;
        service.crisisFlagStream.listen((flag) {
          flagReceived = true;
          expect(flag, isA<CrisisFlag>());
        });

        await service.createCrisisFlag(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          type: CrisisType.suicidalIdeation,
          severity: CrisisSeverity.high,
          description: 'Test flag',
          symptoms: ['Test'],
          riskFactors: ['Test'],
          immediateActions: ['Test'],
        );

        // Stream güncellemesi için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        expect(flagReceived, isTrue);
      });

      test('should emit suicide assessment updates', () async {
        await service.initialize();
        
        bool assessmentReceived = false;
        service.suicideAssessmentStream.listen((assessment) {
          assessmentReceived = true;
          expect(assessment, isA<SuicideRiskAssessment>());
        });

        await service.createSuicideRiskAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          suicidalIdeationScore: 2,
          suicidalBehaviorScore: 1,
          lethalityScore: 1,
          riskFactors: ['Test'],
          protectiveFactors: ['Test'],
          clinicalImpression: 'Test',
        );

        await Future.delayed(Duration(milliseconds: 100));
        expect(assessmentReceived, isTrue);
      });

      test('should emit agitation assessment updates', () async {
        await service.initialize();
        
        bool assessmentReceived = false;
        service.agitationAssessmentStream.listen((assessment) {
          assessmentReceived = true;
          expect(assessment, isA<AgitationAssessment>());
        });

        await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 2,
          verbalAgitationScore: 1,
          aggressiveBehaviorScore: 0,
          impulsivityScore: 1,
          triggers: ['Test'],
        );

        await Future.delayed(Duration(milliseconds: 100));
        expect(assessmentReceived, isTrue);
      });
    });

    group('Error Handling Tests', () {
      test('should handle flag not found error', () async {
        await service.initialize();
        
        expect(
          () => service.updateFlagStatus('nonexistent_flag', FlagStatus.resolved, 'Test'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Data Validation Tests', () {
      test('should validate crisis flag data integrity', () async {
        await service.initialize();
        
        final flag = await service.createCrisisFlag(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          type: CrisisType.suicidalIdeation,
          severity: CrisisSeverity.high,
          description: 'Test flag',
          symptoms: ['Test'],
          riskFactors: ['Test'],
          immediateActions: ['Test'],
        );

        expect(flag.id, isNotEmpty);
        expect(flag.patientId, isNotEmpty);
        expect(flag.clinicianId, isNotEmpty);
        expect(flag.detectedAt, isNotNull);
        expect(flag.description, isNotEmpty);
        expect(flag.symptoms, isNotEmpty);
        expect(flag.riskFactors, isNotEmpty);
        expect(flag.immediateActions, isNotEmpty);
        expect(flag.status, FlagStatus.active);
      });

      test('should validate suicide assessment data integrity', () async {
        await service.initialize();
        
        final assessment = await service.createSuicideRiskAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          suicidalIdeationScore: 2,
          suicidalBehaviorScore: 1,
          lethalityScore: 1,
          riskFactors: ['Test'],
          protectiveFactors: ['Test'],
          clinicalImpression: 'Test',
        );

        expect(assessment.id, isNotEmpty);
        expect(assessment.patientId, isNotEmpty);
        expect(assessment.clinicianId, isNotEmpty);
        expect(assessment.assessmentDate, isNotNull);
        expect(assessment.suicidalIdeationScore, greaterThanOrEqualTo(0));
        expect(assessment.suicidalIdeationScore, lessThanOrEqualTo(5));
        expect(assessment.suicidalBehaviorScore, greaterThanOrEqualTo(0));
        expect(assessment.suicidalBehaviorScore, lessThanOrEqualTo(5));
        expect(assessment.lethalityScore, greaterThanOrEqualTo(0));
        expect(assessment.lethalityScore, lessThanOrEqualTo(5));
        expect(assessment.riskLevel, isNotEmpty);
        expect(assessment.safetyPlan, isNotEmpty);
        expect(assessment.followUpActions, isNotEmpty);
      });

      test('should validate agitation assessment data integrity', () async {
        await service.initialize();
        
        final assessment = await service.createAgitationAssessment(
          patientId: 'patient_test',
          clinicianId: 'clinician_test',
          motorAgitationScore: 2,
          verbalAgitationScore: 1,
          aggressiveBehaviorScore: 0,
          impulsivityScore: 1,
          triggers: ['Test'],
        );

        expect(assessment.id, isNotEmpty);
        expect(assessment.patientId, isNotEmpty);
        expect(assessment.clinicianId, isNotEmpty);
        expect(assessment.assessmentDate, isNotNull);
        expect(assessment.motorAgitationScore, greaterThanOrEqualTo(0));
        expect(assessment.motorAgitationScore, lessThanOrEqualTo(5));
        expect(assessment.verbalAgitationScore, greaterThanOrEqualTo(0));
        expect(assessment.verbalAgitationScore, lessThanOrEqualTo(5));
        expect(assessment.aggressiveBehaviorScore, greaterThanOrEqualTo(0));
        expect(assessment.aggressiveBehaviorScore, lessThanOrEqualTo(5));
        expect(assessment.impulsivityScore, greaterThanOrEqualTo(0));
        expect(assessment.impulsivityScore, lessThanOrEqualTo(5));
        expect(assessment.agitationLevel, isNotEmpty);
        expect(assessment.calmingTechniques, isNotEmpty);
        expect(assessment.interventionPlan, isNotEmpty);
      });
    });

    group('Performance Tests', () {
      test('should create multiple flags within reasonable time', () async {
        await service.initialize();
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10; i++) {
          await service.createCrisisFlag(
            patientId: 'patient_$i',
            clinicianId: 'clinician_$i',
            type: CrisisType.suicidalIdeation,
            severity: CrisisSeverity.moderate,
            description: 'Test flag $i',
            symptoms: ['Test $i'],
            riskFactors: ['Test $i'],
            immediateActions: ['Test $i'],
          );
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1 saniyeden az
      });

      test('should handle large number of assessments efficiently', () async {
        await service.initialize();
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 50; i++) {
          await service.createSuicideRiskAssessment(
            patientId: 'patient_$i',
            clinicianId: 'clinician_$i',
            suicidalIdeationScore: 1,
            suicidalBehaviorScore: 1,
            lethalityScore: 1,
            riskFactors: ['Test $i'],
            protectiveFactors: ['Test $i'],
            clinicalImpression: 'Test $i',
          );
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // 2 saniyeden az
      });
    });
  });
}
