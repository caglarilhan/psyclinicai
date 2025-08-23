// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_training_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingJob _$TrainingJobFromJson(Map<String, dynamic> json) => TrainingJob(
  id: json['id'] as String,
  modelName: json['modelName'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$ModelCategoryEnumMap, json['category']),
  templateId: json['templateId'] as String,
  templateName: json['templateName'] as String,
  datasetId: json['datasetId'] as String,
  datasetName: json['datasetName'] as String,
  status: $enumDecode(_$TrainingStatusEnumMap, json['status']),
  progress: (json['progress'] as num).toInt(),
  currentEpoch: (json['currentEpoch'] as num).toInt(),
  totalEpochs: (json['totalEpochs'] as num).toInt(),
  currentAccuracy: (json['currentAccuracy'] as num).toDouble(),
  currentLoss: (json['currentLoss'] as num).toDouble(),
  elapsedTime: Duration(microseconds: (json['elapsedTime'] as num).toInt()),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
  logs: (json['logs'] as List<dynamic>).map((e) => e as String).toList(),
  errorMessage: json['errorMessage'] as String?,
  metrics: json['metrics'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$TrainingJobToJson(TrainingJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelName': instance.modelName,
      'description': instance.description,
      'category': _$ModelCategoryEnumMap[instance.category]!,
      'templateId': instance.templateId,
      'templateName': instance.templateName,
      'datasetId': instance.datasetId,
      'datasetName': instance.datasetName,
      'status': _$TrainingStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'currentEpoch': instance.currentEpoch,
      'totalEpochs': instance.totalEpochs,
      'currentAccuracy': instance.currentAccuracy,
      'currentLoss': instance.currentLoss,
      'elapsedTime': instance.elapsedTime.inMicroseconds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'hyperparameters': instance.hyperparameters,
      'logs': instance.logs,
      'errorMessage': instance.errorMessage,
      'metrics': instance.metrics,
    };

const _$ModelCategoryEnumMap = {
  ModelCategory.diagnosis: 'diagnosis',
  ModelCategory.treatment: 'treatment',
  ModelCategory.riskAssessment: 'riskAssessment',
  ModelCategory.prognosis: 'prognosis',
  ModelCategory.screening: 'screening',
  ModelCategory.monitoring: 'monitoring',
};

const _$TrainingStatusEnumMap = {
  TrainingStatus.pending: 'pending',
  TrainingStatus.running: 'running',
  TrainingStatus.paused: 'paused',
  TrainingStatus.completed: 'completed',
  TrainingStatus.failed: 'failed',
};

CustomModel _$CustomModelFromJson(Map<String, dynamic> json) => CustomModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$ModelCategoryEnumMap, json['category']),
  version: json['version'] as String,
  size: (json['size'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  performance: ModelPerformance.fromJson(
    json['performance'] as Map<String, dynamic>,
  ),
  metadata: json['metadata'] as Map<String, dynamic>,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  isDeployed: json['isDeployed'] as bool,
  deploymentUrl: json['deploymentUrl'] as String?,
  configuration: json['configuration'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CustomModelToJson(CustomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$ModelCategoryEnumMap[instance.category]!,
      'version': instance.version,
      'size': instance.size,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'performance': instance.performance,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'isDeployed': instance.isDeployed,
      'deploymentUrl': instance.deploymentUrl,
      'configuration': instance.configuration,
    };

ModelPerformance _$ModelPerformanceFromJson(Map<String, dynamic> json) =>
    ModelPerformance(
      accuracy: (json['accuracy'] as num).toDouble(),
      precision: (json['precision'] as num).toDouble(),
      recall: (json['recall'] as num).toDouble(),
      f1Score: (json['f1Score'] as num).toDouble(),
      auc: (json['auc'] as num).toDouble(),
      mse: (json['mse'] as num).toDouble(),
      mae: (json['mae'] as num).toDouble(),
      classMetrics: (json['classMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      customMetrics: (json['customMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$ModelPerformanceToJson(ModelPerformance instance) =>
    <String, dynamic>{
      'accuracy': instance.accuracy,
      'precision': instance.precision,
      'recall': instance.recall,
      'f1Score': instance.f1Score,
      'auc': instance.auc,
      'mse': instance.mse,
      'mae': instance.mae,
      'classMetrics': instance.classMetrics,
      'customMetrics': instance.customMetrics,
    };

Dataset _$DatasetFromJson(Map<String, dynamic> json) => Dataset(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  format: $enumDecode(_$DatasetFormatEnumMap, json['format']),
  samples: (json['samples'] as num).toInt(),
  features: (json['features'] as num).toInt(),
  size: (json['size'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  quality: (json['quality'] as num).toDouble(),
  trainSplit: (json['trainSplit'] as num).toDouble(),
  validationSplit: (json['validationSplit'] as num).toDouble(),
  testSplit: (json['testSplit'] as num).toDouble(),
  schema: json['schema'] as Map<String, dynamic>,
  columns: (json['columns'] as List<dynamic>).map((e) => e as String).toList(),
  statistics: json['statistics'] as Map<String, dynamic>,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  source: json['source'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DatasetToJson(Dataset instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'format': _$DatasetFormatEnumMap[instance.format]!,
  'samples': instance.samples,
  'features': instance.features,
  'size': instance.size,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'quality': instance.quality,
  'trainSplit': instance.trainSplit,
  'validationSplit': instance.validationSplit,
  'testSplit': instance.testSplit,
  'schema': instance.schema,
  'columns': instance.columns,
  'statistics': instance.statistics,
  'tags': instance.tags,
  'source': instance.source,
  'metadata': instance.metadata,
};

const _$DatasetFormatEnumMap = {
  DatasetFormat.csv: 'csv',
  DatasetFormat.json: 'json',
  DatasetFormat.parquet: 'parquet',
  DatasetFormat.hdf5: 'hdf5',
  DatasetFormat.numpy: 'numpy',
  DatasetFormat.pandas: 'pandas',
};

ModelTemplate _$ModelTemplateFromJson(Map<String, dynamic> json) =>
    ModelTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$ModelCategoryEnumMap, json['category']),
      architecture: json['architecture'] as String,
      parameters: (json['parameters'] as num).toInt(),
      size: (json['size'] as num).toDouble(),
      supportedTasks: (json['supportedTasks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      defaultHyperparameters:
          json['defaultHyperparameters'] as Map<String, dynamic>,
      constraints: json['constraints'] as Map<String, dynamic>,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      paperUrl: json['paperUrl'] as String?,
      repositoryUrl: json['repositoryUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModelTemplateToJson(ModelTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$ModelCategoryEnumMap[instance.category]!,
      'architecture': instance.architecture,
      'parameters': instance.parameters,
      'size': instance.size,
      'supportedTasks': instance.supportedTasks,
      'defaultHyperparameters': instance.defaultHyperparameters,
      'constraints': instance.constraints,
      'requirements': instance.requirements,
      'paperUrl': instance.paperUrl,
      'repositoryUrl': instance.repositoryUrl,
      'metadata': instance.metadata,
    };

TrainingConfig _$TrainingConfigFromJson(Map<String, dynamic> json) =>
    TrainingConfig(
      modelName: json['modelName'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$ModelCategoryEnumMap, json['category']),
      templateId: json['templateId'] as String,
      datasetId: json['datasetId'] as String,
      learningRate: (json['learningRate'] as num).toDouble(),
      epochs: (json['epochs'] as num).toInt(),
      batchSize: (json['batchSize'] as num).toInt(),
      validationSplit: (json['validationSplit'] as num).toDouble(),
      hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
      augmentation: json['augmentation'] as Map<String, dynamic>,
      callbacks: json['callbacks'] as Map<String, dynamic>,
      optimizer: json['optimizer'] as Map<String, dynamic>,
      lossFunction: json['lossFunction'] as Map<String, dynamic>,
      metrics: json['metrics'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TrainingConfigToJson(TrainingConfig instance) =>
    <String, dynamic>{
      'modelName': instance.modelName,
      'description': instance.description,
      'category': _$ModelCategoryEnumMap[instance.category]!,
      'templateId': instance.templateId,
      'datasetId': instance.datasetId,
      'learningRate': instance.learningRate,
      'epochs': instance.epochs,
      'batchSize': instance.batchSize,
      'validationSplit': instance.validationSplit,
      'hyperparameters': instance.hyperparameters,
      'augmentation': instance.augmentation,
      'callbacks': instance.callbacks,
      'optimizer': instance.optimizer,
      'lossFunction': instance.lossFunction,
      'metrics': instance.metrics,
    };

TrainingMetrics _$TrainingMetricsFromJson(Map<String, dynamic> json) =>
    TrainingMetrics(
      loss: (json['loss'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      valLoss: (json['valLoss'] as num).toDouble(),
      valAccuracy: (json['valAccuracy'] as num).toDouble(),
      epoch: (json['epoch'] as num).toInt(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      customMetrics: (json['customMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TrainingMetricsToJson(TrainingMetrics instance) =>
    <String, dynamic>{
      'loss': instance.loss,
      'accuracy': instance.accuracy,
      'valLoss': instance.valLoss,
      'valAccuracy': instance.valAccuracy,
      'epoch': instance.epoch,
      'duration': instance.duration.inMicroseconds,
      'customMetrics': instance.customMetrics,
      'metadata': instance.metadata,
    };

TrainingLog _$TrainingLogFromJson(Map<String, dynamic> json) => TrainingLog(
  timestamp: DateTime.parse(json['timestamp'] as String),
  level: json['level'] as String,
  message: json['message'] as String,
  data: json['data'] as Map<String, dynamic>?,
  source: json['source'] as String?,
);

Map<String, dynamic> _$TrainingLogToJson(TrainingLog instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'level': instance.level,
      'message': instance.message,
      'data': instance.data,
      'source': instance.source,
    };

DeploymentConfig _$DeploymentConfigFromJson(Map<String, dynamic> json) =>
    DeploymentConfig(
      modelId: json['modelId'] as String,
      environment: json['environment'] as String,
      resources: json['resources'] as Map<String, dynamic>,
      scaling: json['scaling'] as Map<String, dynamic>,
      monitoring: json['monitoring'] as Map<String, dynamic>,
      security: json['security'] as Map<String, dynamic>,
      endpoints: (json['endpoints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DeploymentConfigToJson(DeploymentConfig instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'environment': instance.environment,
      'resources': instance.resources,
      'scaling': instance.scaling,
      'monitoring': instance.monitoring,
      'security': instance.security,
      'endpoints': instance.endpoints,
      'metadata': instance.metadata,
    };

ModelEvaluation _$ModelEvaluationFromJson(Map<String, dynamic> json) =>
    ModelEvaluation(
      modelId: json['modelId'] as String,
      datasetId: json['datasetId'] as String,
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
      performance: ModelPerformance.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
      predictions: json['predictions'] as Map<String, dynamic>,
      confusionMatrix: json['confusionMatrix'] as Map<String, dynamic>,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ModelEvaluationToJson(ModelEvaluation instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'datasetId': instance.datasetId,
      'evaluatedAt': instance.evaluatedAt.toIso8601String(),
      'performance': instance.performance,
      'predictions': instance.predictions,
      'confusionMatrix': instance.confusionMatrix,
      'errors': instance.errors,
      'metadata': instance.metadata,
    };

TrainingJobRequest _$TrainingJobRequestFromJson(Map<String, dynamic> json) =>
    TrainingJobRequest(
      modelName: json['modelName'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$ModelCategoryEnumMap, json['category']),
      templateId: json['templateId'] as String,
      datasetId: json['datasetId'] as String,
      learningRate: (json['learningRate'] as num).toDouble(),
      epochs: (json['epochs'] as num).toInt(),
      batchSize: (json['batchSize'] as num).toInt(),
      validationSplit: (json['validationSplit'] as num).toDouble(),
      customHyperparameters:
          json['customHyperparameters'] as Map<String, dynamic>?,
      augmentation: json['augmentation'] as Map<String, dynamic>?,
      callbacks: json['callbacks'] as Map<String, dynamic>?,
      optimizer: json['optimizer'] as Map<String, dynamic>?,
      lossFunction: json['lossFunction'] as Map<String, dynamic>?,
      metrics: json['metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TrainingJobRequestToJson(TrainingJobRequest instance) =>
    <String, dynamic>{
      'modelName': instance.modelName,
      'description': instance.description,
      'category': _$ModelCategoryEnumMap[instance.category]!,
      'templateId': instance.templateId,
      'datasetId': instance.datasetId,
      'learningRate': instance.learningRate,
      'epochs': instance.epochs,
      'batchSize': instance.batchSize,
      'validationSplit': instance.validationSplit,
      'customHyperparameters': instance.customHyperparameters,
      'augmentation': instance.augmentation,
      'callbacks': instance.callbacks,
      'optimizer': instance.optimizer,
      'lossFunction': instance.lossFunction,
      'metrics': instance.metrics,
    };

TrainingJobResponse _$TrainingJobResponseFromJson(Map<String, dynamic> json) =>
    TrainingJobResponse(
      success: json['success'] as bool,
      jobId: json['jobId'] as String?,
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TrainingJobResponseToJson(
  TrainingJobResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'jobId': instance.jobId,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

ModelExportConfig _$ModelExportConfigFromJson(Map<String, dynamic> json) =>
    ModelExportConfig(
      modelId: json['modelId'] as String,
      format: json['format'] as String,
      options: json['options'] as Map<String, dynamic>,
      includeMetadata: json['includeMetadata'] as bool,
      includeWeights: json['includeWeights'] as bool,
      outputPath: json['outputPath'] as String?,
      customOptions: json['customOptions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModelExportConfigToJson(ModelExportConfig instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'format': instance.format,
      'options': instance.options,
      'includeMetadata': instance.includeMetadata,
      'includeWeights': instance.includeWeights,
      'outputPath': instance.outputPath,
      'customOptions': instance.customOptions,
    };

DatasetUploadConfig _$DatasetUploadConfigFromJson(Map<String, dynamic> json) =>
    DatasetUploadConfig(
      name: json['name'] as String,
      description: json['description'] as String,
      format: $enumDecode(_$DatasetFormatEnumMap, json['format']),
      filePath: json['filePath'] as String,
      trainSplit: (json['trainSplit'] as num).toDouble(),
      validationSplit: (json['validationSplit'] as num).toDouble(),
      testSplit: (json['testSplit'] as num).toDouble(),
      schema: json['schema'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DatasetUploadConfigToJson(
  DatasetUploadConfig instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'format': _$DatasetFormatEnumMap[instance.format]!,
  'filePath': instance.filePath,
  'trainSplit': instance.trainSplit,
  'validationSplit': instance.validationSplit,
  'testSplit': instance.testSplit,
  'schema': instance.schema,
  'tags': instance.tags,
  'metadata': instance.metadata,
};

DatasetValidationResult _$DatasetValidationResultFromJson(
  Map<String, dynamic> json,
) => DatasetValidationResult(
  isValid: json['isValid'] as bool,
  samples: (json['samples'] as num).toInt(),
  features: (json['features'] as num).toInt(),
  size: (json['size'] as num).toDouble(),
  quality: (json['quality'] as num).toDouble(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
  statistics: json['statistics'] as Map<String, dynamic>,
  schema: json['schema'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DatasetValidationResultToJson(
  DatasetValidationResult instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'samples': instance.samples,
  'features': instance.features,
  'size': instance.size,
  'quality': instance.quality,
  'warnings': instance.warnings,
  'errors': instance.errors,
  'statistics': instance.statistics,
  'schema': instance.schema,
};
