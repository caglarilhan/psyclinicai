import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/performance_tracking_models.dart';

class PerformanceTrackingService {
  static final PerformanceTrackingService _instance = PerformanceTrackingService._internal();
  factory PerformanceTrackingService() => _instance;
  PerformanceTrackingService._internal();

  final List<PerformanceMetric> _metrics = [];
  final List<BurnoutAssessment> _assessments = [];
  final List<WorkloadRecord> _workloads = [];
  final List<PerformanceGoal> _goals = [];
  final List<WellnessCheck> _wellnessChecks = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadMetrics();
    await _loadAssessments();
    await _loadWorkloads();
    await _loadGoals();
    await _loadWellnessChecks();
  }

  // Load metrics from storage
  Future<void> _loadMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getStringList('performance_metrics') ?? [];
      _metrics.clear();
      
      for (final metricJson in metricsJson) {
        final metric = PerformanceMetric.fromJson(jsonDecode(metricJson));
        _metrics.add(metric);
      }
    } catch (e) {
      print('Error loading performance metrics: $e');
      _metrics.clear();
    }
  }

  // Save metrics to storage
  Future<void> _saveMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = _metrics
          .map((metric) => jsonEncode(metric.toJson()))
          .toList();
      await prefs.setStringList('performance_metrics', metricsJson);
    } catch (e) {
      print('Error saving performance metrics: $e');
    }
  }

  // Load assessments from storage
  Future<void> _loadAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = prefs.getStringList('burnout_assessments') ?? [];
      _assessments.clear();
      
      for (final assessmentJson in assessmentsJson) {
        final assessment = BurnoutAssessment.fromJson(jsonDecode(assessmentJson));
        _assessments.add(assessment);
      }
    } catch (e) {
      print('Error loading burnout assessments: $e');
      _assessments.clear();
    }
  }

  // Save assessments to storage
  Future<void> _saveAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = _assessments
          .map((assessment) => jsonEncode(assessment.toJson()))
          .toList();
      await prefs.setStringList('burnout_assessments', assessmentsJson);
    } catch (e) {
      print('Error saving burnout assessments: $e');
    }
  }

  // Load workloads from storage
  Future<void> _loadWorkloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workloadsJson = prefs.getStringList('workload_records') ?? [];
      _workloads.clear();
      
      for (final workloadJson in workloadsJson) {
        final workload = WorkloadRecord.fromJson(jsonDecode(workloadJson));
        _workloads.add(workload);
      }
    } catch (e) {
      print('Error loading workload records: $e');
      _workloads.clear();
    }
  }

  // Save workloads to storage
  Future<void> _saveWorkloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workloadsJson = _workloads
          .map((workload) => jsonEncode(workload.toJson()))
          .toList();
      await prefs.setStringList('workload_records', workloadsJson);
    } catch (e) {
      print('Error saving workload records: $e');
    }
  }

  // Load goals from storage
  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getStringList('performance_goals') ?? [];
      _goals.clear();
      
      for (final goalJson in goalsJson) {
        final goal = PerformanceGoal.fromJson(jsonDecode(goalJson));
        _goals.add(goal);
      }
    } catch (e) {
      print('Error loading performance goals: $e');
      _goals.clear();
    }
  }

  // Save goals to storage
  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = _goals
          .map((goal) => jsonEncode(goal.toJson()))
          .toList();
      await prefs.setStringList('performance_goals', goalsJson);
    } catch (e) {
      print('Error saving performance goals: $e');
    }
  }

  // Load wellness checks from storage
  Future<void> _loadWellnessChecks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wellnessChecksJson = prefs.getStringList('wellness_checks') ?? [];
      _wellnessChecks.clear();
      
      for (final wellnessCheckJson in wellnessChecksJson) {
        final wellnessCheck = WellnessCheck.fromJson(jsonDecode(wellnessCheckJson));
        _wellnessChecks.add(wellnessCheck);
      }
    } catch (e) {
      print('Error loading wellness checks: $e');
      _wellnessChecks.clear();
    }
  }

  // Save wellness checks to storage
  Future<void> _saveWellnessChecks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wellnessChecksJson = _wellnessChecks
          .map((wellnessCheck) => jsonEncode(wellnessCheck.toJson()))
          .toList();
      await prefs.setStringList('wellness_checks', wellnessChecksJson);
    } catch (e) {
      print('Error saving wellness checks: $e');
    }
  }

  // Record performance metric
  Future<PerformanceMetric> recordMetric({
    required String clinicianId,
    required MetricType type,
    required double value,
    required String unit,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final metric = PerformanceMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clinicianId: clinicianId,
      type: type,
      value: value,
      unit: unit,
      recordedAt: DateTime.now(),
      notes: notes,
      metadata: metadata ?? {},
    );

    _metrics.add(metric);
    await _saveMetrics();

    return metric;
  }

  // Complete burnout assessment
  Future<BurnoutAssessment> completeBurnoutAssessment({
    required String clinicianId,
    required AssessmentType type,
    required Map<String, dynamic> responses,
    String? notes,
  }) async {
    // Calculate scores based on assessment type
    final scores = _calculateBurnoutScores(type, responses);
    final level = _determineBurnoutLevel(scores);
    final interpretation = _generateBurnoutInterpretation(level, scores);
    final recommendations = _generateBurnoutRecommendations(level);

    final assessment = BurnoutAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clinicianId: clinicianId,
      type: type,
      responses: responses,
      scores: scores,
      interpretation: interpretation,
      level: level,
      completedAt: DateTime.now(),
      notes: notes,
      recommendations: recommendations,
    );

    _assessments.add(assessment);
    await _saveAssessments();

    return assessment;
  }

  // Calculate burnout scores
  Map<String, dynamic> _calculateBurnoutScores(AssessmentType type, Map<String, dynamic> responses) {
    switch (type) {
      case AssessmentType.mbi:
        return _calculateMBIScores(responses);
      case AssessmentType.mbiGs:
        return _calculateMBIGSScores(responses);
      case AssessmentType.olbi:
        return _calculateOLBIScores(responses);
      case AssessmentType.cbi:
        return _calculateCBIScores(responses);
      default:
        return _calculateGenericScores(responses);
    }
  }

  // Calculate MBI scores
  Map<String, dynamic> _calculateMBIScores(Map<String, dynamic> responses) {
    int emotionalExhaustion = 0;
    int depersonalization = 0;
    int personalAccomplishment = 0;

    // MBI emotional exhaustion items (1-9)
    for (int i = 1; i <= 9; i++) {
      emotionalExhaustion += responses['q$i'] as int? ?? 0;
    }

    // MBI depersonalization items (10-15)
    for (int i = 10; i <= 15; i++) {
      depersonalization += responses['q$i'] as int? ?? 0;
    }

    // MBI personal accomplishment items (16-22)
    for (int i = 16; i <= 22; i++) {
      personalAccomplishment += responses['q$i'] as int? ?? 0;
    }

    return {
      'emotionalExhaustion': emotionalExhaustion,
      'depersonalization': depersonalization,
      'personalAccomplishment': personalAccomplishment,
      'totalScore': emotionalExhaustion + depersonalization + personalAccomplishment,
    };
  }

  // Calculate MBI-GS scores
  Map<String, dynamic> _calculateMBIGSScores(Map<String, dynamic> responses) {
    int exhaustion = 0;
    int cynicism = 0;
    int professionalEfficacy = 0;

    // MBI-GS exhaustion items (1-5)
    for (int i = 1; i <= 5; i++) {
      exhaustion += responses['q$i'] as int? ?? 0;
    }

    // MBI-GS cynicism items (6-9)
    for (int i = 6; i <= 9; i++) {
      cynicism += responses['q$i'] as int? ?? 0;
    }

    // MBI-GS professional efficacy items (10-16)
    for (int i = 10; i <= 16; i++) {
      professionalEfficacy += responses['q$i'] as int? ?? 0;
    }

    return {
      'exhaustion': exhaustion,
      'cynicism': cynicism,
      'professionalEfficacy': professionalEfficacy,
      'totalScore': exhaustion + cynicism + professionalEfficacy,
    };
  }

  // Calculate OLBI scores
  Map<String, dynamic> _calculateOLBIScores(Map<String, dynamic> responses) {
    int exhaustion = 0;
    int disengagement = 0;

    // OLBI exhaustion items (1-8)
    for (int i = 1; i <= 8; i++) {
      exhaustion += responses['q$i'] as int? ?? 0;
    }

    // OLBI disengagement items (9-16)
    for (int i = 9; i <= 16; i++) {
      disengagement += responses['q$i'] as int? ?? 0;
    }

    return {
      'exhaustion': exhaustion,
      'disengagement': disengagement,
      'totalScore': exhaustion + disengagement,
    };
  }

  // Calculate CBI scores
  Map<String, dynamic> _calculateCBIScores(Map<String, dynamic> responses) {
    int workBurnout = 0;
    int clientBurnout = 0;
    int personalBurnout = 0;

    // CBI work burnout items (1-5)
    for (int i = 1; i <= 5; i++) {
      workBurnout += responses['q$i'] as int? ?? 0;
    }

    // CBI client burnout items (6-10)
    for (int i = 6; i <= 10; i++) {
      clientBurnout += responses['q$i'] as int? ?? 0;
    }

    // CBI personal burnout items (11-15)
    for (int i = 11; i <= 15; i++) {
      personalBurnout += responses['q$i'] as int? ?? 0;
    }

    return {
      'workBurnout': workBurnout,
      'clientBurnout': clientBurnout,
      'personalBurnout': personalBurnout,
      'totalScore': workBurnout + clientBurnout + personalBurnout,
    };
  }

  // Calculate generic scores
  Map<String, dynamic> _calculateGenericScores(Map<String, dynamic> responses) {
    int totalScore = 0;
    int itemCount = 0;

    responses.forEach((key, value) {
      if (value is int) {
        totalScore += value;
        itemCount++;
      }
    });

    return {
      'totalScore': totalScore,
      'averageScore': itemCount > 0 ? totalScore / itemCount : 0,
      'itemCount': itemCount,
    };
  }

  // Determine burnout level
  BurnoutLevel _determineBurnoutLevel(Map<String, dynamic> scores) {
    final totalScore = scores['totalScore'] as int? ?? 0;
    
    if (totalScore >= 80) return BurnoutLevel.severe;
    if (totalScore >= 60) return BurnoutLevel.high;
    if (totalScore >= 40) return BurnoutLevel.moderate;
    return BurnoutLevel.low;
  }

  // Generate burnout interpretation
  String _generateBurnoutInterpretation(BurnoutLevel level, Map<String, dynamic> scores) {
    switch (level) {
      case BurnoutLevel.low:
        return 'Düşük düzeyde tükenmişlik belirtileri. Genel olarak iyi durumdasınız.';
      case BurnoutLevel.moderate:
        return 'Orta düzeyde tükenmişlik belirtileri. Dikkatli olunması gereken durum.';
      case BurnoutLevel.high:
        return 'Yüksek düzeyde tükenmişlik belirtileri. Müdahale gerekebilir.';
      case BurnoutLevel.severe:
        return 'Şiddetli tükenmişlik belirtileri. Acil müdahale önerilir.';
    }
  }

  // Generate burnout recommendations
  Map<String, dynamic> _generateBurnoutRecommendations(BurnoutLevel level) {
    switch (level) {
      case BurnoutLevel.low:
        return {
          'recommendations': [
            'Mevcut iyi durumunuzu koruyun',
            'Düzenli egzersiz yapın',
            'Sosyal destek ağınızı güçlendirin',
          ],
          'priority': 'low',
        };
      case BurnoutLevel.moderate:
        return {
          'recommendations': [
            'İş yükünüzü gözden geçirin',
            'Stres yönetimi teknikleri öğrenin',
            'Süpervizyon desteği alın',
            'Düzenli molalar verin',
          ],
          'priority': 'medium',
        };
      case BurnoutLevel.high:
        return {
          'recommendations': [
            'Profesyonel destek alın',
            'İş yükünüzü azaltın',
            'Stres yönetimi eğitimi alın',
            'Düzenli terapi seanslarına katılın',
          ],
          'priority': 'high',
        };
      case BurnoutLevel.severe:
        return {
          'recommendations': [
            'Acil profesyonel destek alın',
            'İş yükünüzü geçici olarak azaltın',
            'Stres yönetimi eğitimi alın',
            'Düzenli terapi seanslarına katılın',
            'Aile ve arkadaş desteği alın',
          ],
          'priority': 'critical',
        };
    }
  }

  // Record workload
  Future<WorkloadRecord> recordWorkload({
    required String clinicianId,
    required DateTime date,
    required int totalHours,
    required int patientHours,
    required int adminHours,
    required int supervisionHours,
    required int researchHours,
    required int otherHours,
    required int patientCount,
    required int sessionCount,
    required double stressLevel,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final workload = WorkloadRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clinicianId: clinicianId,
      date: date,
      totalHours: totalHours,
      patientHours: patientHours,
      adminHours: adminHours,
      supervisionHours: supervisionHours,
      researchHours: researchHours,
      otherHours: otherHours,
      patientCount: patientCount,
      sessionCount: sessionCount,
      stressLevel: stressLevel,
      notes: notes,
      metadata: metadata ?? {},
    );

    _workloads.add(workload);
    await _saveWorkloads();

    return workload;
  }

  // Set performance goal
  Future<PerformanceGoal> setPerformanceGoal({
    required String clinicianId,
    required String title,
    required String description,
    required GoalType type,
    required double targetValue,
    required String unit,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final goal = PerformanceGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clinicianId: clinicianId,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      unit: unit,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      metadata: metadata ?? {},
    );

    _goals.add(goal);
    await _saveGoals();

    return goal;
  }

  // Update goal progress
  Future<bool> updateGoalProgress({
    required String goalId,
    required double currentValue,
  }) async {
    try {
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index == -1) return false;

      final goal = _goals[index];
      final updatedGoal = PerformanceGoal(
        id: goal.id,
        clinicianId: goal.clinicianId,
        title: goal.title,
        description: goal.description,
        type: goal.type,
        targetValue: goal.targetValue,
        unit: goal.unit,
        startDate: goal.startDate,
        endDate: goal.endDate,
        status: currentValue >= goal.targetValue ? GoalStatus.achieved : goal.status,
        currentValue: currentValue,
        achievedAt: currentValue >= goal.targetValue ? DateTime.now() : goal.achievedAt,
        notes: goal.notes,
        metadata: goal.metadata,
      );

      _goals[index] = updatedGoal;
      await _saveGoals();
      return true;
    } catch (e) {
      print('Error updating goal progress: $e');
      return false;
    }
  }

  // Record wellness check
  Future<WellnessCheck> recordWellnessCheck({
    required String clinicianId,
    required DateTime date,
    required double moodScore,
    required double energyScore,
    required double stressScore,
    required double sleepScore,
    required double workLifeBalanceScore,
    String? notes,
    List<String>? concerns,
    List<String>? positiveAspects,
    Map<String, dynamic>? metadata,
  }) async {
    final wellnessCheck = WellnessCheck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clinicianId: clinicianId,
      date: date,
      moodScore: moodScore,
      energyScore: energyScore,
      stressScore: stressScore,
      sleepScore: sleepScore,
      workLifeBalanceScore: workLifeBalanceScore,
      notes: notes,
      concerns: concerns ?? [],
      positiveAspects: positiveAspects ?? [],
      metadata: metadata ?? {},
    );

    _wellnessChecks.add(wellnessCheck);
    await _saveWellnessChecks();

    return wellnessCheck;
  }

  // Get metrics for clinician
  List<PerformanceMetric> getMetricsForClinician(String clinicianId) {
    return _metrics
        .where((m) => m.clinicianId == clinicianId)
        .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // Get assessments for clinician
  List<BurnoutAssessment> getAssessmentsForClinician(String clinicianId) {
    return _assessments
        .where((a) => a.clinicianId == clinicianId)
        .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  // Get workloads for clinician
  List<WorkloadRecord> getWorkloadsForClinician(String clinicianId) {
    return _workloads
        .where((w) => w.clinicianId == clinicianId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get goals for clinician
  List<PerformanceGoal> getGoalsForClinician(String clinicianId) {
    return _goals
        .where((g) => g.clinicianId == clinicianId)
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Get wellness checks for clinician
  List<WellnessCheck> getWellnessChecksForClinician(String clinicianId) {
    return _wellnessChecks
        .where((w) => w.clinicianId == clinicianId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get concerning wellness checks
  List<WellnessCheck> getConcerningWellnessChecks() {
    return _wellnessChecks
        .where((w) => w.isConcerning)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get excessive workloads
  List<WorkloadRecord> getExcessiveWorkloads() {
    return _workloads
        .where((w) => w.isExcessive)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get overdue goals
  List<PerformanceGoal> getOverdueGoals() {
    return _goals
        .where((g) => g.isOverdue)
        .toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalMetrics = _metrics.length;
    final totalAssessments = _assessments.length;
    final totalWorkloads = _workloads.length;
    final totalGoals = _goals.length;
    final totalWellnessChecks = _wellnessChecks.length;

    final concerningWellnessChecks = _wellnessChecks
        .where((w) => w.isConcerning)
        .length;
    final excessiveWorkloads = _workloads
        .where((w) => w.isExcessive)
        .length;
    final overdueGoals = _goals
        .where((g) => g.isOverdue)
        .length;

    return {
      'totalMetrics': totalMetrics,
      'totalAssessments': totalAssessments,
      'totalWorkloads': totalWorkloads,
      'totalGoals': totalGoals,
      'totalWellnessChecks': totalWellnessChecks,
      'concerningWellnessChecks': concerningWellnessChecks,
      'excessiveWorkloads': excessiveWorkloads,
      'overdueGoals': overdueGoals,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_metrics.isNotEmpty) return;

    // Add demo metrics
    final demoMetrics = [
      PerformanceMetric(
        id: 'metric_001',
        clinicianId: 'clinician_001',
        type: MetricType.productivity,
        value: 85.0,
        unit: 'percentage',
        recordedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Haftalık verimlilik skoru',
      ),
      PerformanceMetric(
        id: 'metric_002',
        clinicianId: 'clinician_001',
        type: MetricType.quality,
        value: 92.0,
        unit: 'percentage',
        recordedAt: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Hasta memnuniyet skoru',
      ),
    ];

    for (final metric in demoMetrics) {
      _metrics.add(metric);
    }

    await _saveMetrics();

    // Add demo assessments
    final demoAssessments = [
      BurnoutAssessment(
        id: 'assessment_001',
        clinicianId: 'clinician_001',
        type: AssessmentType.mbi,
        responses: {'q1': 2, 'q2': 3, 'q3': 1},
        scores: {'emotionalExhaustion': 15, 'depersonalization': 8, 'personalAccomplishment': 12},
        interpretation: 'Orta düzeyde tükenmişlik belirtileri. Dikkatli olunması gereken durum.',
        level: BurnoutLevel.moderate,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        recommendations: {
          'recommendations': [
            'İş yükünüzü gözden geçirin',
            'Stres yönetimi teknikleri öğrenin',
            'Süpervizyon desteği alın',
          ],
          'priority': 'medium',
        },
      ),
    ];

    for (final assessment in demoAssessments) {
      _assessments.add(assessment);
    }

    await _saveAssessments();

    // Add demo workloads
    final demoWorkloads = [
      WorkloadRecord(
        id: 'workload_001',
        clinicianId: 'clinician_001',
        date: DateTime.now().subtract(const Duration(days: 1)),
        totalHours: 45,
        patientHours: 30,
        adminHours: 10,
        supervisionHours: 3,
        researchHours: 2,
        otherHours: 0,
        patientCount: 8,
        sessionCount: 12,
        stressLevel: 6.5,
        notes: 'Yoğun gün',
      ),
    ];

    for (final workload in demoWorkloads) {
      _workloads.add(workload);
    }

    await _saveWorkloads();

    // Add demo goals
    final demoGoals = [
      PerformanceGoal(
        id: 'goal_001',
        clinicianId: 'clinician_001',
        title: 'Haftalık Verimlilik Hedefi',
        description: 'Haftalık verimlilik skorunu %90\'a çıkarmak',
        type: GoalType.productivity,
        targetValue: 90.0,
        unit: 'percentage',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        currentValue: 85.0,
        notes: 'İyi gidiyor',
      ),
    ];

    for (final goal in demoGoals) {
      _goals.add(goal);
    }

    await _saveGoals();

    // Add demo wellness checks
    final demoWellnessChecks = [
      WellnessCheck(
        id: 'wellness_001',
        clinicianId: 'clinician_001',
        date: DateTime.now().subtract(const Duration(days: 1)),
        moodScore: 7.0,
        energyScore: 6.5,
        stressScore: 6.0,
        sleepScore: 7.5,
        workLifeBalanceScore: 6.0,
        notes: 'Genel olarak iyi',
        concerns: ['Stres seviyesi yüksek'],
        positiveAspects: ['İyi uyku', 'Yüksek enerji'],
      ),
    ];

    for (final wellnessCheck in demoWellnessChecks) {
      _wellnessChecks.add(wellnessCheck);
    }

    await _saveWellnessChecks();

    print('✅ Demo performance metrics created: ${demoMetrics.length}');
    print('✅ Demo burnout assessments created: ${demoAssessments.length}');
    print('✅ Demo workload records created: ${demoWorkloads.length}');
    print('✅ Demo performance goals created: ${demoGoals.length}');
    print('✅ Demo wellness checks created: ${demoWellnessChecks.length}');
  }
}
