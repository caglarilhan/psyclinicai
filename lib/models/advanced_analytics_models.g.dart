// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BIDashboardData _$BIDashboardDataFromJson(Map<String, dynamic> json) =>
    BIDashboardData(
      financialMetrics: json['financialMetrics'] as Map<String, dynamic>,
      operationalMetrics: json['operationalMetrics'] as Map<String, dynamic>,
      patientMetrics: json['patientMetrics'] as Map<String, dynamic>,
      staffMetrics: json['staffMetrics'] as Map<String, dynamic>,
      qualityMetrics: json['qualityMetrics'] as Map<String, dynamic>,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$BIDashboardDataToJson(BIDashboardData instance) =>
    <String, dynamic>{
      'financialMetrics': instance.financialMetrics,
      'operationalMetrics': instance.operationalMetrics,
      'patientMetrics': instance.patientMetrics,
      'staffMetrics': instance.staffMetrics,
      'qualityMetrics': instance.qualityMetrics,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

PredictiveModel _$PredictiveModelFromJson(Map<String, dynamic> json) =>
    PredictiveModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      lastTrained: DateTime.parse(json['lastTrained'] as String),
      parameters: json['parameters'] as Map<String, dynamic>,
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performance: json['performance'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PredictiveModelToJson(PredictiveModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'accuracy': instance.accuracy,
      'lastTrained': instance.lastTrained.toIso8601String(),
      'parameters': instance.parameters,
      'features': instance.features,
      'performance': instance.performance,
    };

PerformanceMetrics _$PerformanceMetricsFromJson(Map<String, dynamic> json) =>
    PerformanceMetrics(
      metricId: json['metricId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      previousValue: (json['previousValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      changePercentage: (json['changePercentage'] as num).toDouble(),
      trend: json['trend'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PerformanceMetricsToJson(PerformanceMetrics instance) =>
    <String, dynamic>{
      'metricId': instance.metricId,
      'name': instance.name,
      'category': instance.category,
      'currentValue': instance.currentValue,
      'previousValue': instance.previousValue,
      'targetValue': instance.targetValue,
      'changePercentage': instance.changePercentage,
      'trend': instance.trend,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'metadata': instance.metadata,
    };
