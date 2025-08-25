// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_training_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingDataset _$TrainingDatasetFromJson(Map<String, dynamic> json) =>
    TrainingDataset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dataType: $enumDecode(_$TrainingDataTypeEnumMap, json['dataType']),
      totalSamples: (json['totalSamples'] as num).toInt(),
      trainingSamples: (json['trainingSamples'] as num).toInt(),
      validationSamples: (json['validationSamples'] as num).toInt(),
      testSamples: (json['testSamples'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>,
      quality: $enumDecode(_$DataQualityEnumMap, json['quality']),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      source: json['source'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$TrainingDatasetToJson(TrainingDataset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'dataType': _$TrainingDataTypeEnumMap[instance.dataType]!,
      'totalSamples': instance.totalSamples,
      'trainingSamples': instance.trainingSamples,
      'validationSamples': instance.validationSamples,
      'testSamples': instance.testSamples,
      'metadata': instance.metadata,
      'quality': _$DataQualityEnumMap[instance.quality]!,
      'tags': instance.tags,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
    };

const _$TrainingDataTypeEnumMap = {
  TrainingDataType.text: 'text',
  TrainingDataType.image: 'image',
  TrainingDataType.audio: 'audio',
  TrainingDataType.video: 'video',
  TrainingDataType.tabular: 'tabular',
  TrainingDataType.multimodal: 'multimodal',
};

const _$DataQualityEnumMap = {
  DataQuality.excellent: 'excellent',
  DataQuality.good: 'good',
  DataQuality.fair: 'fair',
  DataQuality.poor: 'poor',
  DataQuality.unknown: 'unknown',
};

TrainingDataSample _$TrainingDataSampleFromJson(Map<String, dynamic> json) =>
    TrainingDataSample(
      id: json['id'] as String,
      datasetId: json['datasetId'] as String,
      content: json['content'] as String,
      labels: json['labels'] as Map<String, dynamic>,
      features: json['features'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      isAnnotated: json['isAnnotated'] as bool,
      annotatorId: json['annotatorId'] as String?,
      annotatedAt: json['annotatedAt'] == null
          ? null
          : DateTime.parse(json['annotatedAt'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrainingDataSampleToJson(TrainingDataSample instance) =>
    <String, dynamic>{
      'id': instance.id,
      'datasetId': instance.datasetId,
      'content': instance.content,
      'labels': instance.labels,
      'features': instance.features,
      'metadata': instance.metadata,
      'isAnnotated': instance.isAnnotated,
      'annotatorId': instance.annotatorId,
      'annotatedAt': instance.annotatedAt?.toIso8601String(),
      'confidence': instance.confidence,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AIModelDefinition _$AIModelDefinitionFromJson(Map<String, dynamic> json) =>
    AIModelDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      architecture: $enumDecode(
        _$ModelArchitectureEnumMap,
        json['architecture'],
      ),
      framework: $enumDecode(_$TrainingFrameworkEnumMap, json['framework']),
      hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
      modelConfig: json['modelConfig'] as Map<String, dynamic>,
      parameterCount: (json['parameterCount'] as num).toInt(),
      modelSize: json['modelSize'] as String,
      supportedTasks: (json['supportedTasks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      requirements: json['requirements'] as Map<String, dynamic>,
      version: json['version'] as String,
      author: json['author'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$AIModelDefinitionToJson(AIModelDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'architecture': _$ModelArchitectureEnumMap[instance.architecture]!,
      'framework': _$TrainingFrameworkEnumMap[instance.framework]!,
      'hyperparameters': instance.hyperparameters,
      'modelConfig': instance.modelConfig,
      'parameterCount': instance.parameterCount,
      'modelSize': instance.modelSize,
      'supportedTasks': instance.supportedTasks,
      'supportedLanguages': instance.supportedLanguages,
      'requirements': instance.requirements,
      'version': instance.version,
      'author': instance.author,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
    };

const _$ModelArchitectureEnumMap = {
  ModelArchitecture.transformer: 'transformer',
  ModelArchitecture.cnn: 'cnn',
  ModelArchitecture.rnn: 'rnn',
  ModelArchitecture.lstm: 'lstm',
  ModelArchitecture.gru: 'gru',
  ModelArchitecture.autoencoder: 'autoencoder',
  ModelArchitecture.gan: 'gan',
  ModelArchitecture.custom: 'custom',
};

const _$TrainingFrameworkEnumMap = {
  TrainingFramework.pytorch: 'pytorch',
  TrainingFramework.tensorflow: 'tensorflow',
  TrainingFramework.keras: 'keras',
  TrainingFramework.scikitLearn: 'scikit_learn',
  TrainingFramework.custom: 'custom',
};

TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) =>
    TrainingSession(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      datasetId: json['datasetId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$TrainingStatusEnumMap, json['status']),
      hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
      trainingConfig: json['trainingConfig'] as Map<String, dynamic>,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      currentEpoch: (json['currentEpoch'] as num).toInt(),
      totalEpochs: (json['totalEpochs'] as num).toInt(),
      currentLoss: (json['currentLoss'] as num).toDouble(),
      currentAccuracy: (json['currentAccuracy'] as num).toDouble(),
      metrics: json['metrics'] as Map<String, dynamic>,
      checkpoints: json['checkpoints'] as Map<String, dynamic>,
      trainedModelPath: json['trainedModelPath'] as String?,
      logsPath: json['logsPath'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrainingSessionToJson(TrainingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'datasetId': instance.datasetId,
      'name': instance.name,
      'description': instance.description,
      'status': _$TrainingStatusEnumMap[instance.status]!,
      'hyperparameters': instance.hyperparameters,
      'trainingConfig': instance.trainingConfig,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
      'currentEpoch': instance.currentEpoch,
      'totalEpochs': instance.totalEpochs,
      'currentLoss': instance.currentLoss,
      'currentAccuracy': instance.currentAccuracy,
      'metrics': instance.metrics,
      'checkpoints': instance.checkpoints,
      'trainedModelPath': instance.trainedModelPath,
      'logsPath': instance.logsPath,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TrainingStatusEnumMap = {
  TrainingStatus.pending: 'pending',
  TrainingStatus.inProgress: 'in_progress',
  TrainingStatus.completed: 'completed',
  TrainingStatus.failed: 'failed',
  TrainingStatus.cancelled: 'cancelled',
  TrainingStatus.paused: 'paused',
};

TrainingMetrics _$TrainingMetricsFromJson(Map<String, dynamic> json) =>
    TrainingMetrics(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      epoch: (json['epoch'] as num).toInt(),
      trainingLoss: (json['trainingLoss'] as num).toDouble(),
      validationLoss: (json['validationLoss'] as num).toDouble(),
      trainingAccuracy: (json['trainingAccuracy'] as num).toDouble(),
      validationAccuracy: (json['validationAccuracy'] as num).toDouble(),
      learningRate: (json['learningRate'] as num).toDouble(),
      gradientNorm: (json['gradientNorm'] as num).toDouble(),
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$TrainingMetricsToJson(TrainingMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'epoch': instance.epoch,
      'trainingLoss': instance.trainingLoss,
      'validationLoss': instance.validationLoss,
      'trainingAccuracy': instance.trainingAccuracy,
      'validationAccuracy': instance.validationAccuracy,
      'learningRate': instance.learningRate,
      'gradientNorm': instance.gradientNorm,
      'additionalMetrics': instance.additionalMetrics,
      'timestamp': instance.timestamp.toIso8601String(),
    };

ModelCheckpoint _$ModelCheckpointFromJson(Map<String, dynamic> json) =>
    ModelCheckpoint(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      epoch: (json['epoch'] as num).toInt(),
      modelPath: json['modelPath'] as String,
      optimizerPath: json['optimizerPath'] as String,
      metrics: json['metrics'] as Map<String, dynamic>,
      checkpointType: json['checkpointType'] as String,
      modelSize: (json['modelSize'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ModelCheckpointToJson(ModelCheckpoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'epoch': instance.epoch,
      'modelPath': instance.modelPath,
      'optimizerPath': instance.optimizerPath,
      'metrics': instance.metrics,
      'checkpointType': instance.checkpointType,
      'modelSize': instance.modelSize,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

TrainedModel _$TrainedModelFromJson(Map<String, dynamic> json) => TrainedModel(
  id: json['id'] as String,
  definitionId: json['definitionId'] as String,
  sessionId: json['sessionId'] as String,
  name: json['name'] as String,
  version: json['version'] as String,
  modelPath: json['modelPath'] as String,
  performance: json['performance'] as Map<String, dynamic>,
  evaluation: json['evaluation'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
  supportedTasks: (json['supportedTasks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  trainingCompletedAt: DateTime.parse(json['trainingCompletedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isDeployed: json['isDeployed'] as bool,
);

Map<String, dynamic> _$TrainedModelToJson(TrainedModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'definitionId': instance.definitionId,
      'sessionId': instance.sessionId,
      'name': instance.name,
      'version': instance.version,
      'modelPath': instance.modelPath,
      'performance': instance.performance,
      'evaluation': instance.evaluation,
      'metadata': instance.metadata,
      'supportedTasks': instance.supportedTasks,
      'status': instance.status,
      'trainingCompletedAt': instance.trainingCompletedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeployed': instance.isDeployed,
    };

ModelEvaluation _$ModelEvaluationFromJson(Map<String, dynamic> json) =>
    ModelEvaluation(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      datasetId: json['datasetId'] as String,
      metrics: json['metrics'] as Map<String, dynamic>,
      confusionMatrix: json['confusionMatrix'] as Map<String, dynamic>,
      classificationReport:
          json['classificationReport'] as Map<String, dynamic>,
      predictions: (json['predictions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      groundTruth: (json['groundTruth'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      analysis: json['analysis'] as Map<String, dynamic>,
      evaluatorId: json['evaluatorId'] as String,
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ModelEvaluationToJson(ModelEvaluation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'datasetId': instance.datasetId,
      'metrics': instance.metrics,
      'confusionMatrix': instance.confusionMatrix,
      'classificationReport': instance.classificationReport,
      'predictions': instance.predictions,
      'groundTruth': instance.groundTruth,
      'analysis': instance.analysis,
      'evaluatorId': instance.evaluatorId,
      'evaluatedAt': instance.evaluatedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

TrainingConfiguration _$TrainingConfigurationFromJson(
  Map<String, dynamic> json,
) => TrainingConfiguration(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
  dataConfig: json['dataConfig'] as Map<String, dynamic>,
  modelConfig: json['modelConfig'] as Map<String, dynamic>,
  optimizerConfig: json['optimizerConfig'] as Map<String, dynamic>,
  schedulerConfig: json['schedulerConfig'] as Map<String, dynamic>,
  augmentationConfig: json['augmentationConfig'] as Map<String, dynamic>,
  validationConfig: json['validationConfig'] as Map<String, dynamic>,
  checkpointConfig: json['checkpointConfig'] as Map<String, dynamic>,
  loggingConfig: json['loggingConfig'] as Map<String, dynamic>,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$TrainingConfigurationToJson(
  TrainingConfiguration instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'hyperparameters': instance.hyperparameters,
  'dataConfig': instance.dataConfig,
  'modelConfig': instance.modelConfig,
  'optimizerConfig': instance.optimizerConfig,
  'schedulerConfig': instance.schedulerConfig,
  'augmentationConfig': instance.augmentationConfig,
  'validationConfig': instance.validationConfig,
  'checkpointConfig': instance.checkpointConfig,
  'loggingConfig': instance.loggingConfig,
  'tags': instance.tags,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
};

TrainingJob _$TrainingJobFromJson(Map<String, dynamic> json) => TrainingJob(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  configurationId: json['configurationId'] as String,
  status: json['status'] as String,
  priority: (json['priority'] as num).toInt(),
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  estimatedDuration: json['estimatedDuration'] == null
      ? null
      : Duration(microseconds: (json['estimatedDuration'] as num).toInt()),
  actualDuration: json['actualDuration'] == null
      ? null
      : Duration(microseconds: (json['actualDuration'] as num).toInt()),
  resources: json['resources'] as Map<String, dynamic>,
  constraints: json['constraints'] as Map<String, dynamic>,
  assignedTo: json['assignedTo'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TrainingJobToJson(TrainingJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'configurationId': instance.configurationId,
      'status': instance.status,
      'priority': instance.priority,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'estimatedDuration': instance.estimatedDuration?.inMicroseconds,
      'actualDuration': instance.actualDuration?.inMicroseconds,
      'resources': instance.resources,
      'constraints': instance.constraints,
      'assignedTo': instance.assignedTo,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ModelDeployment _$ModelDeploymentFromJson(Map<String, dynamic> json) =>
    ModelDeployment(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      environment: json['environment'] as String,
      status: json['status'] as String,
      endpoint: json['endpoint'] as String,
      configuration: json['configuration'] as Map<String, dynamic>,
      resources: json['resources'] as Map<String, dynamic>,
      monitoring: json['monitoring'] as Map<String, dynamic>,
      deployedAt: DateTime.parse(json['deployedAt'] as String),
      undeployedAt: json['undeployedAt'] == null
          ? null
          : DateTime.parse(json['undeployedAt'] as String),
      deployedBy: json['deployedBy'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ModelDeploymentToJson(ModelDeployment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'environment': instance.environment,
      'status': instance.status,
      'endpoint': instance.endpoint,
      'configuration': instance.configuration,
      'resources': instance.resources,
      'monitoring': instance.monitoring,
      'deployedAt': instance.deployedAt.toIso8601String(),
      'undeployedAt': instance.undeployedAt?.toIso8601String(),
      'deployedBy': instance.deployedBy,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TrainingProgress _$TrainingProgressFromJson(Map<String, dynamic> json) =>
    TrainingProgress(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      currentEpoch: (json['currentEpoch'] as num).toInt(),
      totalEpochs: (json['totalEpochs'] as num).toInt(),
      progress: (json['progress'] as num).toDouble(),
      currentLoss: (json['currentLoss'] as num).toDouble(),
      currentAccuracy: (json['currentAccuracy'] as num).toDouble(),
      learningRate: (json['learningRate'] as num).toDouble(),
      metrics: json['metrics'] as Map<String, dynamic>,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TrainingProgressToJson(TrainingProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'currentEpoch': instance.currentEpoch,
      'totalEpochs': instance.totalEpochs,
      'progress': instance.progress,
      'currentLoss': instance.currentLoss,
      'currentAccuracy': instance.currentAccuracy,
      'learningRate': instance.learningRate,
      'metrics': instance.metrics,
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

DataPreprocessingPipeline _$DataPreprocessingPipelineFromJson(
  Map<String, dynamic> json,
) => DataPreprocessingPipeline(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
  configuration: json['configuration'] as Map<String, dynamic>,
  parameters: json['parameters'] as Map<String, dynamic>,
  inputFormats: (json['inputFormats'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  outputFormats: (json['outputFormats'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  validation: json['validation'] as Map<String, dynamic>,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$DataPreprocessingPipelineToJson(
  DataPreprocessingPipeline instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'steps': instance.steps,
  'configuration': instance.configuration,
  'parameters': instance.parameters,
  'inputFormats': instance.inputFormats,
  'outputFormats': instance.outputFormats,
  'validation': instance.validation,
  'tags': instance.tags,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
};

ModelVersion _$ModelVersionFromJson(Map<String, dynamic> json) => ModelVersion(
  id: json['id'] as String,
  modelId: json['modelId'] as String,
  version: json['version'] as String,
  description: json['description'] as String,
  changes: json['changes'] as Map<String, dynamic>,
  commitHash: json['commitHash'] as String,
  branch: json['branch'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isStable: json['isStable'] as bool,
);

Map<String, dynamic> _$ModelVersionToJson(ModelVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'version': instance.version,
      'description': instance.description,
      'changes': instance.changes,
      'commitHash': instance.commitHash,
      'branch': instance.branch,
      'metadata': instance.metadata,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isStable': instance.isStable,
    };
