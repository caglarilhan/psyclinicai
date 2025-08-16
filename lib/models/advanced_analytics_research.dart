import 'package:json_annotation/json_annotation.dart';

part 'advanced_analytics_research.g.dart';

// Gelişmiş Analitik ve Araştırma
@JsonSerializable()
class AdvancedAnalyticsResearch {
  final String id;
  final String name;
  final String description;
  final String version;
  final DateTime lastUpdated;
  final String status;
  final Map<String, dynamic> analyticsFeatures;
  final Map<String, dynamic> researchFeatures;
  final Map<String, dynamic> metadata;

  AdvancedAnalyticsResearch({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.lastUpdated,
    required this.status,
    required this.analyticsFeatures,
    required this.researchFeatures,
    required this.metadata,
  });

  factory AdvancedAnalyticsResearch.fromJson(Map<String, dynamic> json) =>
      _$AdvancedAnalyticsResearchFromJson(json);

  Map<String, dynamic> toJson() => _$AdvancedAnalyticsResearchFromJson(this);
}

// Tahminsel Analitik
@JsonSerializable()
class PredictiveAnalytics {
  final String id;
  final String modelName;
  final String description;
  final String algorithm;
  final String modelType; // classification, regression, clustering, time_series
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final Map<String, dynamic> modelParameters;
  final List<String> features;
  final List<String> predictions;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> metadata;

  PredictiveAnalytics({
    required this.id,
    required this.modelName,
    required this.description,
    required this.algorithm,
    required this.modelType,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.modelParameters,
    required this.features,
    required this.predictions,
    required this.performanceMetrics,
    required this.metadata,
  });

  factory PredictiveAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PredictiveAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$PredictiveAnalyticsFromJson(this);
}

// Nüfus Sağlığı İçgörüleri
@JsonSerializable()
class PopulationHealthInsights {
  final String id;
  final String insightName;
  final String description;
  final String populationGroup;
  final String geographicRegion;
  final String timePeriod;
  final List<String> healthIndicators;
  final Map<String, dynamic> demographicData;
  final Map<String, dynamic> healthTrends;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  PopulationHealthInsights({
    required this.id,
    required this.insightName,
    required this.description,
    required this.populationGroup,
    required this.geographicRegion,
    required this.timePeriod,
    required this.healthIndicators,
    required this.demographicData,
    required this.healthTrends,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.recommendations,
    required this.metadata,
  });

  factory PopulationHealthInsights.fromJson(Map<String, dynamic> json) =>
      _$PopulationHealthInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$PopulationHealthInsightsFromJson(this);
}

// Tedavi Sonuç Takibi
@JsonSerializable()
class TreatmentOutcomeTracking {
  final String id;
  final String treatmentId;
  final String treatmentName;
  final String patientId;
  final String diagnosis;
  final DateTime treatmentStartDate;
  final DateTime treatmentEndDate;
  final List<String> outcomeMeasures;
  final Map<String, dynamic> baselineMeasures;
  final Map<String, dynamic> followUpMeasures;
  final double improvementScore; // 0.0 - 1.0
  final String outcomeStatus; // improved, stable, worsened
  final List<String> factors;
  final Map<String, dynamic> metadata;

  TreatmentOutcomeTracking({
    required this.id,
    required this.treatmentId,
    required this.treatmentName,
    required this.patientId,
    required this.diagnosis,
    required this.treatmentStartDate,
    required this.treatmentEndDate,
    required this.outcomeMeasures,
    required this.baselineMeasures,
    required this.followUpMeasures,
    required this.improvementScore,
    required this.outcomeStatus,
    required this.factors,
    required this.metadata,
  });

  factory TreatmentOutcomeTracking.fromJson(Map<String, dynamic> json) =>
      _$TreatmentOutcomeTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentOutcomeTrackingFromJson(this);
}

// Araştırma İşbirliği
@JsonSerializable()
class ResearchCollaboration {
  final String id;
  final String projectName;
  final String description;
  final List<String> collaborators;
  final List<String> institutions;
  final String researchArea;
  final String methodology;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<String> objectives;
  final List<String> deliverables;
  final Map<String, dynamic> progress;
  final Map<String, dynamic> metadata;

  ResearchCollaboration({
    required this.id,
    required this.projectName,
    required this.description,
    required this.collaborators,
    required this.institutions,
    required this.researchArea,
    required this.methodology,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.objectives,
    required this.deliverables,
    required this.progress,
    required this.metadata,
  });

  factory ResearchCollaboration.fromJson(Map<String, dynamic> json) =>
      _$ResearchCollaborationFromJson(json);

  Map<String, dynamic> toJson() => _$ResearchCollaborationFromJson(this);
}

