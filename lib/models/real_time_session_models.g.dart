// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'real_time_session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealTimeSessionData _$RealTimeSessionDataFromJson(Map<String, dynamic> json) =>
    RealTimeSessionData(
      sessionId: json['sessionId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
      metrics: (json['metrics'] as List<dynamic>)
          .map((e) => RealTimeMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => SessionAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiInsights: (json['aiInsights'] as List<dynamic>)
          .map((e) => AIInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RealTimeSessionDataToJson(
  RealTimeSessionData instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'status': instance.status,
  'metrics': instance.metrics,
  'alerts': instance.alerts,
  'aiInsights': instance.aiInsights,
  'metadata': instance.metadata,
};

RealTimeMetric _$RealTimeMetricFromJson(Map<String, dynamic> json) =>
    RealTimeMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      threshold: json['threshold'] as String?,
      isAlert: json['isAlert'] as bool,
    );

Map<String, dynamic> _$RealTimeMetricToJson(RealTimeMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'value': instance.value,
      'unit': instance.unit,
      'timestamp': instance.timestamp.toIso8601String(),
      'threshold': instance.threshold,
      'isAlert': instance.isAlert,
    };

SessionAlert _$SessionAlertFromJson(Map<String, dynamic> json) => SessionAlert(
  id: json['id'] as String,
  type: json['type'] as String,
  severity: json['severity'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isActive: json['isActive'] as bool,
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  context: json['context'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SessionAlertToJson(SessionAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'severity': instance.severity,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'isActive': instance.isActive,
      'actions': instance.actions,
      'context': instance.context,
    };

AIInsight _$AIInsightFromJson(Map<String, dynamic> json) => AIInsight(
  id: json['id'] as String,
  type: json['type'] as String,
  content: json['content'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  supportingData: (json['supportingData'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AIInsightToJson(AIInsight instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'content': instance.content,
  'confidence': instance.confidence,
  'timestamp': instance.timestamp.toIso8601String(),
  'supportingData': instance.supportingData,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
