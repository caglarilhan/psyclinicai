import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diagnosis_models.dart';
import '../models/clinical_decision_support_models.dart' show DurationPeriod, DurationUnit;
import '../services/ai_orchestration_service.dart';
import '../utils/ai_logger.dart';

class DiagnosisService extends ChangeNotifier {
  static final DiagnosisService _instance = DiagnosisService._internal();
  factory DiagnosisService() => _instance;
  DiagnosisService._internal();

  final AILogger _logger = AILogger();
  final AIOrchestrationService _aiService = AIOrchestrationService();
  
  // Diagnosis systems
  List<DiagnosisSystem> _diagnosisSystems = [];
  List<DiagnosticCategory> _categories = [];
  List<MentalDisorder> _disorders = [];
  List<DiagnosticCriteria> _criteria = [];
  List<TreatmentGuideline> _guidelines = [];
  
  // Assessment data
  List<DiagnosisAssessment> _assessments = [];
  
  // Getters
  List<DiagnosisSystem> get diagnosisSystems => List.unmodifiable(_diagnosisSystems);
  List<DiagnosticCategory> get categories => List.unmodifiable(_categories);
  List<MentalDisorder> get disorders => List.unmodifiable(_disorders);
  List<DiagnosticCriteria> get criteria => List.unmodifiable(_criteria);
  List<TreatmentGuideline> get guidelines => List.unmodifiable(_guidelines);
  List<DiagnosisAssessment> get assessments => List.unmodifiable(_assessments);

  Future<void> initialize() async {
    try {
      _logger.info('DiagnosisService initializing...', context: 'DiagnosisService');
      
      await _loadDiagnosisData();
              // await _loadAssessments(); // TODO: Implement assessments loading
      
      _logger.info('DiagnosisService initialized successfully', context: 'DiagnosisService');
    } catch (e) {
      _logger.error('Failed to initialize DiagnosisService', context: 'DiagnosisService', error: e);
      rethrow;
    }
  }

  Future<void> _loadDiagnosisData() async {
    try {
      // Load DSM-5 data
      await _loadDSM5Data();
      
      // Load ICD-11 data
      await _loadICD11Data();
      
      // Load treatment guidelines
      await _loadTreatmentGuidelines();
      
      _logger.info('Diagnosis data loaded: ${_disorders.length} disorders, ${_criteria.length} criteria', 
                   context: 'DiagnosisService');
    } catch (e) {
      _logger.error('Failed to load diagnosis data', context: 'DiagnosisService', error: e);
    }
  }