// Veri Analizi Platformu
@JsonSerializable()
class DataAnalyticsPlatform {
  final String id;
  final String platformName;
  final String description;
  final String version;
  final List<String> dataSources;
  final List<String> analyticsTools;
  final List<String> visualizationTools;
  final Map<String, dynamic> dataProcessingCapabilities;
  final Map<String, dynamic> performanceMetrics;
  final List<String> securityFeatures;
  final Map<String, dynamic> metadata;

  DataAnalyticsPlatform({
    required this.id,
    required this.platformName,
    required this.description,
    required this.version,
    required this.dataSources,
    required this.analyticsTools,
    required this.visualizationTools,
    required this.dataProcessingCapabilities,
    required this.performanceMetrics,
    required this.securityFeatures,
    required this.metadata,
  });

  factory DataAnalyticsPlatform.fromJson(Map<String, dynamic> json) =>
      _$DataAnalyticsPlatformFromJson(json);

  Map<String, dynamic> toJson() => _$DataAnalyticsPlatformFromJson(this);
}

// Makine Öğrenmesi Modelleri
@JsonSerializable()
class MachineLearningModels {
  final String id;
  final String modelName;
  final String description;
  final String algorithm;
  final String modelType;
  final String trainingData;
  final DateTime trainingDate;
  final double trainingAccuracy;
  final double validationAccuracy;
  final double testAccuracy;
  final Map<String, dynamic> hyperparameters;
  final List<String> features;
  final Map<String, dynamic> performanceMetrics;
  final String deploymentStatus;
  final Map<String, dynamic> metadata;

  MachineLearningModels({
    required this.id,
    required this.modelName,
    required this.description,
    required this.algorithm,
    required this.modelType,
    required this.trainingData,
    required this.trainingDate,
    required this.trainingAccuracy,
    required this.validationAccuracy,
    required this.testAccuracy,
    required this.hyperparameters,
    required this.features,
    required this.performanceMetrics,
    required this.deploymentStatus,
    required this.metadata,
  });

  factory MachineLearningModels.fromJson(Map<String, dynamic> json) =>
      _$MachineLearningModelsFromJson(json);

  Map<String, dynamic> toJson() => _$MachineLearningModelsFromJson(this);
}

// Veri Görselleştirme
@JsonSerializable()
class DataVisualization {
  final String id;
  final String visualizationName;
  final String description;
  final String chartType;
  final String dataSource;
  final List<String> dimensions;
  final List<String> measures;
  final Map<String, dynamic> chartConfig;
  final Map<String, dynamic> interactivity;
  final List<String> filters;
  final Map<String, dynamic> metadata;

  DataVisualization({
    required this.id,
    required this.visualizationName,
    required this.description,
    required this.chartType,
    required this.dataSource,
    required this.dimensions,
    required this.measures,
    required this.chartConfig,
    required this.interactivity,
    required this.filters,
    required this.metadata,
  });

  factory DataVisualization.fromJson(Map<String, dynamic> json) =>
      _$DataVisualizationFromJson(json);

  Map<String, dynamic> toJson() => _$DataVisualizationFromJson(this);
}

// İstatistiksel Analiz
@JsonSerializable()
class StatisticalAnalysis {
  final String id;
  final String analysisName;
  final String description;
  final String analysisType;
  final String dataSource;
  final List<String> variables;
  final List<String> statisticalTests;
  final Map<String, dynamic> testResults;
  final double significanceLevel;
  final List<String> assumptions;
  final List<String> limitations;
  final Map<String, dynamic> metadata;

  StatisticalAnalysis({
    required this.id,
    required this.analysisName,
    required this.description,
    required this.analysisType,
    required this.dataSource,
    required this.variables,
    required this.statisticalTests,
    required this.testResults,
    required this.significanceLevel,
    required this.assumptions,
    required this.limitations,
    required this.metadata,
  });

  factory StatisticalAnalysis.fromJson(Map<String, dynamic> json) =>
      _$StatisticalAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$StatisticalAnalysisFromJson(this);
}

// Veri Kalitesi Yönetimi
@JsonSerializable()
class DataQualityManagement {
  final String id;
  final String qualityMetricName;
  final String description;
  final String dataSource;
  final List<String> qualityDimensions;
  final Map<String, dynamic> qualityScores;
  final List<String> dataIssues;
  final List<String> dataCleaningSteps;
  final Map<String, dynamic> qualityMetrics;
  final Map<String, dynamic> metadata;

  DataQualityManagement({
    required this.id,
    required this.qualityMetricName,
    required this.description,
    required this.dataSource,
    required this.qualityDimensions,
    required this.qualityScores,
    required this.dataIssues,
    required this.dataCleaningSteps,
    required this.qualityMetrics,
    required this.metadata,
  });

  factory DataQualityManagement.fromJson(Map<String, dynamic> json) =>
      _$DataQualityManagementFromJson(json);

