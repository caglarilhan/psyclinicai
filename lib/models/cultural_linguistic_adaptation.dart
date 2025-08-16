import 'package:json_annotation/json_annotation.dart';

part 'cultural_linguistic_adaptation.g.dart';

// Kültürel ve Dilsel Adaptasyon
@JsonSerializable()
class CulturalLinguisticAdaptation {
  final String id;
  final String name;
  final String description;
  final String version;
  final DateTime lastUpdated;
  final String status;
  final Map<String, dynamic> culturalFeatures;
  final Map<String, dynamic> linguisticFeatures;
  final Map<String, dynamic> adaptationFeatures;
  final Map<String, dynamic> metadata;

  CulturalLinguisticAdaptation({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.lastUpdated,
    required this.status,
    required this.culturalFeatures,
    required this.linguisticFeatures,
    required this.adaptationFeatures,
    required this.metadata,
  });

  factory CulturalLinguisticAdaptation.fromJson(Map<String, dynamic> json) =>
      _$CulturalLinguisticAdaptationFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalLinguisticAdaptationToJson(this);
}

// 100+ Dil Desteği
@JsonSerializable()
class MultiLanguageSupport {
  final String id;
  final String languageCode; // ISO 639-1
  final String languageName;
  final String nativeName;
  final String region;
  final String script;
  final bool isRTL; // Right-to-left text
  final String status; // active, beta, planned
  final double translationCompleteness; // 0.0 - 1.0
  final Map<String, String> translations;
  final Map<String, String> culturalAdaptations;
  final List<String> regionalVariations;
  final List<String> dialects;
  final Map<String, dynamic> metadata;

  MultiLanguageSupport({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.region,
    required this.script,
    required this.isRTL,
    required this.status,
    required this.translationCompleteness,
    required this.translations,
    required this.culturalAdaptations,
    required this.regionalVariations,
    required this.dialects,
    required this.metadata,
  });

  factory MultiLanguageSupport.fromJson(Map<String, dynamic> json) =>
      _$MultiLanguageSupportFromJson(json);

  Map<String, dynamic> toJson() => _$MultiLanguageSupportToJson(this);
}

// Kültürel Norm Entegrasyonu
@JsonSerializable()
class CulturalNormsIntegration {
  final String id;
  final String countryCode;
  final String countryName;
  final String culture;
  final Map<String, dynamic> socialNorms;
  final Map<String, dynamic> familyStructures;
  final Map<String, dynamic> communicationStyles;
  final Map<String, dynamic> religiousPractices;
  final Map<String, dynamic> traditionalMedicine;
  final Map<String, dynamic> healthBeliefs;
  final List<String> taboos;
  final List<String> culturalValues;
  final Map<String, dynamic> metadata;

  CulturalNormsIntegration({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.culture,
    required this.socialNorms,
    required this.familyStructures,
    required this.communicationStyles,
    required this.religiousPractices,
    required this.traditionalMedicine,
    required this.healthBeliefs,
    required this.taboos,
    required this.culturalValues,
    required this.metadata,
  });

  factory CulturalNormsIntegration.fromJson(Map<String, dynamic> json) =>
      _$CulturalNormsIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalNormsIntegrationToJson(this);
}

// Yerel Terapi Yaklaşımları
@JsonSerializable()
class LocalTherapeuticApproaches {
  final String id;
  final String countryCode;
  final String countryName;
  final String approachName;
  final String description;
  final String category;
  final List<String> techniques;
  final List<String> principles;
  final List<String> applications;
  final double evidenceLevel; // 0.0 - 1.0
  final List<String> culturalContext;
  final List<String> contraindications;
  final Map<String, dynamic> metadata;

  LocalTherapeuticApproaches({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.approachName,
    required this.description,
    required this.category,
    required this.techniques,
    required this.principles,
    required this.applications,
    required this.evidenceLevel,
    required this.culturalContext,
    required this.contraindications,
    required this.metadata,
  });

  factory LocalTherapeuticApproaches.fromJson(Map<String, dynamic> json) =>
      _$LocalTherapeuticApproachesFromJson(json);

  Map<String, dynamic> toJson() => _$LocalTherapeuticApproachesToJson(this);
}

