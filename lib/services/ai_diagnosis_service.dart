import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/ai_diagnosis_models.dart';
import '../utils/ai_logger.dart';

class AIDiagnosisService extends ChangeNotifier {
  static final AIDiagnosisService _instance = AIDiagnosisService._internal();
  factory AIDiagnosisService() => _instance;
  AIDiagnosisService._internal();

  final AILogger _logger = AILogger();
  
  // AI Diagnosis state
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  List<DiagnosisSuggestion> _recentSuggestions = [];
  List<RiskAssessment> _riskAssessments = [];
  List<TreatmentPlan> _treatmentPlans = [];

  // Stream controllers
  final StreamController<DiagnosisProgress> _progressController = StreamController<DiagnosisProgress>.broadcast();
  final StreamController<DiagnosisResult> _resultController = StreamController<DiagnosisResult>.broadcast();
  final StreamController<RiskAlert> _riskAlertController = StreamController<RiskAlert>.broadcast();

  // Streams
  Stream<DiagnosisProgress> get progressStream => _progressController.stream;
  Stream<DiagnosisResult> get resultStream => _resultController.stream;
  Stream<RiskAlert> get riskAlertStream => _riskAlertController.stream;

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  double get analysisProgress => _analysisProgress;
  List<DiagnosisSuggestion> get recentSuggestions => _recentSuggestions;
  List<RiskAssessment> get riskAssessments => _riskAssessments;
  List<TreatmentPlan> get treatmentPlans => _treatmentPlans;

  Future<void> initialize() async {
    _logger.info('AIDiagnosisService initializing...', context: 'AIDiagnosisService');
    
    try {
      // Load saved analysis data
      await _loadSavedData();
      
      // Initialize AI models
      await _initializeAIModels();
      
      _logger.info('AIDiagnosisService initialized successfully', context: 'AIDiagnosisService');
    } catch (e) {
      _logger.error('AIDiagnosisService initialization failed', context: 'AIDiagnosisService', error: e);
      rethrow;
    }
  }

  Future<void> _loadSavedData() async {
    // TODO: Load from local storage/database
    _recentSuggestions = [];
    _riskAssessments = [];
    _treatmentPlans = [];
  }

