import 'package:json_annotation/json_annotation.dart';

part 'cultural_competency_models.g.dart';

@JsonSerializable()
class CulturalProfile {
  final String id;
  final String patientId;
  final String primaryCulture;
  final List<String> culturalBackgrounds;
  final String language;
  final String religion;
  final String ethnicity;
  final String nationality;
  final Map<String, dynamic> culturalValues;
  final Map<String, dynamic> communicationPreferences;
  final Map<String, dynamic> healthBeliefs;
  final Map<String, dynamic> familyStructure;
  final Map<String, dynamic> socialContext;
  final Map<String, dynamic> metadata;

  const CulturalProfile({
    required this.id,
    required this.patientId,
    required this.primaryCulture,
    required this.culturalBackgrounds,
    required this.language,
    required this.religion,
    required this.ethnicity,
    required this.nationality,
    this.culturalValues = const {},
    this.communicationPreferences = const {},
    this.healthBeliefs = const {},
    this.familyStructure = const {},
    this.socialContext = const {},
    this.metadata = const {},
  });

  factory CulturalProfile.fromJson(Map<String, dynamic> json) => _$CulturalProfileFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalProfileToJson(this);
}

@JsonSerializable()
class CulturalCompetencyAssessment {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime assessmentDate;
  final double culturalSensitivityScore;
  final double communicationEffectivenessScore;
  final double treatmentCulturalFitScore;
  final List<CulturalCompetencyDimension> dimensions;
  final List<CulturalCompetencyRecommendation> recommendations;
  final Map<String, dynamic> metadata;

  const CulturalCompetencyAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.assessmentDate,
    required this.culturalSensitivityScore,
    required this.communicationEffectivenessScore,
    required this.treatmentCulturalFitScore,
    required this.dimensions,
    required this.recommendations,
    this.metadata = const {},
  });

  factory CulturalCompetencyAssessment.fromJson(Map<String, dynamic> json) => _$CulturalCompetencyAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalCompetencyAssessmentToJson(this);
}

@JsonSerializable()
class CulturalCompetencyDimension {
  final String dimension;
  final double score;
  final String description;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final Map<String, dynamic> metadata;

  const CulturalCompetencyDimension({
    required this.dimension,
    required this.score,
    required this.description,
    required this.strengths,
    required this.areasForImprovement,
    this.metadata = const {},
  });

  factory CulturalCompetencyDimension.fromJson(Map<String, dynamic> json) => _$CulturalCompetencyDimensionFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalCompetencyDimensionToJson(this);
}

@JsonSerializable()
class CulturalCompetencyRecommendation {
  final String id;
  final String category;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final List<String> actions;
  final List<String> resources;
  final Map<String, dynamic> metadata;

  const CulturalCompetencyRecommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    required this.actions,
    required this.resources,
    this.metadata = const {},
  });

  factory CulturalCompetencyRecommendation.fromJson(Map<String, dynamic> json) => _$CulturalCompetencyRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalCompetencyRecommendationToJson(this);
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical
}

@JsonSerializable()
class CulturalTreatmentGuideline {
  final String id;
  final String culture;
  final String condition;
  final List<String> preferredApproaches;
  final List<String> avoidedApproaches;
  final List<String> culturalConsiderations;
  final List<String> familyInvolvement;
  final List<String> communicationTips;
  final Map<String, dynamic> metadata;

  const CulturalTreatmentGuideline({
    required this.id,
    required this.culture,
    required this.condition,
    required this.preferredApproaches,
    required this.avoidedApproaches,
    required this.culturalConsiderations,
    required this.familyInvolvement,
    required this.communicationTips,
    this.metadata = const {},
  });

  factory CulturalTreatmentGuideline.fromJson(Map<String, dynamic> json) => _$CulturalTreatmentGuidelineFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalTreatmentGuidelineToJson(this);
}

@JsonSerializable()
class CulturalCommunicationGuide {
  final String id;
  final String culture;
  final String language;
  final List<String> greetingCustoms;
  final List<String> communicationStyles;
  final List<String> tabooTopics;
  final List<String> respectfulTerms;
  final List<String> nonverbalCues;
  final Map<String, dynamic> metadata;

  const CulturalCommunicationGuide({
    required this.id,
    required this.culture,
    required this.language,
    required this.greetingCustoms,
    required this.communicationStyles,
    required this.tabooTopics,
    required this.respectfulTerms,
    required this.nonverbalCues,
    this.metadata = const {},
  });

  factory CulturalCommunicationGuide.fromJson(Map<String, dynamic> json) => _$CulturalCommunicationGuideFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalCommunicationGuideToJson(this);
}

@JsonSerializable()
class CulturalHealthBelief {
  final String id;
  final String culture;
  final String belief;
  final String description;
  final String impactOnTreatment;
  final List<String> alternativePractices;
  final List<String> integrationStrategies;
  final Map<String, dynamic> metadata;

  const CulturalHealthBelief({
    required this.id,
    required this.culture,
    required this.belief,
    required this.description,
    required this.impactOnTreatment,
    required this.alternativePractices,
    required this.integrationStrategies,
    this.metadata = const {},
  });

  factory CulturalHealthBelief.fromJson(Map<String, dynamic> json) => _$CulturalHealthBeliefFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalHealthBeliefToJson(this);
}

@JsonSerializable()
class CulturalCompetencyTraining {
  final String id;
  final String title;
  final String description;
  final List<String> targetCultures;
  final List<String> learningObjectives;
  final List<String> modules;
  final int estimatedDuration;
  final String difficulty;
  final Map<String, dynamic> metadata;

  const CulturalCompetencyTraining({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCultures,
    required this.learningObjectives,
    required this.modules,
    required this.estimatedDuration,
    required this.difficulty,
    this.metadata = const {},
  });

  factory CulturalCompetencyTraining.fromJson(Map<String, dynamic> json) => _$CulturalCompetencyTrainingFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalCompetencyTrainingToJson(this);
}

@JsonSerializable()
class CulturalCompetencyMetrics {
  final String id;
  final String clinicianId;
  final DateTime assessmentDate;
  final double overallScore;
  final Map<String, double> cultureScores;
  final Map<String, double> dimensionScores;
  final List<String> completedTrainings;
  final List<String> pendingTrainings;
  final Map<String, dynamic> metadata;

  const CulturalCompetencyMetrics({
    required this.id,
    required this.clinicianId,
    required this.assessmentDate,
    required this.overallScore,
    required this.cultureScores,
    required this.dimensionScores,
    required this.completedTrainings,
    required this.pendingTrainings,
    this.metadata = const {},
  });

  factory CulturalCompetencyMetrics.fromJson(Map<String, dynamic> json) => _$CulturalCompetencyMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalCompetencyMetricsToJson(this);
}

@JsonSerializable()
class CulturalCompetencyReport {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime reportDate;
  final CulturalProfile patientCulturalProfile;
  final CulturalCompetencyAssessment assessment;
  final List<CulturalTreatmentGuideline> treatmentGuidelines;
  final List<CulturalCommunicationGuide> communicationGuides;
  final List<CulturalCompetencyRecommendation> recommendations;
  final Map<String, dynamic> insights;
  final Map<String, dynamic> metadata;

  const CulturalCompetencyReport({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.reportDate,
    required this.patientCulturalProfile,
    required this.assessment,
    required this.treatmentGuidelines,
    required this.communicationGuides,
    required this.recommendations,
    required this.insights,
    this.metadata = const {},
  });

  factory CulturalCompetencyReport.fromJson(Map<String, dynamic> json) => _$CulturalCompetencyReportFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalCompetencyReportToJson(this);
}