// Dini Düşünceler
@JsonSerializable()
class ReligiousConsiderations {
  final String id;
  final String religion;
  final String denomination;
  final String region;
  final Map<String, dynamic> beliefs;
  final Map<String, dynamic> practices;
  final List<String> healthGuidelines;
  final List<String> dietaryRestrictions;
  final List<String> treatmentPreferences;
  final List<String> contraindications;
  final Map<String, dynamic> culturalContext;
  final Map<String, dynamic> metadata;

  ReligiousConsiderations({
    required this.id,
    required this.religion,
    required this.denomination,
    required this.region,
    required this.beliefs,
    required this.practices,
    required this.healthGuidelines,
    required this.dietaryRestrictions,
    required this.treatmentPreferences,
    required this.contraindications,
    required this.culturalContext,
    required this.metadata,
  });

  factory ReligiousConsiderations.fromJson(Map<String, dynamic> json) =>
      _$ReligiousConsiderationsFromJson(json);

  Map<String, dynamic> toJson() => _$ReligiousConsiderationsToJson(this);
}

// Kültürel Duyarlılık Eğitimi
@JsonSerializable()
class CulturalSensitivityTraining {
  final String id;
  final String trainingName;
  final String description;
  final String targetAudience;
  final List<String> learningObjectives;
  final List<String> culturalTopics;
  final List<String> caseStudies;
  final List<String> assessmentMethods;
  final int durationHours;
  final String format; // online, in_person, hybrid
  final double completionRate;
  final Map<String, dynamic> metadata;

  CulturalSensitivityTraining({
    required this.id,
    required this.trainingName,
    required this.description,
    required this.targetAudience,
    required this.learningObjectives,
    required this.culturalTopics,
    required this.caseStudies,
    required this.assessmentMethods,
    required this.durationHours,
    required this.format,
    required this.completionRate,
    required this.metadata,
  });

  factory CulturalSensitivityTraining.fromJson(Map<String, dynamic> json) =>
      _$CulturalSensitivityTrainingFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalSensitivityTrainingToJson(this);
}

// Kültürel Uyumluluk Değerlendirmesi
@JsonSerializable()
class CulturalCompatibilityAssessment {
  final String id;
  final String assessmentName;
  final String description;
  final String targetCulture;
  final List<String> assessmentAreas;
  final List<String> evaluationCriteria;
  final Map<String, dynamic> assessmentResults;
  final double compatibilityScore; // 0.0 - 1.0
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  CulturalCompatibilityAssessment({
    required this.id,
    required this.assessmentName,
    required this.description,
    required this.targetCulture,
    required this.assessmentAreas,
    required this.evaluationCriteria,
    required this.assessmentResults,
    required this.compatibilityScore,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.metadata,
  });

  factory CulturalCompatibilityAssessment.fromJson(Map<String, dynamic> json) =>
      _$CulturalCompatibilityAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalCompatibilityAssessmentFromJson(this);
}

// Çok Dilli İletişim
@JsonSerializable()
class MultilingualCommunication {
  final String id;
  final String communicationType;
  final String sourceLanguage;
  final String targetLanguage;
  final String content;
  final String translatedContent;
  final double translationQuality; // 0.0 - 1.0
  final List<String> culturalAdaptations;
  final List<String> contextNotes;
  final Map<String, dynamic> metadata;

  MultilingualCommunication({
    required this.id,
    required this.communicationType,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.content,
    required this.translatedContent,
    required this.translationQuality,
    required this.culturalAdaptations,
    required this.contextNotes,
    required this.metadata,
  });

  factory MultilingualCommunication.fromJson(Map<String, dynamic> json) =>
      _$MultilingualCommunicationFromJson(json);

  Map<String, dynamic> toJson() => _$MultilingualCommunicationFromJson(this);
}

// Kültürel İçerik Yönetimi
@JsonSerializable()
class CulturalContentManagement {
  final String id;
  final String contentId;
  final String contentType;
  final String originalContent;
  final Map<String, String> localizedContent;
  final Map<String, dynamic> culturalContext;
  final List<String> culturalNotes;
  final List<String> adaptationGuidelines;
  final String reviewStatus;
  final DateTime lastReviewed;
  final Map<String, dynamic> metadata;

  CulturalContentManagement({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.originalContent,
    required this.localizedContent,
    required this.culturalContext,
    required this.culturalNotes,
    required this.adaptationGuidelines,
    required this.reviewStatus,
    required this.lastReviewed,
    required this.metadata,
  });