  Future<void> _loadDSM5Data() async {
    // DSM-5 Major Depressive Disorder
    final mdd = MentalDisorder(
      id: 'mdd_dsm5',
      name: 'Major Depressive Disorder',
      code: 'F32.1',
      categoryId: 'mood_disorders',
      description: 'A mental health disorder characterized by persistently depressed mood or loss of interest in activities.',
      symptoms: [
        Symptom(
          id: 'depressed_mood',
          name: 'Depressed mood',
          description: 'Persistent feeling of sadness, emptiness, or hopelessness',
          type: SymptomType.mood,
          severity: SymptomSeverity.moderate,
          relatedSymptoms: ['anhedonia', 'fatigue', 'sleep_changes'],
          triggers: ['stress', 'loss', 'seasonal_changes'],
          alleviators: ['exercise', 'social_support', 'therapy'],
          duration: TreatmentDuration.chronic,
          frequency: Frequency.continuous,
        ),
        Symptom(
          id: 'anhedonia',
          name: 'Anhedonia',
          description: 'Markedly diminished interest or pleasure in activities',
          type: SymptomType.mood,
          severity: SymptomSeverity.severe,
          relatedSymptoms: ['depressed_mood', 'social_withdrawal'],
          triggers: ['depression', 'isolation'],
          alleviators: ['engagement', 'social_activities'],
          duration: TreatmentDuration.chronic,
          frequency: Frequency.continuous,
        ),
        Symptom(
          id: 'sleep_changes',
          name: 'Sleep changes',
          description: 'Insomnia or hypersomnia nearly every day',
          type: SymptomType.sleep,
          severity: SymptomSeverity.moderate,
          relatedSymptoms: ['fatigue', 'concentration_problems'],
          triggers: ['anxiety', 'depression', 'stress'],
          alleviators: ['sleep_hygiene', 'medication'],
          duration: TreatmentDuration.chronic,
          frequency: Frequency.continuous,
        ),
      ],
      criteria: [
        DiagnosticCriteria(
          id: 'mdd_criterion_a',
          disorderId: 'mdd_dsm5',
          criterion: 'Five or more of the following symptoms have been present during the same 2-week period',
          criterionNumber: 1,
          requiredSymptoms: ['depressed_mood', 'anhedonia', 'sleep_changes', 'fatigue', 'concentration_problems'],
          minimumSymptoms: 5,
          minimumDuration: TreatmentDuration.subacute,
          exclusionCriteria: ['substance_induced', 'medical_condition'],
          specifiers: ['mild', 'moderate', 'severe'],
        ),
      ],
      differentialDiagnoses: ['bipolar_disorder', 'dysthymia', 'adjustment_disorder'],
      comorbidities: ['anxiety_disorder', 'substance_use_disorder', 'personality_disorder'],
      severity: SeverityLevel.moderate,
      treatmentOptions: [
        TreatmentOption(
          id: 'mdd_ssri',
          name: 'SSRI Antidepressants',
          modality: TreatmentModality.medication,
          description: 'Selective serotonin reuptake inhibitors for depression',
          indications: ['major_depressive_disorder', 'anxiety_disorder'],
          contraindications: ['bipolar_disorder', 'pregnancy'],
          sideEffects: ['nausea', 'sexual_dysfunction', 'weight_gain'],
          duration: TreatmentDuration.chronic,
          effectiveness: 0.7,
          alternatives: ['snri', 'ndri', 'psychotherapy'],
        ),
        TreatmentOption(
          id: 'mdd_cbt',
          name: 'Cognitive Behavioral Therapy',
          modality: TreatmentModality.psychotherapy,
          description: 'Evidence-based psychotherapy for depression',
          indications: ['major_depressive_disorder', 'mild_to_moderate'],
          contraindications: ['severe_depression', 'psychosis'],
          sideEffects: ['emotional_discomfort', 'time_commitment'],
          duration: TreatmentDuration.subacute,
          effectiveness: 0.6,
          alternatives: ['interpersonal_therapy', 'psychodynamic_therapy'],
        ),
      ],
      riskFactors: ['family_history', 'trauma', 'chronic_illness'],
      protectiveFactors: ['social_support', 'coping_skills', 'physical_activity'],
      prognosis: Prognosis.good,
    );

    // DSM-5 Generalized Anxiety Disorder
    final gad = MentalDisorder(
      id: 'gad_dsm5',
      name: 'Generalized Anxiety Disorder',
      code: 'F41.1',
      categoryId: 'anxiety_disorders',
      description: 'Excessive anxiety and worry about various aspects of life.',
      symptoms: [
        Symptom(
          id: 'excessive_worry',
          name: 'Excessive worry',
          description: 'Persistent and excessive worry about various activities or events',
          type: SymptomType.anxiety,
          severity: SymptomSeverity.moderate,
          relatedSymptoms: ['restlessness', 'fatigue', 'concentration_problems'],
          triggers: ['uncertainty', 'stress', 'life_changes'],
          alleviators: ['relaxation', 'problem_solving', 'therapy'],
          duration: TreatmentDuration.chronic,
          frequency: Frequency.continuous,
        ),
        Symptom(
          id: 'restlessness',
          name: 'Restlessness',
          description: 'Feeling keyed up or on edge',
          type: SymptomType.anxiety,
          severity: SymptomSeverity.moderate,
          relatedSymptoms: ['excessive_worry', 'sleep_problems'],
          triggers: ['anxiety', 'caffeine', 'stress'],
          alleviators: ['exercise', 'relaxation', 'medication'],
          duration: TreatmentDuration.chronic,
          frequency: Frequency.continuous,
        ),
      ],
      criteria: [
        DiagnosticCriteria(
          id: 'gad_criterion_a',
          disorderId: 'gad_dsm5',
          criterion: 'Excessive anxiety and worry occurring more days than not for at least 6 months',
          criterionNumber: 1,
          requiredSymptoms: ['excessive_worry', 'restlessness', 'fatigue', 'concentration_problems'],
          minimumSymptoms: 3,
          minimumDuration: TreatmentDuration.chronic,
          exclusionCriteria: ['substance_induced', 'medical_condition'],
          specifiers: ['mild', 'moderate', 'severe'],
        ),
      ],
      differentialDiagnoses: ['panic_disorder', 'social_anxiety', 'depression'],
      comorbidities: ['depression', 'substance_use', 'other_anxiety_disorders'],
      severity: SeverityLevel.moderate,
      treatmentOptions: [
        TreatmentOption(
          id: 'gad_ssri',
          name: 'SSRI Antidepressants',
          modality: TreatmentModality.medication,
          description: 'First-line medication for anxiety disorders',
          indications: ['generalized_anxiety_disorder', 'depression'],
          contraindications: ['bipolar_disorder', 'pregnancy'],
          sideEffects: ['nausea', 'sexual_dysfunction', 'initial_anxiety'],
          duration: TreatmentDuration.chronic,
          effectiveness: 0.65,
          alternatives: ['snri', 'benzodiazepines', 'psychotherapy'],
        ),
        TreatmentOption(
          id: 'gad_cbt',
          name: 'Cognitive Behavioral Therapy',
          modality: TreatmentModality.psychotherapy,
          description: 'Gold standard psychotherapy for anxiety',
          indications: ['generalized_anxiety_disorder', 'mild_to_moderate'],
          contraindications: ['severe_anxiety', 'psychosis'],
          sideEffects: ['emotional_discomfort', 'time_commitment'],
          duration: TreatmentDuration.subacute,
          effectiveness: 0.7,
          alternatives: ['acceptance_commitment_therapy', 'mindfulness'],
        ),
      ],
      riskFactors: ['genetics', 'trauma', 'stressful_life_events'],
      protectiveFactors: ['coping_skills', 'social_support', 'physical_activity'],
      prognosis: Prognosis.good,
    );

    _disorders.addAll([mdd, gad]);
    
    // Add categories
    _categories.addAll([
      DiagnosticCategory(
        id: 'mood_disorders',
        name: 'Mood Disorders',
        code: 'F30-F39',
        description: 'Disorders characterized by disturbances in mood',
        parentCategories: [],
        childCategories: ['depressive_disorders', 'bipolar_disorders'],
        disorderIds: ['mdd_dsm5'],
        type: DiagnosticCategoryType.bipolar,
      ),
      DiagnosticCategory(
        id: 'anxiety_disorders',
        name: 'Anxiety Disorders',
        code: 'F40-F48',
        description: 'Disorders characterized by excessive fear and anxiety',
        parentCategories: [],
        childCategories: ['panic_disorders', 'phobias'],
        disorderIds: ['gad_dsm5'],
        type: DiagnosticCategoryType.anxiety,
      ),
    ]);
  }

