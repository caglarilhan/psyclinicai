import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/case_management_models.dart';

/// Vaka Yöneticisi Servisi
/// Her danışan için tanı & gelişim takibi
class CaseManagementService {
  static const String _baseUrl = 'https://api.psyclinicai.com/case-management';
  static const String _apiKey = 'your_api_key_here';
  
  // Caches
  final Map<String, CaseManagement> _casesCache = {};
  final Map<String, List<CaseAssessment>> _assessmentsCache = {};
  final Map<String, List<CaseProgress>> _progressCache = {};
  final Map<String, List<TreatmentGoal>> _goalsCache = {};
  final Map<String, List<CaseTimeline>> _timelineCache = {};
  final Map<String, List<CaseAlert>> _alertsCache = {};
  final Map<String, CaseStatistics> _statisticsCache = {};
  
  // Stream controllers
  final StreamController<CaseManagement> _caseController = 
      StreamController<CaseManagement>.broadcast();
  final StreamController<CaseAssessment> _assessmentController = 
      StreamController<CaseAssessment>.broadcast();
  final StreamController<CaseProgress> _progressController = 
      StreamController<CaseProgress>.broadcast();
  final StreamController<CaseAlert> _alertController = 
      StreamController<CaseAlert>.broadcast();
  
  // Streams
  Stream<CaseManagement> get caseStream => _caseController.stream;
  Stream<CaseAssessment> get assessmentStream => _assessmentController.stream;
  Stream<CaseProgress> get progressStream => _progressController.stream;
  Stream<CaseAlert> get alertStream => _alertController.stream;
  
  /// Servisi başlat
  Future<void> initialize() async {
    try {
      await _loadMockData();
      print('CaseManagementService initialized successfully');
    } catch (e) {
      print('Error initializing CaseManagementService: $e');
      await _loadMockData();
    }
  }
  
  /// Mock data yükle
  Future<void> _loadMockData() async {
    _casesCache.addAll(_generateMockCases());
    _assessmentsCache.addAll(_generateMockAssessments());
    _progressCache.addAll(_generateMockProgress());
    _goalsCache.addAll(_generateMockGoals());
    _timelineCache.addAll(_generateMockTimeline());
    _alertsCache.addAll(_generateMockAlerts());
  }
  
