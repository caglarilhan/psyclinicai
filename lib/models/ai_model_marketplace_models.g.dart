// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model_marketplace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIModel _$AIModelFromJson(Map<String, dynamic> json) => AIModel(
  id: json['id'] as String,
  name: json['name'] as String,
  provider: json['provider'] as String,
  description: json['description'] as String,
  capabilities: (json['capabilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  parameters: json['parameters'] as Map<String, dynamic>,
  costPerToken: (json['costPerToken'] as num).toDouble(),
  costPerRequest: (json['costPerRequest'] as num).toDouble(),
  rating: (json['rating'] as num).toDouble(),
  usageCount: (json['usageCount'] as num).toInt(),
  isActive: json['isActive'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AIModelToJson(AIModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'provider': instance.provider,
  'description': instance.description,
  'capabilities': instance.capabilities,
  'supportedLanguages': instance.supportedLanguages,
  'parameters': instance.parameters,
  'costPerToken': instance.costPerToken,
  'costPerRequest': instance.costPerRequest,
  'rating': instance.rating,
  'usageCount': instance.usageCount,
  'isActive': instance.isActive,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'metadata': instance.metadata,
};

AIModelInstance _$AIModelInstanceFromJson(Map<String, dynamic> json) =>
    AIModelInstance(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      configuration: json['configuration'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      totalRequests: (json['totalRequests'] as num).toInt(),
      totalCost: (json['totalCost'] as num).toDouble(),
      performance: json['performance'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AIModelInstanceToJson(AIModelInstance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'name': instance.name,
      'provider': instance.provider,
      'configuration': instance.configuration,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'totalRequests': instance.totalRequests,
      'totalCost': instance.totalCost,
      'performance': instance.performance,
    };

AIModelPerformance _$AIModelPerformanceFromJson(Map<String, dynamic> json) =>
    AIModelPerformance(
      modelId: json['modelId'] as String,
      modelName: json['modelName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      responseTime: (json['responseTime'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      costEfficiency: (json['costEfficiency'] as num).toDouble(),
      requestsProcessed: (json['requestsProcessed'] as num).toInt(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      customMetrics: json['customMetrics'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AIModelPerformanceToJson(AIModelPerformance instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'modelName': instance.modelName,
      'timestamp': instance.timestamp.toIso8601String(),
      'responseTime': instance.responseTime,
      'accuracy': instance.accuracy,
      'costEfficiency': instance.costEfficiency,
      'requestsProcessed': instance.requestsProcessed,
      'errors': instance.errors,
      'customMetrics': instance.customMetrics,
    };

AIModelRequest _$AIModelRequestFromJson(Map<String, dynamic> json) =>
    AIModelRequest(
      modelId: json['modelId'] as String,
      prompt: json['prompt'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
      context: json['context'] as String?,
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AIModelRequestToJson(AIModelRequest instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'prompt': instance.prompt,
      'parameters': instance.parameters,
      'context': instance.context,
      'examples': instance.examples,
      'metadata': instance.metadata,
    };

AIModelResponse _$AIModelResponseFromJson(Map<String, dynamic> json) =>
    AIModelResponse(
      requestId: json['requestId'] as String,
      modelId: json['modelId'] as String,
      response: json['response'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      cost: (json['cost'] as num).toDouble(),
      tokensUsed: (json['tokensUsed'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSuccess: json['isSuccess'] as bool,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$AIModelResponseToJson(AIModelResponse instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'modelId': instance.modelId,
      'response': instance.response,
      'metadata': instance.metadata,
      'cost': instance.cost,
      'tokensUsed': instance.tokensUsed,
      'timestamp': instance.timestamp.toIso8601String(),
      'isSuccess': instance.isSuccess,
      'error': instance.error,
    };
