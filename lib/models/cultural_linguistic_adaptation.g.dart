// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cultural_linguistic_adaptation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CulturalLinguisticAdaptation _$CulturalLinguisticAdaptationFromJson(
  Map<String, dynamic> json,
) => CulturalLinguisticAdaptation(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  version: json['version'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  culturalFeatures: json['culturalFeatures'] as Map<String, dynamic>,
  linguisticFeatures: json['linguisticFeatures'] as Map<String, dynamic>,
  adaptationFeatures: json['adaptationFeatures'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalLinguisticAdaptationToJson(
  CulturalLinguisticAdaptation instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'version': instance.version,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'culturalFeatures': instance.culturalFeatures,
  'linguisticFeatures': instance.linguisticFeatures,
  'adaptationFeatures': instance.adaptationFeatures,
  'metadata': instance.metadata,
};

MultiLanguageSupport _$MultiLanguageSupportFromJson(
  Map<String, dynamic> json,
) => MultiLanguageSupport(
  id: json['id'] as String,
  languageCode: json['languageCode'] as String,
  languageName: json['languageName'] as String,
  nativeName: json['nativeName'] as String,
  region: json['region'] as String,
  script: json['script'] as String,
  isRTL: json['isRTL'] as bool,
  status: json['status'] as String,
  translationCompleteness: (json['translationCompleteness'] as num).toDouble(),
  translations: Map<String, String>.from(json['translations'] as Map),
  culturalAdaptations: Map<String, String>.from(
    json['culturalAdaptations'] as Map,
  ),
  regionalVariations: (json['regionalVariations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dialects: (json['dialects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MultiLanguageSupportToJson(
  MultiLanguageSupport instance,
) => <String, dynamic>{
  'id': instance.id,
  'languageCode': instance.languageCode,
  'languageName': instance.languageName,
  'nativeName': instance.nativeName,
  'region': instance.region,
  'script': instance.script,
  'isRTL': instance.isRTL,
  'status': instance.status,
  'translationCompleteness': instance.translationCompleteness,
  'translations': instance.translations,
  'culturalAdaptations': instance.culturalAdaptations,
  'regionalVariations': instance.regionalVariations,
  'dialects': instance.dialects,
  'metadata': instance.metadata,
};

CulturalNormsIntegration _$CulturalNormsIntegrationFromJson(
  Map<String, dynamic> json,
) => CulturalNormsIntegration(
  id: json['id'] as String,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  culture: json['culture'] as String,
  socialNorms: json['socialNorms'] as Map<String, dynamic>,
  familyStructures: json['familyStructures'] as Map<String, dynamic>,
  communicationStyles: json['communicationStyles'] as Map<String, dynamic>,
  religiousPractices: json['religiousPractices'] as Map<String, dynamic>,
  traditionalMedicine: json['traditionalMedicine'] as Map<String, dynamic>,
  healthBeliefs: json['healthBeliefs'] as Map<String, dynamic>,
  taboos: (json['taboos'] as List<dynamic>).map((e) => e as String).toList(),
  culturalValues: (json['culturalValues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalNormsIntegrationToJson(
  CulturalNormsIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'culture': instance.culture,
  'socialNorms': instance.socialNorms,
  'familyStructures': instance.familyStructures,
  'communicationStyles': instance.communicationStyles,
  'religiousPractices': instance.religiousPractices,
  'traditionalMedicine': instance.traditionalMedicine,
  'healthBeliefs': instance.healthBeliefs,
  'taboos': instance.taboos,
  'culturalValues': instance.culturalValues,
  'metadata': instance.metadata,
};

LocalTherapeuticApproaches _$LocalTherapeuticApproachesFromJson(
  Map<String, dynamic> json,
) => LocalTherapeuticApproaches(
  id: json['id'] as String,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  approachName: json['approachName'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  techniques: (json['techniques'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  principles: (json['principles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  applications: (json['applications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  evidenceLevel: (json['evidenceLevel'] as num).toDouble(),
  culturalContext: (json['culturalContext'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$LocalTherapeuticApproachesToJson(
  LocalTherapeuticApproaches instance,
) => <String, dynamic>{
  'id': instance.id,
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'approachName': instance.approachName,
  'description': instance.description,
  'category': instance.category,
  'techniques': instance.techniques,
  'principles': instance.principles,
  'applications': instance.applications,
  'evidenceLevel': instance.evidenceLevel,
  'culturalContext': instance.culturalContext,
  'contraindications': instance.contraindications,
  'metadata': instance.metadata,
};

ReligiousConsiderations _$ReligiousConsiderationsFromJson(
  Map<String, dynamic> json,
) => ReligiousConsiderations(
  id: json['id'] as String,
  religion: json['religion'] as String,
  denomination: json['denomination'] as String,
  region: json['region'] as String,
  beliefs: json['beliefs'] as Map<String, dynamic>,
  practices: json['practices'] as Map<String, dynamic>,
  healthGuidelines: (json['healthGuidelines'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  treatmentPreferences: (json['treatmentPreferences'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  culturalContext: json['culturalContext'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ReligiousConsiderationsToJson(
  ReligiousConsiderations instance,
) => <String, dynamic>{
  'id': instance.id,
  'religion': instance.religion,
  'denomination': instance.denomination,
  'region': instance.region,
  'beliefs': instance.beliefs,
  'practices': instance.practices,
  'healthGuidelines': instance.healthGuidelines,
  'dietaryRestrictions': instance.dietaryRestrictions,
  'treatmentPreferences': instance.treatmentPreferences,
  'contraindications': instance.contraindications,
  'culturalContext': instance.culturalContext,
  'metadata': instance.metadata,
};

CulturalSensitivityTraining _$CulturalSensitivityTrainingFromJson(
  Map<String, dynamic> json,
) => CulturalSensitivityTraining(
  id: json['id'] as String,
  trainingName: json['trainingName'] as String,
  description: json['description'] as String,
  targetAudience: json['targetAudience'] as String,
  learningObjectives: (json['learningObjectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  culturalTopics: (json['culturalTopics'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  caseStudies: (json['caseStudies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assessmentMethods: (json['assessmentMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  durationHours: (json['durationHours'] as num).toInt(),
  format: json['format'] as String,
  completionRate: (json['completionRate'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalSensitivityTrainingToJson(
  CulturalSensitivityTraining instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainingName': instance.trainingName,
  'description': instance.description,
  'targetAudience': instance.targetAudience,
  'learningObjectives': instance.learningObjectives,
  'culturalTopics': instance.culturalTopics,
  'caseStudies': instance.caseStudies,
  'assessmentMethods': instance.assessmentMethods,
  'durationHours': instance.durationHours,
  'format': instance.format,
  'completionRate': instance.completionRate,
  'metadata': instance.metadata,
};

CulturalCompatibilityAssessment _$CulturalCompatibilityAssessmentFromJson(
  Map<String, dynamic> json,
) => CulturalCompatibilityAssessment(
  id: json['id'] as String,
  assessmentName: json['assessmentName'] as String,
  description: json['description'] as String,
  targetCulture: json['targetCulture'] as String,
  assessmentAreas: (json['assessmentAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  evaluationCriteria: (json['evaluationCriteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assessmentResults: json['assessmentResults'] as Map<String, dynamic>,
  compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
  strengths: (json['strengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  weaknesses: (json['weaknesses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalCompatibilityAssessmentToJson(
  CulturalCompatibilityAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'assessmentName': instance.assessmentName,
  'description': instance.description,
  'targetCulture': instance.targetCulture,
  'assessmentAreas': instance.assessmentAreas,
  'evaluationCriteria': instance.evaluationCriteria,
  'assessmentResults': instance.assessmentResults,
  'compatibilityScore': instance.compatibilityScore,
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};

MultilingualCommunication _$MultilingualCommunicationFromJson(
  Map<String, dynamic> json,
) => MultilingualCommunication(
  id: json['id'] as String,
  communicationType: json['communicationType'] as String,
  sourceLanguage: json['sourceLanguage'] as String,
  targetLanguage: json['targetLanguage'] as String,
  content: json['content'] as String,
  translatedContent: json['translatedContent'] as String,
  translationQuality: (json['translationQuality'] as num).toDouble(),
  culturalAdaptations: (json['culturalAdaptations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contextNotes: (json['contextNotes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MultilingualCommunicationToJson(
  MultilingualCommunication instance,
) => <String, dynamic>{
  'id': instance.id,
  'communicationType': instance.communicationType,
  'sourceLanguage': instance.sourceLanguage,
  'targetLanguage': instance.targetLanguage,
  'content': instance.content,
  'translatedContent': instance.translatedContent,
  'translationQuality': instance.translationQuality,
  'culturalAdaptations': instance.culturalAdaptations,
  'contextNotes': instance.contextNotes,
  'metadata': instance.metadata,
};

CulturalContentManagement _$CulturalContentManagementFromJson(
  Map<String, dynamic> json,
) => CulturalContentManagement(
  id: json['id'] as String,
  contentId: json['contentId'] as String,
  contentType: json['contentType'] as String,
  originalContent: json['originalContent'] as String,
  localizedContent: Map<String, String>.from(json['localizedContent'] as Map),
  culturalContext: json['culturalContext'] as Map<String, dynamic>,
  culturalNotes: (json['culturalNotes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  adaptationGuidelines: (json['adaptationGuidelines'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  reviewStatus: json['reviewStatus'] as String,
  lastReviewed: DateTime.parse(json['lastReviewed'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalContentManagementToJson(
  CulturalContentManagement instance,
) => <String, dynamic>{
  'id': instance.id,
  'contentId': instance.contentId,
  'contentType': instance.contentType,
  'originalContent': instance.originalContent,
  'localizedContent': instance.localizedContent,
  'culturalContext': instance.culturalContext,
  'culturalNotes': instance.culturalNotes,
  'adaptationGuidelines': instance.adaptationGuidelines,
  'reviewStatus': instance.reviewStatus,
  'lastReviewed': instance.lastReviewed.toIso8601String(),
  'metadata': instance.metadata,
};

CulturalDataAnalysis _$CulturalDataAnalysisFromJson(
  Map<String, dynamic> json,
) => CulturalDataAnalysis(
  id: json['id'] as String,
  analysisName: json['analysisName'] as String,
  description: json['description'] as String,
  targetCulture: json['targetCulture'] as String,
  dataSources: (json['dataSources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  analysisMethods: (json['analysisMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  analysisResults: json['analysisResults'] as Map<String, dynamic>,
  insights: (json['insights'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalDataAnalysisToJson(
  CulturalDataAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'analysisName': instance.analysisName,
  'description': instance.description,
  'targetCulture': instance.targetCulture,
  'dataSources': instance.dataSources,
  'analysisMethods': instance.analysisMethods,
  'analysisResults': instance.analysisResults,
  'insights': instance.insights,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};

CulturalPerformanceMetrics _$CulturalPerformanceMetricsFromJson(
  Map<String, dynamic> json,
) => CulturalPerformanceMetrics(
  id: json['id'] as String,
  metricName: json['metricName'] as String,
  description: json['description'] as String,
  targetCulture: json['targetCulture'] as String,
  currentValue: (json['currentValue'] as num).toDouble(),
  targetValue: (json['targetValue'] as num).toDouble(),
  unit: json['unit'] as String,
  measurementDate: DateTime.parse(json['measurementDate'] as String),
  factors: (json['factors'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalPerformanceMetricsToJson(
  CulturalPerformanceMetrics instance,
) => <String, dynamic>{
  'id': instance.id,
  'metricName': instance.metricName,
  'description': instance.description,
  'targetCulture': instance.targetCulture,
  'currentValue': instance.currentValue,
  'targetValue': instance.targetValue,
  'unit': instance.unit,
  'measurementDate': instance.measurementDate.toIso8601String(),
  'factors': instance.factors,
  'metadata': instance.metadata,
};

CulturalQualityControl _$CulturalQualityControlFromJson(
  Map<String, dynamic> json,
) => CulturalQualityControl(
  id: json['id'] as String,
  qualityCheckName: json['qualityCheckName'] as String,
  description: json['description'] as String,
  targetCulture: json['targetCulture'] as String,
  qualityCriteria: (json['qualityCriteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  checkMethods: (json['checkMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  checkResults: json['checkResults'] as Map<String, dynamic>,
  qualityStatus: json['qualityStatus'] as String,
  issues: (json['issues'] as List<dynamic>).map((e) => e as String).toList(),
  correctiveActions: (json['correctiveActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalQualityControlToJson(
  CulturalQualityControl instance,
) => <String, dynamic>{
  'id': instance.id,
  'qualityCheckName': instance.qualityCheckName,
  'description': instance.description,
  'targetCulture': instance.targetCulture,
  'qualityCriteria': instance.qualityCriteria,
  'checkMethods': instance.checkMethods,
  'checkResults': instance.checkResults,
  'qualityStatus': instance.qualityStatus,
  'issues': instance.issues,
  'correctiveActions': instance.correctiveActions,
  'metadata': instance.metadata,
};

CulturalContinuousImprovement _$CulturalContinuousImprovementFromJson(
  Map<String, dynamic> json,
) => CulturalContinuousImprovement(
  id: json['id'] as String,
  improvementName: json['improvementName'] as String,
  description: json['description'] as String,
  targetCulture: json['targetCulture'] as String,
  improvementAreas: (json['improvementAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  improvementActions: (json['improvementActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  improvementResults: json['improvementResults'] as Map<String, dynamic>,
  improvementScore: (json['improvementScore'] as num).toDouble(),
  lessonsLearned: (json['lessonsLearned'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  nextSteps: (json['nextSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalContinuousImprovementToJson(
  CulturalContinuousImprovement instance,
) => <String, dynamic>{
  'id': instance.id,
  'improvementName': instance.improvementName,
  'description': instance.description,
  'targetCulture': instance.targetCulture,
  'improvementAreas': instance.improvementAreas,
  'improvementActions': instance.improvementActions,
  'improvementResults': instance.improvementResults,
  'improvementScore': instance.improvementScore,
  'lessonsLearned': instance.lessonsLearned,
  'nextSteps': instance.nextSteps,
  'metadata': instance.metadata,
};

CulturalInnovation _$CulturalInnovationFromJson(Map<String, dynamic> json) =>
    CulturalInnovation(
      id: json['id'] as String,
      innovationName: json['innovationName'] as String,
      description: json['description'] as String,
      targetCulture: json['targetCulture'] as String,
      innovationAreas: (json['innovationAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      innovationMethods: (json['innovationMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      innovationResults: json['innovationResults'] as Map<String, dynamic>,
      innovationImpact: (json['innovationImpact'] as num).toDouble(),
      successFactors: (json['successFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CulturalInnovationToJson(CulturalInnovation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'innovationName': instance.innovationName,
      'description': instance.description,
      'targetCulture': instance.targetCulture,
      'innovationAreas': instance.innovationAreas,
      'innovationMethods': instance.innovationMethods,
      'innovationResults': instance.innovationResults,
      'innovationImpact': instance.innovationImpact,
      'successFactors': instance.successFactors,
      'challenges': instance.challenges,
      'metadata': instance.metadata,
    };
