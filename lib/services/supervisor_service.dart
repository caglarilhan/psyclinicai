import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supervisor_models.dart';

/// Süpervizör Paneli Servisi
/// Terapist performansı, seans süresi, AI değerlendirme
class SupervisorService {
  static const String _baseUrl = 'https://api.psyclinicai.com/supervisor';
  static const String _apiKey = 'your_api_key_here';
  
  // Caches
  final Map<String, TherapistPerformance> _performanceCache = {};
  final Map<String, List<SessionEvaluation>> _evaluationsCache = {};
  final Map<String, List<AIEvaluation>> _aiEvaluationsCache = {};
  final Map<String, List<SupervisionSession>> _supervisionCache = {};
  final Map<String, PerformanceMetrics> _metricsCache = {};
  final Map<String, List<DevelopmentPlan>> _developmentPlansCache = {};
  final Map<String, List<PerformanceReport>> _reportsCache = {};
  final Map<String, TeamPerformance> _teamPerformanceCache = {};
  
  // Stream controllers
  final StreamController<TherapistPerformance> _performanceController = 
      StreamController<TherapistPerformance>.broadcast();
  final StreamController<SessionEvaluation> _evaluationController = 
      StreamController<SessionEvaluation>.broadcast();
  final StreamController<AIEvaluation> _aiEvaluationController = 
      StreamController<AIEvaluation>.broadcast();
  final StreamController<SupervisionSession> _supervisionController = 
      StreamController<SupervisionSession>.broadcast();
  
  // Streams
  Stream<TherapistPerformance> get performanceStream => _performanceController.stream;
  Stream<SessionEvaluation> get evaluationStream => _evaluationController.stream;
  Stream<AIEvaluation> get aiEvaluationStream => _aiEvaluationController.stream;
  Stream<SupervisionSession> get supervisionStream => _supervisionController.stream;
  
  /// Servisi başlat
  Future<void> initialize() async {
    try {
      await _loadMockData();
      print('SupervisorService initialized successfully');
    } catch (e) {
      print('Error initializing SupervisorService: $e');
      await _loadMockData();
    }
  }
  
  /// Mock data yükle
  Future<void> _loadMockData() async {
    _performanceCache.addAll(_generateMockPerformance());
    _evaluationsCache.addAll(_generateMockEvaluations());
    _aiEvaluationsCache.addAll(_generateMockAIEvaluations());
    _supervisionCache.addAll(_generateMockSupervision());
    _metricsCache.addAll(_generateMockMetrics());
    _developmentPlansCache.addAll(_generateMockDevelopmentPlans());
    _reportsCache.addAll(_generateMockReports());
    _teamPerformanceCache.addAll(_generateMockTeamPerformance());
  }
  
