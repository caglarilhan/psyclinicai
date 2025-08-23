// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predictive_analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictiveModel _$PredictiveModelFromJson(Map<String, dynamic> json) =>
    PredictiveModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      type: $enumDecode(_$ModelTypeEnumMap, json['type']),
      status: $enumDecode(_$ModelStatusEnumMap, json['status']),
      accuracy: (json['accuracy'] as num).toDouble(),
      lastTrained: DateTime.parse(json['lastTrained'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PredictiveModelToJson(PredictiveModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'version': instance.version,
      'type': _$ModelTypeEnumMap[instance.type]!,
      'status': _$ModelStatusEnumMap[instance.status]!,
      'accuracy': instance.accuracy,
      'lastTrained': instance.lastTrained.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'parameters': instance.parameters,
      'metadata': instance.metadata,
    };

const _$ModelTypeEnumMap = {
  ModelType.regression: 'regression',
  ModelType.classification: 'classification',
  ModelType.clustering: 'clustering',
  ModelType.timeSeries: 'timeSeries',
  ModelType.anomalyDetection: 'anomalyDetection',
  ModelType.recommendation: 'recommendation',
  ModelType.treatmentOutcome: 'treatmentOutcome',
  ModelType.relapseRisk: 'relapseRisk',
  ModelType.crisisPrediction: 'crisisPrediction',
  ModelType.patientProgress: 'patientProgress',
};

const _$ModelStatusEnumMap = {
  ModelStatus.training: 'training',
  ModelStatus.active: 'active',
  ModelStatus.inactive: 'inactive',
  ModelStatus.deprecated: 'deprecated',
  ModelStatus.error: 'error',
};

PredictionRequest _$PredictionRequestFromJson(Map<String, dynamic> json) =>
    PredictionRequest(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      tenantId: json['tenantId'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      inputData: json['inputData'] as Map<String, dynamic>,
      context: json['context'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PredictionRequestToJson(PredictionRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'tenantId': instance.tenantId,
      'userId': instance.userId,
      'timestamp': instance.timestamp.toIso8601String(),
      'inputData': instance.inputData,
      'context': instance.context,
      'metadata': instance.metadata,
    };

PredictionResult _$PredictionResultFromJson(Map<String, dynamic> json) =>
    PredictionResult(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      modelId: json['modelId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      predictions: json['predictions'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
      explanations: json['explanations'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PredictionResultToJson(PredictionResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requestId': instance.requestId,
      'modelId': instance.modelId,
      'timestamp': instance.timestamp.toIso8601String(),
      'predictions': instance.predictions,
      'confidence': instance.confidence,
      'explanations': instance.explanations,
      'metadata': instance.metadata,
    };

TreatmentOutcomePrediction _$TreatmentOutcomePredictionFromJson(
  Map<String, dynamic> json,
) => TreatmentOutcomePrediction(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  treatmentId: json['treatmentId'] as String,
  successProbability: (json['successProbability'] as num).toDouble(),
  estimatedDurationWeeks: (json['estimatedDurationWeeks'] as num).toInt(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendedAdjustments: (json['recommendedAdjustments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidenceIntervals:
      json['confidenceIntervals'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$TreatmentOutcomePredictionToJson(
  TreatmentOutcomePrediction instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'treatmentId': instance.treatmentId,
  'successProbability': instance.successProbability,
  'estimatedDurationWeeks': instance.estimatedDurationWeeks,
  'riskFactors': instance.riskFactors,
  'recommendedAdjustments': instance.recommendedAdjustments,
  'confidenceIntervals': instance.confidenceIntervals,
  'metadata': instance.metadata,
};

RelapseRiskPrediction _$RelapseRiskPredictionFromJson(
  Map<String, dynamic> json,
) => RelapseRiskPrediction(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  relapseRisk: (json['relapseRisk'] as num).toDouble(),
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  predictedRiskPeriod: DateTime.parse(json['predictedRiskPeriod'] as String),
  preventionStrategies: (json['preventionStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$RelapseRiskPredictionToJson(
  RelapseRiskPrediction instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'relapseRisk': instance.relapseRisk,
  'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
  'riskFactors': instance.riskFactors,
  'protectiveFactors': instance.protectiveFactors,
  'predictedRiskPeriod': instance.predictedRiskPeriod.toIso8601String(),
  'preventionStrategies': instance.preventionStrategies,
  'metadata': instance.metadata,
};

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

PatientProgressPrediction _$PatientProgressPredictionFromJson(
  Map<String, dynamic> json,
) => PatientProgressPrediction(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  predictionDate: DateTime.parse(json['predictionDate'] as String),
  improvementScore: (json['improvementScore'] as num).toDouble(),
  estimatedRecoveryWeeks: (json['estimatedRecoveryWeeks'] as num).toInt(),
  milestones: (json['milestones'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  challenges: (json['challenges'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidenceMetrics:
      json['confidenceMetrics'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PatientProgressPredictionToJson(
  PatientProgressPrediction instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'predictionDate': instance.predictionDate.toIso8601String(),
  'improvementScore': instance.improvementScore,
  'estimatedRecoveryWeeks': instance.estimatedRecoveryWeeks,
  'milestones': instance.milestones,
  'challenges': instance.challenges,
  'confidenceMetrics': instance.confidenceMetrics,
  'metadata': instance.metadata,
};

CrisisPrediction _$CrisisPredictionFromJson(Map<String, dynamic> json) =>
    CrisisPrediction(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      crisisType: $enumDecode(_$CrisisTypeEnumMap, json['crisisType']),
      crisisProbability: (json['crisisProbability'] as num).toDouble(),
      predictedTimeframe: DateTime.parse(json['predictedTimeframe'] as String),
      warningSigns: (json['warningSigns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventionStrategies: (json['interventionStrategies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      urgency: $enumDecode(_$UrgencyLevelEnumMap, json['urgency']),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CrisisPredictionToJson(CrisisPrediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'crisisType': _$CrisisTypeEnumMap[instance.crisisType]!,
      'crisisProbability': instance.crisisProbability,
      'predictedTimeframe': instance.predictedTimeframe.toIso8601String(),
      'warningSigns': instance.warningSigns,
      'interventionStrategies': instance.interventionStrategies,
      'urgency': _$UrgencyLevelEnumMap[instance.urgency]!,
      'metadata': instance.metadata,
    };

const _$CrisisTypeEnumMap = {
  CrisisType.suicidal: 'suicidal',
  CrisisType.violent: 'violent',
  CrisisType.psychotic: 'psychotic',
  CrisisType.substanceAbuse: 'substanceAbuse',
  CrisisType.selfHarm: 'selfHarm',
  CrisisType.other: 'other',
};

const _$UrgencyLevelEnumMap = {
  UrgencyLevel.low: 'low',
  UrgencyLevel.medium: 'medium',
  UrgencyLevel.high: 'high',
  UrgencyLevel.immediate: 'immediate',
};

ModelPerformanceMetrics _$ModelPerformanceMetricsFromJson(
  Map<String, dynamic> json,
) => ModelPerformanceMetrics(
  id: json['id'] as String,
  modelId: json['modelId'] as String,
  evaluationDate: DateTime.parse(json['evaluationDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  accuracy: (json['accuracy'] as num).toDouble(),
  precision: (json['precision'] as num).toDouble(),
  recall: (json['recall'] as num).toDouble(),
  f1Score: (json['f1Score'] as num).toDouble(),
  auc: (json['auc'] as num).toDouble(),
  classMetrics:
      (json['classMetrics'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  confusionMatrix: json['confusionMatrix'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ModelPerformanceMetricsToJson(
  ModelPerformanceMetrics instance,
) => <String, dynamic>{
  'id': instance.id,
  'modelId': instance.modelId,
  'evaluationDate': instance.evaluationDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'accuracy': instance.accuracy,
  'precision': instance.precision,
  'recall': instance.recall,
  'f1Score': instance.f1Score,
  'auc': instance.auc,
  'classMetrics': instance.classMetrics,
  'confusionMatrix': instance.confusionMatrix,
  'metadata': instance.metadata,
};

FeatureImportance _$FeatureImportanceFromJson(Map<String, dynamic> json) =>
    FeatureImportance(
      featureName: json['featureName'] as String,
      importance: (json['importance'] as num).toDouble(),
      standardDeviation: (json['standardDeviation'] as num).toDouble(),
      importanceHistory:
          (json['importanceHistory'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FeatureImportanceToJson(FeatureImportance instance) =>
    <String, dynamic>{
      'featureName': instance.featureName,
      'importance': instance.importance,
      'standardDeviation': instance.standardDeviation,
      'importanceHistory': instance.importanceHistory,
      'metadata': instance.metadata,
    };

ModelTrainingJob _$ModelTrainingJobFromJson(
  Map<String, dynamic> json,
) => ModelTrainingJob(
  id: json['id'] as String,
  modelId: json['modelId'] as String,
  modelName: json['modelName'] as String,
  status: $enumDecode(_$TrainingStatusEnumMap, json['status']),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  duration: Duration(microseconds: (json['duration'] as num).toInt()),
  startedAt: DateTime.parse(json['startedAt'] as String),
  progress: (json['progress'] as num).toDouble(),
  hyperparameters: json['hyperparameters'] as Map<String, dynamic>? ?? const {},
  trainingMetrics: json['trainingMetrics'] as Map<String, dynamic>? ?? const {},
  errorMessage: json['errorMessage'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ModelTrainingJobToJson(ModelTrainingJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'modelName': instance.modelName,
      'status': _$TrainingStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'startedAt': instance.startedAt.toIso8601String(),
      'progress': instance.progress,
      'hyperparameters': instance.hyperparameters,
      'trainingMetrics': instance.trainingMetrics,
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

const _$TrainingStatusEnumMap = {
  TrainingStatus.pending: 'pending',
  TrainingStatus.running: 'running',
  TrainingStatus.completed: 'completed',
  TrainingStatus.failed: 'failed',
  TrainingStatus.cancelled: 'cancelled',
};