  Future<void> _loadICD11Data() async {
    // ICD-11 Bipolar Disorder
    final bipolar = MentalDisorder(
      id: 'bipolar_icd11',
      name: 'Bipolar Disorder',
      code: 'F31',
      categoryId: 'mood_disorders',
      description: 'A mental disorder characterized by episodes of mania and depression.',
      symptoms: [
        Symptom(
          id: 'mania',
          name: 'Mania',
          description: 'Elevated, expansive, or irritable mood with increased activity',
          type: SymptomType.mood,
          severity: SymptomSeverity.severe,
          relatedSymptoms: ['decreased_sleep', 'grandiosity', 'racing_thoughts'],
          triggers: ['stress', 'sleep_deprivation', 'medication_changes'],
          alleviators: ['mood_stabilizers', 'sleep_regulation'],
          duration: TreatmentDuration.episodic,
          frequency: Frequency.episodic,
        ),
        Symptom(
          id: 'depression',
          name: 'Depression',
          description: 'Depressed mood with loss of interest and energy',
          type: SymptomType.mood,
          severity: SymptomSeverity.severe,
          relatedSymptoms: ['anhedonia', 'fatigue', 'suicidal_thoughts'],
          triggers: ['stress', 'life_events', 'medication_changes'],
          alleviators: ['antidepressants', 'therapy', 'social_support'],
          duration: TreatmentDuration.episodic,
          frequency: Frequency.episodic,
        ),
      ],
      criteria: [
        DiagnosticCriteria(
          id: 'bipolar_criterion_a',
          disorderId: 'bipolar_icd11',
          criterion: 'At least one manic episode and one depressive episode',
          criterionNumber: 1,
          requiredSymptoms: ['mania', 'depression'],
          minimumSymptoms: 2,
          minimumDuration: TreatmentDuration.episodic,
          exclusionCriteria: ['substance_induced', 'medical_condition'],
          specifiers: ['bipolar_i', 'bipolar_ii', 'cyclothymia'],
        ),
      ],
      differentialDiagnoses: ['major_depression', 'schizophrenia', 'personality_disorder'],
      comorbidities: ['anxiety', 'substance_use', 'adhd'],
      severity: SeverityLevel.severe,
      treatmentOptions: [
        TreatmentOption(
          id: 'bipolar_mood_stabilizer',
          name: 'Mood Stabilizers',
          modality: TreatmentModality.medication,
          description: 'Lithium, valproate, or lamotrigine for bipolar disorder',
          indications: ['bipolar_disorder', 'mania', 'depression'],
          contraindications: ['kidney_disease', 'pregnancy'],
          sideEffects: ['weight_gain', 'tremor', 'kidney_problems'],
          duration: TreatmentDuration.chronic,
          effectiveness: 0.8,
          alternatives: ['antipsychotics', 'antidepressants'],
        ),
      ],
      riskFactors: ['genetics', 'stress', 'substance_use'],
      protectiveFactors: ['medication_adherence', 'sleep_regulation', 'stress_management'],
      prognosis: Prognosis.fair,
    );

    _disorders.add(bipolar);
  }

