import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/supervisor_service.dart';
import 'package:psyclinicai/models/supervisor_models.dart';

void main() {
  group('SupervisorService Tests', () {
    late SupervisorService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = SupervisorService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Initialization Tests', () {
      test('should initialize successfully', () async {
        await service.initialize();
        
        // Mock veriler yüklenmiş olmalı
        final performance = service.getPerformance('therapist_1');
        expect(performance, isNotNull);
        expect(performance?.therapistName, 'Dr. Ahmet Yılmaz');
      });

      test('should load mock data', () async {
        await service.initialize();
        
        final performance = service.getPerformance('therapist_1');
        final evaluations = service.getEvaluations('therapist_1');
        final aiEvaluations = service.getAIEvaluations('therapist_1');
        
        expect(performance, isNotNull);
        expect(evaluations, isNotEmpty);
        expect(aiEvaluations, isNotEmpty);
      });
    });

    group('Therapist Performance Tests', () {
      test('should evaluate therapist performance', () async {
        await service.initialize();
        
        final performance = await service.evaluateTherapist(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          evaluationPeriod: DateTime.now().subtract(Duration(days: 30)),
          categoryScores: {'CBT': 85.0, 'DBT': 78.0, 'Empati': 92.0},
          metrics: {'sessions': 40, 'clients': 10},
          strengths: ['Empatik yaklaşım'],
          areasForImprovement: ['DBT teknikleri'],
          recommendations: ['DBT eğitimi alınmalı'],
        );
        
        expect(performance, isNotNull);
        expect(performance.therapistId, 'therapist_test');
        expect(performance.therapistName, 'Dr. Test Terapist');
        expect(performance.overallScore, 85.0);
        expect(performance.overallLevel, PerformanceLevel.good);
        expect(performance.strengths, contains('Empatik yaklaşım'));
        expect(performance.areasForImprovement, contains('DBT teknikleri'));
      });

      test('should calculate overall score correctly', () async {
        await service.initialize();
        
        final performance = await service.evaluateTherapist(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          evaluationPeriod: DateTime.now().subtract(Duration(days: 30)),
          categoryScores: {'CBT': 90.0, 'DBT': 95.0, 'Empati': 88.0},
          metrics: {'sessions': 40, 'clients': 10},
        );
        
        expect(performance.overallScore, 91.0);
        expect(performance.overallLevel, PerformanceLevel.excellent);
      });

      test('should identify strengths and areas for improvement', () async {
        await service.initialize();
        
        final performance = await service.evaluateTherapist(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          evaluationPeriod: DateTime.now().subtract(Duration(days: 30)),
          categoryScores: {'CBT': 85.0, 'DBT': 65.0, 'Empati': 92.0},
          metrics: {'sessions': 40, 'clients': 10},
        );
        
        expect(performance.strengths, contains('CBT: 85.0'));
        expect(performance.strengths, contains('Empati: 92.0'));
        expect(performance.areasForImprovement, contains('DBT: 65.0'));
        expect(performance.recommendations, contains('DBT alanında ek eğitim alınmalı'));
      });
    });

    group('Session Evaluation Tests', () {
      test('should add session evaluation', () async {
        await service.initialize();
        
        final evaluation = await service.addSessionEvaluation(
          sessionId: 'session_test',
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          clientId: 'client_test',
          clientName: 'Test Danışan',
          sessionDate: DateTime.now().subtract(Duration(days: 1)),
          evaluatorId: 'supervisor_test',
          evaluatorName: 'Dr. Test Süpervizör',
          quality: SessionQuality.good,
          qualityScore: 85.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 88.0, 'Empati': 90.0, 'Zaman Yönetimi': 80.0},
        );
        
        expect(evaluation, isNotNull);
        expect(evaluation.sessionId, 'session_test');
        expect(evaluation.therapistId, 'therapist_test');
        expect(evaluation.quality, SessionQuality.good);
        expect(evaluation.qualityScore, 85.0);
        expect(evaluation.skillScores['CBT'], 88.0);
        expect(evaluation.strengths, contains('CBT: 88.0'));
        expect(evaluation.areasForImprovement, isNotEmpty);
      });

      test('should get evaluations for therapist', () async {
        await service.initialize();
        
        await service.addSessionEvaluation(
          sessionId: 'session_1',
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          clientId: 'client_1',
          clientName: 'Test Danışan 1',
          sessionDate: DateTime.now().subtract(Duration(days: 2)),
          evaluatorId: 'supervisor_test',
          quality: SessionQuality.excellent,
          qualityScore: 95.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 95.0, 'Empati': 95.0},
        );
        
        await service.addSessionEvaluation(
          sessionId: 'session_2',
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          clientId: 'client_2',
          clientName: 'Test Danışan 2',
          sessionDate: DateTime.now().subtract(Duration(days: 1)),
          evaluatorId: 'supervisor_test',
          quality: SessionQuality.good,
          qualityScore: 85.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 85.0, 'Empati': 85.0},
        );
        
        final evaluations = service.getEvaluations('therapist_test');
        expect(evaluations.length, 2);
        expect(evaluations[0].quality, SessionQuality.excellent);
        expect(evaluations[1].quality, SessionQuality.good);
      });
    });

    group('AI Evaluation Tests', () {
      test('should add AI evaluation', () async {
        await service.initialize();
        
        final aiEvaluation = await service.addAIEvaluation(
          sessionId: 'session_test',
          therapistId: 'therapist_test',
          aiModel: 'GPT-4',
          aiVersion: '4.0',
          confidenceScore: 0.88,
          skillAssessments: {'CBT': 0.85, 'Empati': 0.90, 'DBT': 0.75},
          techniqueEvaluations: {'Sokratik Sorgulama': 0.88, 'Davranış Aktivasyonu': 0.82},
          interventionScores: {'Müdahale 1': 0.87, 'Müdahale 2': 0.83},
          aiAnalysis: 'AI analizi: Terapist genel olarak iyi performans gösteriyor.',
        );
        
        expect(aiEvaluation, isNotNull);
        expect(aiEvaluation.sessionId, 'session_test');
        expect(aiEvaluation.therapistId, 'therapist_test');
        expect(aiEvaluation.aiModel, 'GPT-4');
        expect(aiEvaluation.confidenceScore, 0.88);
        expect(aiEvaluation.detectedStrengths, isNotEmpty);
        expect(aiEvaluation.detectedAreasForImprovement, isNotEmpty);
        expect(aiEvaluation.isReviewed, false);
      });

      test('should review AI evaluation', () async {
        await service.initialize();
        
        final aiEvaluation = await service.addAIEvaluation(
          sessionId: 'session_test',
          therapistId: 'therapist_test',
          aiModel: 'GPT-4',
          aiVersion: '4.0',
          confidenceScore: 0.88,
          skillAssessments: {'CBT': 0.85, 'Empati': 0.90},
          techniqueEvaluations: {'Sokratik Sorgulama': 0.88},
          interventionScores: {'Müdahale 1': 0.87},
          aiAnalysis: 'AI analizi test',
        );
        
        await service.reviewAIEvaluation(
          aiEvaluation.id,
          'therapist_test',
          reviewedBy: 'supervisor_test',
          reviewNotes: 'AI değerlendirmesi onaylandı',
        );
        
        final evaluations = service.getAIEvaluations('therapist_test');
        final reviewedEvaluation = evaluations.firstWhere((e) => e.id == aiEvaluation.id);
        expect(reviewedEvaluation.isReviewed, true);
        expect(reviewedEvaluation.reviewedBy, 'supervisor_test');
        expect(reviewedEvaluation.reviewNotes, 'AI değerlendirmesi onaylandı');
        expect(reviewedEvaluation.reviewedAt, isNotNull);
      });

      test('should get AI evaluations for therapist', () async {
        await service.initialize();
        
        await service.addAIEvaluation(
          sessionId: 'session_1',
          therapistId: 'therapist_test',
          aiModel: 'GPT-4',
          aiVersion: '4.0',
          confidenceScore: 0.88,
          skillAssessments: {'CBT': 0.85},
          techniqueEvaluations: {'Sokratik Sorgulama': 0.88},
          interventionScores: {'Müdahale 1': 0.87},
          aiAnalysis: 'AI analizi 1',
        );
        
        await service.addAIEvaluation(
          sessionId: 'session_2',
          therapistId: 'therapist_test',
          aiModel: 'Claude',
          aiVersion: '3.5',
          confidenceScore: 0.92,
          skillAssessments: {'CBT': 0.90},
          techniqueEvaluations: {'Davranış Aktivasyonu': 0.92},
          interventionScores: {'Müdahale 2': 0.90},
          aiAnalysis: 'AI analizi 2',
        );
        
        final aiEvaluations = service.getAIEvaluations('therapist_test');
        expect(aiEvaluations.length, 2);
        expect(aiEvaluations[0].aiModel, 'GPT-4');
        expect(aiEvaluations[1].aiModel, 'Claude');
      });
    });

    group('Supervision Session Tests', () {
      test('should create supervision session', () async {
        await service.initialize();
        
        final session = await service.createSupervisionSession(
          supervisorId: 'supervisor_test',
          supervisorName: 'Dr. Test Süpervizör',
          therapistIds: ['therapist_1', 'therapist_2'],
          therapistNames: ['Dr. Test 1', 'Dr. Test 2'],
          type: SupervisionType.group,
          scheduledDate: DateTime.now().add(Duration(days: 3)),
          plannedDuration: 90,
          location: 'Toplantı Odası B',
          agenda: 'Haftalık değerlendirme',
          discussionTopics: ['Vaka 1', 'Vaka 2'],
        );
        
        expect(session, isNotNull);
        expect(session.supervisorId, 'supervisor_test');
        expect(session.therapistIds.length, 2);
        expect(session.type, SupervisionType.group);
        expect(session.plannedDuration, 90);
        expect(session.location, 'Toplantı Odası B');
        expect(session.agenda, 'Haftalık değerlendirme');
        expect(session.discussionTopics, contains('Vaka 1'));
        expect(session.status, EvaluationStatus.pending);
      });

      test('should get supervision sessions for supervisor', () async {
        await service.initialize();
        
        await service.createSupervisionSession(
          supervisorId: 'supervisor_test',
          supervisorName: 'Dr. Test Süpervizör',
          therapistIds: ['therapist_1'],
          therapistNames: ['Dr. Test 1'],
          type: SupervisionType.individual,
          scheduledDate: DateTime.now().add(Duration(days: 1)),
          plannedDuration: 60,
        );
        
        await service.createSupervisionSession(
          supervisorId: 'supervisor_test',
          supervisorName: 'Dr. Test Süpervizör',
          therapistIds: ['therapist_2'],
          therapistNames: ['Dr. Test 2'],
          type: SupervisionType.individual,
          scheduledDate: DateTime.now().add(Duration(days: 2)),
          plannedDuration: 60,
        );
        
        final sessions = service.getSupervisionSessions('supervisor_test');
        expect(sessions.length, 2);
        expect(sessions[0].type, SupervisionType.individual);
        expect(sessions[1].type, SupervisionType.individual);
      });
    });

    group('Performance Metrics Tests', () {
      test('should calculate performance metrics', () async {
        await service.initialize();
        
        // Seans değerlendirmeleri ekle
        await service.addSessionEvaluation(
          sessionId: 'session_1',
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          clientId: 'client_1',
          clientName: 'Test Danışan 1',
          sessionDate: DateTime.now().subtract(Duration(days: 5)),
          evaluatorId: 'supervisor_test',
          quality: SessionQuality.excellent,
          qualityScore: 95.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 95.0, 'Empati': 95.0},
        );
        
        await service.addSessionEvaluation(
          sessionId: 'session_2',
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          clientId: 'client_2',
          clientName: 'Test Danışan 2',
          sessionDate: DateTime.now().subtract(Duration(days: 3)),
          evaluatorId: 'supervisor_test',
          quality: SessionQuality.good,
          qualityScore: 85.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 85.0, 'Empati': 85.0},
        );
        
        final metrics = await service.calculatePerformanceMetrics(
          therapistId: 'therapist_test',
          periodStart: DateTime.now().subtract(Duration(days: 10)),
          periodEnd: DateTime.now(),
        );
        
        expect(metrics, isNotNull);
        expect(metrics.therapistId, 'therapist_test');
        expect(metrics.totalSessions, 2);
        expect(metrics.completedSessions, 2);
        expect(metrics.onTimeRate, 100.0);
        expect(metrics.completionRate, 100.0);
        expect(metrics.averageQualityScore, 90.0);
        expect(metrics.averageSessionDuration, 50.0);
        expect(metrics.skillAverages['CBT'], 90.0);
        expect(metrics.skillAverages['Empati'], 90.0);
        expect(metrics.totalClients, 2);
      });

      test('should get performance metrics', () async {
        await service.initialize();
        
        final calculatedMetrics = await service.calculatePerformanceMetrics(
          therapistId: 'therapist_test',
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );
        
        expect(calculatedMetrics, isNotNull);
        expect(calculatedMetrics.therapistId, 'therapist_test');
        
        final metrics = service.getMetrics('therapist_test');
        expect(metrics, isNotNull);
        expect(metrics?.therapistId, 'therapist_test');
      });
    });

    group('Development Plan Tests', () {
      test('should create development plan', () async {
        await service.initialize();
        
        final plan = await service.createDevelopmentPlan(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          supervisorId: 'supervisor_test',
          supervisorName: 'Dr. Test Süpervizör',
          goals: ['DBT tekniklerini geliştir', 'Zaman yönetimini iyileştir'],
          actionSteps: ['DBT eğitimi al', 'Seans planlamasını optimize et'],
          resources: ['DBT Manual', 'Zaman yönetimi kursu'],
          milestones: ['DBT eğitimi tamamlandı', 'Seans süreleri optimize edildi'],
          targetDate: DateTime.now().add(Duration(days: 60)),
        );
        
        expect(plan, isNotNull);
        expect(plan.therapistId, 'therapist_test');
        expect(plan.supervisorId, 'supervisor_test');
        expect(plan.goals.length, 2);
        expect(plan.actionSteps.length, 2);
        expect(plan.resources.length, 2);
        expect(plan.milestones.length, 2);
        expect(plan.targetDate, isNotNull);
        expect(plan.progressPercentage, 0.0);
        expect(plan.status, EvaluationStatus.pending);
      });

      test('should get development plans for therapist', () async {
        await service.initialize();
        
        await service.createDevelopmentPlan(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          supervisorId: 'supervisor_test',
          goals: ['Hedef 1'],
          actionSteps: ['Adım 1'],
          resources: ['Kaynak 1'],
          milestones: ['Kilometre taşı 1'],
        );
        
        await service.createDevelopmentPlan(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          supervisorId: 'supervisor_test',
          goals: ['Hedef 2'],
          actionSteps: ['Adım 2'],
          resources: ['Kaynak 2'],
          milestones: ['Kilometre taşı 2'],
        );
        
        final plans = service.getDevelopmentPlans('therapist_test');
        expect(plans.length, 2);
        expect(plans[0].goals, contains('Hedef 1'));
        expect(plans[1].goals, contains('Hedef 2'));
      });
    });

    group('Performance Report Tests', () {
      test('should generate performance report', () async {
        await service.initialize();
        
        final report = await service.generatePerformanceReport(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          generatedBy: 'supervisor_test',
        );
        
        expect(report, isNotNull);
        expect(report.therapistId, 'therapist_test');
        expect(report.therapistName, 'Dr. Test Terapist');
        expect(report.generatedBy, 'supervisor_test');
        expect(report.periodStart, isNotNull);
        expect(report.periodEnd, isNotNull);
        expect(report.reportDate, isNotNull);
        expect(report.summary, isNotEmpty);
        expect(report.keyAchievements, isNotNull);
        expect(report.areasForImprovement, isNotNull);
        expect(report.recommendations, isNotNull);
      });

      test('should get performance reports for therapist', () async {
        await service.initialize();
        
        await service.generatePerformanceReport(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          generatedBy: 'supervisor_test',
        );
        
        final reports = service.getReports('therapist_test');
        expect(reports, isNotEmpty);
        expect(reports.first.therapistId, 'therapist_test');
      });
    });

    group('Team Performance Tests', () {
      test('should calculate team performance', () async {
        await service.initialize();
        
        final teamPerformance = await service.calculateTeamPerformance(
          teamId: 'team_test',
          teamName: 'Test Ekibi',
          therapistIds: ['therapist_1', 'therapist_2'],
          therapistNames: ['Dr. Test 1', 'Dr. Test 2'],
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );
        
        expect(teamPerformance, isNotNull);
        expect(teamPerformance.teamId, 'team_test');
        expect(teamPerformance.teamName, 'Test Ekibi');
        expect(teamPerformance.therapistIds.length, 2);
        expect(teamPerformance.therapistNames.length, 2);
        expect(teamPerformance.teamAverageScore, isNotNull);
        expect(teamPerformance.teamLevel, isNotNull);
        expect(teamPerformance.individualScores, isNotEmpty);
        expect(teamPerformance.comparativeMetrics, isNotEmpty);
      });

      test('should get team performance', () async {
        await service.initialize();
        
        await service.calculateTeamPerformance(
          teamId: 'team_test',
          teamName: 'Test Ekibi',
          therapistIds: ['therapist_1', 'therapist_2'],
          therapistNames: ['Dr. Test 1', 'Dr. Test 2'],
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );
        
        final teamPerformance = service.getTeamPerformance('team_test');
        expect(teamPerformance, isNotNull);
        expect(teamPerformance?.teamId, 'team_test');
      });
    });

    group('Stream Tests', () {
      test('should emit performance updates', () async {
        await service.initialize();
        
        final performanceUpdates = <TherapistPerformance>[];
        service.performanceStream.listen(performanceUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        await service.evaluateTherapist(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          evaluationPeriod: DateTime.now().subtract(Duration(days: 30)),
          categoryScores: {'CBT': 85.0, 'DBT': 78.0},
          metrics: {'sessions': 40, 'clients': 10},
        );
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(performanceUpdates.length, 1);
        expect(performanceUpdates[0].therapistId, 'therapist_test');
        expect(performanceUpdates[0].therapistName, 'Dr. Test Terapist');
      });

      test('should emit evaluation updates', () async {
        await service.initialize();
        
        final evaluationUpdates = <SessionEvaluation>[];
        service.evaluationStream.listen(evaluationUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        await service.addSessionEvaluation(
          sessionId: 'session_test',
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          clientId: 'client_test',
          clientName: 'Test Danışan',
          sessionDate: DateTime.now().subtract(Duration(days: 1)),
          evaluatorId: 'supervisor_test',
          quality: SessionQuality.good,
          qualityScore: 85.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 88.0, 'Empati': 90.0},
        );
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(evaluationUpdates.length, 1);
        expect(evaluationUpdates[0].sessionId, 'session_test');
        expect(evaluationUpdates[0].therapistId, 'therapist_test');
      });

      test('should emit AI evaluation updates', () async {
        await service.initialize();
        
        final aiEvaluationUpdates = <AIEvaluation>[];
        service.aiEvaluationStream.listen(aiEvaluationUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        await service.addAIEvaluation(
          sessionId: 'session_test',
          therapistId: 'therapist_test',
          aiModel: 'GPT-4',
          aiVersion: '4.0',
          confidenceScore: 0.88,
          skillAssessments: {'CBT': 0.85, 'Empati': 0.90},
          techniqueEvaluations: {'Sokratik Sorgulama': 0.88},
          interventionScores: {'Müdahale 1': 0.87},
          aiAnalysis: 'AI analizi test',
        );
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(aiEvaluationUpdates.length, 1);
        expect(aiEvaluationUpdates[0].sessionId, 'session_test');
        expect(aiEvaluationUpdates[0].aiModel, 'GPT-4');
      });

      test('should emit supervision updates', () async {
        await service.initialize();
        
        final supervisionUpdates = <SupervisionSession>[];
        service.supervisionStream.listen(supervisionUpdates.add);
        
        // Stream listener'ın kurulması için kısa bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        await service.createSupervisionSession(
          supervisorId: 'supervisor_test',
          supervisorName: 'Dr. Test Süpervizör',
          therapistIds: ['therapist_1'],
          therapistNames: ['Dr. Test 1'],
          type: SupervisionType.individual,
          scheduledDate: DateTime.now().add(Duration(days: 1)),
          plannedDuration: 60,
        );
        
        // Stream güncellemelerinin işlenmesi için bekleme
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(supervisionUpdates.length, 1);
        expect(supervisionUpdates[0].supervisorId, 'supervisor_test');
        expect(supervisionUpdates[0].type, SupervisionType.individual);
      });
    });

    group('Data Validation Tests', () {
      test('should validate therapist performance data integrity', () async {
        await service.initialize();
        
        final performance = await service.evaluateTherapist(
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          evaluationPeriod: DateTime.now().subtract(Duration(days: 30)),
          categoryScores: {'CBT': 85.0, 'DBT': 78.0, 'Empati': 92.0},
          metrics: {'sessions': 40, 'clients': 10},
          strengths: ['Empatik yaklaşım', 'CBT teknikleri'],
          areasForImprovement: ['DBT teknikleri'],
          recommendations: ['DBT eğitimi alınmalı'],
          supervisorNotes: 'Genel olarak iyi performans',
          therapistNotes: 'DBT alanında gelişim hedefliyorum',
        );
        
        expect(performance.id, isNotEmpty);
        expect(performance.createdAt, isNotNull);
        expect(performance.categoryScores.length, 3);
        expect(performance.strengths.length, 2);
        expect(performance.areasForImprovement.length, 1);
        expect(performance.recommendations.length, 1);
        expect(performance.supervisorNotes, 'Genel olarak iyi performans');
        expect(performance.therapistNotes, 'DBT alanında gelişim hedefliyorum');
        expect(performance.metadata, isNotNull);
      });

      test('should validate session evaluation data integrity', () async {
        await service.initialize();
        
        final evaluation = await service.addSessionEvaluation(
          sessionId: 'session_test',
          therapistId: 'therapist_test',
          therapistName: 'Dr. Test Terapist',
          clientId: 'client_test',
          clientName: 'Test Danışan',
          sessionDate: DateTime.now().subtract(Duration(days: 1)),
          evaluatorId: 'supervisor_test',
          evaluatorName: 'Dr. Test Süpervizör',
          quality: SessionQuality.excellent,
          qualityScore: 95.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 95.0, 'Empati': 95.0, 'Zaman Yönetimi': 90.0},
          strengths: ['Empatik yaklaşım', 'CBT teknikleri'],
          areasForImprovement: ['Zaman yönetimi'],
          recommendations: ['Seans sürelerini optimize et'],
          evaluatorNotes: 'Mükemmel seans',
          therapistNotes: 'Teşekkürler',
        );
        
        expect(evaluation.id, isNotEmpty);
        expect(evaluation.sessionId, 'session_test');
        expect(evaluation.therapistId, 'therapist_test');
        expect(evaluation.clientId, 'client_test');
        expect(evaluation.sessionDate, isNotNull);
        expect(evaluation.evaluationDate, isNotNull);
        expect(evaluation.evaluatorId, 'supervisor_test');
        expect(evaluation.evaluatorName, 'Dr. Test Süpervizör');
        expect(evaluation.quality, SessionQuality.excellent);
        expect(evaluation.qualityScore, 95.0);
        expect(evaluation.sessionDuration, 50);
        expect(evaluation.plannedDuration, 45);
        expect(evaluation.isOnTime, true);
        expect(evaluation.isComplete, true);
        expect(evaluation.skillScores.length, 3);
        expect(evaluation.strengths.length, 2);
        expect(evaluation.areasForImprovement.length, 1);
        expect(evaluation.recommendations.length, 1);
        expect(evaluation.evaluatorNotes, 'Mükemmel seans');
        expect(evaluation.therapistNotes, 'Teşekkürler');
        expect(evaluation.status, EvaluationStatus.completed);
        expect(evaluation.metadata, isNotNull);
      });

      test('should validate AI evaluation data integrity', () async {
        await service.initialize();
        
        final aiEvaluation = await service.addAIEvaluation(
          sessionId: 'session_test',
          therapistId: 'therapist_test',
          aiModel: 'GPT-4',
          aiVersion: '4.0',
          confidenceScore: 0.88,
          skillAssessments: {'CBT': 0.85, 'Empati': 0.90, 'DBT': 0.75},
          techniqueEvaluations: {'Sokratik Sorgulama': 0.88, 'Davranış Aktivasyonu': 0.82},
          interventionScores: {'Müdahale 1': 0.87, 'Müdahale 2': 0.83},
          aiAnalysis: 'AI analizi: Terapist genel olarak iyi performans gösteriyor.',
          rawAnalysis: {'detail1': 'value1', 'detail2': 'value2'},
        );
        
        expect(aiEvaluation.id, isNotEmpty);
        expect(aiEvaluation.sessionId, 'session_test');
        expect(aiEvaluation.therapistId, 'therapist_test');
        expect(aiEvaluation.evaluationDate, isNotNull);
        expect(aiEvaluation.aiModel, 'GPT-4');
        expect(aiEvaluation.aiVersion, '4.0');
        expect(aiEvaluation.confidenceScore, 0.88);
        expect(aiEvaluation.skillAssessments.length, 3);
        expect(aiEvaluation.techniqueEvaluations.length, 2);
        expect(aiEvaluation.interventionScores.length, 2);
        expect(aiEvaluation.detectedStrengths, isNotEmpty);
        expect(aiEvaluation.detectedAreasForImprovement, isNotEmpty);
        expect(aiEvaluation.aiRecommendations, isNotEmpty);
        expect(aiEvaluation.aiAnalysis, 'AI analizi: Terapist genel olarak iyi performans gösteriyor.');
        expect(aiEvaluation.rawAnalysis.length, 2);
        expect(aiEvaluation.isReviewed, false);
        expect(aiEvaluation.metadata, isNotNull);
      });
    });
  });
}
