// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_performance_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIModelPerformance _$AIModelPerformanceFromJson(Map<String, dynamic> json) =>
    AIModelPerformance(
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      taskType: json['taskType'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      responseTime: (json['responseTime'] as num).toDouble(),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      totalRequests: (json['totalRequests'] as num).toInt(),
      successfulRequests: (json['successfulRequests'] as num).toInt(),
      failedRequests: (json['failedRequests'] as num).toInt(),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AIModelPerformanceToJson(AIModelPerformance instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'modelName': instance.modelName,
      'taskType': instance.taskType,
      'accuracy': instance.accuracy,
      'responseTime': instance.responseTime,
      'confidenceScore': instance.confidenceScore,
      'totalRequests': instance.totalRequests,
      'successfulRequests': instance.successfulRequests,
      'failedRequests': instance.failedRequests,
      'lastUsed': instance.lastUsed.toIso8601String(),
      'metadata': instance.metadata,
    };

AITaskResult _$AITaskResultFromJson(Map<String, dynamic> json) => AITaskResult(
  taskId: json['taskId'] as String,
  modelId: json['modelId'] as String,
  taskType: json['taskType'] as String,
  success: json['success'] as bool,
  confidence: (json['confidence'] as num).toDouble(),
  responseTime: Duration(microseconds: (json['responseTime'] as num).toInt()),
  errorMessage: json['errorMessage'] as String?,
  result: json['result'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$AITaskResultToJson(AITaskResult instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'modelId': instance.modelId,
      'taskType': instance.taskType,
      'success': instance.success,
      'confidence': instance.confidence,
      'responseTime': instance.responseTime.inMicroseconds,
      'errorMessage': instance.errorMessage,
      'result': instance.result,
      'timestamp': instance.timestamp.toIso8601String(),
    };

AIModelComparison _$AIModelComparisonFromJson(Map<String, dynamic> json) =>
    AIModelComparison(
      taskType: json['taskType'] as String,
      models: (json['models'] as List<dynamic>)
          .map((e) => AIModelPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedModel: json['recommendedModel'] as String?,
      comparisonDate: DateTime.parse(json['comparisonDate'] as String),
    );

Map<String, dynamic> _$AIModelComparisonToJson(AIModelComparison instance) =>
    <String, dynamic>{
      'taskType': instance.taskType,
      'models': instance.models,
      'recommendedModel': instance.recommendedModel,
      'comparisonDate': instance.comparisonDate.toIso8601String(),
    };
