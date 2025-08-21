// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiagnosisSystem _$DiagnosisSystemFromJson(Map<String, dynamic> json) =>
    DiagnosisSystem(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => DiagnosticCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => DiagnosticCriteria.fromJson(e as Map<String, dynamic>))
          .toList(),
      guidelines: (json['guidelines'] as List<dynamic>)
          .map((e) => TreatmentGuideline.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$DiagnosisSystemToJson(DiagnosisSystem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'categories': instance.categories,
      'criteria': instance.criteria,
      'guidelines': instance.guidelines,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

DiagnosticCategory _$DiagnosticCategoryFromJson(Map<String, dynamic> json) =>
    DiagnosticCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      parentCategories: (json['parentCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      childCategories: (json['childCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      disorderIds: (json['disorderIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: $enumDecode(_$DiagnosticCategoryTypeEnumMap, json['type']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DiagnosticCategoryToJson(DiagnosticCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'parentCategories': instance.parentCategories,
      'childCategories': instance.childCategories,
      'disorderIds': instance.disorderIds,
      'type': _$DiagnosticCategoryTypeEnumMap[instance.type]!,
      'metadata': instance.metadata,
    };

const _$DiagnosticCategoryTypeEnumMap = {
  DiagnosticCategoryType.neurodevelopmental: 'neurodevelopmental',
  DiagnosticCategoryType.schizophrenia: 'schizophrenia',
  DiagnosticCategoryType.bipolar: 'bipolar',
  DiagnosticCategoryType.depressive: 'depressive',
  DiagnosticCategoryType.anxiety: 'anxiety',
  DiagnosticCategoryType.obsessiveCompulsive: 'obsessiveCompulsive',
  DiagnosticCategoryType.trauma: 'trauma',
  DiagnosticCategoryType.dissociative: 'dissociative',
  DiagnosticCategoryType.somatic: 'somatic',
  DiagnosticCategoryType.feeding: 'feeding',
  DiagnosticCategoryType.elimination: 'elimination',
  DiagnosticCategoryType.sleepWake: 'sleepWake',
  DiagnosticCategoryType.sexualDysfunction: 'sexualDysfunction',
  DiagnosticCategoryType.genderDysphoria: 'genderDysphoria',
  DiagnosticCategoryType.disruptive: 'disruptive',
  DiagnosticCategoryType.substance: 'substance',
  DiagnosticCategoryType.neurocognitive: 'neurocognitive',
  DiagnosticCategoryType.personality: 'personality',
  DiagnosticCategoryType.paraphilic: 'paraphilic',
  DiagnosticCategoryType.other: 'other',
};

MentalDisorder _$MentalDisorderFromJson(Map<String, dynamic> json) =>
    MentalDisorder(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => Symptom.fromJson(e as Map<String, dynamic>))
          .toList(),
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => DiagnosticCriteria.fromJson(e as Map<String, dynamic>))
          .toList(),
      differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comorbidities: (json['comorbidities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      severity: $enumDecode(_$SeverityLevelEnumMap, json['severity']),
      treatmentOptions: (json['treatmentOptions'] as List<dynamic>)
          .map((e) => TreatmentOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      prognosis: $enumDecode(_$PrognosisEnumMap, json['prognosis']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MentalDisorderToJson(MentalDisorder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'categoryId': instance.categoryId,
      'description': instance.description,
      'symptoms': instance.symptoms,
      'criteria': instance.criteria,
      'differentialDiagnoses': instance.differentialDiagnoses,
      'comorbidities': instance.comorbidities,
      'severity': _$SeverityLevelEnumMap[instance.severity]!,
      'treatmentOptions': instance.treatmentOptions,
      'riskFactors': instance.riskFactors,
      'protectiveFactors': instance.protectiveFactors,
      'prognosis': _$PrognosisEnumMap[instance.prognosis]!,
      'metadata': instance.metadata,
    };

const _$SeverityLevelEnumMap = {
  SeverityLevel.none: 'none',
  SeverityLevel.mild: 'mild',
  SeverityLevel.moderate: 'moderate',
  SeverityLevel.severe: 'severe',
  SeverityLevel.extreme: 'extreme',
};

const _$PrognosisEnumMap = {
  Prognosis.excellent: 'excellent',
  Prognosis.good: 'good',
  Prognosis.fair: 'fair',
  Prognosis.poor: 'poor',
  Prognosis.guarded: 'guarded',
};

Symptom _$SymptomFromJson(Map<String, dynamic> json) => Symptom(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$SymptomTypeEnumMap, json['type']),
  severity: $enumDecode(_$SymptomSeverityEnumMap, json['severity']),
  relatedSymptoms: (json['relatedSymptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  alleviators: (json['alleviators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  duration: $enumDecode(_$TreatmentDurationEnumMap, json['duration']),
  frequency: $enumDecode(_$FrequencyEnumMap, json['frequency']),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SymptomToJson(Symptom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$SymptomTypeEnumMap[instance.type]!,
  'severity': _$SymptomSeverityEnumMap[instance.severity]!,
  'relatedSymptoms': instance.relatedSymptoms,
  'triggers': instance.triggers,
  'alleviators': instance.alleviators,
  'duration': _$TreatmentDurationEnumMap[instance.duration]!,
  'frequency': _$FrequencyEnumMap[instance.frequency]!,
  'metadata': instance.metadata,
};

const _$SymptomTypeEnumMap = {
  SymptomType.mood: 'mood',
  SymptomType.anxiety: 'anxiety',
  SymptomType.psychotic: 'psychotic',
  SymptomType.cognitive: 'cognitive',
  SymptomType.behavioral: 'behavioral',
  SymptomType.somatic: 'somatic',
  SymptomType.sleep: 'sleep',
  SymptomType.appetite: 'appetite',
  SymptomType.energy: 'energy',
  SymptomType.concentration: 'concentration',
  SymptomType.memory: 'memory',
  SymptomType.social: 'social',
  SymptomType.occupational: 'occupational',
  SymptomType.other: 'other',
};

const _$SymptomSeverityEnumMap = {
  SymptomSeverity.none: 'none',
  SymptomSeverity.mild: 'mild',
  SymptomSeverity.moderate: 'moderate',
  SymptomSeverity.severe: 'severe',
  SymptomSeverity.extreme: 'extreme',
};

const _$TreatmentDurationEnumMap = {
  TreatmentDuration.acute: 'acute',
  TreatmentDuration.subacute: 'subacute',
  TreatmentDuration.chronic: 'chronic',
  TreatmentDuration.episodic: 'episodic',
  TreatmentDuration.continuous: 'continuous',
};

const _$FrequencyEnumMap = {
  Frequency.never: 'never',
  Frequency.rarely: 'rarely',
  Frequency.sometimes: 'sometimes',
  Frequency.often: 'often',
  Frequency.always: 'always',
  Frequency.episodic: 'episodic',
  Frequency.continuous: 'continuous',
  Frequency.daily: 'daily',
  Frequency.weekly: 'weekly',
  Frequency.monthly: 'monthly',
};

DiagnosticCriteria _$DiagnosticCriteriaFromJson(Map<String, dynamic> json) =>
    DiagnosticCriteria(
      id: json['id'] as String,
      disorderId: json['disorderId'] as String,
      criterion: json['criterion'] as String,
      criterionNumber: (json['criterionNumber'] as num).toInt(),
      requiredSymptoms: (json['requiredSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      minimumSymptoms: (json['minimumSymptoms'] as num).toInt(),
      minimumDuration: $enumDecode(
        _$TreatmentDurationEnumMap,
        json['minimumDuration'],
      ),
      exclusionCriteria: (json['exclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specifiers: (json['specifiers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DiagnosticCriteriaToJson(DiagnosticCriteria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'disorderId': instance.disorderId,
      'criterion': instance.criterion,
      'criterionNumber': instance.criterionNumber,
      'requiredSymptoms': instance.requiredSymptoms,
      'minimumSymptoms': instance.minimumSymptoms,
      'minimumDuration': _$TreatmentDurationEnumMap[instance.minimumDuration]!,
      'exclusionCriteria': instance.exclusionCriteria,
      'specifiers': instance.specifiers,
      'metadata': instance.metadata,
    };

TreatmentGuideline _$TreatmentGuidelineFromJson(Map<String, dynamic> json) =>
    TreatmentGuideline(
      id: json['id'] as String,
      disorderId: json['disorderId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: $enumDecode(_$TreatmentLevelEnumMap, json['level']),
      modalities: (json['modalities'] as List<dynamic>)
          .map((e) => $enumDecode(_$TreatmentModalityEnumMap, e))
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map(
            (e) => MedicationRecommendation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      psychotherapies: (json['psychotherapies'] as List<dynamic>)
          .map(
            (e) =>
                PsychotherapyRecommendation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      expectedDuration: $enumDecode(
        _$TreatmentDurationEnumMap,
        json['expectedDuration'],
      ),
      outcomeMeasures: (json['outcomeMeasures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TreatmentGuidelineToJson(
  TreatmentGuideline instance,
) => <String, dynamic>{
  'id': instance.id,
  'disorderId': instance.disorderId,
  'title': instance.title,
  'description': instance.description,
  'level': _$TreatmentLevelEnumMap[instance.level]!,
  'modalities': instance.modalities
      .map((e) => _$TreatmentModalityEnumMap[e]!)
      .toList(),
  'medications': instance.medications,
  'psychotherapies': instance.psychotherapies,
  'contraindications': instance.contraindications,
  'sideEffects': instance.sideEffects,
  'expectedDuration': _$TreatmentDurationEnumMap[instance.expectedDuration]!,
  'outcomeMeasures': instance.outcomeMeasures,
  'metadata': instance.metadata,
};

const _$TreatmentLevelEnumMap = {
  TreatmentLevel.firstLine: 'firstLine',
  TreatmentLevel.secondLine: 'secondLine',
  TreatmentLevel.thirdLine: 'thirdLine',
  TreatmentLevel.experimental: 'experimental',
  TreatmentLevel.notRecommended: 'notRecommended',
};

const _$TreatmentModalityEnumMap = {
  TreatmentModality.medication: 'medication',
  TreatmentModality.psychotherapy: 'psychotherapy',
  TreatmentModality.brainStimulation: 'brainStimulation',
  TreatmentModality.lifestyle: 'lifestyle',
  TreatmentModality.complementary: 'complementary',
  TreatmentModality.other: 'other',
};

TreatmentOption _$TreatmentOptionFromJson(Map<String, dynamic> json) =>
    TreatmentOption(
      id: json['id'] as String,
      name: json['name'] as String,
      modality: $enumDecode(_$TreatmentModalityEnumMap, json['modality']),
      description: json['description'] as String,
      indications: (json['indications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      duration: $enumDecode(_$TreatmentDurationEnumMap, json['duration']),
      effectiveness: (json['effectiveness'] as num).toDouble(),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TreatmentOptionToJson(TreatmentOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'modality': _$TreatmentModalityEnumMap[instance.modality]!,
      'description': instance.description,
      'indications': instance.indications,
      'contraindications': instance.contraindications,
      'sideEffects': instance.sideEffects,
      'duration': _$TreatmentDurationEnumMap[instance.duration]!,
      'effectiveness': instance.effectiveness,
      'alternatives': instance.alternatives,
      'metadata': instance.metadata,
    };

MedicationRecommendation _$MedicationRecommendationFromJson(
  Map<String, dynamic> json,
) => MedicationRecommendation(
  id: json['id'] as String,
  medicationName: json['medicationName'] as String,
  genericName: json['genericName'] as String,
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  drugInteractions: (json['drugInteractions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoringRequirements: (json['monitoringRequirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  treatmentDuration: $enumDecode(
    _$TreatmentDurationEnumMap,
    json['treatmentDuration'],
  ),
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MedicationRecommendationToJson(
  MedicationRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationName': instance.medicationName,
  'genericName': instance.genericName,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'sideEffects': instance.sideEffects,
  'drugInteractions': instance.drugInteractions,
  'monitoringRequirements': instance.monitoringRequirements,
  'treatmentDuration': _$TreatmentDurationEnumMap[instance.treatmentDuration]!,
  'alternatives': instance.alternatives,
  'metadata': instance.metadata,
};

PsychotherapyRecommendation _$PsychotherapyRecommendationFromJson(
  Map<String, dynamic> json,
) => PsychotherapyRecommendation(
  id: json['id'] as String,
  therapyName: json['therapyName'] as String,
  description: json['description'] as String,
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sessionDuration: DurationPeriod.fromJson(
    json['sessionDuration'] as Map<String, dynamic>,
  ),
  totalSessions: (json['totalSessions'] as num).toInt(),
  effectiveness: (json['effectiveness'] as num).toDouble(),
  techniques: (json['techniques'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PsychotherapyRecommendationToJson(
  PsychotherapyRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'therapyName': instance.therapyName,
  'description': instance.description,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'sessionDuration': instance.sessionDuration,
  'totalSessions': instance.totalSessions,
  'effectiveness': instance.effectiveness,
  'techniques': instance.techniques,
  'metadata': instance.metadata,
};

DiagnosisAssessment _$DiagnosisAssessmentFromJson(
  Map<String, dynamic> json,
) => DiagnosisAssessment(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  diagnoses: (json['diagnoses'] as List<dynamic>)
      .map((e) => DiagnosisResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => SymptomAssessment.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallSeverity: $enumDecode(_$SeverityLevelEnumMap, json['overallSeverity']),
  differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  comorbidities: (json['comorbidities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  prognosis: $enumDecode(_$PrognosisEnumMap, json['prognosis']),
  treatmentRecommendations: (json['treatmentRecommendations'] as List<dynamic>)
      .map((e) => TreatmentRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  clinicalNotes: json['clinicalNotes'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$DiagnosisAssessmentToJson(
  DiagnosisAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'diagnoses': instance.diagnoses,
  'symptoms': instance.symptoms,
  'overallSeverity': _$SeverityLevelEnumMap[instance.overallSeverity]!,
  'differentialDiagnoses': instance.differentialDiagnoses,
  'comorbidities': instance.comorbidities,
  'riskFactors': instance.riskFactors,
  'protectiveFactors': instance.protectiveFactors,
  'prognosis': _$PrognosisEnumMap[instance.prognosis]!,
  'treatmentRecommendations': instance.treatmentRecommendations,
  'clinicalNotes': instance.clinicalNotes,
  'metadata': instance.metadata,
};

DiagnosisResult _$DiagnosisResultFromJson(Map<String, dynamic> json) =>
    DiagnosisResult(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => Symptom.fromJson(e as Map<String, dynamic>))
          .toList(),
      symptomAnalysis: SymptomAnalysis.fromJson(
        json['symptomAnalysis'] as Map<String, dynamic>,
      ),
      riskAssessment: RiskAssessment.fromJson(
        json['riskAssessment'] as Map<String, dynamic>,
      ),
      diagnosisSuggestions: (json['diagnosisSuggestions'] as List<dynamic>)
          .map((e) => DiagnosisSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      treatmentPlan: TreatmentPlan.fromJson(
        json['treatmentPlan'] as Map<String, dynamic>,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      aiModel: json['aiModel'] as String,
      processingTime: (json['processingTime'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DiagnosisResultToJson(DiagnosisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'symptoms': instance.symptoms,
      'symptomAnalysis': instance.symptomAnalysis,
      'riskAssessment': instance.riskAssessment,
      'diagnosisSuggestions': instance.diagnosisSuggestions,
      'treatmentPlan': instance.treatmentPlan,
      'confidence': instance.confidence,
      'aiModel': instance.aiModel,
      'processingTime': instance.processingTime,
      'metadata': instance.metadata,
    };

SymptomAnalysis _$SymptomAnalysisFromJson(Map<String, dynamic> json) =>
    SymptomAnalysis(
      id: json['id'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => Symptom.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallSeverity: (json['overallSeverity'] as num).toDouble(),
      primaryCategories: (json['primaryCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => Pattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      analysisDate: DateTime.parse(json['analysisDate'] as String),
    );

Map<String, dynamic> _$SymptomAnalysisToJson(SymptomAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symptoms': instance.symptoms,
      'overallSeverity': instance.overallSeverity,
      'primaryCategories': instance.primaryCategories,
      'patterns': instance.patterns,
      'recommendations': instance.recommendations,
      'analysisDate': instance.analysisDate.toIso8601String(),
    };

Pattern _$PatternFromJson(Map<String, dynamic> json) => Pattern(
  id: json['id'] as String,
  type: $enumDecode(_$PatternTypeEnumMap, json['type']),
  description: json['description'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => Symptom.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PatternToJson(Pattern instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$PatternTypeEnumMap[instance.type]!,
  'description': instance.description,
  'confidence': instance.confidence,
  'symptoms': instance.symptoms,
};

const _$PatternTypeEnumMap = {
  PatternType.mood: 'mood',
  PatternType.sleep: 'sleep',
  PatternType.anxiety: 'anxiety',
  PatternType.cognitive: 'cognitive',
  PatternType.behavioral: 'behavioral',
  PatternType.physical: 'physical',
  PatternType.social: 'social',
};

SymptomAssessment _$SymptomAssessmentFromJson(Map<String, dynamic> json) =>
    SymptomAssessment(
      id: json['id'] as String,
      symptomId: json['symptomId'] as String,
      symptomName: json['symptomName'] as String,
      severity: $enumDecode(_$SymptomSeverityEnumMap, json['severity']),
      duration: $enumDecode(_$TreatmentDurationEnumMap, json['duration']),
      frequency: $enumDecode(_$FrequencyEnumMap, json['frequency']),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alleviators: (json['alleviators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      impact: json['impact'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SymptomAssessmentToJson(SymptomAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symptomId': instance.symptomId,
      'symptomName': instance.symptomName,
      'severity': _$SymptomSeverityEnumMap[instance.severity]!,
      'duration': _$TreatmentDurationEnumMap[instance.duration]!,
      'frequency': _$FrequencyEnumMap[instance.frequency]!,
      'triggers': instance.triggers,
      'alleviators': instance.alleviators,
      'impact': instance.impact,
      'metadata': instance.metadata,
    };

TreatmentRecommendation _$TreatmentRecommendationFromJson(
  Map<String, dynamic> json,
) => TreatmentRecommendation(
  id: json['id'] as String,
  treatmentId: json['treatmentId'] as String,
  treatmentName: json['treatmentName'] as String,
  modality: $enumDecode(_$TreatmentModalityEnumMap, json['modality']),
  rationale: json['rationale'] as String,
  duration: $enumDecode(_$TreatmentDurationEnumMap, json['duration']),
  goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
  expectedOutcomes: (json['expectedOutcomes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoringRequirements: (json['monitoringRequirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$TreatmentRecommendationToJson(
  TreatmentRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'treatmentId': instance.treatmentId,
  'treatmentName': instance.treatmentName,
  'modality': _$TreatmentModalityEnumMap[instance.modality]!,
  'rationale': instance.rationale,
  'duration': _$TreatmentDurationEnumMap[instance.duration]!,
  'goals': instance.goals,
  'expectedOutcomes': instance.expectedOutcomes,
  'monitoringRequirements': instance.monitoringRequirements,
  'metadata': instance.metadata,
};

DiagnosisSuggestion _$DiagnosisSuggestionFromJson(Map<String, dynamic> json) =>
    DiagnosisSuggestion(
      id: json['id'] as String,
      diagnosis: json['diagnosis'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      evidence: (json['evidence'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      icd10Code: json['icd10Code'] as String,
      severity: $enumDecode(_$DiagnosisSeverityEnumMap, json['severity']),
      treatmentPriority: $enumDecode(
        _$TreatmentPriorityEnumMap,
        json['treatmentPriority'],
      ),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DiagnosisSuggestionToJson(
  DiagnosisSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'diagnosis': instance.diagnosis,
  'confidence': instance.confidence,
  'evidence': instance.evidence,
  'differentialDiagnoses': instance.differentialDiagnoses,
  'icd10Code': instance.icd10Code,
  'severity': _$DiagnosisSeverityEnumMap[instance.severity]!,
  'treatmentPriority': _$TreatmentPriorityEnumMap[instance.treatmentPriority]!,
  'notes': instance.notes,
};

const _$DiagnosisSeverityEnumMap = {
  DiagnosisSeverity.mild: 'mild',
  DiagnosisSeverity.moderate: 'moderate',
  DiagnosisSeverity.severe: 'severe',
  DiagnosisSeverity.verySevere: 'verySevere',
};

const _$TreatmentPriorityEnumMap = {
  TreatmentPriority.low: 'low',
  TreatmentPriority.medium: 'medium',
  TreatmentPriority.high: 'high',
  TreatmentPriority.urgent: 'urgent',
};

RiskAssessment _$RiskAssessmentFromJson(Map<String, dynamic> json) =>
    RiskAssessment(
      id: json['id'] as String,
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      urgency: $enumDecode(_$UrgencyEnumMap, json['urgency']),
    );

Map<String, dynamic> _$RiskAssessmentToJson(RiskAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'riskFactors': instance.riskFactors,
      'urgency': _$UrgencyEnumMap[instance.urgency]!,
      'recommendations': instance.recommendations,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

const _$UrgencyEnumMap = {
  Urgency.routine: 'routine',
  Urgency.urgent: 'urgent',
  Urgency.immediate: 'immediate',
};

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  type: $enumDecode(_$RiskTypeEnumMap, json['type']),
  severity: $enumDecode(_$RiskSeverityEnumMap, json['severity']),
  description: json['description'] as String,
  probability: (json['probability'] as num).toDouble(),
  mitigation: json['mitigation'] as String,
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RiskTypeEnumMap[instance.type]!,
      'severity': _$RiskSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'probability': instance.probability,
      'mitigation': instance.mitigation,
    };

const _$RiskTypeEnumMap = {
  RiskType.biological: 'biological',
  RiskType.psychological: 'psychological',
  RiskType.social: 'social',
  RiskType.environmental: 'environmental',
  RiskType.genetic: 'genetic',
  RiskType.lifestyle: 'lifestyle',
  RiskType.medication: 'medication',
  RiskType.substance: 'substance',
  RiskType.trauma: 'trauma',
  RiskType.other: 'other',
};

const _$RiskSeverityEnumMap = {
  RiskSeverity.low: 'low',
  RiskSeverity.medium: 'medium',
  RiskSeverity.high: 'high',
  RiskSeverity.critical: 'critical',
};

TreatmentPlan _$TreatmentPlanFromJson(Map<String, dynamic> json) =>
    TreatmentPlan(
      id: json['id'] as String,
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map((e) => DiagnosisSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => TreatmentIntervention.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>)
          .map((e) => TreatmentGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: DurationPeriod.fromJson(
        json['timeline'] as Map<String, dynamic>,
      ),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      monitoringSchedule: MonitoringSchedule.fromJson(
        json['monitoringSchedule'] as Map<String, dynamic>,
      ),
      planDate: DateTime.parse(json['planDate'] as String),
    );

Map<String, dynamic> _$TreatmentPlanToJson(TreatmentPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diagnoses': instance.diagnoses,
      'interventions': instance.interventions,
      'goals': instance.goals,
      'timeline': instance.timeline,
      'riskFactors': instance.riskFactors,
      'monitoringSchedule': instance.monitoringSchedule,
      'planDate': instance.planDate.toIso8601String(),
    };

TreatmentIntervention _$TreatmentInterventionFromJson(
  Map<String, dynamic> json,
) => TreatmentIntervention(
  id: json['id'] as String,
  type: $enumDecode(_$InterventionTypeEnumMap, json['type']),
  name: json['name'] as String,
  description: json['description'] as String,
  frequency: json['frequency'] as String,
  duration: json['duration'] as String,
  priority: $enumDecode(_$InterventionPriorityEnumMap, json['priority']),
);

Map<String, dynamic> _$TreatmentInterventionToJson(
  TreatmentIntervention instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$InterventionTypeEnumMap[instance.type]!,
  'name': instance.name,
  'description': instance.description,
  'frequency': instance.frequency,
  'duration': instance.duration,
  'priority': _$InterventionPriorityEnumMap[instance.priority]!,
};

const _$InterventionTypeEnumMap = {
  InterventionType.psychotherapy: 'psychotherapy',
  InterventionType.medication: 'medication',
  InterventionType.lifestyle: 'lifestyle',
  InterventionType.social: 'social',
  InterventionType.educational: 'educational',
  InterventionType.emergency: 'emergency',
};

const _$InterventionPriorityEnumMap = {
  InterventionPriority.low: 'low',
  InterventionPriority.medium: 'medium',
  InterventionPriority.high: 'high',
  InterventionPriority.critical: 'critical',
};

TreatmentGoal _$TreatmentGoalFromJson(Map<String, dynamic> json) =>
    TreatmentGoal(
      id: json['id'] as String,
      description: json['description'] as String,
      target: json['target'] as String,
      timeline: json['timeline'] as String,
      priority: $enumDecode(_$GoalPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$TreatmentGoalToJson(TreatmentGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'target': instance.target,
      'timeline': instance.timeline,
      'priority': _$GoalPriorityEnumMap[instance.priority]!,
    };

const _$GoalPriorityEnumMap = {
  GoalPriority.low: 'low',
  GoalPriority.medium: 'medium',
  GoalPriority.high: 'high',
  GoalPriority.critical: 'critical',
};

MonitoringSchedule _$MonitoringScheduleFromJson(Map<String, dynamic> json) =>
    MonitoringSchedule(
      id: json['id'] as String,
      name: json['name'] as String,
      frequency: json['frequency'] as String,
      parameters: (json['parameters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextDue: DateTime.parse(json['nextDue'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$MonitoringScheduleToJson(MonitoringSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'frequency': instance.frequency,
      'parameters': instance.parameters,
      'nextDue': instance.nextDue.toIso8601String(),
      'isActive': instance.isActive,
    };