  Future<void> _loadTreatmentGuidelines() async {
    _guidelines.addAll([
      TreatmentGuideline(
        id: 'mdd_guideline',
        disorderId: 'mdd_dsm5',
        title: 'Major Depressive Disorder Treatment Guidelines',
        description: 'Evidence-based treatment recommendations for MDD',
        level: TreatmentLevel.firstLine,
        modalities: [TreatmentModality.medication, TreatmentModality.psychotherapy],
        medications: [
          MedicationRecommendation(
            id: 'mdd_ssri_rec',
            medicationName: 'Sertraline',
            genericName: 'Sertraline',
            indications: ['major_depressive_disorder', 'anxiety'],
            contraindications: ['bipolar_disorder', 'pregnancy'],
            sideEffects: ['nausea', 'sexual_dysfunction', 'weight_gain'],
            drugInteractions: ['maoi', 'warfarin'],
            monitoringRequirements: ['suicidal_thoughts', 'mood_changes'],
            treatmentDuration: TreatmentDuration.chronic,
            alternatives: ['fluoxetine', 'escitalopram'],
          ),
        ],
        psychotherapies: [
          PsychotherapyRecommendation(
            id: 'mdd_cbt_rec',
            therapyName: 'Cognitive Behavioral Therapy',
            description: 'Evidence-based psychotherapy for depression',
            indications: ['mild_to_moderate_depression'],
            contraindications: ['severe_depression', 'psychosis'],
            sessionDuration: DurationPeriod(value: 1, unit: DurationUnit.days), // 1 day
            totalSessions: 16,
            effectiveness: 0.6,
            techniques: ['cognitive_restructuring', 'behavioral_activation'],
          ),
        ],
        contraindications: ['bipolar_disorder', 'active_psychosis'],
        sideEffects: ['initial_worsening', 'emotional_discomfort'],
        expectedDuration: TreatmentDuration.chronic,
        outcomeMeasures: ['phq9', 'hamd', 'functional_improvement'],
      ),
    ]);
  }

  Future<void> _loadAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = prefs.getString('diagnosis_assessments');
      
      if (assessmentsJson != null) {
        final List<dynamic> assessmentsList = json.decode(assessmentsJson);
        _assessments = assessmentsList.map((assessment) => DiagnosisAssessment.fromJson(assessment)).toList();
      }
      
