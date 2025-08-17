// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_analytics_research.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvancedAnalyticsResearch _$AdvancedAnalyticsResearchFromJson(
  Map<String, dynamic> json,
) => AdvancedAnalyticsResearch(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  version: json['version'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  analyticsFeatures: json['analyticsFeatures'] as Map<String, dynamic>,
  researchFeatures: json['researchFeatures'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AdvancedAnalyticsResearchToJson(
  AdvancedAnalyticsResearch instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'version': instance.version,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'analyticsFeatures': instance.analyticsFeatures,
  'researchFeatures': instance.researchFeatures,
  'metadata': instance.metadata,
};

PredictiveAnalytics _$PredictiveAnalyticsFromJson(Map<String, dynamic> json) =>
    PredictiveAnalytics(
      id: json['id'] as String,
      modelName: json['modelName'] as String,
      description: json['description'] as String,
      algorithm: json['algorithm'] as String,
      modelType: json['modelType'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      precision: (json['precision'] as num).toDouble(),
      recall: (json['recall'] as num).toDouble(),
      f1Score: (json['f1Score'] as num).toDouble(),
      modelParameters: json['modelParameters'] as Map<String, dynamic>,
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      predictions: (json['predictions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PredictiveAnalyticsToJson(
  PredictiveAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'modelName': instance.modelName,
  'description': instance.description,
  'algorithm': instance.algorithm,
  'modelType': instance.modelType,
  'accuracy': instance.accuracy,
  'precision': instance.precision,
  'recall': instance.recall,
  'f1Score': instance.f1Score,
  'modelParameters': instance.modelParameters,
  'features': instance.features,
  'predictions': instance.predictions,
  'performanceMetrics': instance.performanceMetrics,
  'metadata': instance.metadata,
};

PopulationHealthInsights _$PopulationHealthInsightsFromJson(
  Map<String, dynamic> json,
) => PopulationHealthInsights(
  id: json['id'] as String,
  insightName: json['insightName'] as String,
  description: json['description'] as String,
  populationGroup: json['populationGroup'] as String,
  geographicRegion: json['geographicRegion'] as String,
  timePeriod: json['timePeriod'] as String,
  healthIndicators: (json['healthIndicators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  demographicData: json['demographicData'] as Map<String, dynamic>,
  healthTrends: json['healthTrends'] as Map<String, dynamic>,
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PopulationHealthInsightsToJson(
  PopulationHealthInsights instance,
) => <String, dynamic>{
  'id': instance.id,
  'insightName': instance.insightName,
  'description': instance.description,
  'populationGroup': instance.populationGroup,
  'geographicRegion': instance.geographicRegion,
  'timePeriod': instance.timePeriod,
  'healthIndicators': instance.healthIndicators,
  'demographicData': instance.demographicData,
  'healthTrends': instance.healthTrends,
  'riskFactors': instance.riskFactors,
  'protectiveFactors': instance.protectiveFactors,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};

TreatmentOutcomeTracking _$TreatmentOutcomeTrackingFromJson(
  Map<String, dynamic> json,
) => TreatmentOutcomeTracking(
  id: json['id'] as String,
  treatmentId: json['treatmentId'] as String,
  treatmentName: json['treatmentName'] as String,
  patientId: json['patientId'] as String,
  diagnosis: json['diagnosis'] as String,
  treatmentStartDate: DateTime.parse(json['treatmentStartDate'] as String),
  treatmentEndDate: DateTime.parse(json['treatmentEndDate'] as String),
  outcomeMeasures: (json['outcomeMeasures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  baselineMeasures: json['baselineMeasures'] as Map<String, dynamic>,
  followUpMeasures: json['followUpMeasures'] as Map<String, dynamic>,
  improvementScore: (json['improvementScore'] as num).toDouble(),
  outcomeStatus: json['outcomeStatus'] as String,
  factors: (json['factors'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$TreatmentOutcomeTrackingToJson(
  TreatmentOutcomeTracking instance,
) => <String, dynamic>{
  'id': instance.id,
  'treatmentId': instance.treatmentId,
  'treatmentName': instance.treatmentName,
  'patientId': instance.patientId,
  'diagnosis': instance.diagnosis,
  'treatmentStartDate': instance.treatmentStartDate.toIso8601String(),
  'treatmentEndDate': instance.treatmentEndDate.toIso8601String(),
  'outcomeMeasures': instance.outcomeMeasures,
  'baselineMeasures': instance.baselineMeasures,
  'followUpMeasures': instance.followUpMeasures,
  'improvementScore': instance.improvementScore,
  'outcomeStatus': instance.outcomeStatus,
  'factors': instance.factors,
  'metadata': instance.metadata,
};

ResearchCollaboration _$ResearchCollaborationFromJson(
  Map<String, dynamic> json,
) => ResearchCollaboration(
  id: json['id'] as String,
  projectName: json['projectName'] as String,
  description: json['description'] as String,
  collaborators: (json['collaborators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  institutions: (json['institutions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  researchArea: json['researchArea'] as String,
  methodology: json['methodology'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  status: json['status'] as String,
  objectives: (json['objectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  deliverables: (json['deliverables'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  progress: json['progress'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ResearchCollaborationToJson(
  ResearchCollaboration instance,
) => <String, dynamic>{
  'id': instance.id,
  'projectName': instance.projectName,
  'description': instance.description,
  'collaborators': instance.collaborators,
  'institutions': instance.institutions,
  'researchArea': instance.researchArea,
  'methodology': instance.methodology,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'status': instance.status,
  'objectives': instance.objectives,
  'deliverables': instance.deliverables,
  'progress': instance.progress,
  'metadata': instance.metadata,
};

DataAnalyticsPlatform _$DataAnalyticsPlatformFromJson(
  Map<String, dynamic> json,
) => DataAnalyticsPlatform(
  id: json['id'] as String,
  platformName: json['platformName'] as String,
  description: json['description'] as String,
  version: json['version'] as String,
  dataSources: (json['dataSources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  analyticsTools: (json['analyticsTools'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  visualizationTools: (json['visualizationTools'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dataProcessingCapabilities:
      json['dataProcessingCapabilities'] as Map<String, dynamic>,
  performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
  securityFeatures: (json['securityFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DataAnalyticsPlatformToJson(
  DataAnalyticsPlatform instance,
) => <String, dynamic>{
  'id': instance.id,
  'platformName': instance.platformName,
  'description': instance.description,
  'version': instance.version,
  'dataSources': instance.dataSources,
  'analyticsTools': instance.analyticsTools,
  'visualizationTools': instance.visualizationTools,
  'dataProcessingCapabilities': instance.dataProcessingCapabilities,
  'performanceMetrics': instance.performanceMetrics,
  'securityFeatures': instance.securityFeatures,
  'metadata': instance.metadata,
};

MachineLearningModels _$MachineLearningModelsFromJson(
  Map<String, dynamic> json,
) => MachineLearningModels(
  id: json['id'] as String,
  modelName: json['modelName'] as String,
  description: json['description'] as String,
  algorithm: json['algorithm'] as String,
  modelType: json['modelType'] as String,
  trainingData: json['trainingData'] as String,
  trainingDate: DateTime.parse(json['trainingDate'] as String),
  trainingAccuracy: (json['trainingAccuracy'] as num).toDouble(),
  validationAccuracy: (json['validationAccuracy'] as num).toDouble(),
  testAccuracy: (json['testAccuracy'] as num).toDouble(),
  hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
  deploymentStatus: json['deploymentStatus'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MachineLearningModelsToJson(
  MachineLearningModels instance,
) => <String, dynamic>{
  'id': instance.id,
  'modelName': instance.modelName,
  'description': instance.description,
  'algorithm': instance.algorithm,
  'modelType': instance.modelType,
  'trainingData': instance.trainingData,
  'trainingDate': instance.trainingDate.toIso8601String(),
  'trainingAccuracy': instance.trainingAccuracy,
  'validationAccuracy': instance.validationAccuracy,
  'testAccuracy': instance.testAccuracy,
  'hyperparameters': instance.hyperparameters,
  'features': instance.features,
  'performanceMetrics': instance.performanceMetrics,
  'deploymentStatus': instance.deploymentStatus,
  'metadata': instance.metadata,
};

DataVisualization _$DataVisualizationFromJson(Map<String, dynamic> json) =>
    DataVisualization(
      id: json['id'] as String,
      visualizationName: json['visualizationName'] as String,
      description: json['description'] as String,
      chartType: json['chartType'] as String,
      dataSource: json['dataSource'] as String,
      dimensions: (json['dimensions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      measures: (json['measures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      chartConfig: json['chartConfig'] as Map<String, dynamic>,
      interactivity: json['interactivity'] as Map<String, dynamic>,
      filters: (json['filters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DataVisualizationToJson(DataVisualization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visualizationName': instance.visualizationName,
      'description': instance.description,
      'chartType': instance.chartType,
      'dataSource': instance.dataSource,
      'dimensions': instance.dimensions,
      'measures': instance.measures,
      'chartConfig': instance.chartConfig,
      'interactivity': instance.interactivity,
      'filters': instance.filters,
      'metadata': instance.metadata,
    };

StatisticalAnalysis _$StatisticalAnalysisFromJson(Map<String, dynamic> json) =>
    StatisticalAnalysis(
      id: json['id'] as String,
      analysisName: json['analysisName'] as String,
      description: json['description'] as String,
      analysisType: json['analysisType'] as String,
      dataSource: json['dataSource'] as String,
      variables: (json['variables'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      statisticalTests: (json['statisticalTests'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      testResults: json['testResults'] as Map<String, dynamic>,
      significanceLevel: (json['significanceLevel'] as num).toDouble(),
      assumptions: (json['assumptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      limitations: (json['limitations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$StatisticalAnalysisToJson(
  StatisticalAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'analysisName': instance.analysisName,
  'description': instance.description,
  'analysisType': instance.analysisType,
  'dataSource': instance.dataSource,
  'variables': instance.variables,
  'statisticalTests': instance.statisticalTests,
  'testResults': instance.testResults,
  'significanceLevel': instance.significanceLevel,
  'assumptions': instance.assumptions,
  'limitations': instance.limitations,
  'metadata': instance.metadata,
};

DataQualityManagement _$DataQualityManagementFromJson(
  Map<String, dynamic> json,
) => DataQualityManagement(
  id: json['id'] as String,
  qualityMetricName: json['qualityMetricName'] as String,
  description: json['description'] as String,
  dataSource: json['dataSource'] as String,
  qualityDimensions: (json['qualityDimensions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  qualityScores: json['qualityScores'] as Map<String, dynamic>,
  dataIssues: (json['dataIssues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dataCleaningSteps: (json['dataCleaningSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  qualityMetrics: json['qualityMetrics'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DataQualityManagementToJson(
  DataQualityManagement instance,
) => <String, dynamic>{
  'id': instance.id,
  'qualityMetricName': instance.qualityMetricName,
  'description': instance.description,
  'dataSource': instance.dataSource,
  'qualityDimensions': instance.qualityDimensions,
  'qualityScores': instance.qualityScores,
  'dataIssues': instance.dataIssues,
  'dataCleaningSteps': instance.dataCleaningSteps,
  'qualityMetrics': instance.qualityMetrics,
  'metadata': instance.metadata,
};

ResearchMethodology _$ResearchMethodologyFromJson(Map<String, dynamic> json) =>
    ResearchMethodology(
      id: json['id'] as String,
      methodologyName: json['methodologyName'] as String,
      description: json['description'] as String,
      researchType: json['researchType'] as String,
      studyDesign: json['studyDesign'] as String,
      dataCollectionMethods: (json['dataCollectionMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      samplingMethods: (json['samplingMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      analysisMethods: (json['analysisMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      validityMeasures: (json['validityMeasures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reliabilityMeasures: (json['reliabilityMeasures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ResearchMethodologyToJson(
  ResearchMethodology instance,
) => <String, dynamic>{
  'id': instance.id,
  'methodologyName': instance.methodologyName,
  'description': instance.description,
  'researchType': instance.researchType,
  'studyDesign': instance.studyDesign,
  'dataCollectionMethods': instance.dataCollectionMethods,
  'samplingMethods': instance.samplingMethods,
  'analysisMethods': instance.analysisMethods,
  'validityMeasures': instance.validityMeasures,
  'reliabilityMeasures': instance.reliabilityMeasures,
  'metadata': instance.metadata,
};

EthicalReview _$EthicalReviewFromJson(Map<String, dynamic> json) =>
    EthicalReview(
      id: json['id'] as String,
      reviewName: json['reviewName'] as String,
      description: json['description'] as String,
      researchProject: json['researchProject'] as String,
      reviewBoard: json['reviewBoard'] as String,
      reviewDate: DateTime.parse(json['reviewDate'] as String),
      approvalStatus: json['approvalStatus'] as String,
      ethicalConsiderations: (json['ethicalConsiderations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskAssessments: (json['riskAssessments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mitigationStrategies: (json['mitigationStrategies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      conditions: (json['conditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EthicalReviewToJson(EthicalReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewName': instance.reviewName,
      'description': instance.description,
      'researchProject': instance.researchProject,
      'reviewBoard': instance.reviewBoard,
      'reviewDate': instance.reviewDate.toIso8601String(),
      'approvalStatus': instance.approvalStatus,
      'ethicalConsiderations': instance.ethicalConsiderations,
      'riskAssessments': instance.riskAssessments,
      'mitigationStrategies': instance.mitigationStrategies,
      'conditions': instance.conditions,
      'expiryDate': instance.expiryDate.toIso8601String(),
      'metadata': instance.metadata,
    };

PublicationManagement _$PublicationManagementFromJson(
  Map<String, dynamic> json,
) => PublicationManagement(
  id: json['id'] as String,
  publicationTitle: json['publicationTitle'] as String,
  description: json['description'] as String,
  authors: (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
  journal: json['journal'] as String,
  publicationType: json['publicationType'] as String,
  submissionDate: DateTime.parse(json['submissionDate'] as String),
  publicationDate: DateTime.parse(json['publicationDate'] as String),
  status: json['status'] as String,
  keywords: (json['keywords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  abstract: json['abstract'] as String,
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PublicationManagementToJson(
  PublicationManagement instance,
) => <String, dynamic>{
  'id': instance.id,
  'publicationTitle': instance.publicationTitle,
  'description': instance.description,
  'authors': instance.authors,
  'journal': instance.journal,
  'publicationType': instance.publicationType,
  'submissionDate': instance.submissionDate.toIso8601String(),
  'publicationDate': instance.publicationDate.toIso8601String(),
  'status': instance.status,
  'keywords': instance.keywords,
  'abstract': instance.abstract,
  'references': instance.references,
  'metadata': instance.metadata,
};

DataSharing _$DataSharingFromJson(Map<String, dynamic> json) => DataSharing(
  id: json['id'] as String,
  datasetName: json['datasetName'] as String,
  description: json['description'] as String,
  dataOwner: json['dataOwner'] as String,
  dataType: json['dataType'] as String,
  creationDate: DateTime.parse(json['creationDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  sharingStatus: json['sharingStatus'] as String,
  accessLevels: (json['accessLevels'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  useRestrictions: (json['useRestrictions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dataDictionary: json['dataDictionary'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DataSharingToJson(DataSharing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'datasetName': instance.datasetName,
      'description': instance.description,
      'dataOwner': instance.dataOwner,
      'dataType': instance.dataType,
      'creationDate': instance.creationDate.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'sharingStatus': instance.sharingStatus,
      'accessLevels': instance.accessLevels,
      'useRestrictions': instance.useRestrictions,
      'dataDictionary': instance.dataDictionary,
      'metadata': instance.metadata,
    };

PerformanceMonitoring _$PerformanceMonitoringFromJson(
  Map<String, dynamic> json,
) => PerformanceMonitoring(
  id: json['id'] as String,
  monitoringName: json['monitoringName'] as String,
  description: json['description'] as String,
  systemComponent: json['systemComponent'] as String,
  performanceMetrics: (json['performanceMetrics'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  baselineMetrics: json['baselineMetrics'] as Map<String, dynamic>,
  currentMetrics: json['currentMetrics'] as Map<String, dynamic>,
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PerformanceMonitoringToJson(
  PerformanceMonitoring instance,
) => <String, dynamic>{
  'id': instance.id,
  'monitoringName': instance.monitoringName,
  'description': instance.description,
  'systemComponent': instance.systemComponent,
  'performanceMetrics': instance.performanceMetrics,
  'baselineMetrics': instance.baselineMetrics,
  'currentMetrics': instance.currentMetrics,
  'alerts': instance.alerts,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