  factory CulturalContentManagement.fromJson(Map<String, dynamic> json) =>
      _$CulturalContentManagementFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalContentManagementFromJson(this);
}

// Kültürel Veri Analizi
@JsonSerializable()
class CulturalDataAnalysis {
  final String id;
  final String analysisName;
  final String description;
  final String targetCulture;
  final List<String> dataSources;
  final List<String> analysisMethods;
  final Map<String, dynamic> analysisResults;
  final List<String> insights;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  CulturalDataAnalysis({
    required this.id,
    required this.analysisName,
    required this.description,
    required this.targetCulture,
    required this.dataSources,
    required this.analysisMethods,
    required this.analysisResults,
    required this.insights,
    required this.recommendations,
    required this.metadata,
  });

  factory CulturalDataAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CulturalDataAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalDataAnalysisFromJson(this);
}

// Kültürel Performans Metrikleri
@JsonSerializable()
class CulturalPerformanceMetrics {
  final String id;
  final String metricName;
  final String description;
  final String targetCulture;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime measurementDate;
  final List<String> factors;
  final Map<String, dynamic> metadata;

  CulturalPerformanceMetrics({
    required this.id,
    required this.metricName,
    required this.description,
    required this.targetCulture,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.measurementDate,
    required this.factors,
    required this.metadata,
  });

  factory CulturalPerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$CulturalPerformanceMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalPerformanceMetricsFromJson(this);
}

// Kültürel Kalite Kontrolü
@JsonSerializable()
class CulturalQualityControl {
  final String id;
  final String qualityCheckName;
  final String description;
  final String targetCulture;
  final List<String> qualityCriteria;
  final List<String> checkMethods;
  final Map<String, dynamic> checkResults;
  final String qualityStatus;
  final List<String> issues;
  final List<String> correctiveActions;
  final Map<String, dynamic> metadata;

  CulturalQualityControl({
    required this.id,
    required this.qualityCheckName,
    required this.description,
    required this.targetCulture,
    required this.qualityCriteria,
    required this.checkMethods,
    required this.checkResults,
    required this.qualityStatus,
    required this.issues,
    required this.correctiveActions,
    required this.metadata,
  });

  factory CulturalQualityControl.fromJson(Map<String, dynamic> json) =>
      _$CulturalQualityControlFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalQualityControlFromJson(this);
}

// Kültürel Sürekli İyileştirme
@JsonSerializable()
class CulturalContinuousImprovement {
  final String id;
  final String improvementName;
  final String description;
  final String targetCulture;
  final List<String> improvementAreas;
  final List<String> improvementActions;
  final Map<String, dynamic> improvementResults;
  final double improvementScore; // 0.0 - 1.0
  final List<String> lessonsLearned;
  final List<String> nextSteps;
  final Map<String, dynamic> metadata;

  CulturalContinuousImprovement({
    required this.id,
    required this.improvementName,
    required this.description,
    required this.targetCulture,
    required this.improvementAreas,
    required this.improvementActions,
    required this.improvementResults,
    required this.improvementScore,
    required this.lessonsLearned,
    required this.nextSteps,
    required this.metadata,
  });

  factory CulturalContinuousImprovement.fromJson(Map<String, dynamic> json) =>
      _$CulturalContinuousImprovementFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalContinuousImprovementFromJson(this);
}

// Kültürel İnovasyon
@JsonSerializable()
class CulturalInnovation {
  final String id;
  final String innovationName;
  final String description;
  final String targetCulture;
  final List<String> innovationAreas;
  final List<String> innovationMethods;
  final Map<String, dynamic> innovationResults;
  final double innovationImpact; // 0.0 - 1.0
  final List<String> successFactors;
  final List<String> challenges;
  final Map<String, dynamic> metadata;

  CulturalInnovation({
    required this.id,
    required this.innovationName,
    required this.description,
    required this.targetCulture,
    required this.innovationAreas,
    required this.innovationMethods,
    required this.innovationResults,
    required this.innovationImpact,
    required this.successFactors,
    required this.challenges,
    required this.metadata,
  });

  factory CulturalInnovation.fromJson(Map<String, dynamic> json) =>
      _$CulturalInnovationFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalInnovationFromJson(this);
}