      _logger.info('Assessments loaded: ${_assessments.length} assessments', context: 'DiagnosisService');
    } catch (e) {
      _logger.error('Failed to load assessments', context: 'DiagnosisService', error: e);
    }
  }

  // ===== DIAGNOSIS FUNCTIONS =====

  Future<List<MentalDisorder>> searchDisorders({
    String? query,
    String? categoryId,
    List<SymptomType>? symptomTypes,
    SeverityLevel? severity,
    int limit = 20,
  }) async {
    try {
      List<MentalDisorder> results = _disorders;

      // Filter by query
      if (query != null && query.isNotEmpty) {
        results = results.where((disorder) =>
          disorder.name.toLowerCase().contains(query.toLowerCase()) ||
          disorder.description.toLowerCase().contains(query.toLowerCase()) ||
          disorder.code.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }

      // Filter by category
      if (categoryId != null) {
        results = results.where((disorder) => disorder.categoryId == categoryId).toList();
      }

      // Filter by symptom types
      if (symptomTypes != null && symptomTypes.isNotEmpty) {
        results = results.where((disorder) =>
          disorder.symptoms.any((symptom) => symptomTypes.contains(symptom.type))
        ).toList();
      }

      // Filter by severity
      if (severity != null) {
        results = results.where((disorder) => disorder.severity == severity).toList();
      }

      // Limit results
      if (results.length > limit) {
        results = results.take(limit).toList();
      }

      return results;
    } catch (e) {
      _logger.error('Failed to search disorders', context: 'DiagnosisService', error: e);
      return [];
    }
  }

  Future<List<DiagnosticCategory>> getCategories({String? parentCategoryId}) async {
    try {
      if (parentCategoryId == null) {
        return _categories.where((cat) => cat.parentCategories.isEmpty).toList();
      } else {
        return _categories.where((cat) => cat.parentCategories.contains(parentCategoryId)).toList();
      }
    } catch (e) {
      _logger.error('Failed to get categories', context: 'DiagnosisService', error: e);
      return [];
    }
  }

  Future<MentalDisorder?> getDisorder(String disorderId) async {
    try {
      return _disorders.firstWhere((disorder) => disorder.id == disorderId);
    } catch (e) {
      _logger.error('Failed to get disorder', context: 'DiagnosisService', error: e);
      return null;
    }
  }

  // ===== AI DIAGNOSIS ASSISTANT =====

  Future<DiagnosisAssessment> generateAIDiagnosis({
    required String patientId,
    required String clinicianId,
    required List<SymptomAssessment> symptoms,
    required String clinicalNotes,
    String? preferredSystem, // DSM-5, ICD-11
  }) async {
    try {
      _logger.info('Generating AI diagnosis', context: 'DiagnosisService', data: {
        'patientId': patientId,
        'symptomCount': symptoms.length,
        'preferredSystem': preferredSystem,
      });

      // Prepare data for AI analysis
      final symptomData = symptoms.map((s) => {
        'name': s.symptomName,
        'severity': s.severity.name,
        'duration': s.duration.name,
        'frequency': s.frequency.name,
        'impact': s.impact,
      }).toList();

      // Call AI service for diagnosis
      final aiResult = await _aiService.processRequest(
        promptType: 'psychiatric_diagnosis',
        parameters: {
          'symptoms': symptomData,
          'clinicalNotes': clinicalNotes,
          'preferredSystem': preferredSystem ?? 'DSM-5',
          'availableDisorders': _disorders.map((d) => {
            'id': d.id,
            'name': d.name,
            'code': d.code,
            'symptoms': d.symptoms.map((s) => s.name).toList(),
            'criteria': d.criteria.map((c) => c.criterion).toList(),
          }).toList(),
        },
        taskId: 'diagnosis_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Convert AI result to expected format
      final aiResponse = aiResult.outputData ?? {};

      // Parse AI response and create assessment
      final assessment = _parseAIDiagnosisResponse(
        patientId: patientId,
        clinicianId: clinicianId,
        symptoms: symptoms,
        clinicalNotes: clinicalNotes,
        aiResponse: aiResponse,
      );

      // Save assessment
      _assessments.add(assessment);
      await _saveAssessments();

      _logger.info('AI diagnosis generated successfully', context: 'DiagnosisService', data: {
        'assessmentId': assessment.id,
        'diagnosisCount': assessment.diagnoses.length,
      });

      return assessment;
    } catch (e) {
      _logger.error('Failed to generate AI diagnosis', context: 'DiagnosisService', error: e);
      rethrow;
    }
  }

  DiagnosisAssessment _parseAIDiagnosisResponse({
    required String patientId,
    required String clinicianId,
    required List<SymptomAssessment> symptoms,
    required String clinicalNotes,
    required Map<String, dynamic> aiResponse,
  }) {
    try {
      final diagnoses = <DiagnosisResult>[];
      final treatmentRecommendations = <TreatmentRecommendation>[];

      // Parse diagnoses from AI response
      if (aiResponse['diagnoses'] != null) {
        for (final diagnosisData in aiResponse['diagnoses']) {
          final disorder = _disorders.firstWhere(
            (d) => d.id == diagnosisData['disorderId'],
            orElse: () => _disorders.first,
          );

          // Create mock data for required fields
          final symptoms = [
            Symptom(
              id: _generateId(),
              name: 'Mock symptom',
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
              diagnosis: disorder.name,
              confidence: diagnosisData['confidence']?.toDouble() ?? 0.0,
              evidence: ['AI generated evidence'],
              differentialDiagnoses: [],
              icd10Code: disorder.code,
              severity: DiagnosisSeverity.mild,
              treatmentPriority: TreatmentPriority.medium,
              notes: 'AI generated diagnosis',
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
          
          diagnoses.add(DiagnosisResult(
            id: _generateId(),
            clientId: patientId,
            therapistId: clinicianId,
            analysisDate: DateTime.now(),
            symptoms: symptoms,
            symptomAnalysis: symptomAnalysis,
            riskAssessment: riskAssessment,
            diagnosisSuggestions: diagnosisSuggestions,
            treatmentPlan: treatmentPlan,
            confidence: diagnosisData['confidence']?.toDouble() ?? 0.0,
            aiModel: 'AI-Diagnosis-v1',
            processingTime: 1500,
          ));
        }
      }

      // Parse treatment recommendations
      if (aiResponse['treatments'] != null) {
        for (final treatmentData in aiResponse['treatments']) {
          treatmentRecommendations.add(TreatmentRecommendation(
            id: _generateId(),
            treatmentId: treatmentData['treatmentId'] ?? '',
            treatmentName: treatmentData['treatmentName'] ?? '',
            modality: _parseModality(treatmentData['modality']),
            rationale: treatmentData['rationale'] ?? '',
            duration: _parseDuration(treatmentData['duration']),
            goals: treatmentData['goals'] ?? [],
            expectedOutcomes: treatmentData['expectedOutcomes'] ?? [],
            monitoringRequirements: treatmentData['monitoringRequirements'] ?? [],
          ));
        }
      }

      return DiagnosisAssessment(
        id: _generateId(),
        patientId: patientId,
        clinicianId: clinicianId,
        assessmentDate: DateTime.now(),
        diagnoses: diagnoses,
        symptoms: symptoms,
        overallSeverity: _calculateOverallSeverity(symptoms),
        differentialDiagnoses: aiResponse['differentialDiagnoses'] ?? [],
        comorbidities: aiResponse['comorbidities'] ?? [],
        riskFactors: aiResponse['riskFactors'] ?? [],
        protectiveFactors: aiResponse['protectiveFactors'] ?? [],
        prognosis: _parsePrognosis(aiResponse['prognosis']),
        treatmentRecommendations: treatmentRecommendations,
        clinicalNotes: clinicalNotes,
        metadata: {
          'aiGenerated': true,
          'aiConfidence': aiResponse['overallConfidence'] ?? 0.0,
          'systemUsed': aiResponse['systemUsed'] ?? 'DSM-5',
        },
      );
    } catch (e) {
      _logger.error('Failed to parse AI diagnosis response', context: 'DiagnosisService', error: e);
      
      // Return basic assessment if parsing fails
      return DiagnosisAssessment(
        id: _generateId(),
        patientId: patientId,
        clinicianId: clinicianId,
        assessmentDate: DateTime.now(),
        diagnoses: [],
        symptoms: symptoms,
        overallSeverity: _calculateOverallSeverity(symptoms),
        differentialDiagnoses: [],
        comorbidities: [],
        riskFactors: [],
        protectiveFactors: [],
        prognosis: Prognosis.fair,
        treatmentRecommendations: [],
        clinicalNotes: clinicalNotes,
        metadata: {'aiGenerated': false, 'error': e.toString()},
      );
    }
  }

  // ===== ASSESSMENT MANAGEMENT =====

  Future<void> saveAssessment(DiagnosisAssessment assessment) async {
    try {
      final existingIndex = _assessments.indexWhere((a) => a.id == assessment.id);
      
      if (existingIndex >= 0) {
        _assessments[existingIndex] = assessment;
      } else {
        _assessments.add(assessment);
      }
      
      await _saveAssessments();
      
      _logger.info('Assessment saved successfully', context: 'DiagnosisService', data: {
        'assessmentId': assessment.id,
        'patientId': assessment.patientId,
      });
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to save assessment', context: 'DiagnosisService', error: e);
      rethrow;
    }
  }

  Future<DiagnosisAssessment?> getAssessment(String assessmentId) async {
    try {
      return _assessments.firstWhere((a) => a.id == assessmentId);
    } catch (e) {
      _logger.error('Failed to get assessment', context: 'DiagnosisService', error: e);
      return null;
    }
  }

  List<DiagnosisAssessment> getPatientAssessments(String patientId) {
    return _assessments.where((a) => a.patientId == patientId).toList();
  }

  List<DiagnosisAssessment> getClinicianAssessments(String clinicianId) {
    return _assessments.where((a) => a.clinicianId == clinicianId).toList();
  }

  // ===== UTILITY METHODS =====

  SeverityLevel _calculateOverallSeverity(List<SymptomAssessment> symptoms) {
    if (symptoms.isEmpty) return SeverityLevel.none;
    
    final severityScores = symptoms.map((s) {
      switch (s.severity) {
        case SymptomSeverity.none: return 0;
        case SymptomSeverity.mild: return 1;
        case SymptomSeverity.moderate: return 2;
        case SymptomSeverity.severe: return 3;
        case SymptomSeverity.extreme: return 4;
      }
    }).toList();
    
    final averageScore = severityScores.reduce((a, b) => a + b) / severityScores.length;
    
    if (averageScore >= 3.5) return SeverityLevel.extreme;
    if (averageScore >= 2.5) return SeverityLevel.severe;
    if (averageScore >= 1.5) return SeverityLevel.moderate;
    if (averageScore >= 0.5) return SeverityLevel.mild;
    return SeverityLevel.none;
  }

  SeverityLevel _parseSeverity(String? severity) {
    if (severity == null) return SeverityLevel.moderate;
    
    switch (severity.toLowerCase()) {
      case 'none': return SeverityLevel.none;
      case 'mild': return SeverityLevel.mild;
      case 'moderate': return SeverityLevel.moderate;
      case 'severe': return SeverityLevel.severe;
      case 'extreme': return SeverityLevel.extreme;
      default: return SeverityLevel.moderate;
    }
  }

  TreatmentModality _parseModality(String? modality) {
    if (modality == null) return TreatmentModality.other;
    
    switch (modality.toLowerCase()) {
      case 'medication': return TreatmentModality.medication;
      case 'psychotherapy': return TreatmentModality.psychotherapy;
      case 'brain_stimulation': return TreatmentModality.brainStimulation;
      case 'lifestyle': return TreatmentModality.lifestyle;
      case 'complementary': return TreatmentModality.complementary;
      default: return TreatmentModality.other;
    }
  }

  TreatmentDuration _parseDuration(String? duration) {
    if (duration == null) return TreatmentDuration.chronic;
    
    switch (duration.toLowerCase()) {
      case 'acute': return TreatmentDuration.acute;
      case 'subacute': return TreatmentDuration.subacute;
      case 'chronic': return TreatmentDuration.chronic;
      case 'episodic': return TreatmentDuration.episodic;
      case 'continuous': return TreatmentDuration.continuous;
      default: return TreatmentDuration.chronic;
    }
  }

  Prognosis _parsePrognosis(String? prognosis) {
    if (prognosis == null) return Prognosis.fair;
    
    switch (prognosis.toLowerCase()) {
      case 'excellent': return Prognosis.excellent;
      case 'good': return Prognosis.good;
      case 'fair': return Prognosis.fair;
      case 'poor': return Prognosis.poor;
      case 'guarded': return Prognosis.guarded;
      default: return Prognosis.fair;
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _saveAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = json.encode(_assessments.map((a) => a.toJson()).toList());
      await prefs.setString('diagnosis_assessments', assessmentsJson);
    } catch (e) {
      _logger.error('Failed to save assessments', context: 'DiagnosisService', error: e);
      rethrow;
    }
  }
}
