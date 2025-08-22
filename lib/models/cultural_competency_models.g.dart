// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cultural_competency_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CulturalProfile _$CulturalProfileFromJson(
  Map<String, dynamic> json,
) => CulturalProfile(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  primaryCulture: json['primaryCulture'] as String,
  culturalBackgrounds: (json['culturalBackgrounds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  language: json['language'] as String,
  religion: json['religion'] as String,
  ethnicity: json['ethnicity'] as String,
  nationality: json['nationality'] as String,
  culturalValues: json['culturalValues'] as Map<String, dynamic>? ?? const {},
  communicationPreferences:
      json['communicationPreferences'] as Map<String, dynamic>? ?? const {},
  healthBeliefs: json['healthBeliefs'] as Map<String, dynamic>? ?? const {},
  familyStructure: json['familyStructure'] as Map<String, dynamic>? ?? const {},
  socialContext: json['socialContext'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalProfileToJson(CulturalProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'primaryCulture': instance.primaryCulture,
      'culturalBackgrounds': instance.culturalBackgrounds,
      'language': instance.language,
      'religion': instance.religion,
      'ethnicity': instance.ethnicity,
      'nationality': instance.nationality,
      'culturalValues': instance.culturalValues,
      'communicationPreferences': instance.communicationPreferences,
      'healthBeliefs': instance.healthBeliefs,
      'familyStructure': instance.familyStructure,
      'socialContext': instance.socialContext,
      'metadata': instance.metadata,
    };

CulturalCompetencyAssessment _$CulturalCompetencyAssessmentFromJson(
  Map<String, dynamic> json,
) => CulturalCompetencyAssessment(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  culturalSensitivityScore: (json['culturalSensitivityScore'] as num)
      .toDouble(),
  communicationEffectivenessScore:
      (json['communicationEffectivenessScore'] as num).toDouble(),
  treatmentCulturalFitScore: (json['treatmentCulturalFitScore'] as num)
      .toDouble(),
  dimensions: (json['dimensions'] as List<dynamic>)
      .map(
        (e) => CulturalCompetencyDimension.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map(
        (e) => CulturalCompetencyRecommendation.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalCompetencyAssessmentToJson(
  CulturalCompetencyAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'culturalSensitivityScore': instance.culturalSensitivityScore,
  'communicationEffectivenessScore': instance.communicationEffectivenessScore,
  'treatmentCulturalFitScore': instance.treatmentCulturalFitScore,
  'dimensions': instance.dimensions,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};

CulturalCompetencyDimension _$CulturalCompetencyDimensionFromJson(
  Map<String, dynamic> json,
) => CulturalCompetencyDimension(
  dimension: json['dimension'] as String,
  score: (json['score'] as num).toDouble(),
  description: json['description'] as String,
  strengths: (json['strengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalCompetencyDimensionToJson(
  CulturalCompetencyDimension instance,
) => <String, dynamic>{
  'dimension': instance.dimension,
  'score': instance.score,
  'description': instance.description,
  'strengths': instance.strengths,
  'areasForImprovement': instance.areasForImprovement,
  'metadata': instance.metadata,
};

CulturalCompetencyRecommendation _$CulturalCompetencyRecommendationFromJson(
  Map<String, dynamic> json,
) => CulturalCompetencyRecommendation(
  id: json['id'] as String,
  category: json['category'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  priority: $enumDecode(_$RecommendationPriorityEnumMap, json['priority']),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  resources: (json['resources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalCompetencyRecommendationToJson(
  CulturalCompetencyRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'title': instance.title,
  'description': instance.description,
  'priority': _$RecommendationPriorityEnumMap[instance.priority]!,
  'actions': instance.actions,
  'resources': instance.resources,
  'metadata': instance.metadata,
};

const _$RecommendationPriorityEnumMap = {
  RecommendationPriority.low: 'low',
  RecommendationPriority.medium: 'medium',
  RecommendationPriority.high: 'high',
  RecommendationPriority.critical: 'critical',
};

CulturalTreatmentGuideline _$CulturalTreatmentGuidelineFromJson(
  Map<String, dynamic> json,
) => CulturalTreatmentGuideline(
  id: json['id'] as String,
  culture: json['culture'] as String,
  condition: json['condition'] as String,
  preferredApproaches: (json['preferredApproaches'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  avoidedApproaches: (json['avoidedApproaches'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  culturalConsiderations: (json['culturalConsiderations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  familyInvolvement: (json['familyInvolvement'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  communicationTips: (json['communicationTips'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalTreatmentGuidelineToJson(
  CulturalTreatmentGuideline instance,
) => <String, dynamic>{
  'id': instance.id,
  'culture': instance.culture,
  'condition': instance.condition,
  'preferredApproaches': instance.preferredApproaches,
  'avoidedApproaches': instance.avoidedApproaches,
  'culturalConsiderations': instance.culturalConsiderations,
  'familyInvolvement': instance.familyInvolvement,
  'communicationTips': instance.communicationTips,
  'metadata': instance.metadata,
};

CulturalCommunicationGuide _$CulturalCommunicationGuideFromJson(
  Map<String, dynamic> json,
) => CulturalCommunicationGuide(
  id: json['id'] as String,
  culture: json['culture'] as String,
  language: json['language'] as String,
  greetingCustoms: (json['greetingCustoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  communicationStyles: (json['communicationStyles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tabooTopics: (json['tabooTopics'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  respectfulTerms: (json['respectfulTerms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  nonverbalCues: (json['nonverbalCues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalCommunicationGuideToJson(
  CulturalCommunicationGuide instance,
) => <String, dynamic>{
  'id': instance.id,
  'culture': instance.culture,
  'language': instance.language,
  'greetingCustoms': instance.greetingCustoms,
  'communicationStyles': instance.communicationStyles,
  'tabooTopics': instance.tabooTopics,
  'respectfulTerms': instance.respectfulTerms,
  'nonverbalCues': instance.nonverbalCues,
  'metadata': instance.metadata,
};

CulturalHealthBelief _$CulturalHealthBeliefFromJson(
  Map<String, dynamic> json,
) => CulturalHealthBelief(
  id: json['id'] as String,
  culture: json['culture'] as String,
  belief: json['belief'] as String,
  description: json['description'] as String,
  impactOnTreatment: json['impactOnTreatment'] as String,
  alternativePractices: (json['alternativePractices'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  integrationStrategies: (json['integrationStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalHealthBeliefToJson(
  CulturalHealthBelief instance,
) => <String, dynamic>{
  'id': instance.id,
  'culture': instance.culture,
  'belief': instance.belief,
  'description': instance.description,
  'impactOnTreatment': instance.impactOnTreatment,
  'alternativePractices': instance.alternativePractices,
  'integrationStrategies': instance.integrationStrategies,
  'metadata': instance.metadata,
};

CulturalCompetencyTraining _$CulturalCompetencyTrainingFromJson(
  Map<String, dynamic> json,
) => CulturalCompetencyTraining(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  targetCultures: (json['targetCultures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  learningObjectives: (json['learningObjectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  modules: (json['modules'] as List<dynamic>).map((e) => e as String).toList(),
  estimatedDuration: (json['estimatedDuration'] as num).toInt(),
  difficulty: json['difficulty'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalCompetencyTrainingToJson(
  CulturalCompetencyTraining instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'targetCultures': instance.targetCultures,
  'learningObjectives': instance.learningObjectives,
  'modules': instance.modules,
  'estimatedDuration': instance.estimatedDuration,
  'difficulty': instance.difficulty,
  'metadata': instance.metadata,
};

CulturalCompetencyMetrics _$CulturalCompetencyMetricsFromJson(
  Map<String, dynamic> json,
) => CulturalCompetencyMetrics(
  id: json['id'] as String,
  clinicianId: json['clinicianId'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  overallScore: (json['overallScore'] as num).toDouble(),
  cultureScores: (json['cultureScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  dimensionScores: (json['dimensionScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  completedTrainings: (json['completedTrainings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pendingTrainings: (json['pendingTrainings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalCompetencyMetricsToJson(
  CulturalCompetencyMetrics instance,
) => <String, dynamic>{
  'id': instance.id,
  'clinicianId': instance.clinicianId,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'overallScore': instance.overallScore,
  'cultureScores': instance.cultureScores,
  'dimensionScores': instance.dimensionScores,
  'completedTrainings': instance.completedTrainings,
  'pendingTrainings': instance.pendingTrainings,
  'metadata': instance.metadata,
};

CulturalCompetencyReport _$CulturalCompetencyReportFromJson(
  Map<String, dynamic> json,
) => CulturalCompetencyReport(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  reportDate: DateTime.parse(json['reportDate'] as String),
  patientCulturalProfile: CulturalProfile.fromJson(
    json['patientCulturalProfile'] as Map<String, dynamic>,
  ),
  assessment: CulturalCompetencyAssessment.fromJson(
    json['assessment'] as Map<String, dynamic>,
  ),
  treatmentGuidelines: (json['treatmentGuidelines'] as List<dynamic>)
      .map(
        (e) => CulturalTreatmentGuideline.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  communicationGuides: (json['communicationGuides'] as List<dynamic>)
      .map(
        (e) => CulturalCommunicationGuide.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map(
        (e) => CulturalCompetencyRecommendation.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  insights: json['insights'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CulturalCompetencyReportToJson(
  CulturalCompetencyReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'reportDate': instance.reportDate.toIso8601String(),
  'patientCulturalProfile': instance.patientCulturalProfile,
  'assessment': instance.assessment,
  'treatmentGuidelines': instance.treatmentGuidelines,
  'communicationGuides': instance.communicationGuides,
  'recommendations': instance.recommendations,
  'insights': instance.insights,
  'metadata': instance.metadata,
};
