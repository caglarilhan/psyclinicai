import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/case_management_service.dart';
import 'package:psyclinicai/models/case_management_models.dart';

void main() {
  group('CaseManagementService Tests', () {
    late CaseManagementService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = CaseManagementService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Initialization Tests', () {
      test('should initialize successfully', () async {
        await service.initialize();
        
        // Mock veriler yüklenmiş olmalı
        final cases = service.getCases();
        expect(cases, isNotEmpty);
        expect(cases.length, greaterThanOrEqualTo(2));
      });

      test('should load mock cases', () async {
        await service.initialize();
        
        final cases = service.getCases();
        expect(cases.any((c) => c.title.contains('Depresyon')), isTrue);
        expect(cases.any((c) => c.title.contains('Anksiyete')), isTrue);
      });
    });

    group('Case Management Tests', () {
      test('should create new case', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
          priority: PriorityLevel.high,
        );
        
        expect(case_, isNotNull);
        expect(case_.title, 'Test Vakası');
        expect(case_.status, CaseStatus.active);
        expect(case_.priority, PriorityLevel.high);
        expect(case_.clientId, 'client_test');
        expect(case_.therapistId, 'therapist_test');
      });

      test('should update case', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.updateCase(case_.id, 
          title: 'Güncellenmiş Vaka',
          status: CaseStatus.completed,
        );
        
        final updatedCase = service.getCase(case_.id);
        expect(updatedCase?.title, 'Güncellenmiş Vaka');
        expect(updatedCase?.status, CaseStatus.completed);
        expect(updatedCase?.completedAt, isNotNull);
      });

      test('should get case by id', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final retrievedCase = service.getCase(case_.id);
        expect(retrievedCase, isNotNull);
        expect(retrievedCase?.id, case_.id);
        expect(retrievedCase?.title, 'Test Vakası');
      });

      test('should get all cases', () async {
        await service.initialize();
        
        await service.createCase(
          clientId: 'client_1',
          therapistId: 'therapist_1',
          title: 'Vaka 1',
          description: 'Açıklama 1',
        );
        
        await service.createCase(
          clientId: 'client_2',
          therapistId: 'therapist_2',
          title: 'Vaka 2',
          description: 'Açıklama 2',
        );
        
        final cases = service.getCases();
        expect(cases.length, greaterThanOrEqualTo(2));
      });
    });

    group('Assessment Tests', () {
      test('should add assessment', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final assessment = await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.initial,
          assessorId: 'therapist_test',
          assessorName: 'Dr. Test',
          clinicalFindings: {'mood': 'depressed'},
          strengths: ['Motivasyon'],
          challenges: ['Düşük enerji'],
          recommendations: ['CBT başlat'],
        );
        
        expect(assessment, isNotNull);
        expect(assessment.caseId, case_.id);
        expect(assessment.type, AssessmentType.initial);
        expect(assessment.assessorId, 'therapist_test');
        expect(assessment.strengths, contains('Motivasyon'));
        expect(assessment.challenges, contains('Düşük enerji'));
      });

      test('should get assessments for case', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.initial,
          assessorId: 'therapist_test',
        );
        
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.progress,
          assessorId: 'therapist_test',
        );
        
        final assessments = service.getAssessments(case_.id);
        expect(assessments.length, 2);
        expect(assessments[0].type, AssessmentType.initial);
        expect(assessments[1].type, AssessmentType.progress);
      });

      test('should create alert for high risk assessment', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.crisis,
          assessorId: 'therapist_test',
          riskLevel: RiskLevel.critical,
        );
        
        final alerts = service.getAlerts(case_.id);
        expect(alerts, isNotEmpty);
        expect(alerts.any((a) => a.alertType == 'high_risk'), isTrue);
      });
    });

    group('Progress Tests', () {
      test('should add progress record', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final progress = await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          recordedByName: 'Dr. Test',
          progressNote: 'Hasta daha iyi görünüyor',
          indicator: ProgressIndicator.improving,
          achievedGoals: ['Hedef 1'],
          newGoals: ['Hedef 2'],
        );
        
        expect(progress, isNotNull);
        expect(progress.caseId, case_.id);
        expect(progress.progressNote, 'Hasta daha iyi görünüyor');
        expect(progress.indicator, ProgressIndicator.improving);
        expect(progress.achievedGoals, contains('Hedef 1'));
        expect(progress.newGoals, contains('Hedef 2'));
      });

      test('should get progress records for case', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          progressNote: 'İlerleme 1',
        );
        
        await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          progressNote: 'İlerleme 2',
        );
        
        final progressRecords = service.getProgress(case_.id);
        expect(progressRecords.length, 2);
        expect(progressRecords[0].progressNote, 'İlerleme 1');
        expect(progressRecords[1].progressNote, 'İlerleme 2');
      });

      test('should create alert for declining progress', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          progressNote: 'Hasta kötüleşiyor',
          indicator: ProgressIndicator.declining,
        );
        
        final alerts = service.getAlerts(case_.id);
        expect(alerts, isNotEmpty);
        expect(alerts.any((a) => a.alertType == 'declining_progress'), isTrue);
      });
    });

    group('Treatment Goals Tests', () {
      test('should add treatment goal', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final goal = await service.addTreatmentGoal(
          caseId: case_.id,
          title: 'Ruh halini iyileştirme',
          description: 'Depresif belirtileri azaltma',
          category: 'Mood',
          targetDate: DateTime.now().add(Duration(days: 30)),
          priority: 1,
          milestones: ['PHQ-9 skorunu düşür'],
        );
        
        expect(goal, isNotNull);
        expect(goal.caseId, case_.id);
        expect(goal.title, 'Ruh halini iyileştirme');
        expect(goal.category, 'Mood');
        expect(goal.isAchieved, false);
        expect(goal.milestones, contains('PHQ-9 skorunu düşür'));
      });

      test('should get treatment goals for case', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.addTreatmentGoal(
          caseId: case_.id,
          title: 'Hedef 1',
          description: 'Açıklama 1',
          category: 'Category 1',
          targetDate: DateTime.now().add(Duration(days: 30)),
        );
        
        await service.addTreatmentGoal(
          caseId: case_.id,
          title: 'Hedef 2',
          description: 'Açıklama 2',
          category: 'Category 2',
          targetDate: DateTime.now().add(Duration(days: 60)),
        );
        
        final goals = service.getGoals(case_.id);
        expect(goals.length, 2);
        expect(goals[0].title, 'Hedef 1');
        expect(goals[1].title, 'Hedef 2');
      });

      test('should complete treatment goal', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final goal = await service.addTreatmentGoal(
          caseId: case_.id,
          title: 'Test Hedefi',
          description: 'Test açıklaması',
          category: 'Test',
          targetDate: DateTime.now().add(Duration(days: 30)),
        );
        
        await service.completeGoal(goal.id, case_.id);
        
        final goals = service.getGoals(case_.id);
        final completedGoal = goals.firstWhere((g) => g.id == goal.id);
        expect(completedGoal.isAchieved, true);
        expect(completedGoal.achievedDate, isNotNull);
      });
    });

    group('Statistics Tests', () {
      test('should calculate case statistics', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        // Değerlendirme ekle
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.initial,
          assessorId: 'therapist_test',
          riskLevel: RiskLevel.moderate,
        );
        
        // İlerleme kaydı ekle
        await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          progressNote: 'Test ilerleme',
          indicator: ProgressIndicator.improving,
        );
        
        // Hedef ekle
        await service.addTreatmentGoal(
          caseId: case_.id,
          title: 'Test Hedefi',
          description: 'Test açıklaması',
          category: 'Test',
          targetDate: DateTime.now().add(Duration(days: 30)),
        );
        
        final statistics = await service.calculateStatistics(case_.id);
        expect(statistics, isNotNull);
        expect(statistics.caseId, case_.id);
        expect(statistics.totalAssessments, 1);
        expect(statistics.totalGoals, 1);
        expect(statistics.achievedGoals, 0);
        expect(statistics.riskScore, 2.0); // moderate risk
      });

      test('should get case statistics', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.calculateStatistics(case_.id);
        
        final statistics = service.getStatistics(case_.id);
        expect(statistics, isNotNull);
        expect(statistics?.caseId, case_.id);
      });
    });

    group('Summary Tests', () {
      test('should generate case summary', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
          primaryDiagnosis: 'F32.1 - Majör Depresyon',
        );
        
        // Değerlendirme ekle
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.initial,
          assessorId: 'therapist_test',
          summary: 'İlk değerlendirme tamamlandı',
        );
        
        // İlerleme kaydı ekle
        await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          progressNote: 'Hasta daha iyi görünüyor',
        );
        
        // Hedef ekle
        await service.addTreatmentGoal(
          caseId: case_.id,
          title: 'Ruh halini iyileştirme',
          description: 'Depresif belirtileri azaltma',
          category: 'Mood',
          targetDate: DateTime.now().add(Duration(days: 30)),
        );
        
        final summary = await service.generateSummary(case_.id, 'therapist_test');
        expect(summary, isNotNull);
        expect(summary.caseId, case_.id);
        expect(summary.generatedBy, 'therapist_test');
        expect(summary.summary, isNotEmpty);
        expect(summary.summary, contains('Test Vakası'));
        expect(summary.keyMetrics, isNotEmpty);
        expect(summary.achievements, isNotNull);
        expect(summary.challenges, isNotNull);
        expect(summary.recommendations, isNotNull);
      });
    });

    group('Timeline Tests', () {
      test('should get case timeline', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final timeline = service.getTimeline(case_.id);
        expect(timeline, isNotEmpty);
        expect(timeline.any((t) => t.eventType == 'case_created'), isTrue);
      });
    });

    group('Alert Tests', () {
      test('should get case alerts', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        // Yüksek risk değerlendirmesi ekle
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.crisis,
          assessorId: 'therapist_test',
          riskLevel: RiskLevel.critical,
        );
        
        final alerts = service.getAlerts(case_.id);
        expect(alerts, isNotEmpty);
        expect(alerts.any((a) => a.alertType == 'high_risk'), isTrue);
        expect(alerts.any((a) => a.isActive), isTrue);
      });

      test('should acknowledge alert', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        // Yüksek risk değerlendirmesi ekle
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.crisis,
          assessorId: 'therapist_test',
          riskLevel: RiskLevel.critical,
        );
        
        final alerts = service.getAlerts(case_.id);
        final alert = alerts.firstWhere((a) => a.alertType == 'high_risk');
        
        await service.acknowledgeAlert(alert.id, case_.id, 'therapist_test');
        
        final updatedAlerts = service.getAlerts(case_.id);
        final updatedAlert = updatedAlerts.firstWhere((a) => a.id == alert.id);
        expect(updatedAlert.acknowledgedAt, isNotNull);
        expect(updatedAlert.acknowledgedBy, 'therapist_test');
        expect(updatedAlert.isActive, false);
      });
    });

    group('Stream Tests', () {
      test('should emit case updates', () async {
        await service.initialize();
        
        final caseUpdates = <CaseManagement>[];
        service.caseStream.listen(caseUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        await service.updateCase(case_.id, status: CaseStatus.completed);
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(caseUpdates.length, greaterThanOrEqualTo(1)); // create + update
        expect(caseUpdates.any((c) => c.status == CaseStatus.active), isTrue);
        expect(caseUpdates.any((c) => c.status == CaseStatus.completed), isTrue);
      });

      test('should emit assessment updates', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final assessmentUpdates = <CaseAssessment>[];
        service.assessmentStream.listen(assessmentUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.initial,
          assessorId: 'therapist_test',
        );
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(assessmentUpdates.length, 1);
        expect(assessmentUpdates[0].type, AssessmentType.initial);
      });

      test('should emit progress updates', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final progressUpdates = <CaseProgress>[];
        service.progressStream.listen(progressUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          progressNote: 'Test ilerleme',
        );
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(progressUpdates.length, 1);
        expect(progressUpdates[0].progressNote, 'Test ilerleme');
      });

      test('should emit alert updates', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final alertUpdates = <CaseAlert>[];
        service.alertStream.listen(alertUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.crisis,
          assessorId: 'therapist_test',
          riskLevel: RiskLevel.critical,
        );
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(alertUpdates.length, 1);
        expect(alertUpdates[0].alertType, 'high_risk');
      });
    });

    group('Error Handling Tests', () {
      test('should handle case not found error', () async {
        await service.initialize();
        
        expect(
          () => service.updateCase('non_existent_id', title: 'Test'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle invalid case id in assessment', () async {
        await service.initialize();
        
        expect(
          () => service.addAssessment(
            caseId: 'non_existent_id',
            type: AssessmentType.initial,
            assessorId: 'therapist_test',
          ),
          returnsNormally, // Service handles errors gracefully
        );
      });
    });

    group('Data Validation Tests', () {
      test('should validate case data integrity', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
          primaryDiagnosis: 'F32.1',
          secondaryDiagnoses: ['F41.1'],
          treatmentGoals: ['Hedef 1', 'Hedef 2'],
        );
        
        expect(case_.id, isNotEmpty);
        expect(case_.createdAt, isNotNull);
        expect(case_.startedAt, isNotNull);
        expect(case_.primaryDiagnosis, 'F32.1');
        expect(case_.secondaryDiagnoses.length, 1);
        expect(case_.treatmentGoals.length, 2);
        expect(case_.metadata, isNotNull);
      });

      test('should validate assessment data integrity', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final assessment = await service.addAssessment(
          caseId: case_.id,
          type: AssessmentType.initial,
          assessorId: 'therapist_test',
          assessorName: 'Dr. Test',
          clinicalFindings: {'mood': 'depressed'},
          strengths: ['Motivasyon'],
          challenges: ['Düşük enerji'],
          recommendations: ['CBT başlat'],
          scores: {'phq9': 15},
        );
        
        expect(assessment.id, isNotEmpty);
        expect(assessment.caseId, case_.id);
        expect(assessment.assessmentDate, isNotNull);
        expect(assessment.assessorId, 'therapist_test');
        expect(assessment.assessorName, 'Dr. Test');
        expect(assessment.clinicalFindings['mood'], 'depressed');
        expect(assessment.strengths, contains('Motivasyon'));
        expect(assessment.challenges, contains('Düşük enerji'));
        expect(assessment.recommendations, contains('CBT başlat'));
        expect(assessment.scores['phq9'], 15);
        expect(assessment.metadata, isNotNull);
      });

      test('should validate progress data integrity', () async {
        await service.initialize();
        
        final case_ = await service.createCase(
          clientId: 'client_test',
          therapistId: 'therapist_test',
          title: 'Test Vakası',
          description: 'Test açıklaması',
        );
        
        final progress = await service.addProgress(
          caseId: case_.id,
          recordedBy: 'therapist_test',
          recordedByName: 'Dr. Test',
          progressNote: 'Hasta daha iyi görünüyor',
          indicator: ProgressIndicator.improving,
          achievedGoals: ['Hedef 1'],
          newGoals: ['Hedef 2'],
          measurements: {'mood_scale': 7},
          observations: {'attendance': 'good'},
          nextSteps: 'Devam et',
          relatedSessions: ['session_1'],
        );
        
        expect(progress.id, isNotEmpty);
        expect(progress.caseId, case_.id);
        expect(progress.progressDate, isNotNull);
        expect(progress.recordedBy, 'therapist_test');
        expect(progress.recordedByName, 'Dr. Test');
        expect(progress.progressNote, 'Hasta daha iyi görünüyor');
        expect(progress.indicator, ProgressIndicator.improving);
        expect(progress.achievedGoals, contains('Hedef 1'));
        expect(progress.newGoals, contains('Hedef 2'));
        expect(progress.measurements['mood_scale'], 7);
        expect(progress.observations['attendance'], 'good');
        expect(progress.nextSteps, 'Devam et');
        expect(progress.relatedSessions, contains('session_1'));
        expect(progress.metadata, isNotNull);
      });
    });
  });
}
