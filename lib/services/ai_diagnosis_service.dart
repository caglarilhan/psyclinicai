import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diagnosis_models.dart';
import '../models/clinical_decision_support_models.dart';
import '../utils/ai_logger.dart';
import 'ai_service.dart';

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

  AIService? _aiService;
  List<DiagnosisSystem> _diagnosisSystems = [];
  List<DiagnosticCategory> _categories = [];
  List<MentalDisorder> _disorders = [];
  List<DiagnosticCriteria> _criteria = [];
  List<TreatmentGuideline> _guidelines = [];
  List<DiagnosisAssessment> _assessments = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<DiagnosisSystem> get diagnosisSystems => _diagnosisSystems;
  List<DiagnosticCategory> get categories => _categories;
  List<MentalDisorder> get disorders => _disorders;
  List<DiagnosticCriteria> get criteria => _criteria;
  List<TreatmentGuideline> get guidelines => _guidelines;
  List<DiagnosisAssessment> get assessments => _assessments;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _aiService = AIService();
      await _loadDiagnosisData();
      // await _loadAssessments(); // TODO: Implement assessments loading
      _isInitialized = true;
      notifyListeners();
      print('AIDiagnosisService initialized successfully');
    } catch (e) {
      print('AIDiagnosisService initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _loadDiagnosisData() async {
    // Mock data loading
    await _loadDSM5Data();
    await _loadICD11Data();
    await _loadTreatmentGuidelines();
  }

  Future<void> _loadDSM5Data() async {
    // DSM-5 mock data
    _diagnosisSystems.add(
      DiagnosisSystem(
        id: 'dsm5',
        name: 'DSM-5',
        version: '5.0',
        categories: [],
        criteria: [],
        guidelines: [],
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
    );

    _categories.addAll([
      DiagnosticCategory(
        id: 'dsm5_mood',
        name: 'Mood Disorders',
        code: 'MD',
        description: 'Disorders characterized by mood disturbances',
        parentCategories: [],
        childCategories: [],
        disorderIds: [],
        type: DiagnosticCategoryType.clinical,
      ),
      DiagnosticCategory(
        id: 'dsm5_anxiety',
        name: 'Anxiety Disorders',
        code: 'AD',
        description: 'Disorders characterized by excessive anxiety and fear',
        parentCategories: [],
        childCategories: [],
        disorderIds: [],
        type: DiagnosticCategoryType.clinical,
      ),
      DiagnosticCategory(
        id: 'dsm5_psychotic',
        name: 'Psychotic Disorders',
        code: 'PD',
        description: 'Disorders characterized by psychosis',
        parentCategories: [],
        childCategories: [],
        disorderIds: [],
        type: DiagnosticCategoryType.clinical,
      ),
    ]);

    _disorders.addAll([
      MentalDisorder(
        id: 'dsm5_mdd',
        categoryId: 'dsm5_mood',
        code: '296.32',
        name: 'Major Depressive Disorder',
        description: 'A mood disorder characterized by persistent feelings of sadness and loss of interest',
        symptoms: [],
        criteria: [],
        differentialDiagnoses: [],
        comorbidities: [],
        severity: SeverityLevel.moderate,
        treatmentOptions: [],
        riskFactors: [],
        protectiveFactors: [],
        prognosis: Prognosis.fair,
      ),
      MentalDisorder(
        id: 'dsm5_gad',
        categoryId: 'dsm5_anxiety',
        code: '300.02',
        name: 'Generalized Anxiety Disorder',
        description: 'Excessive anxiety and worry about various aspects of life',
        symptoms: [],
        criteria: [],
        differentialDiagnoses: [],
        comorbidities: [],
        severity: SeverityLevel.moderate,
        treatmentOptions: [],
        riskFactors: [],
        protectiveFactors: [],
        prognosis: Prognosis.fair,
      ),
    ]);

    _criteria.addAll([
      DiagnosticCriteria(
        id: 'dsm5_mdd_criterion_a',
        disorderId: 'dsm5_mdd',
        criterionNumber: 1,
        criterion: 'Depressed mood or loss of interest or pleasure in nearly all activities',
        requiredSymptoms: ['Depressed mood', 'Loss of interest'],
        minimumSymptoms: 2,
        minimumDuration: TreatmentDuration.episodic,
        exclusionCriteria: [],
        specifiers: [],
      ),
      DiagnosticCriteria(
        id: 'dsm5_mdd_criterion_b',
        disorderId: 'dsm5_mdd',
        criterionNumber: 2,
        criterion: 'Significant weight loss or gain, or decrease or increase in appetite',
        requiredSymptoms: ['Weight changes', 'Appetite changes'],
        minimumSymptoms: 1,
        minimumDuration: TreatmentDuration.episodic,
        exclusionCriteria: [],
        specifiers: [],
      ),
    ]);

    _guidelines.addAll([
      TreatmentGuideline(
        id: 'dsm5_mdd_treatment_1',
        disorderId: 'dsm5_mdd',
        title: 'MDD First Line Treatment',
        description: 'SSRIs and psychotherapy as first-line treatment',
        level: TreatmentLevel.firstLine,
        modalities: [TreatmentModality.medication, TreatmentModality.psychotherapy],
        medications: [],
        psychotherapies: [],
        contraindications: [],
        sideEffects: [],
        expectedDuration: TreatmentDuration.acute,
        outcomeMeasures: [],
      ),
    ]);
  }

  Future<void> _loadICD11Data() async {
    // ICD-11 mock data
    _diagnosisSystems.add(
      DiagnosisSystem(
        id: 'icd11',
        name: 'ICD-11',
        version: '11.0',
        categories: [],
        criteria: [],
        guidelines: [],
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
    );

    _categories.addAll([
      DiagnosticCategory(
        id: 'icd11_mood',
        name: 'Mood Disorders',
        code: 'MD',
        description: 'Disorders of mood',
        parentCategories: [],
        childCategories: [],
        disorderIds: [],
        type: DiagnosticCategoryType.clinical,
      ),
    ]);

    _disorders.addAll([
      MentalDisorder(
        id: 'icd11_depression',
        categoryId: 'icd11_mood',
        code: '6A70',
        name: 'Depressive Disorder',
        description: 'A mood disorder characterized by depressive symptoms',
        symptoms: [],
        criteria: [],
        differentialDiagnoses: [],
        comorbidities: [],
        severity: SeverityLevel.moderate,
        treatmentOptions: [],
        riskFactors: [],
        protectiveFactors: [],
        prognosis: Prognosis.fair,
      ),
    ]);
  }

  Future<void> _loadTreatmentGuidelines() async {
    // Treatment guidelines are already loaded with disorders
  }

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
    
    final severity = symptoms.fold(0.0, (sum, s) => sum + _severityToNumber(s.severity)) / symptoms.length;
    final categories = symptoms.map((s) => s.type.name).toSet().toList();
    
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
        treatmentPriority: TreatmentPriority.urgent,
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
    if (symptoms.any((s) => s.type.name == 'mood')) {
      patterns.add(Pattern(
        id: _generateId(),
        type: PatternType.mood,
        description: 'Mood-related symptoms cluster',
        confidence: 0.85,
        symptoms: symptoms.where((s) => s.type.name == 'mood').toList(),
      ));
    }
    
    // Sleep patterns
    if (symptoms.any((s) => s.type.name == 'sleep')) {
      patterns.add(Pattern(
        id: _generateId(),
        type: PatternType.sleep,
        description: 'Sleep disturbance pattern',
        confidence: 0.78,
        symptoms: symptoms.where((s) => s.type.name == 'sleep').toList(),
      ));
    }
    
    return patterns;
  }

  List<String> _generateSymptomRecommendations(List<Symptom> symptoms) {
    final recommendations = <String>[];
    
    if (symptoms.any((s) => s.severity == SymptomSeverity.severe)) {
      recommendations.add('Yüksek şiddetli semptomlar için acil değerlendirme gerekli');
    }
    
    if (symptoms.any((s) => s.type.name == 'suicidal')) {
      recommendations.add('İntihar düşünceleri için acil psikiyatrik değerlendirme');
    }
    
    if (symptoms.any((s) => s.type.name == 'psychosis')) {
      recommendations.add('Psikotik semptomlar için psikiyatrik değerlendirme');
    }
    
    return recommendations;
  }

  List<RiskFactor> _identifyRiskFactors(List<Symptom> symptoms, Map<String, dynamic> clientHistory) {
    final riskFactors = <RiskFactor>[];
    
    // Symptom-based risks
    if (symptoms.any((s) => s.type.name == 'suicidal')) {
      riskFactors.add(RiskFactor(
        id: _generateId(),
        type: RiskType.other,
        severity: RiskSeverity.critical,
        description: 'İntihar düşünceleri mevcut',
        probability: 0.95,
        mitigation: 'Acil psikiyatrik değerlendirme, güvenlik planı',
      ));
    }
    
    if (symptoms.any((s) => s.type.name == 'psychosis')) {
      riskFactors.add(RiskFactor(
        id: _generateId(),
        type: RiskType.other,
        severity: RiskSeverity.high,
        description: 'İntihar düşünceleri mevcut',
        probability: 0.80,
        mitigation: 'Psikiyatrik değerlendirme, antipsikotik tedavi',
      ));
    }
    
    // History-based risks
    if (clientHistory['previousAttempts'] == true) {
      riskFactors.add(RiskFactor(
        id: _generateId(),
        type: RiskType.other,
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
    
    if (riskFactors.any((r) => r.severity == RiskLevel.high)) {
      return RiskLevel.high;
    }
    
    if (riskFactors.any((r) => r.severity == RiskLevel.medium)) {
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
    
    if (symptoms.any((s) => s.severity == SymptomSeverity.severe)) {
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

  DurationPeriod _calculateTimeline(List<TreatmentIntervention> interventions) {
    if (interventions.isEmpty) return DurationPeriod(value: 30, unit: DurationUnit.days);
    
    final maxDuration = interventions.fold<int>(0, (max, i) {
      final weeks = _parseDuration(i.duration);
      return weeks > max ? weeks : max;
    });
    
    return DurationPeriod(value: maxDuration * 7, unit: DurationUnit.days);
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

  List<MentalDisorder> searchDisorders(String query) {
    if (query.isEmpty) return [];
    
    return _disorders.where((disorder) {
      return disorder.name.toLowerCase().contains(query.toLowerCase()) ||
             disorder.description.toLowerCase().contains(query.toLowerCase()) ||
             disorder.code.contains(query);
    }).toList();
  }

  List<DiagnosticCategory> getCategories() {
    return _categories;
  }

  MentalDisorder? getDisorder(String id) {
    try {
      return _disorders.firstWhere((disorder) => disorder.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<DiagnosisResult> generateAIDiagnosis(SymptomAssessment assessment) async {
    if (_aiService == null) {
      throw Exception('AI Service not initialized');
    }

    try {
      // Analyze symptoms and generate AI diagnosis
      final prompt = _buildDiagnosisPrompt(assessment);
      final response = await _aiService!.generateResponse(prompt);
      
      return _parseAIDiagnosisResponse(response, assessment);
    } catch (e) {
      print('AI diagnosis generation failed: $e');
      rethrow;
    }
  }

  String _buildDiagnosisPrompt(SymptomAssessment assessment) {
    final symptoms = '${assessment.symptomName} (${assessment.severity})';
    
    return '''
    Based on the following psychiatric symptoms, provide a diagnosis suggestion:
    
    Symptoms: $symptoms
    Duration: ${assessment.duration}
    Frequency: ${assessment.frequency}
    
    Please provide:
    1. Most likely diagnosis
    2. Confidence level (0-100%)
    3. Supporting symptoms
    4. Differential diagnoses
    5. Recommended assessments
    ''';
  }

  DiagnosisResult _parseAIDiagnosisResponse(String aiResponse, SymptomAssessment assessment) {
    // Parse AI response and create DiagnosisResult
    // This is a simplified parser - in production, you'd want more sophisticated parsing
    
    // Create mock data for required fields
    final symptoms = [
      Symptom(
        id: _generateId(),
        name: assessment.symptomName,
        description: 'AI generated symptom',
        type: SymptomType.mood,
        severity: SymptomSeverity.moderate,
        relatedSymptoms: [],
        triggers: [],
        alleviators: [],
        duration: TreatmentDuration.episodic,
        frequency: Frequency.daily,
      )
    ];
    
    final symptomAnalysis = SymptomAnalysis(
      id: _generateId(),
      symptoms: symptoms,
      overallSeverity: 0.5,
      primaryCategories: ['mood'],
      patterns: [],
      recommendations: ['AI analysis recommended'],
      analysisDate: DateTime.now(),
    );
    
    final riskAssessment = RiskAssessment(
      id: _generateId(),
      riskLevel: RiskLevel.low,
      riskFactors: [],
      urgency: Urgency.routine,
      recommendations: ['Continue monitoring'],
      assessmentDate: DateTime.now(),
    );
    
    final diagnosisSuggestions = [
      DiagnosisSuggestion(
        id: _generateId(),
        diagnosis: 'AI Generated Diagnosis',
        confidence: 0.85,
        evidence: [assessment.symptomName],
        differentialDiagnoses: ['Alternative Diagnosis 1', 'Alternative Diagnosis 2'],
        icd10Code: 'AI-001',
        severity: DiagnosisSeverity.mild,
        treatmentPriority: TreatmentPriority.medium,
        notes: aiResponse,
      )
    ];
    
    final treatmentPlan = TreatmentPlan(
      id: _generateId(),
      diagnoses: diagnosisSuggestions,
      interventions: [],
      goals: [],
      timeline: DurationPeriod(value: 30, unit: DurationUnit.days),
      riskFactors: [],
      monitoringSchedule: MonitoringSchedule(
        id: _generateId(),
        events: [],
        createdDate: DateTime.now(),
      ),
      planDate: DateTime.now(),
    );
    
    return DiagnosisResult(
      id: _generateId(),
      clientId: assessment.patientId,
      therapistId: assessment.clinicianId,
      analysisDate: DateTime.now(),
      symptoms: symptoms,
      symptomAnalysis: symptomAnalysis,
      riskAssessment: riskAssessment,
      diagnosisSuggestions: diagnosisSuggestions,
      treatmentPlan: treatmentPlan,
      confidence: 0.85,
      aiModel: 'AI-Diagnosis-v1',
      processingTime: 1500,
    );
  }

  Future<void> saveAssessment(DiagnosisAssessment assessment) async {
    _assessments.add(assessment);
    // await _saveAssessments(); // TODO: Implement assessments saving
    notifyListeners();
  }

  DiagnosisAssessment? getAssessment(String id) {
    try {
      return _assessments.firstWhere((assessment) => assessment.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DiagnosisAssessment> getPatientAssessments(String patientId) {
    return _assessments.where((assessment) => assessment.patientId == patientId).toList();
  }

  List<DiagnosisAssessment> getClinicianAssessments(String clinicianId) {
    return _assessments.where((assessment) => assessment.clinicianId == clinicianId).toList();
  }

  // Utility methods for parsing enums
  SymptomSeverity _parseSymptomSeverity(String value) {
    switch (value.toLowerCase()) {
      case 'mild':
        return SymptomSeverity.mild;
      case 'moderate':
        return SymptomSeverity.moderate;
      case 'severe':
        return SymptomSeverity.severe;
      default:
        return SymptomSeverity.mild;
    }
  }

  double _severityToNumber(SymptomSeverity severity) {
    switch (severity) {
      case SymptomSeverity.none:
        return 0.0;
      case SymptomSeverity.mild:
        return 1.0;
      case SymptomSeverity.moderate:
        return 2.0;
      case SymptomSeverity.severe:
        return 3.0;
      case SymptomSeverity.extreme:
        return 4.0;
    }
  }



  Frequency _parseFrequency(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return Frequency.daily;
      case 'weekly':
        return Frequency.weekly;
      case 'monthly':
        return Frequency.monthly;
      default:
        return Frequency.daily;
    }
  }
}