  Future<void> _initializeAIModels() async {
    // TODO: Initialize AI models (Claude, LLaMA3, etc.)
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // AI Diagnosis Analysis
  Future<DiagnosisResult> analyzeSymptoms({
    required String clientId,
    required List<Symptom> symptoms,
    required Map<String, dynamic> clientHistory,
    required String therapistId,
  }) async {
    _logger.info('Starting AI diagnosis analysis', context: 'AIDiagnosisService', data: {
      'clientId': clientId,
      'symptomsCount': symptoms.length,
      'therapistId': therapistId,
    });

    _setAnalyzing(true);
    _resetProgress();

    try {
      // Step 1: Symptom Analysis
      await _updateProgress(0.2, 'Semptomlar analiz ediliyor...');
      final symptomAnalysis = await _analyzeSymptoms(symptoms);
      
      // Step 2: Risk Assessment
      await _updateProgress(0.4, 'Risk değerlendirmesi yapılıyor...');
      final riskAssessment = await _assessRisk(symptoms, clientHistory);
      
      // Step 3: Diagnosis Suggestions
      await _updateProgress(0.6, 'Tanı önerileri oluşturuluyor...');
      final diagnosisSuggestions = await _generateDiagnosisSuggestions(symptomAnalysis, riskAssessment);
      
      // Step 4: Treatment Planning
      await _updateProgress(0.8, 'Tedavi planı hazırlanıyor...');
      final treatmentPlan = await _createTreatmentPlan(diagnosisSuggestions, clientHistory);
      
      // Step 5: Final Analysis
      await _updateProgress(1.0, 'Analiz tamamlandı');
      
      final result = DiagnosisResult(
        id: _generateId(),
        clientId: clientId,
        therapistId: therapistId,
        analysisDate: DateTime.now(),
        symptoms: symptoms,
        symptomAnalysis: symptomAnalysis,
        riskAssessment: riskAssessment,
        diagnosisSuggestions: diagnosisSuggestions,
        treatmentPlan: treatmentPlan,
        confidence: _calculateConfidence(diagnosisSuggestions),
        aiModel: 'Claude-3.5-Sonnet',
        processingTime: DateTime.now().difference(DateTime.now()).inMilliseconds,
      );

      // Save results
      _saveDiagnosisResult(result);
      
      // Send to stream
      _resultController.add(result);
      
      _logger.info('AI diagnosis analysis completed successfully', context: 'AIDiagnosisService', data: {
        'resultId': result.id,
        'confidence': result.confidence,
        'suggestionsCount': result.diagnosisSuggestions.length,
      });

      return result;
    } catch (e) {
      _logger.error('AI diagnosis analysis failed', context: 'AIDiagnosisService', error: e);
      rethrow;
    } finally {
      _setAnalyzing(false);
    }
  }

  Future<SymptomAnalysis> _analyzeSymptoms(List<Symptom> symptoms) async {
    // Simulate AI symptom analysis
    await Future.delayed(const Duration(milliseconds: 800));
    
    final severity = symptoms.fold(0.0, (sum, s) => sum + s.severity) / symptoms.length;
    final categories = symptoms.map((s) => s.category).toSet().toList();
    
    return SymptomAnalysis(
      id: _generateId(),
      symptoms: symptoms,
      overallSeverity: severity,
      primaryCategories: categories,
      patterns: _identifyPatterns(symptoms),
      recommendations: _generateSymptomRecommendations(symptoms),
      analysisDate: DateTime.now(),
    );
  }

  Future<RiskAssessment> _assessRisk(List<Symptom> symptoms, Map<String, dynamic> clientHistory) async {
    // Simulate AI risk assessment
    await Future.delayed(const Duration(milliseconds: 600));
    
    final riskFactors = _identifyRiskFactors(symptoms, clientHistory);
    final riskLevel = _calculateRiskLevel(riskFactors);
    
    final assessment = RiskAssessment(
      id: _generateId(),
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      urgency: _calculateUrgency(riskLevel, symptoms),
      recommendations: _generateRiskRecommendations(riskFactors),
      assessmentDate: DateTime.now(),
    );

    // Check for high-risk alerts
    if (riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical) {
      _sendRiskAlert(assessment);
    }

    return assessment;
  }

  Future<List<DiagnosisSuggestion>> _generateDiagnosisSuggestions(
    SymptomAnalysis symptomAnalysis,
    RiskAssessment riskAssessment,
  ) async {
    // Simulate AI diagnosis generation
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final suggestions = <DiagnosisSuggestion>[];
    
    // Generate primary diagnosis suggestions
    if (symptomAnalysis.primaryCategories.contains('mood')) {
      suggestions.add(DiagnosisSuggestion(
        id: _generateId(),
        diagnosis: 'Major Depressive Disorder (F32.1)',
        confidence: 0.87,
        evidence: ['Depressed mood', 'Loss of interest', 'Sleep disturbances'],
        differentialDiagnoses: ['Bipolar Disorder', 'Persistent Depressive Disorder'],
        icd10Code: 'F32.1',
        severity: DiagnosisSeverity.moderate,
        treatmentPriority: TreatmentPriority.high,
        notes: 'Consider ruling out bipolar disorder with detailed mood history',
      ));
    }
    
    if (symptomAnalysis.primaryCategories.contains('anxiety')) {
      suggestions.add(DiagnosisSuggestion(
        id: _generateId(),
        diagnosis: 'Generalized Anxiety Disorder (F41.1)',
        confidence: 0.82,
        evidence: ['Excessive anxiety', 'Worry', 'Physical symptoms'],
        differentialDiagnoses: ['Panic Disorder', 'Social Anxiety Disorder'],
        icd10Code: 'F41.1',
        severity: DiagnosisSeverity.mild,
        treatmentPriority: TreatmentPriority.medium,
        notes: 'Assess for panic attacks and social anxiety symptoms',
      ));
    }
    
    if (symptomAnalysis.primaryCategories.contains('trauma')) {
      suggestions.add(DiagnosisSuggestion(
        id: _generateId(),
        diagnosis: 'Post-Traumatic Stress Disorder (F43.1)',
        confidence: 0.91,
        evidence: ['Trauma exposure', 'Intrusive memories', 'Avoidance'],
        differentialDiagnoses: ['Acute Stress Disorder', 'Adjustment Disorder'],
        icd10Code: 'F43.1',
        severity: DiagnosisSeverity.severe,
        treatmentPriority: TreatmentPriority.critical,
        notes: 'Immediate safety assessment required',
      ));
    }

    return suggestions;
  }

  Future<TreatmentPlan> _createTreatmentPlan(
    List<DiagnosisSuggestion> diagnoses,
    Map<String, dynamic> clientHistory,
  ) async {
    // Simulate AI treatment planning
    await Future.delayed(const Duration(milliseconds: 700));
    
    final interventions = <TreatmentIntervention>[];
    
    for (final diagnosis in diagnoses) {
      switch (diagnosis.icd10Code) {
        case 'F32.1': // Major Depression
          interventions.addAll([
            TreatmentIntervention(
              id: _generateId(),
              type: InterventionType.psychotherapy,
              name: 'Cognitive Behavioral Therapy (CBT)',
              description: 'Evidence-based treatment for depression',
              frequency: 'Weekly sessions',
              duration: '12-20 weeks',
              priority: InterventionPriority.high,
            ),
            TreatmentIntervention(
              id: _generateId(),
              type: InterventionType.medication,
              name: 'Selective Serotonin Reuptake Inhibitor (SSRI)',
              description: 'First-line antidepressant medication',
              frequency: 'Daily',
              duration: '6-12 months minimum',
              priority: InterventionPriority.high,
            ),
          ]);
          break;
          
        case 'F41.1': // Generalized Anxiety
          interventions.addAll([
            TreatmentIntervention(
              id: _generateId(),
              type: InterventionType.psychotherapy,
              name: 'Acceptance and Commitment Therapy (ACT)',
              description: 'Mindfulness-based anxiety treatment',
              frequency: 'Weekly sessions',
              duration: '8-16 weeks',
              priority: InterventionPriority.medium,
            ),
          ]);
          break;
          
        case 'F43.1': // PTSD
          interventions.addAll([
            TreatmentIntervention(
              id: _generateId(),
              type: InterventionType.psychotherapy,
              name: 'Eye Movement Desensitization and Reprocessing (EMDR)',
              description: 'Trauma-focused therapy',
              frequency: 'Weekly sessions',
              duration: '8-12 weeks',
              priority: InterventionPriority.critical,
            ),
            TreatmentIntervention(
              id: _generateId(),
              type: InterventionType.medication,
              name: 'Serotonin-Norepinephrine Reuptake Inhibitor (SNRI)',
              description: 'Trauma-related medication',
              frequency: 'Daily',
              duration: '12-18 months',
              priority: InterventionPriority.high,
            ),
          ]);
          break;
      }
    }

    return TreatmentPlan(
      id: _generateId(),
      diagnoses: diagnoses,
      interventions: interventions,
      goals: _generateTreatmentGoals(diagnoses),
      timeline: _calculateTimeline(interventions),
      riskFactors: _identifyTreatmentRisks(interventions, clientHistory),
      monitoringSchedule: _createMonitoringSchedule(diagnoses),
      planDate: DateTime.now(),
    );
  }

  // Helper methods
  List<Pattern> _identifyPatterns(List<Symptom> symptoms) {
    final patterns = <Pattern>[];
    
    // Mood patterns
    if (symptoms.any((s) => s.category == 'mood')) {
      patterns.add(Pattern(
        id: _generateId(),
        type: PatternType.mood,
        description: 'Mood-related symptoms cluster',
        confidence: 0.85,
        symptoms: symptoms.where((s) => s.category == 'mood').toList(),
      ));
    }
    
    // Sleep patterns
    if (symptoms.any((s) => s.category == 'sleep')) {
      patterns.add(Pattern(
        id: _generateId(),
        type: PatternType.sleep,
        description: 'Sleep disturbance pattern',
        confidence: 0.78,
        symptoms: symptoms.where((s) => s.category == 'sleep').toList(),
      ));
    }
    
    return patterns;
  }

  List<String> _generateSymptomRecommendations(List<Symptom> symptoms) {
    final recommendations = <String>[];
    
    if (symptoms.any((s) => s.severity > 7)) {
      recommendations.add('Yüksek şiddetli semptomlar için acil değerlendirme gerekli');
    }
    
    if (symptoms.any((s) => s.category == 'suicidal')) {
      recommendations.add('İntihar düşünceleri için acil psikiyatrik değerlendirme');
    }
    
    if (symptoms.any((s) => s.category == 'psychosis')) {
      recommendations.add('Psikotik semptomlar için psikiyatrik değerlendirme');
    }
    
    return recommendations;
  }

  List<RiskFactor> _identifyRiskFactors(List<Symptom> symptoms, Map<String, dynamic> clientHistory) {
    final riskFactors = <RiskFactor>[];
    
    // Symptom-based risks
    if (symptoms.any((s) => s.category == 'suicidal')) {
      riskFactors.add(RiskFactor(
        id: _generateId(),
        type: RiskType.suicidal,
        severity: RiskSeverity.critical,
        description: 'İntihar düşünceleri mevcut',
        probability: 0.95,
        mitigation: 'Acil psikiyatrik değerlendirme, güvenlik planı',
      ));
    }
    
    if (symptoms.any((s) => s.category == 'psychosis')) {
      riskFactors.add(RiskFactor(
        id: _generateId(),
        type: RiskType.psychosis,
        severity: RiskSeverity.high,
        description: 'Psikotik semptomlar',
        probability: 0.80,
        mitigation: 'Psikiyatrik değerlendirme, antipsikotik tedavi',
      ));
    }
    
    // History-based risks
    if (clientHistory['previousAttempts'] == true) {
      riskFactors.add(RiskFactor(
        id: _generateId(),
        type: RiskType.historical,
        severity: RiskSeverity.high,
        description: 'Önceki intihar girişimi öyküsü',
        probability: 0.85,
        mitigation: 'Güvenlik planı, sık takip',
      ));
    }
    
    return riskFactors;
  }

  RiskLevel _calculateRiskLevel(List<RiskFactor> riskFactors) {
    if (riskFactors.any((r) => r.severity == RiskSeverity.critical)) {
      return RiskLevel.critical;
    }
    
    if (riskFactors.any((r) => r.severity == RiskSeverity.high)) {
      return RiskLevel.high;
    }
    
    if (riskFactors.any((r) => r.severity == RiskSeverity.medium)) {
      return RiskLevel.medium;
    }
    
    return RiskLevel.low;
  }

  Urgency _calculateUrgency(RiskLevel riskLevel, List<Symptom> symptoms) {
    if (riskLevel == RiskLevel.critical) {
      return Urgency.immediate;
    }
    
    if (riskLevel == RiskLevel.high) {
      return Urgency.urgent;
    }
    
    if (symptoms.any((s) => s.severity > 8)) {
      return Urgency.urgent;
    }
    
    return Urgency.routine;
  }

  List<String> _generateRiskRecommendations(List<RiskFactor> riskFactors) {
    final recommendations = <String>[];
    
    for (final factor in riskFactors) {
      recommendations.add(factor.mitigation);
    }
    
    return recommendations;
  }

  List<TreatmentGoal> _generateTreatmentGoals(List<DiagnosisSuggestion> diagnoses) {
    final goals = <TreatmentGoal>[];
    
    for (final diagnosis in diagnoses) {
      switch (diagnosis.icd10Code) {
        case 'F32.1': // Depression
          goals.addAll([
            TreatmentGoal(
              id: _generateId(),
              description: 'Depresif semptomları %50 azalt',
              target: 'PHQ-9 skoru <10',
              timeline: '8 hafta',
              priority: GoalPriority.high,
            ),
            TreatmentGoal(
              id: _generateId(),
              description: 'İşlevselliği artır',
              target: 'Günlük aktivitelere katılım',
              timeline: '12 hafta',
              priority: GoalPriority.medium,
            ),
          ]);
          break;
          
        case 'F41.1': // Anxiety
          goals.addAll([
            TreatmentGoal(
              id: _generateId(),
              description: 'Anksiyete semptomlarını azalt',
              target: 'GAD-7 skoru <8',
              timeline: '6 hafta',
              priority: GoalPriority.high,
            ),
          ]);
          break;
      }
    }
    
    return goals;
  }

  Duration _calculateTimeline(List<TreatmentIntervention> interventions) {
    if (interventions.isEmpty) return const Duration(days: 30);
    
    final maxDuration = interventions.fold<int>(0, (max, i) {
      final weeks = _parseDuration(i.duration);
      return weeks > max ? weeks : max;
    });
    
    return Duration(days: maxDuration * 7);
  }

  int _parseDuration(String duration) {
    if (duration.contains('hafta')) {
      return int.tryParse(duration.replaceAll(RegExp(r'[^\d]'), '')) ?? 8;
    }
    if (duration.contains('ay')) {
      return int.tryParse(duration.replaceAll(RegExp(r'[^\d]'), '')) ?? 3 * 4;
    }
    return 8; // Default 8 weeks
  }

  List<RiskFactor> _identifyTreatmentRisks(List<TreatmentIntervention> interventions, Map<String, dynamic> clientHistory) {
    final risks = <RiskFactor>[];
    
    for (final intervention in interventions) {
      if (intervention.type == InterventionType.medication) {
        // Check for medication interactions
        if (clientHistory['currentMedications'] != null) {
          risks.add(RiskFactor(
            id: _generateId(),
            type: RiskType.medication,
            severity: RiskSeverity.medium,
            description: 'İlaç etkileşimi riski',
            probability: 0.60,
            mitigation: 'İlaç etkileşim kontrolü yapılmalı',
          ));
        }
      }
    }
    
    return risks;
  }

  MonitoringSchedule _createMonitoringSchedule(List<DiagnosisSuggestion> diagnoses) {
    final schedule = <MonitoringEvent>[];
    
    for (final diagnosis in diagnoses) {
      switch (diagnosis.icd10Code) {
        case 'F32.1': // Depression
          schedule.addAll([
            MonitoringEvent(
              id: _generateId(),
              type: MonitoringType.assessment,
              name: 'PHQ-9 Değerlendirmesi',
              frequency: 'Haftalık',
              nextDue: DateTime.now().add(const Duration(days: 7)),
            ),
            MonitoringEvent(
              id: _generateId(),
              type: MonitoringType.safety,
              name: 'Güvenlik Değerlendirmesi',
              frequency: 'Haftalık',
              nextDue: DateTime.now().add(const Duration(days: 7)),
            ),
          ]);
          break;
          
        case 'F41.1': // Anxiety
          schedule.addAll([
            MonitoringEvent(
              id: _generateId(),
              type: MonitoringType.assessment,
              name: 'GAD-7 Değerlendirmesi',
              frequency: 'Haftalık',
              nextDue: DateTime.now().add(const Duration(days: 7)),
            ),
          ]);
          break;
      }
    }
    
    return MonitoringSchedule(
      id: _generateId(),
      events: schedule,
      createdDate: DateTime.now(),
    );
  }

  double _calculateConfidence(List<DiagnosisSuggestion> suggestions) {
    if (suggestions.isEmpty) return 0.0;
    
    final totalConfidence = suggestions.fold(0.0, (sum, s) => sum + s.confidence);
    return totalConfidence / suggestions.length;
  }

  void _sendRiskAlert(RiskAssessment assessment) {
    final alert = RiskAlert(
      id: _generateId(),
      assessment: assessment,
      timestamp: DateTime.now(),
      priority: assessment.riskLevel == RiskLevel.critical ? AlertPriority.critical : AlertPriority.high,
    );
    
    _riskAlertController.add(alert);
  }

  void _saveDiagnosisResult(DiagnosisResult result) {
    _recentSuggestions = result.diagnosisSuggestions;
    _riskAssessments = [result.riskAssessment];
    _treatmentPlans = [result.treatmentPlan];
    
    notifyListeners();
  }

  void _setAnalyzing(bool analyzing) {
    _isAnalyzing = analyzing;
    notifyListeners();
  }

  void _resetProgress() {
    _analysisProgress = 0.0;
    _progressController.add(DiagnosisProgress(0.0, 'Analiz başlatılıyor...'));
  }

  Future<void> _updateProgress(double progress, String message) async {
    _analysisProgress = progress;
    _progressController.add(DiagnosisProgress(progress, message));
    await Future.delayed(const Duration(milliseconds: 200));
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void dispose() {
    _progressController.close();
    _resultController.close();
    _riskAlertController.close();
    super.dispose();
  }
}
