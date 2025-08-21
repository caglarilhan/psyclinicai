// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_insight_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionInsight _$SessionInsightFromJson(Map<String, dynamic> json) =>
    SessionInsight(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
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

Map<String, dynamic> _$SessionInsightToJson(SessionInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'type': instance.type,
      'content': instance.content,
      'confidence': instance.confidence,
      'timestamp': instance.timestamp.toIso8601String(),
      'supportingData': instance.supportingData,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
    };

SessionRiskAssessment _$SessionRiskAssessmentFromJson(
  Map<String, dynamic> json,
) => SessionRiskAssessment(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  riskType: json['riskType'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  indicators: (json['indicators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$SessionRiskAssessmentToJson(
  SessionRiskAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'riskType': instance.riskType,
  'severity': instance.severity,
  'description': instance.description,
  'indicators': instance.indicators,
  'actions': instance.actions,
  'timestamp': instance.timestamp.toIso8601String(),
  'isActive': instance.isActive,
};

SessionIntervention _$SessionInterventionFromJson(Map<String, dynamic> json) =>
    SessionIntervention(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      rationale: json['rationale'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isImplemented: json['isImplemented'] as bool,
      outcome: json['outcome'] as String?,
    );

Map<String, dynamic> _$SessionInterventionToJson(
  SessionIntervention instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'type': instance.type,
  'description': instance.description,
  'rationale': instance.rationale,
  'timestamp': instance.timestamp.toIso8601String(),
  'isImplemented': instance.isImplemented,
  'outcome': instance.outcome,
};
