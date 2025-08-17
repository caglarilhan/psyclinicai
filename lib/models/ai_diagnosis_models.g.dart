// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_diagnosis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIDiagnosisResult _$AIDiagnosisResultFromJson(Map<String, dynamic> json) =>
    AIDiagnosisResult(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: $enumDecode(_$DiagnosisConfidenceEnumMap, json['confidence']),
      primaryDiagnoses: (json['primaryDiagnoses'] as List<dynamic>)
          .map((e) => DiagnosisCode.fromJson(e as Map<String, dynamic>))
          .toList(),
      differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
          .map((e) => DiagnosisCode.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
          .map((e) => ProtectiveFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      treatmentRecommendation: TreatmentRecommendation.fromJson(
        json['treatmentRecommendation'] as Map<String, dynamic>,
      ),
      culturalContext: CulturalContext.fromJson(
        json['culturalContext'] as Map<String, dynamic>,
      ),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AIDiagnosisResultToJson(AIDiagnosisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'confidence': _$DiagnosisConfidenceEnumMap[instance.confidence]!,
      'primaryDiagnoses': instance.primaryDiagnoses,
      'differentialDiagnoses': instance.differentialDiagnoses,
      'riskFactors': instance.riskFactors,
      'protectiveFactors': instance.protectiveFactors,
      'treatmentRecommendation': instance.treatmentRecommendation,
      'culturalContext': instance.culturalContext,
      'metadata': instance.metadata,
    };

const _$DiagnosisConfidenceEnumMap = {
  DiagnosisConfidence.veryLow: 'very_low',
  DiagnosisConfidence.low: 'low',
  DiagnosisConfidence.moderate: 'moderate',
  DiagnosisConfidence.high: 'high',
  DiagnosisConfidence.veryHigh: 'very_high',
};

DiagnosisCode _$DiagnosisCodeFromJson(Map<String, dynamic> json) =>
    DiagnosisCode(
      code: json['code'] as String,
      name: json['name'] as String,
      classification: json['classification'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$DiagnosisCodeToJson(DiagnosisCode instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'classification': instance.classification,
      'category': instance.category,
      'description': instance.description,
      'symptoms': instance.symptoms,
      'criteria': instance.criteria,
      'confidence': instance.confidence,
    };

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  name: json['name'] as String,
  level: $enumDecode(_$RiskLevelEnumMap, json['level']),
  description: json['description'] as String,
  category: json['category'] as String,
  impactScore: (json['impactScore'] as num).toDouble(),
  interventions: (json['interventions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'level': _$RiskLevelEnumMap[instance.level]!,
      'description': instance.description,
      'category': instance.category,
      'impactScore': instance.impactScore,
      'interventions': instance.interventions,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.none: 'none',
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
  RiskLevel.emergency: 'emergency',
};

ProtectiveFactor _$ProtectiveFactorFromJson(Map<String, dynamic> json) =>
    ProtectiveFactor(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      strengthScore: (json['strengthScore'] as num).toDouble(),
      enhancementStrategies: (json['enhancementStrategies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ProtectiveFactorToJson(ProtectiveFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'strengthScore': instance.strengthScore,
      'enhancementStrategies': instance.enhancementStrategies,
    };

TreatmentRecommendation _$TreatmentRecommendationFromJson(
  Map<String, dynamic> json,
) => TreatmentRecommendation(
  id: json['id'] as String,
  modalities: (json['modalities'] as List<dynamic>)
      .map((e) => TreatmentModality.fromJson(e as Map<String, dynamic>))
      .toList(),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => MedicationRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  therapies: (json['therapies'] as List<dynamic>)
      .map((e) => TherapyRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  lifestyleChanges: (json['lifestyleChanges'] as List<dynamic>)
      .map((e) => LifestyleRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  followUpPlans: (json['followUpPlans'] as List<dynamic>)
      .map((e) => FollowUpPlan.fromJson(e as Map<String, dynamic>))
      .toList(),
  rationale: json['rationale'] as String,
  expectedEfficacy: (json['expectedEfficacy'] as num).toDouble(),
);

Map<String, dynamic> _$TreatmentRecommendationToJson(
  TreatmentRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'modalities': instance.modalities,
  'medications': instance.medications,
  'therapies': instance.therapies,
  'lifestyleChanges': instance.lifestyleChanges,
  'followUpPlans': instance.followUpPlans,
  'rationale': instance.rationale,
  'expectedEfficacy': instance.expectedEfficacy,
};

TreatmentModality _$TreatmentModalityFromJson(Map<String, dynamic> json) =>
    TreatmentModality(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$TreatmentTypeEnumMap, json['type']),
      intensity: json['intensity'] as String,
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      successRate: (json['successRate'] as num).toDouble(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TreatmentModalityToJson(TreatmentModality instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$TreatmentTypeEnumMap[instance.type]!,
      'intensity': instance.intensity,
      'durationWeeks': instance.durationWeeks,
      'successRate': instance.successRate,
      'contraindications': instance.contraindications,
    };

const _$TreatmentTypeEnumMap = {
  TreatmentType.psychotherapy: 'psychotherapy',
  TreatmentType.pharmacotherapy: 'pharmacotherapy',
  TreatmentType.neuromodulation: 'neuromodulation',
  TreatmentType.lifestyle: 'lifestyle',
  TreatmentType.alternative: 'alternative',
  TreatmentType.combination: 'combination',
};

MedicationRecommendation _$MedicationRecommendationFromJson(
  Map<String, dynamic> json,
) => MedicationRecommendation(
  id: json['id'] as String,
  medicationName: json['medicationName'] as String,
  genericName: json['genericName'] as String,
  classification: json['classification'] as String,
  mechanism: json['mechanism'] as String,
  dosage: json['dosage'] as String,
  frequency: json['frequency'] as String,
  durationDays: (json['durationDays'] as num).toInt(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  efficacyScore: (json['efficacyScore'] as num).toDouble(),
  countryCode: json['countryCode'] as String,
);

Map<String, dynamic> _$MedicationRecommendationToJson(
  MedicationRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationName': instance.medicationName,
  'genericName': instance.genericName,
  'classification': instance.classification,
  'mechanism': instance.mechanism,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
  'durationDays': instance.durationDays,
  'sideEffects': instance.sideEffects,
  'interactions': instance.interactions,
  'contraindications': instance.contraindications,
  'efficacyScore': instance.efficacyScore,
  'countryCode': instance.countryCode,
};

TherapyRecommendation _$TherapyRecommendationFromJson(
  Map<String, dynamic> json,
) => TherapyRecommendation(
  id: json['id'] as String,
  therapyName: json['therapyName'] as String,
  approach: json['approach'] as String,
  description: json['description'] as String,
  sessionCount: (json['sessionCount'] as num).toInt(),
  sessionDurationMinutes: (json['sessionDurationMinutes'] as num).toInt(),
  frequency: json['frequency'] as String,
  evidenceLevel: (json['evidenceLevel'] as num).toDouble(),
  techniques: (json['techniques'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$TherapyRecommendationToJson(
  TherapyRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'therapyName': instance.therapyName,
  'approach': instance.approach,
  'description': instance.description,
  'sessionCount': instance.sessionCount,
  'sessionDurationMinutes': instance.sessionDurationMinutes,
  'frequency': instance.frequency,
  'evidenceLevel': instance.evidenceLevel,
  'techniques': instance.techniques,
  'goals': instance.goals,
};

LifestyleRecommendation _$LifestyleRecommendationFromJson(
  Map<String, dynamic> json,
) => LifestyleRecommendation(
  id: json['id'] as String,
  category: json['category'] as String,
  recommendation: json['recommendation'] as String,
  rationale: json['rationale'] as String,
  frequencyPerWeek: (json['frequencyPerWeek'] as num).toInt(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  impactScore: (json['impactScore'] as num).toDouble(),
  resources: (json['resources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$LifestyleRecommendationToJson(
  LifestyleRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'recommendation': instance.recommendation,
  'rationale': instance.rationale,
  'frequencyPerWeek': instance.frequencyPerWeek,
  'durationMinutes': instance.durationMinutes,
  'impactScore': instance.impactScore,
  'resources': instance.resources,
};

FollowUpPlan _$FollowUpPlanFromJson(Map<String, dynamic> json) => FollowUpPlan(
  id: json['id'] as String,
  type: json['type'] as String,
  frequencyDays: (json['frequencyDays'] as num).toInt(),
  description: json['description'] as String,
  metrics: (json['metrics'] as List<dynamic>).map((e) => e as String).toList(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$FollowUpPlanToJson(FollowUpPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'frequencyDays': instance.frequencyDays,
      'description': instance.description,
      'metrics': instance.metrics,
      'actions': instance.actions,
    };

CulturalContext _$CulturalContextFromJson(Map<String, dynamic> json) =>
    CulturalContext(
      countryCode: json['countryCode'] as String,
      culture: json['culture'] as String,
      culturalNorms: json['culturalNorms'] as Map<String, dynamic>,
      taboos: (json['taboos'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      communicationStyles: Map<String, String>.from(
        json['communicationStyles'] as Map,
      ),
      traditionalHealing: (json['traditionalHealing'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stigmaFactors: json['stigmaFactors'] as Map<String, dynamic>,
      familyStructures: (json['familyStructures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      religiousConsiderations:
          json['religiousConsiderations'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CulturalContextToJson(CulturalContext instance) =>
    <String, dynamic>{
      'countryCode': instance.countryCode,
      'culture': instance.culture,
      'culturalNorms': instance.culturalNorms,
      'taboos': instance.taboos,
      'communicationStyles': instance.communicationStyles,
      'traditionalHealing': instance.traditionalHealing,
      'stigmaFactors': instance.stigmaFactors,
      'familyStructures': instance.familyStructures,
      'religiousConsiderations': instance.religiousConsiderations,
    };