  Map<String, dynamic> toJson() => _$DataQualityManagementFromJson(this);
}

// Araştırma Metodolojisi
@JsonSerializable()
class ResearchMethodology {
  final String id;
  final String methodologyName;
  final String description;
  final String researchType;
  final String studyDesign;
  final List<String> dataCollectionMethods;
  final List<String> samplingMethods;
  final List<String> analysisMethods;
  final List<String> validityMeasures;
  final List<String> reliabilityMeasures;
  final Map<String, dynamic> metadata;

  ResearchMethodology({
    required this.id,
    required this.methodologyName,
    required this.description,
    required this.researchType,
    required this.studyDesign,
    required this.dataCollectionMethods,
    required this.samplingMethods,
    required this.analysisMethods,
    required this.validityMeasures,
    required this.reliabilityMeasures,
    required this.metadata,
  });

  factory ResearchMethodology.fromJson(Map<String, dynamic> json) =>
      _$ResearchMethodologyFromJson(json);

  Map<String, dynamic> toJson() => _$ResearchMethodologyFromJson(this);
}

// Etik Gözden Geçirme
@JsonSerializable()
class EthicalReview {
  final String id;
  final String reviewName;
  final String description;
  final String researchProject;
  final String reviewBoard;
  final DateTime reviewDate;
  final String approvalStatus;
  final List<String> ethicalConsiderations;
  final List<String> riskAssessments;
  final List<String> mitigationStrategies;
  final List<String> conditions;
  final DateTime expiryDate;
  final Map<String, dynamic> metadata;

  EthicalReview({
    required this.id,
    required this.reviewName,
    required this.description,
    required this.researchProject,
    required this.reviewBoard,
    required this.reviewDate,
    required this.approvalStatus,
    required this.ethicalConsiderations,
    required this.riskAssessments,
    required this.mitigationStrategies,
    required this.conditions,
    required this.expiryDate,
    required this.metadata,
  });

  factory EthicalReview.fromJson(Map<String, dynamic> json) =>
      _$EthicalReviewFromJson(json);

  Map<String, dynamic> toJson() => _$EthicalReviewFromJson(this);
}

// Yayın Yönetimi
@JsonSerializable()
class PublicationManagement {
  final String id;
  final String publicationTitle;
  final String description;
  final List<String> authors;
  final String journal;
  final String publicationType;
  final DateTime submissionDate;
  final DateTime publicationDate;
  final String status;
  final List<String> keywords;
  final String abstract;
  final List<String> references;
  final Map<String, dynamic> metadata;

  PublicationManagement({
    required this.id,
    required this.publicationTitle,
    required this.description,
    required this.authors,
    required this.journal,
    required this.publicationType,
    required this.submissionDate,
    required this.publicationDate,
    required this.status,
    required this.keywords,
    required this.abstract,
    required this.references,
    required this.metadata,
  });

  factory PublicationManagement.fromJson(Map<String, dynamic> json) =>
      _$PublicationManagementFromJson(json);

  Map<String, dynamic> toJson() => _$PublicationManagementFromJson(this);
}

// Veri Paylaşımı
@JsonSerializable()
class DataSharing {
  final String id;
  final String datasetName;
  final String description;
  final String dataOwner;
  final String dataType;
  final DateTime creationDate;
  final DateTime lastUpdated;
  final String sharingStatus;
  final List<String> accessLevels;
  final List<String> useRestrictions;
  final Map<String, dynamic> dataDictionary;
  final Map<String, dynamic> metadata;

  DataSharing({
    required this.id,
    required this.datasetName,
    required this.description,
    required this.dataOwner,
    required this.dataType,
    required this.creationDate,
    required this.lastUpdated,
    required this.sharingStatus,
    required this.accessLevels,
    required this.useRestrictions,
    required this.dataDictionary,
    required this.metadata,
  });

  factory DataSharing.fromJson(Map<String, dynamic> json) =>
      _$DataSharingFromJson(json);

  Map<String, dynamic> toJson() => _$DataSharingFromJson(this);
}

// Performans İzleme
@JsonSerializable()
class PerformanceMonitoring {
  final String id;
  final String monitoringName;
  final String description;
  final String systemComponent;
  final List<String> performanceMetrics;
  final Map<String, dynamic> baselineMetrics;
  final Map<String, dynamic> currentMetrics;
  final List<String> alerts;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  PerformanceMonitoring({
    required this.id,
    required this.monitoringName,
    required this.description,
    required this.systemComponent,
    required this.performanceMetrics,
    required this.baselineMetrics,
    required this.currentMetrics,
    required this.alerts,
    required this.recommendations,
    required this.metadata,
  });

  factory PerformanceMonitoring.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceMonitoringFromJson(this);
}