  /// Yeni vaka oluştur
  Future<CaseManagement> createCase({
    required String clientId,
    required String therapistId,
    required String title,
    required String description,
    PriorityLevel priority = PriorityLevel.medium,
    String? primaryDiagnosis,
    List<String>? secondaryDiagnoses,
    List<String>? treatmentGoals,
    List<String>? interventions,
    Map<String, dynamic>? clientInfo,
    Map<String, dynamic>? treatmentPlan,
    String? supervisorId,
    String? notes,
  }) async {
    try {
      final case_ = CaseManagement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: clientId,
        therapistId: therapistId,
        title: title,
        description: description,
        status: CaseStatus.active,
        priority: priority,
        createdAt: DateTime.now(),
        startedAt: DateTime.now(),
        primaryDiagnosis: primaryDiagnosis,
        secondaryDiagnoses: secondaryDiagnoses ?? [],
        treatmentGoals: treatmentGoals ?? [],
        interventions: interventions ?? [],
        clientInfo: clientInfo ?? {},
        treatmentPlan: treatmentPlan ?? {},
        metadata: {},
        supervisorId: supervisorId,
        notes: notes,
      );
      
      // Cache'e ekle
      _casesCache[case_.id] = case_;
      
      // Timeline'a ekle
      await _addTimelineEvent(
        caseId: case_.id,
        eventType: 'case_created',
        title: 'Vaka Oluşturuldu',
        description: 'Yeni vaka oluşturuldu: $title',
        performedBy: therapistId,
      );
      
      // Stream'e gönder
      _caseController.add(case_);
      
      return case_;
    } catch (e) {
      print('Error creating case: $e');
      rethrow;
    }
  }
  
  /// Vaka güncelle
  Future<void> updateCase(String caseId, {
    String? title,
    String? description,
    CaseStatus? status,
    PriorityLevel? priority,
    String? primaryDiagnosis,
    List<String>? secondaryDiagnoses,
    List<String>? treatmentGoals,
    List<String>? interventions,
    Map<String, dynamic>? clientInfo,
    Map<String, dynamic>? treatmentPlan,
    String? supervisorId,
    String? notes,
  }) async {
    try {
      final existingCase = _casesCache[caseId];
      if (existingCase == null) {
        throw Exception('Case not found');
      }
      
      final updatedCase = CaseManagement(
        id: existingCase.id,
        clientId: existingCase.clientId,
        therapistId: existingCase.therapistId,
        title: title ?? existingCase.title,
        description: description ?? existingCase.description,
        status: status ?? existingCase.status,
        priority: priority ?? existingCase.priority,
        createdAt: existingCase.createdAt,
        startedAt: existingCase.startedAt,
        completedAt: status == CaseStatus.completed ? DateTime.now() : existingCase.completedAt,
        primaryDiagnosis: primaryDiagnosis ?? existingCase.primaryDiagnosis,
        secondaryDiagnoses: secondaryDiagnoses ?? existingCase.secondaryDiagnoses,
        treatmentGoals: treatmentGoals ?? existingCase.treatmentGoals,
        interventions: interventions ?? existingCase.interventions,
        clientInfo: clientInfo ?? existingCase.clientInfo,
        treatmentPlan: treatmentPlan ?? existingCase.treatmentPlan,
        metadata: existingCase.metadata,
        supervisorId: supervisorId ?? existingCase.supervisorId,
        notes: notes ?? existingCase.notes,
      );
      
      _casesCache[caseId] = updatedCase;
      
      // Timeline'a ekle
      await _addTimelineEvent(
        caseId: caseId,
        eventType: 'case_updated',
        title: 'Vaka Güncellendi',
        description: 'Vaka bilgileri güncellendi',
        performedBy: updatedCase.therapistId,
      );
      
      _caseController.add(updatedCase);
    } catch (e) {
      print('Error updating case: $e');
      rethrow;
    }
  }
  
  /// Değerlendirme ekle
  Future<CaseAssessment> addAssessment({
    required String caseId,
    required AssessmentType type,
    required String assessorId,
    String? assessorName,
    Map<String, dynamic>? clinicalFindings,
    Map<String, dynamic>? functionalAssessment,
    Map<String, dynamic>? riskAssessment,
    List<String>? strengths,
    List<String>? challenges,
    List<String>? recommendations,
    ProgressIndicator? progressIndicator,
    RiskLevel? riskLevel,
    String? summary,
    Map<String, dynamic>? scores,
  }) async {
    try {
      final assessment = CaseAssessment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caseId: caseId,
        type: type,
        assessmentDate: DateTime.now(),
        assessorId: assessorId,
        assessorName: assessorName,
        clinicalFindings: clinicalFindings ?? {},
        functionalAssessment: functionalAssessment ?? {},
        riskAssessment: riskAssessment ?? {},
        strengths: strengths ?? [],
        challenges: challenges ?? [],
        recommendations: recommendations ?? [],
        progressIndicator: progressIndicator ?? ProgressIndicator.stable,
        riskLevel: riskLevel ?? RiskLevel.low,
        summary: summary,
        scores: scores ?? {},
        metadata: {},
        attachments: [],
      );
      
      // Cache'e ekle
      if (_assessmentsCache[caseId] == null) {
        _assessmentsCache[caseId] = [];
      }
      _assessmentsCache[caseId]!.add(assessment);
      
      // Timeline'a ekle
      await _addTimelineEvent(
        caseId: caseId,
        eventType: 'assessment_added',
        title: 'Değerlendirme Eklendi',
        description: '${type.toString().split('.').last} değerlendirmesi eklendi',
        performedBy: assessorId,
      );
      
      // Risk seviyesi yüksekse uyarı oluştur
      if (riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical) {
        await _createAlert(
          caseId: caseId,
          alertType: 'high_risk',
          title: 'Yüksek Risk Tespit Edildi',
          message: 'Değerlendirmede yüksek risk seviyesi tespit edildi',
          priority: riskLevel == RiskLevel.critical ? PriorityLevel.urgent : PriorityLevel.high,
        );
      }
      
      _assessmentController.add(assessment);
      return assessment;
    } catch (e) {
      print('Error adding assessment: $e');
      rethrow;
    }
  }
  
  /// İlerleme kaydı ekle
  Future<CaseProgress> addProgress({
    required String caseId,
    required String recordedBy,
    String? recordedByName,
    required String progressNote,
    ProgressIndicator? indicator,
    List<String>? achievedGoals,
    List<String>? newGoals,
    List<String>? interventions,
    Map<String, dynamic>? measurements,
    Map<String, dynamic>? observations,
    String? nextSteps,
    List<String>? relatedSessions,
  }) async {
    try {
      final progress = CaseProgress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caseId: caseId,
        progressDate: DateTime.now(),
        recordedBy: recordedBy,
        recordedByName: recordedByName,
        progressNote: progressNote,
        indicator: indicator ?? ProgressIndicator.stable,
        achievedGoals: achievedGoals ?? [],
        newGoals: newGoals ?? [],
        interventions: interventions ?? [],
        measurements: measurements ?? {},
        observations: observations ?? {},
        nextSteps: nextSteps,
        metadata: {},
        relatedSessions: relatedSessions ?? [],
      );
      
      // Cache'e ekle
      if (_progressCache[caseId] == null) {
        _progressCache[caseId] = [];
      }
      _progressCache[caseId]!.add(progress);
      
      // Timeline'a ekle
      await _addTimelineEvent(
        caseId: caseId,
        eventType: 'progress_recorded',
        title: 'İlerleme Kaydedildi',
        description: 'Vaka ilerlemesi kaydedildi',
        performedBy: recordedBy,
      );
      
      // İlerleme kötüyse uyarı oluştur
      if (indicator == ProgressIndicator.declining) {
        await _createAlert(
          caseId: caseId,
          alertType: 'declining_progress',
          title: 'İlerleme Gerilemesi',
          message: 'Vakada ilerleme gerilemesi tespit edildi',
          priority: PriorityLevel.high,
        );
      }
      
      _progressController.add(progress);
      return progress;
    } catch (e) {
      print('Error adding progress: $e');
      rethrow;
    }
  }
  
  /// Tedavi hedefi ekle
  Future<TreatmentGoal> addTreatmentGoal({
    required String caseId,
    required String title,
    required String description,
    required String category,
    required DateTime targetDate,
    int priority = 1,
    List<String>? milestones,
    List<String>? interventions,
    Map<String, dynamic>? measurements,
    String? notes,
  }) async {
    try {
      final goal = TreatmentGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caseId: caseId,
        title: title,
        description: description,
        category: category,
        targetDate: targetDate,
        isAchieved: false,
        priority: priority,
        milestones: milestones ?? [],
        interventions: interventions ?? [],
        measurements: measurements ?? {},
        metadata: {},
        notes: notes,
      );
      
      // Cache'e ekle
      if (_goalsCache[caseId] == null) {
        _goalsCache[caseId] = [];
      }
      _goalsCache[caseId]!.add(goal);
      
      // Timeline'a ekle
      await _addTimelineEvent(
        caseId: caseId,
        eventType: 'goal_added',
        title: 'Hedef Eklendi',
        description: 'Yeni tedavi hedefi: $title',
        performedBy: _casesCache[caseId]?.therapistId ?? 'unknown',
      );
      
      return goal;
    } catch (e) {
      print('Error adding treatment goal: $e');
      rethrow;
    }
  }
  
  /// Hedefi tamamla
  Future<void> completeGoal(String goalId, String caseId) async {
    try {
      final goals = _goalsCache[caseId];
      if (goals == null) return;
      
      final goalIndex = goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return;
      
      final updatedGoal = TreatmentGoal(
        id: goals[goalIndex].id,
        caseId: goals[goalIndex].caseId,
        title: goals[goalIndex].title,
        description: goals[goalIndex].description,
        category: goals[goalIndex].category,
        targetDate: goals[goalIndex].targetDate,
        achievedDate: DateTime.now(),
        isAchieved: true,
        priority: goals[goalIndex].priority,
        milestones: goals[goalIndex].milestones,
        interventions: goals[goalIndex].interventions,
        measurements: goals[goalIndex].measurements,
        metadata: goals[goalIndex].metadata,
        notes: goals[goalIndex].notes,
      );
      
      goals[goalIndex] = updatedGoal;
      
      // Timeline'a ekle
      await _addTimelineEvent(
        caseId: caseId,
        eventType: 'goal_achieved',
        title: 'Hedef Tamamlandı',
        description: 'Tedavi hedefi tamamlandı: ${updatedGoal.title}',
        performedBy: _casesCache[caseId]?.therapistId ?? 'unknown',
      );
    } catch (e) {
      print('Error completing goal: $e');
    }
  }
  
  /// Timeline olayı ekle
  Future<void> _addTimelineEvent({
    required String caseId,
    required String eventType,
    required String title,
    required String description,
    String? performedBy,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final timelineEvent = CaseTimeline(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caseId: caseId,
        eventDate: DateTime.now(),
        eventType: eventType,
        title: title,
        description: description,
        performedBy: performedBy,
        eventData: eventData ?? {},
        metadata: {},
      );
      
      if (_timelineCache[caseId] == null) {
        _timelineCache[caseId] = [];
      }
      _timelineCache[caseId]!.add(timelineEvent);
    } catch (e) {
      print('Error adding timeline event: $e');
    }
  }
  
  /// Uyarı oluştur
  Future<void> _createAlert({
    required String caseId,
    required String alertType,
    required String title,
    required String message,
    PriorityLevel priority = PriorityLevel.medium,
    Map<String, dynamic>? alertData,
  }) async {
    try {
      final alert = CaseAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caseId: caseId,
        alertType: alertType,
        title: title,
        message: message,
        priority: priority,
        createdAt: DateTime.now(),
        isActive: true,
        alertData: alertData ?? {},
        metadata: {},
      );
      
      if (_alertsCache[caseId] == null) {
        _alertsCache[caseId] = [];
      }
      _alertsCache[caseId]!.add(alert);
      
      _alertController.add(alert);
    } catch (e) {
      print('Error creating alert: $e');
    }
  }
  
  /// Uyarıyı onayla
  Future<void> acknowledgeAlert(String alertId, String caseId, String acknowledgedBy) async {
    try {
      final alerts = _alertsCache[caseId];
      if (alerts == null) return;
      
      final alertIndex = alerts.indexWhere((a) => a.id == alertId);
      if (alertIndex == -1) return;
      
      final updatedAlert = CaseAlert(
        id: alerts[alertIndex].id,
        caseId: alerts[alertIndex].caseId,
        alertType: alerts[alertIndex].alertType,
        title: alerts[alertIndex].title,
        message: alerts[alertIndex].message,
        priority: alerts[alertIndex].priority,
        createdAt: alerts[alertIndex].createdAt,
        acknowledgedAt: DateTime.now(),
        acknowledgedBy: acknowledgedBy,
        isActive: false,
        alertData: alerts[alertIndex].alertData,
        metadata: alerts[alertIndex].metadata,
      );
      
      alerts[alertIndex] = updatedAlert;
    } catch (e) {
      print('Error acknowledging alert: $e');
    }
  }
  
  /// Vaka istatistiklerini hesapla
  Future<CaseStatistics> calculateStatistics(String caseId) async {
    try {
      final assessments = _assessmentsCache[caseId] ?? [];
      final progress = _progressCache[caseId] ?? [];
      final goals = _goalsCache[caseId] ?? [];
      
      final achievedGoals = goals.where((g) => g.isAchieved).length;
      final totalGoals = goals.length;
      
      // İlerleme skorunu hesapla
      double averageProgressScore = 0.0;
      if (progress.isNotEmpty) {
        final scores = progress.map((p) {
          switch (p.indicator) {
            case ProgressIndicator.improving:
              return 4.0;
            case ProgressIndicator.stable:
              return 3.0;
            case ProgressIndicator.fluctuating:
              return 2.0;
            case ProgressIndicator.declining:
              return 1.0;
          }
        }).toList();
        averageProgressScore = scores.reduce((a, b) => a + b) / scores.length;
      }
      
      // Risk skorunu hesapla
      double riskScore = 0.0;
      if (assessments.isNotEmpty) {
        final latestAssessment = assessments.last;
        switch (latestAssessment.riskLevel) {
          case RiskLevel.low:
            riskScore = 1.0;
            break;
          case RiskLevel.moderate:
            riskScore = 2.0;
            break;
          case RiskLevel.high:
            riskScore = 3.0;
            break;
          case RiskLevel.critical:
            riskScore = 4.0;
            break;
        }
      }
      
      final statistics = CaseStatistics(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caseId: caseId,
        calculatedAt: DateTime.now(),
        totalSessions: progress.length,
        completedSessions: progress.length,
        totalAssessments: assessments.length,
        achievedGoals: achievedGoals,
        totalGoals: totalGoals,
        averageProgressScore: averageProgressScore,
        riskScore: riskScore,
        progressTrend: _calculateProgressTrend(progress),
        goalAchievement: _calculateGoalAchievement(goals),
        interventionEffectiveness: _calculateInterventionEffectiveness(progress),
        metadata: {},
      );
      
      _statisticsCache[caseId] = statistics;
      return statistics;
    } catch (e) {
      print('Error calculating statistics: $e');
      return _generateMockStatistics(caseId);
    }
  }
  
  /// İlerleme trendini hesapla
  Map<String, dynamic> _calculateProgressTrend(List<CaseProgress> progress) {
    if (progress.isEmpty) return {};
    
    final trend = <String, int>{
      'improving': 0,
      'stable': 0,
      'declining': 0,
      'fluctuating': 0,
    };
    
    for (final p in progress) {
      trend[p.indicator.toString().split('.').last] = 
          (trend[p.indicator.toString().split('.').last] ?? 0) + 1;
    }
    
    return trend;
  }
  
  /// Hedef başarısını hesapla
  Map<String, dynamic> _calculateGoalAchievement(List<TreatmentGoal> goals) {
    if (goals.isEmpty) return {};
    
    final achieved = goals.where((g) => g.isAchieved).length;
    final total = goals.length;
    final percentage = total > 0 ? (achieved / total * 100) : 0.0;
    
    return {
      'achieved': achieved,
      'total': total,
      'percentage': percentage,
      'onTime': goals.where((g) => g.isAchieved && 
          g.achievedDate != null && 
          g.achievedDate!.isBefore(g.targetDate)).length,
    };
  }
  
  /// Müdahale etkinliğini hesapla
  Map<String, dynamic> _calculateInterventionEffectiveness(List<CaseProgress> progress) {
    if (progress.isEmpty) return {};
    
    final interventionCounts = <String, int>{};
    final interventionResults = <String, List<ProgressIndicator>>{};
    
    for (final p in progress) {
      for (final intervention in p.interventions) {
        interventionCounts[intervention] = (interventionCounts[intervention] ?? 0) + 1;
        if (interventionResults[intervention] == null) {
          interventionResults[intervention] = [];
        }
        interventionResults[intervention]!.add(p.indicator);
      }
    }
    
    final effectiveness = <String, double>{};
    for (final intervention in interventionResults.keys) {
      final results = interventionResults[intervention]!;
      double score = 0.0;
      for (final result in results) {
        switch (result) {
          case ProgressIndicator.improving:
            score += 4.0;
            break;
          case ProgressIndicator.stable:
            score += 3.0;
            break;
          case ProgressIndicator.fluctuating:
            score += 2.0;
            break;
          case ProgressIndicator.declining:
            score += 1.0;
            break;
        }
      }
      effectiveness[intervention] = results.isNotEmpty ? score / results.length : 0.0;
    }
    
    return {
      'interventionCounts': interventionCounts,
      'effectiveness': effectiveness,
    };
  }
  
  /// Vaka özeti oluştur
  Future<CaseSummary> generateSummary(String caseId, String generatedBy) async {
    try {
      final case_ = _casesCache[caseId];
      if (case_ == null) {
        throw Exception('Case not found');
      }
      
      final assessments = _assessmentsCache[caseId] ?? [];
      final progress = _progressCache[caseId] ?? [];
      final goals = _goalsCache[caseId] ?? [];
      final statistics = await calculateStatistics(caseId);
      
      final achievements = goals.where((g) => g.isAchieved).map((g) => g.title).toList();
      final challenges = assessments.isNotEmpty ? assessments.last.challenges : <String>[];
      
      final recommendations = <String>[];
      if (assessments.isNotEmpty) {
        recommendations.addAll(assessments.last.recommendations);
      }
      
      final summary = CaseSummary(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caseId: caseId,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
        summary: _generateSummaryText(case_, assessments, progress, goals, statistics),
        keyMetrics: {
          'totalSessions': statistics.totalSessions,
          'achievedGoals': statistics.achievedGoals,
          'totalGoals': statistics.totalGoals,
          'averageProgressScore': statistics.averageProgressScore,
          'riskScore': statistics.riskScore,
        },
        achievements: achievements,
        challenges: challenges,
        recommendations: recommendations,
        statistics: statistics.toJson(),
        metadata: {},
      );
      
      return summary;
    } catch (e) {
      print('Error generating summary: $e');
      rethrow;
    }
  }
  
  /// Özet metni oluştur
  String _generateSummaryText(
    CaseManagement case_,
    List<CaseAssessment> assessments,
    List<CaseProgress> progress,
    List<TreatmentGoal> goals,
    CaseStatistics statistics,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Vaka Özeti: ${case_.title}');
    buffer.writeln('Durum: ${case_.status.toString().split('.').last}');
    buffer.writeln('Öncelik: ${case_.priority.toString().split('.').last}');
    buffer.writeln('');
    
    buffer.writeln('İstatistikler:');
    buffer.writeln('- Toplam Seans: ${statistics.totalSessions}');
    buffer.writeln('- Tamamlanan Hedefler: ${statistics.achievedGoals}/${statistics.totalGoals}');
    buffer.writeln('- Ortalama İlerleme Skoru: ${statistics.averageProgressScore.toStringAsFixed(1)}');
    buffer.writeln('- Risk Skoru: ${statistics.riskScore.toStringAsFixed(1)}');
    buffer.writeln('');
    
    if (assessments.isNotEmpty) {
      final latestAssessment = assessments.last;
      buffer.writeln('Son Değerlendirme:');
      buffer.writeln('- Tarih: ${latestAssessment.assessmentDate.day}/${latestAssessment.assessmentDate.month}/${latestAssessment.assessmentDate.year}');
      buffer.writeln('- İlerleme: ${latestAssessment.progressIndicator.toString().split('.').last}');
      buffer.writeln('- Risk: ${latestAssessment.riskLevel.toString().split('.').last}');
      buffer.writeln('');
    }
    
    if (goals.isNotEmpty) {
      buffer.writeln('Hedefler:');
      for (final goal in goals.take(3)) {
        buffer.writeln('- ${goal.title}: ${goal.isAchieved ? 'Tamamlandı' : 'Devam ediyor'}');
      }
      if (goals.length > 3) {
        buffer.writeln('- ... ve ${goals.length - 3} hedef daha');
      }
    }
    
    return buffer.toString();
  }
  
  /// Mock veriler oluştur
  Map<String, CaseManagement> _generateMockCases() {
    return {
      '1': CaseManagement(
        id: '1',
        clientId: 'client_1',
        therapistId: 'therapist_1',
        title: 'Depresyon Vakası',
        description: 'Majör depresyon tanısı ile gelen 25 yaşında hasta',
        status: CaseStatus.active,
        priority: PriorityLevel.high,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        startedAt: DateTime.now().subtract(Duration(days: 30)),
        primaryDiagnosis: 'F32.1 - Majör Depresyon, Orta Şiddet',
        secondaryDiagnoses: ['F41.1 - Genelleşmiş Anksiyete Bozukluğu'],
        treatmentGoals: ['Ruh halini iyileştirme', 'Sosyal işlevselliği artırma'],
        interventions: ['CBT', 'Davranış aktivasyonu'],
        clientInfo: {'age': 25, 'gender': 'female'},
        treatmentPlan: {'approach': 'CBT', 'frequency': 'haftalık'},
        metadata: {},
        notes: 'Hasta motivasyonu düşük, aile desteği mevcut',
      ),
      '2': CaseManagement(
        id: '2',
        clientId: 'client_2',
        therapistId: 'therapist_1',
        title: 'Anksiyete Vakası',
        description: 'Sosyal anksiyete bozukluğu tanısı ile gelen 30 yaşında hasta',
        status: CaseStatus.active,
        priority: PriorityLevel.medium,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        startedAt: DateTime.now().subtract(Duration(days: 15)),
        primaryDiagnosis: 'F40.1 - Sosyal Fobi',
        secondaryDiagnoses: [],
        treatmentGoals: ['Sosyal durumlarda rahatlama', 'Özgüven artırma'],
        interventions: ['DBT', 'Maruz bırakma terapisi'],
        clientInfo: {'age': 30, 'gender': 'male'},
        treatmentPlan: {'approach': 'DBT', 'frequency': 'haftalık'},
        metadata: {},
        notes: 'Hasta iş hayatında zorlanıyor',
      ),
    };
  }
  
  Map<String, List<CaseAssessment>> _generateMockAssessments() {
    return {
      '1': [
        CaseAssessment(
          id: '1',
          caseId: '1',
          type: AssessmentType.initial,
          assessmentDate: DateTime.now().subtract(Duration(days: 30)),
          assessorId: 'therapist_1',
          assessorName: 'Dr. Ahmet Yılmaz',
          clinicalFindings: {'mood': 'depressed', 'energy': 'low'},
          functionalAssessment: {'work': 'impaired', 'social': 'withdrawn'},
          riskAssessment: {'suicide_risk': 'low', 'self_harm': 'none'},
          strengths: ['Aile desteği', 'Motivasyon'],
          challenges: ['Düşük enerji', 'Sosyal izolasyon'],
          recommendations: ['CBT başlat', 'Egzersiz öner'],
          progressIndicator: ProgressIndicator.stable,
          riskLevel: RiskLevel.low,
          summary: 'İlk değerlendirme tamamlandı',
          scores: {'phq9': 15, 'gad7': 12},
          metadata: {},
          attachments: [],
        ),
      ],
      '2': [
        CaseAssessment(
          id: '2',
          caseId: '2',
          type: AssessmentType.initial,
          assessmentDate: DateTime.now().subtract(Duration(days: 15)),
          assessorId: 'therapist_1',
          assessorName: 'Dr. Ahmet Yılmaz',
          clinicalFindings: {'anxiety': 'high', 'avoidance': 'severe'},
          functionalAssessment: {'work': 'severely_impaired', 'social': 'avoidant'},
          riskAssessment: {'suicide_risk': 'none', 'self_harm': 'none'},
          strengths: ['İş motivasyonu', 'Aile desteği'],
          challenges: ['Sosyal kaçınma', 'Performans anksiyetesi'],
          recommendations: ['DBT başlat', 'Maruz bırakma planla'],
          progressIndicator: ProgressIndicator.stable,
          riskLevel: RiskLevel.low,
          summary: 'İlk değerlendirme tamamlandı',
          scores: {'gad7': 18, 'lsas': 65},
          metadata: {},
          attachments: [],
        ),
      ],
    };
  }
  
  Map<String, List<CaseProgress>> _generateMockProgress() {
    return {
      '1': [
        CaseProgress(
          id: '1',
          caseId: '1',
          progressDate: DateTime.now().subtract(Duration(days: 7)),
          recordedBy: 'therapist_1',
          recordedByName: 'Dr. Ahmet Yılmaz',
          progressNote: 'Hasta daha iyi görünüyor, egzersiz programına başladı',
          indicator: ProgressIndicator.improving,
          achievedGoals: [],
          newGoals: ['Düzenli egzersiz'],
          interventions: ['CBT', 'Davranış aktivasyonu'],
          measurements: {'mood_scale': 6, 'energy_level': 5},
          observations: {'attendance': 'good', 'engagement': 'high'},
          nextSteps: 'Egzersiz programını sürdür',
          metadata: {},
          relatedSessions: ['session_1', 'session_2'],
        ),
      ],
      '2': [
        CaseProgress(
          id: '2',
          caseId: '2',
          progressDate: DateTime.now().subtract(Duration(days: 3)),
          recordedBy: 'therapist_1',
          recordedByName: 'Dr. Ahmet Yılmaz',
          progressNote: 'İlk maruz bırakma egzersizi yapıldı, hasta endişeli ama katıldı',
          indicator: ProgressIndicator.stable,
          achievedGoals: [],
          newGoals: ['Sosyal durumlarda rahatlama'],
          interventions: ['DBT', 'Maruz bırakma'],
          measurements: {'anxiety_level': 7, 'avoidance': 8},
          observations: {'attendance': 'good', 'engagement': 'moderate'},
          nextSteps: 'Maruz bırakma egzersizlerini artır',
          metadata: {},
          relatedSessions: ['session_3'],
        ),
      ],
    };
  }
  
  Map<String, List<TreatmentGoal>> _generateMockGoals() {
    return {
      '1': [
        TreatmentGoal(
          id: '1',
          caseId: '1',
          title: 'Ruh halini iyileştirme',
          description: 'Depresif belirtileri azaltma',
          category: 'Mood',
          targetDate: DateTime.now().add(Duration(days: 30)),
          isAchieved: false,
          priority: 1,
          milestones: ['PHQ-9 skorunu 10\'un altına düşür'],
          interventions: ['CBT', 'Davranış aktivasyonu'],
          measurements: {'phq9_target': 10},
          metadata: {},
        ),
        TreatmentGoal(
          id: '2',
          caseId: '1',
          title: 'Sosyal işlevselliği artırma',
          description: 'Sosyal aktivitelere katılımı artırma',
          category: 'Social',
          targetDate: DateTime.now().add(Duration(days: 45)),
          isAchieved: false,
          priority: 2,
          milestones: ['Haftada 2 sosyal aktivite'],
          interventions: ['Davranış aktivasyonu'],
          measurements: {'social_activities_per_week': 2},
          metadata: {},
        ),
      ],
      '2': [
        TreatmentGoal(
          id: '3',
          caseId: '2',
          title: 'Sosyal durumlarda rahatlama',
          description: 'Sosyal anksiyeteyi azaltma',
          category: 'Anxiety',
          targetDate: DateTime.now().add(Duration(days: 60)),
          isAchieved: false,
          priority: 1,
          milestones: ['LSAS skorunu 40\'ın altına düşür'],
          interventions: ['DBT', 'Maruz bırakma'],
          measurements: {'lsas_target': 40},
          metadata: {},
        ),
      ],
    };
  }
  
  Map<String, List<CaseTimeline>> _generateMockTimeline() {
    return {
      '1': [
        CaseTimeline(
          id: '1',
          caseId: '1',
          eventDate: DateTime.now().subtract(Duration(days: 30)),
          eventType: 'case_created',
          title: 'Vaka Oluşturuldu',
          description: 'Yeni vaka oluşturuldu: Depresyon Vakası',
          performedBy: 'therapist_1',
          eventData: {},
          metadata: {},
        ),
        CaseTimeline(
          id: '2',
          caseId: '1',
          eventDate: DateTime.now().subtract(Duration(days: 30)),
          eventType: 'assessment_added',
          title: 'Değerlendirme Eklendi',
          description: 'initial değerlendirmesi eklendi',
          performedBy: 'therapist_1',
          eventData: {},
          metadata: {},
        ),
      ],
      '2': [
        CaseTimeline(
          id: '3',
          caseId: '2',
          eventDate: DateTime.now().subtract(Duration(days: 15)),
          eventType: 'case_created',
          title: 'Vaka Oluşturuldu',
          description: 'Yeni vaka oluşturuldu: Anksiyete Vakası',
          performedBy: 'therapist_1',
          eventData: {},
          metadata: {},
        ),
      ],
    };
  }
  
  Map<String, List<CaseAlert>> _generateMockAlerts() {
    return {
      '1': [],
      '2': [],
    };
  }
  
  CaseStatistics _generateMockStatistics(String caseId) {
    return CaseStatistics(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      caseId: caseId,
      calculatedAt: DateTime.now(),
      totalSessions: 5,
      completedSessions: 5,
      totalAssessments: 2,
      achievedGoals: 1,
      totalGoals: 3,
      averageProgressScore: 3.2,
      riskScore: 1.5,
      progressTrend: {'improving': 2, 'stable': 2, 'declining': 1},
      goalAchievement: {'achieved': 1, 'total': 3, 'percentage': 33.3},
      interventionEffectiveness: {'CBT': 3.5, 'DBT': 3.0},
      metadata: {},
    );
  }
  
  /// Getter metodları
  CaseManagement? getCase(String caseId) => _casesCache[caseId];
  List<CaseManagement> getCases() => List.unmodifiable(_casesCache.values);
  List<CaseAssessment> getAssessments(String caseId) => List.unmodifiable(_assessmentsCache[caseId] ?? []);
  List<CaseProgress> getProgress(String caseId) => List.unmodifiable(_progressCache[caseId] ?? []);
  List<TreatmentGoal> getGoals(String caseId) => List.unmodifiable(_goalsCache[caseId] ?? []);
  List<CaseTimeline> getTimeline(String caseId) => List.unmodifiable(_timelineCache[caseId] ?? []);
  List<CaseAlert> getAlerts(String caseId) => List.unmodifiable(_alertsCache[caseId] ?? []);
  CaseStatistics? getStatistics(String caseId) => _statisticsCache[caseId];
  
  /// Servisi temizle
  void dispose() {
    _caseController.close();
    _assessmentController.close();
    _progressController.close();
    _alertController.close();
  }
}