  /// Terapist performansını değerlendir
  Future<TherapistPerformance> evaluateTherapist({
    required String therapistId,
    required String therapistName,
    required DateTime evaluationPeriod,
    required Map<String, double> categoryScores,
    required Map<String, dynamic> metrics,
    List<String>? strengths,
    List<String>? areasForImprovement,
    List<String>? recommendations,
    String? supervisorNotes,
    String? therapistNotes,
  }) async {
    try {
      // Genel skoru hesapla
      final overallScore = _calculateOverallScore(categoryScores);
      final overallLevel = _determinePerformanceLevel(overallScore);
      
      final performance = TherapistPerformance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        therapistId: therapistId,
        therapistName: therapistName,
        evaluationPeriod: evaluationPeriod,
        createdAt: DateTime.now(),
        overallLevel: overallLevel,
        overallScore: overallScore,
        categoryScores: categoryScores,
        metrics: metrics,
        strengths: strengths ?? _identifyStrengths(categoryScores),
        areasForImprovement: areasForImprovement ?? _identifyAreasForImprovement(categoryScores),
        recommendations: recommendations ?? _generateRecommendations(categoryScores),
        supervisorNotes: supervisorNotes,
        therapistNotes: therapistNotes,
        metadata: {},
      );
      
      // Cache'e ekle
      _performanceCache[therapistId] = performance;
      
      // Stream'e gönder
      _performanceController.add(performance);
      
      return performance;
    } catch (e) {
      print('Error evaluating therapist: $e');
      rethrow;
    }
  }
  
  /// Seans değerlendirmesi ekle
  Future<SessionEvaluation> addSessionEvaluation({
    required String sessionId,
    required String therapistId,
    required String therapistName,
    required String clientId,
    required String clientName,
    required DateTime sessionDate,
    required String evaluatorId,
    String? evaluatorName,
    required SessionQuality quality,
    required double qualityScore,
    required int sessionDuration,
    required int plannedDuration,
    required bool isOnTime,
    required bool isComplete,
    required Map<String, double> skillScores,
    List<String>? strengths,
    List<String>? areasForImprovement,
    List<String>? recommendations,
    String? evaluatorNotes,
    String? therapistNotes,
  }) async {
    try {
      final evaluation = SessionEvaluation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        therapistId: therapistId,
        therapistName: therapistName,
        clientId: clientId,
        clientName: clientName,
        sessionDate: sessionDate,
        evaluationDate: DateTime.now(),
        evaluatorId: evaluatorId,
        evaluatorName: evaluatorName,
        quality: quality,
        qualityScore: qualityScore,
        sessionDuration: sessionDuration,
        plannedDuration: plannedDuration,
        isOnTime: isOnTime,
        isComplete: isComplete,
        skillScores: skillScores,
        strengths: strengths ?? _identifySessionStrengths(skillScores),
        areasForImprovement: areasForImprovement ?? _identifySessionAreasForImprovement(skillScores),
        recommendations: recommendations ?? _generateSessionRecommendations(skillScores),
        evaluatorNotes: evaluatorNotes,
        therapistNotes: therapistNotes,
        status: EvaluationStatus.completed,
        metadata: {},
      );
      
      // Cache'e ekle
      if (_evaluationsCache[therapistId] == null) {
        _evaluationsCache[therapistId] = [];
      }
      _evaluationsCache[therapistId]!.add(evaluation);
      
      // Stream'e gönder
      _evaluationController.add(evaluation);
      
      return evaluation;
    } catch (e) {
      print('Error adding session evaluation: $e');
      rethrow;
    }
  }
  
  /// AI değerlendirmesi ekle
  Future<AIEvaluation> addAIEvaluation({
    required String sessionId,
    required String therapistId,
    required String aiModel,
    required String aiVersion,
    required double confidenceScore,
    required Map<String, double> skillAssessments,
    required Map<String, double> techniqueEvaluations,
    required Map<String, double> interventionScores,
    required String aiAnalysis,
    Map<String, dynamic>? rawAnalysis,
  }) async {
    try {
      final aiEvaluation = AIEvaluation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        therapistId: therapistId,
        evaluationDate: DateTime.now(),
        aiModel: aiModel,
        aiVersion: aiVersion,
        confidenceScore: confidenceScore,
        skillAssessments: skillAssessments,
        techniqueEvaluations: techniqueEvaluations,
        interventionScores: interventionScores,
        detectedStrengths: _detectAIStrengths(skillAssessments),
        detectedAreasForImprovement: _detectAIAreasForImprovement(skillAssessments),
        aiRecommendations: _generateAIRecommendations(skillAssessments),
        aiAnalysis: aiAnalysis,
        rawAnalysis: rawAnalysis ?? {},
        isReviewed: false,
        metadata: {},
      );
      
      // Cache'e ekle
      if (_aiEvaluationsCache[therapistId] == null) {
        _aiEvaluationsCache[therapistId] = [];
      }
      _aiEvaluationsCache[therapistId]!.add(aiEvaluation);
      
      // Stream'e gönder
      _aiEvaluationController.add(aiEvaluation);
      
      return aiEvaluation;
    } catch (e) {
      print('Error adding AI evaluation: $e');
      rethrow;
    }
  }
  
  /// AI değerlendirmesini onayla
  Future<void> reviewAIEvaluation(String evaluationId, String therapistId, {
    required String reviewedBy,
    String? reviewNotes,
  }) async {
    try {
      final evaluations = _aiEvaluationsCache[therapistId];
      if (evaluations == null) return;
      
      final evaluationIndex = evaluations.indexWhere((e) => e.id == evaluationId);
      if (evaluationIndex == -1) return;
      
      final updatedEvaluation = AIEvaluation(
        id: evaluations[evaluationIndex].id,
        sessionId: evaluations[evaluationIndex].sessionId,
        therapistId: evaluations[evaluationIndex].therapistId,
        evaluationDate: evaluations[evaluationIndex].evaluationDate,
        aiModel: evaluations[evaluationIndex].aiModel,
        aiVersion: evaluations[evaluationIndex].aiVersion,
        confidenceScore: evaluations[evaluationIndex].confidenceScore,
        skillAssessments: evaluations[evaluationIndex].skillAssessments,
        techniqueEvaluations: evaluations[evaluationIndex].techniqueEvaluations,
        interventionScores: evaluations[evaluationIndex].interventionScores,
        detectedStrengths: evaluations[evaluationIndex].detectedStrengths,
        detectedAreasForImprovement: evaluations[evaluationIndex].detectedAreasForImprovement,
        aiRecommendations: evaluations[evaluationIndex].aiRecommendations,
        aiAnalysis: evaluations[evaluationIndex].aiAnalysis,
        rawAnalysis: evaluations[evaluationIndex].rawAnalysis,
        isReviewed: true,
        reviewedBy: reviewedBy,
        reviewedAt: DateTime.now(),
        reviewNotes: reviewNotes,
        metadata: evaluations[evaluationIndex].metadata,
      );
      
      evaluations[evaluationIndex] = updatedEvaluation;
      _aiEvaluationController.add(updatedEvaluation);
    } catch (e) {
      print('Error reviewing AI evaluation: $e');
    }
  }
  
  /// Süpervizyon seansı oluştur
  Future<SupervisionSession> createSupervisionSession({
    required String supervisorId,
    required String supervisorName,
    required List<String> therapistIds,
    required List<String> therapistNames,
    required SupervisionType type,
    required DateTime scheduledDate,
    required int plannedDuration,
    String? location,
    String? agenda,
    List<String>? discussionTopics,
  }) async {
    try {
      final session = SupervisionSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        supervisorId: supervisorId,
        supervisorName: supervisorName,
        therapistIds: therapistIds,
        therapistNames: therapistNames,
        type: type,
        scheduledDate: scheduledDate,
        plannedDuration: plannedDuration,
        actualDuration: 0,
        location: location,
        agenda: agenda,
        discussionTopics: discussionTopics ?? [],
        actionItems: [],
        therapistNotes: List.filled(therapistIds.length, ''),
        status: EvaluationStatus.pending,
        metadata: {},
        attachments: [],
      );
      
      // Cache'e ekle
      if (_supervisionCache[supervisorId] == null) {
        _supervisionCache[supervisorId] = [];
      }
      _supervisionCache[supervisorId]!.add(session);
      
      // Stream'e gönder
      _supervisionController.add(session);
      
      return session;
    } catch (e) {
      print('Error creating supervision session: $e');
      rethrow;
    }
  }
  
  /// Performans metriklerini hesapla
  Future<PerformanceMetrics> calculatePerformanceMetrics({
    required String therapistId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final evaluations = _evaluationsCache[therapistId] ?? [];
      final periodEvaluations = evaluations.where((e) => 
        e.sessionDate.isAfter(periodStart) && e.sessionDate.isBefore(periodEnd)
      ).toList();
      
      if (periodEvaluations.isEmpty) {
        final emptyMetrics = _generateMockMetrics()[therapistId] ?? _createEmptyMetrics(therapistId, periodStart, periodEnd);
        _metricsCache[therapistId] = emptyMetrics;
        return emptyMetrics;
      }
      
      final totalSessions = periodEvaluations.length;
      final completedSessions = periodEvaluations.where((e) => e.isComplete).length;
      final onTimeSessions = periodEvaluations.where((e) => e.isOnTime).length;
      
      final averageSessionDuration = periodEvaluations
          .map((e) => e.sessionDuration.toDouble())
          .reduce((a, b) => a + b) / totalSessions;
      
      final averageQualityScore = periodEvaluations
          .map((e) => e.qualityScore)
          .reduce((a, b) => a + b) / totalSessions;
      
      final onTimeRate = (onTimeSessions / totalSessions) * 100;
      final completionRate = (completedSessions / totalSessions) * 100;
      
      final skillAverages = _calculateSkillAverages(periodEvaluations);
      final techniqueUsage = _calculateTechniqueUsage(periodEvaluations);
      final interventionEffectiveness = _calculateInterventionEffectiveness(periodEvaluations);
      
      final metrics = PerformanceMetrics(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        therapistId: therapistId,
        calculationDate: DateTime.now(),
        periodStart: periodStart,
        periodEnd: periodEnd,
        totalSessions: totalSessions,
        completedSessions: completedSessions,
        cancelledSessions: 0,
        noShowSessions: 0,
        averageSessionDuration: averageSessionDuration,
        onTimeRate: onTimeRate,
        completionRate: completionRate,
        averageQualityScore: averageQualityScore,
        skillAverages: skillAverages,
        techniqueUsage: techniqueUsage,
        interventionEffectiveness: interventionEffectiveness,
        totalClients: periodEvaluations.map((e) => e.clientId).toSet().length,
        activeClients: periodEvaluations.map((e) => e.clientId).toSet().length,
        dischargedClients: 0,
        clientSatisfactionScore: 85.0, // Mock data
        detailedMetrics: _generateDetailedMetrics(periodEvaluations),
        metadata: {},
      );
      
      _metricsCache[therapistId] = metrics;
      return metrics;
    } catch (e) {
      print('Error calculating performance metrics: $e');
      return _generateMockMetrics()[therapistId] ?? _createEmptyMetrics(therapistId, periodStart, periodEnd);
    }
  }
  
  /// Gelişim planı oluştur
  Future<DevelopmentPlan> createDevelopmentPlan({
    required String therapistId,
    required String therapistName,
    required String supervisorId,
    String? supervisorName,
    required List<String> goals,
    required List<String> actionSteps,
    required List<String> resources,
    required List<String> milestones,
    Map<String, DateTime>? milestoneDates,
    DateTime? targetDate,
  }) async {
    try {
      final plan = DevelopmentPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        therapistId: therapistId,
        therapistName: therapistName,
        createdDate: DateTime.now(),
        targetDate: targetDate,
        supervisorId: supervisorId,
        supervisorName: supervisorName,
        goals: goals,
        actionSteps: actionSteps,
        resources: resources,
        milestones: milestones,
        milestoneDates: milestoneDates ?? {},
        completedActions: [],
        completedMilestones: [],
        progressPercentage: 0.0,
        status: EvaluationStatus.pending,
        metadata: {},
      );
      
      // Cache'e ekle
      if (_developmentPlansCache[therapistId] == null) {
        _developmentPlansCache[therapistId] = [];
      }
      _developmentPlansCache[therapistId]!.add(plan);
      
      return plan;
    } catch (e) {
      print('Error creating development plan: $e');
      rethrow;
    }
  }
  
  /// Performans raporu oluştur
  Future<PerformanceReport> generatePerformanceReport({
    required String therapistId,
    required String therapistName,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String generatedBy,
  }) async {
    try {
      final performance = _performanceCache[therapistId];
      final metrics = await calculatePerformanceMetrics(
        therapistId: therapistId,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      
      final report = PerformanceReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        therapistId: therapistId,
        therapistName: therapistName,
        reportDate: DateTime.now(),
        periodStart: periodStart,
        periodEnd: periodEnd,
        generatedBy: generatedBy,
        overallLevel: performance?.overallLevel ?? PerformanceLevel.average,
        overallScore: performance?.overallScore ?? 75.0,
        categoryBreakdown: performance?.categoryScores ?? {},
        keyAchievements: performance?.strengths ?? [],
        areasForImprovement: performance?.areasForImprovement ?? [],
        recommendations: performance?.recommendations ?? [],
        statistics: metrics.toJson(),
        strengths: performance?.strengths ?? [],
        challenges: performance?.areasForImprovement ?? [],
        summary: _generateReportSummary(performance, metrics),
        metadata: {},
        attachments: [],
      );
      
      // Cache'e ekle
      if (_reportsCache[therapistId] == null) {
        _reportsCache[therapistId] = [];
      }
      _reportsCache[therapistId]!.add(report);
      
      return report;
    } catch (e) {
      print('Error generating performance report: $e');
      rethrow;
    }
  }
  
  /// Takım performansını hesapla
  Future<TeamPerformance> calculateTeamPerformance({
    required String teamId,
    required String teamName,
    required List<String> therapistIds,
    required List<String> therapistNames,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final individualScores = <String, double>{};
      final categoryAverages = <String, double>{};
      double totalScore = 0.0;
      
      for (int i = 0; i < therapistIds.length; i++) {
        final therapistId = therapistIds[i];
        final metrics = await calculatePerformanceMetrics(
          therapistId: therapistId,
          periodStart: periodStart,
          periodEnd: periodEnd,
        );
        
        individualScores[therapistId] = metrics.averageQualityScore;
        totalScore += metrics.averageQualityScore;
        
        // Kategori ortalamalarını hesapla
        for (final entry in metrics.skillAverages.entries) {
          categoryAverages[entry.key] = (categoryAverages[entry.key] ?? 0.0) + entry.value;
        }
      }
      
      final teamAverageScore = totalScore / therapistIds.length;
      final teamLevel = _determinePerformanceLevel(teamAverageScore);
      
      // Kategori ortalamalarını normalize et
      for (final key in categoryAverages.keys) {
        categoryAverages[key] = categoryAverages[key]! / therapistIds.length;
      }
      
      final teamPerformance = TeamPerformance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teamId: teamId,
        teamName: teamName,
        evaluationDate: DateTime.now(),
        periodStart: periodStart,
        periodEnd: periodEnd,
        therapistIds: therapistIds,
        therapistNames: therapistNames,
        teamAverageScore: teamAverageScore,
        teamLevel: teamLevel,
        categoryAverages: categoryAverages,
        teamStrengths: _identifyTeamStrengths(categoryAverages),
        teamChallenges: _identifyTeamChallenges(categoryAverages),
        teamRecommendations: _generateTeamRecommendations(categoryAverages),
        individualScores: individualScores,
        comparativeMetrics: _generateComparativeMetrics(individualScores),
        metadata: {},
      );
      
      _teamPerformanceCache[teamId] = teamPerformance;
      return teamPerformance;
    } catch (e) {
      print('Error calculating team performance: $e');
      rethrow;
    }
  }
  
  // Helper metodları
  double _calculateOverallScore(Map<String, double> categoryScores) {
    if (categoryScores.isEmpty) return 0.0;
    return categoryScores.values.reduce((a, b) => a + b) / categoryScores.length;
  }
  
  PerformanceLevel _determinePerformanceLevel(double score) {
    if (score >= 90) return PerformanceLevel.excellent;
    if (score >= 80) return PerformanceLevel.good;
    if (score >= 70) return PerformanceLevel.average;
    if (score >= 60) return PerformanceLevel.belowAverage;
    return PerformanceLevel.poor;
  }
  
  List<String> _identifyStrengths(Map<String, double> categoryScores) {
    final strengths = <String>[];
    for (final entry in categoryScores.entries) {
      if (entry.value >= 80) {
        strengths.add('${entry.key}: ${entry.value.toStringAsFixed(1)}');
      }
    }
    // Eğer hiç güçlü yan yoksa, en yüksek skoru ekle
    if (strengths.isEmpty && categoryScores.isNotEmpty) {
      final highestEntry = categoryScores.entries.reduce((a, b) => a.value > b.value ? a : b);
      strengths.add('${highestEntry.key}: ${highestEntry.value.toStringAsFixed(1)}');
    }
    return strengths;
  }
  
  List<String> _identifyAreasForImprovement(Map<String, double> categoryScores) {
    final areas = <String>[];
    for (final entry in categoryScores.entries) {
      if (entry.value < 70) {
        areas.add('${entry.key}: ${entry.value.toStringAsFixed(1)}');
      }
    }
    // Eğer hiç gelişim alanı yoksa, en düşük skoru ekle
    if (areas.isEmpty && categoryScores.isNotEmpty) {
      final lowestEntry = categoryScores.entries.reduce((a, b) => a.value < b.value ? a : b);
      areas.add('${lowestEntry.key}: ${lowestEntry.value.toStringAsFixed(1)}');
    }
    return areas;
  }
  
  List<String> _generateRecommendations(Map<String, double> categoryScores) {
    final recommendations = <String>[];
    for (final entry in categoryScores.entries) {
      if (entry.value < 70) {
        recommendations.add('${entry.key} alanında ek eğitim alınmalı');
      }
    }
    return recommendations;
  }
  
  List<String> _identifySessionStrengths(Map<String, double> skillScores) {
    return _identifyStrengths(skillScores);
  }
  
  List<String> _identifySessionAreasForImprovement(Map<String, double> skillScores) {
    return _identifyAreasForImprovement(skillScores);
  }
  
  List<String> _generateSessionRecommendations(Map<String, double> skillScores) {
    return _generateRecommendations(skillScores);
  }
  
  List<String> _detectAIStrengths(Map<String, double> skillAssessments) {
    return _identifyStrengths(skillAssessments);
  }
  
  List<String> _detectAIAreasForImprovement(Map<String, double> skillAssessments) {
    return _identifyAreasForImprovement(skillAssessments);
  }
  
  List<String> _generateAIRecommendations(Map<String, double> skillAssessments) {
    return _generateRecommendations(skillAssessments);
  }
  
  Map<String, double> _calculateSkillAverages(List<SessionEvaluation> evaluations) {
    final skillTotals = <String, double>{};
    final skillCounts = <String, int>{};
    
    for (final evaluation in evaluations) {
      for (final entry in evaluation.skillScores.entries) {
        skillTotals[entry.key] = (skillTotals[entry.key] ?? 0.0) + entry.value;
        skillCounts[entry.key] = (skillCounts[entry.key] ?? 0) + 1;
      }
    }
    
    final averages = <String, double>{};
    for (final key in skillTotals.keys) {
      averages[key] = skillTotals[key]! / skillCounts[key]!;
    }
    
    return averages;
  }
  
  Map<String, int> _calculateTechniqueUsage(List<SessionEvaluation> evaluations) {
    final usage = <String, int>{};
    for (final evaluation in evaluations) {
      for (final entry in evaluation.skillScores.entries) {
        usage[entry.key] = (usage[entry.key] ?? 0) + 1;
      }
    }
    return usage;
  }
  
  Map<String, double> _calculateInterventionEffectiveness(List<SessionEvaluation> evaluations) {
    final effectiveness = <String, double>{};
    for (final evaluation in evaluations) {
      for (final entry in evaluation.skillScores.entries) {
        effectiveness[entry.key] = (effectiveness[entry.key] ?? 0.0) + entry.value;
      }
    }
    
    for (final key in effectiveness.keys) {
      effectiveness[key] = effectiveness[key]! / evaluations.length;
    }
    
    return effectiveness;
  }
  
  Map<String, dynamic> _generateDetailedMetrics(List<SessionEvaluation> evaluations) {
    return {
      'totalEvaluations': evaluations.length,
      'qualityDistribution': _calculateQualityDistribution(evaluations),
      'durationAnalysis': _calculateDurationAnalysis(evaluations),
      'skillTrends': _calculateSkillTrends(evaluations),
    };
  }
  
  Map<String, int> _calculateQualityDistribution(List<SessionEvaluation> evaluations) {
    final distribution = <String, int>{};
    for (final evaluation in evaluations) {
      final quality = evaluation.quality.toString().split('.').last;
      distribution[quality] = (distribution[quality] ?? 0) + 1;
    }
    return distribution;
  }
  
  Map<String, dynamic> _calculateDurationAnalysis(List<SessionEvaluation> evaluations) {
    if (evaluations.isEmpty) return {};
    
    final durations = evaluations.map((e) => e.sessionDuration.toDouble()).toList();
    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final minDuration = durations.reduce((a, b) => a < b ? a : b);
    final maxDuration = durations.reduce((a, b) => a > b ? a : b);
    
    return {
      'average': avgDuration,
      'minimum': minDuration,
      'maximum': maxDuration,
      'total': durations.reduce((a, b) => a + b),
    };
  }
  
  Map<String, dynamic> _calculateSkillTrends(List<SessionEvaluation> evaluations) {
    if (evaluations.length < 2) return {};
    
    final sortedEvaluations = evaluations.toList()
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));
    
    final trends = <String, String>{};
    for (final skill in sortedEvaluations.first.skillScores.keys) {
      final firstScore = sortedEvaluations.first.skillScores[skill] ?? 0.0;
      final lastScore = sortedEvaluations.last.skillScores[skill] ?? 0.0;
      
      if (lastScore > firstScore) {
        trends[skill] = 'improving';
      } else if (lastScore < firstScore) {
        trends[skill] = 'declining';
      } else {
        trends[skill] = 'stable';
      }
    }
    
    return trends;
  }
  
  String _generateReportSummary(TherapistPerformance? performance, PerformanceMetrics metrics) {
    final buffer = StringBuffer();
    
    buffer.writeln('Performans Raporu Özeti');
    buffer.writeln('Genel Skor: ${performance?.overallScore.toStringAsFixed(1) ?? 'N/A'}');
    buffer.writeln('Seans Sayısı: ${metrics.totalSessions}');
    buffer.writeln('Ortalama Kalite: ${metrics.averageQualityScore.toStringAsFixed(1)}');
    buffer.writeln('Zamanında Oranı: ${metrics.onTimeRate.toStringAsFixed(1)}%');
    
    if (performance?.strengths.isNotEmpty == true) {
      buffer.writeln('Güçlü Yanlar: ${performance!.strengths.take(3).join(', ')}');
    }
    
    if (performance?.areasForImprovement.isNotEmpty == true) {
      buffer.writeln('Gelişim Alanları: ${performance!.areasForImprovement.take(3).join(', ')}');
    }
    
    return buffer.toString();
  }
  
  List<String> _identifyTeamStrengths(Map<String, double> categoryAverages) {
    return _identifyStrengths(categoryAverages);
  }
  
  List<String> _identifyTeamChallenges(Map<String, double> categoryAverages) {
    return _identifyAreasForImprovement(categoryAverages);
  }
  
  List<String> _generateTeamRecommendations(Map<String, double> categoryAverages) {
    return _generateRecommendations(categoryAverages);
  }
  
  Map<String, dynamic> _generateComparativeMetrics(Map<String, double> individualScores) {
    if (individualScores.isEmpty) return {};
    
    final scores = individualScores.values.toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    
    return {
      'average': avgScore,
      'highest': maxScore,
      'lowest': minScore,
      'range': maxScore - minScore,
    };
  }
  
  // Mock data generators
  Map<String, TherapistPerformance> _generateMockPerformance() {
    return {
      'therapist_1': TherapistPerformance(
        id: '1',
        therapistId: 'therapist_1',
        therapistName: 'Dr. Ahmet Yılmaz',
        evaluationPeriod: DateTime.now().subtract(Duration(days: 30)),
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        overallLevel: PerformanceLevel.good,
        overallScore: 85.0,
        categoryScores: {'CBT': 88.0, 'DBT': 82.0, 'Empati': 90.0},
        metrics: {'sessions': 45, 'clients': 12},
        strengths: ['Empatik yaklaşım', 'CBT teknikleri'],
        areasForImprovement: ['DBT teknikleri', 'Zaman yönetimi'],
        recommendations: ['DBT eğitimi alınmalı', 'Seans süreleri optimize edilmeli'],
        metadata: {},
      ),
    };
  }
  
  Map<String, List<SessionEvaluation>> _generateMockEvaluations() {
    return {
      'therapist_1': [
        SessionEvaluation(
          id: '1',
          sessionId: 'session_1',
          therapistId: 'therapist_1',
          therapistName: 'Dr. Ahmet Yılmaz',
          clientId: 'client_1',
          clientName: 'Ayşe K.',
          sessionDate: DateTime.now().subtract(Duration(days: 1)),
          evaluationDate: DateTime.now().subtract(Duration(days: 1)),
          evaluatorId: 'supervisor_1',
          evaluatorName: 'Dr. Mehmet Öz',
          quality: SessionQuality.good,
          qualityScore: 85.0,
          sessionDuration: 50,
          plannedDuration: 45,
          isOnTime: true,
          isComplete: true,
          skillScores: {'CBT': 88.0, 'Empati': 90.0, 'Zaman Yönetimi': 80.0},
          strengths: ['Empatik yaklaşım', 'CBT teknikleri'],
          areasForImprovement: ['Zaman yönetimi'],
          recommendations: ['Seans sürelerini optimize et'],
          status: EvaluationStatus.completed,
          metadata: {},
        ),
      ],
    };
  }
  
  Map<String, List<AIEvaluation>> _generateMockAIEvaluations() {
    return {
      'therapist_1': [
        AIEvaluation(
          id: '1',
          sessionId: 'session_1',
          therapistId: 'therapist_1',
          evaluationDate: DateTime.now().subtract(Duration(days: 1)),
          aiModel: 'GPT-4',
          aiVersion: '4.0',
          confidenceScore: 0.85,
          skillAssessments: {'CBT': 0.88, 'Empati': 0.90, 'Zaman Yönetimi': 0.80},
          techniqueEvaluations: {'Sokratik Sorgulama': 0.85, 'Davranış Aktivasyonu': 0.82},
          interventionScores: {'Müdahale 1': 0.87, 'Müdahale 2': 0.83},
          detectedStrengths: ['Empatik yaklaşım', 'CBT teknikleri'],
          detectedAreasForImprovement: ['Zaman yönetimi'],
          aiRecommendations: ['Seans sürelerini optimize et', 'DBT tekniklerini geliştir'],
          aiAnalysis: 'AI analizi: Terapist genel olarak iyi performans gösteriyor.',
          rawAnalysis: {},
          isReviewed: false,
          metadata: {},
        ),
      ],
    };
  }
  
  Map<String, List<SupervisionSession>> _generateMockSupervision() {
    return {
      'supervisor_1': [
        SupervisionSession(
          id: '1',
          supervisorId: 'supervisor_1',
          supervisorName: 'Dr. Mehmet Öz',
          therapistIds: ['therapist_1', 'therapist_2'],
          therapistNames: ['Dr. Ahmet Yılmaz', 'Dr. Fatma Demir'],
          type: SupervisionType.group,
          scheduledDate: DateTime.now().add(Duration(days: 2)),
          plannedDuration: 90,
          actualDuration: 0,
          location: 'Toplantı Odası A',
          agenda: 'Haftalık vaka değerlendirmesi',
          discussionTopics: ['Vaka 1', 'Vaka 2', 'Genel performans'],
          actionItems: ['Rapor hazırla', 'Eğitim planla'],
          therapistNotes: ['', ''],
          status: EvaluationStatus.pending,
          metadata: {},
          attachments: [],
        ),
      ],
    };
  }
  
  Map<String, PerformanceMetrics> _generateMockMetrics() {
    return {
      'therapist_1': PerformanceMetrics(
        id: '1',
        therapistId: 'therapist_1',
        calculationDate: DateTime.now(),
        periodStart: DateTime.now().subtract(Duration(days: 30)),
        periodEnd: DateTime.now(),
        totalSessions: 45,
        completedSessions: 42,
        cancelledSessions: 2,
        noShowSessions: 1,
        averageSessionDuration: 47.5,
        onTimeRate: 93.3,
        completionRate: 93.3,
        averageQualityScore: 85.0,
        skillAverages: {'CBT': 88.0, 'DBT': 82.0, 'Empati': 90.0},
        techniqueUsage: {'CBT': 30, 'DBT': 15},
        interventionEffectiveness: {'Müdahale 1': 87.0, 'Müdahale 2': 83.0},
        totalClients: 12,
        activeClients: 10,
        dischargedClients: 2,
        clientSatisfactionScore: 88.0,
        detailedMetrics: {},
        metadata: {},
      ),
    };
  }
  
  Map<String, List<DevelopmentPlan>> _generateMockDevelopmentPlans() {
    return {
      'therapist_1': [
        DevelopmentPlan(
          id: '1',
          therapistId: 'therapist_1',
          therapistName: 'Dr. Ahmet Yılmaz',
          createdDate: DateTime.now().subtract(Duration(days: 15)),
          targetDate: DateTime.now().add(Duration(days: 45)),
          supervisorId: 'supervisor_1',
          supervisorName: 'Dr. Mehmet Öz',
          goals: ['DBT tekniklerini geliştir', 'Zaman yönetimini iyileştir'],
          actionSteps: ['DBT eğitimi al', 'Seans planlamasını optimize et'],
          resources: ['DBT Manual', 'Zaman yönetimi kursu'],
          milestones: ['DBT eğitimi tamamlandı', 'Seans süreleri optimize edildi'],
          milestoneDates: {},
          completedActions: [],
          completedMilestones: [],
          progressPercentage: 0.0,
          status: EvaluationStatus.inProgress,
          metadata: {},
        ),
      ],
    };
  }
  
  Map<String, List<PerformanceReport>> _generateMockReports() {
    return {
      'therapist_1': [
        PerformanceReport(
          id: '1',
          therapistId: 'therapist_1',
          therapistName: 'Dr. Ahmet Yılmaz',
          reportDate: DateTime.now().subtract(Duration(days: 5)),
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now().subtract(Duration(days: 5)),
          generatedBy: 'supervisor_1',
          overallLevel: PerformanceLevel.good,
          overallScore: 85.0,
          categoryBreakdown: {'CBT': 88.0, 'DBT': 82.0, 'Empati': 90.0},
          keyAchievements: ['Empatik yaklaşım', 'CBT teknikleri'],
          areasForImprovement: ['DBT teknikleri', 'Zaman yönetimi'],
          recommendations: ['DBT eğitimi alınmalı', 'Seans süreleri optimize edilmeli'],
          statistics: {},
          strengths: ['Empatik yaklaşım', 'CBT teknikleri'],
          challenges: ['DBT teknikleri', 'Zaman yönetimi'],
          summary: 'Genel olarak iyi performans, gelişim alanları mevcut',
          metadata: {},
          attachments: [],
        ),
      ],
    };
  }
  
  PerformanceMetrics _createEmptyMetrics(String therapistId, DateTime periodStart, DateTime periodEnd) {
    return PerformanceMetrics(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      therapistId: therapistId,
      calculationDate: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalSessions: 0,
      completedSessions: 0,
      cancelledSessions: 0,
      noShowSessions: 0,
      averageSessionDuration: 0.0,
      onTimeRate: 0.0,
      completionRate: 0.0,
      averageQualityScore: 0.0,
      skillAverages: {},
      techniqueUsage: {},
      interventionEffectiveness: {},
      totalClients: 0,
      activeClients: 0,
      dischargedClients: 0,
      clientSatisfactionScore: 0.0,
      detailedMetrics: {},
      metadata: {},
    );
  }

  Map<String, TeamPerformance> _generateMockTeamPerformance() {
    return {
      'team_1': TeamPerformance(
        id: '1',
        teamId: 'team_1',
        teamName: 'Klinik Psikoloji Ekibi',
        evaluationDate: DateTime.now(),
        periodStart: DateTime.now().subtract(Duration(days: 30)),
        periodEnd: DateTime.now(),
        therapistIds: ['therapist_1', 'therapist_2'],
        therapistNames: ['Dr. Ahmet Yılmaz', 'Dr. Fatma Demir'],
        teamAverageScore: 83.5,
        teamLevel: PerformanceLevel.good,
        categoryAverages: {'CBT': 85.0, 'DBT': 80.0, 'Empati': 87.0},
        teamStrengths: ['Empatik yaklaşım', 'CBT teknikleri'],
        teamChallenges: ['DBT teknikleri', 'Zaman yönetimi'],
        teamRecommendations: ['DBT eğitimi verilmeli', 'Zaman yönetimi kursu'],
        individualScores: {'therapist_1': 85.0, 'therapist_2': 82.0},
        comparativeMetrics: {'average': 83.5, 'highest': 85.0, 'lowest': 82.0},
        metadata: {},
      ),
    };
  }
  

  
  /// Getter metodları
  TherapistPerformance? getPerformance(String therapistId) => _performanceCache[therapistId];
  List<SessionEvaluation> getEvaluations(String therapistId) => List.unmodifiable(_evaluationsCache[therapistId] ?? []);
  List<AIEvaluation> getAIEvaluations(String therapistId) => List.unmodifiable(_aiEvaluationsCache[therapistId] ?? []);
  List<SupervisionSession> getSupervisionSessions(String supervisorId) => List.unmodifiable(_supervisionCache[supervisorId] ?? []);
  PerformanceMetrics? getMetrics(String therapistId) => _metricsCache[therapistId];
  List<DevelopmentPlan> getDevelopmentPlans(String therapistId) => List.unmodifiable(_developmentPlansCache[therapistId] ?? []);
  List<PerformanceReport> getReports(String therapistId) => List.unmodifiable(_reportsCache[therapistId] ?? []);
  TeamPerformance? getTeamPerformance(String teamId) => _teamPerformanceCache[teamId];
  
  /// Servisi temizle
  void dispose() {
    _performanceController.close();
    _evaluationController.close();
    _aiEvaluationController.close();
    _supervisionController.close();
  }
}
