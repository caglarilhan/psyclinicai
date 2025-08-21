// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_case_management_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AICase _$AICaseFromJson(Map<String, dynamic> json) => AICase(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  clientId: json['clientId'] as String,
  clinicianId: json['clinicianId'] as String,
  status: json['status'] as String,
  priority: json['priority'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AICaseToJson(AICase instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'clientId': instance.clientId,
  'clinicianId': instance.clinicianId,
  'status': instance.status,
  'priority': instance.priority,
  'tags': instance.tags,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

AITask _$AITaskFromJson(Map<String, dynamic> json) => AITask(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: json['type'] as String,
  status: json['status'] as String,
  priority: json['priority'] as String,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AITaskToJson(AITask instance) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'title': instance.title,
  'description': instance.description,
  'type': instance.type,
  'status': instance.status,
  'priority': instance.priority,
  'dueDate': instance.dueDate?.toIso8601String(),
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

AIAnalysis _$AIAnalysisFromJson(Map<String, dynamic> json) => AIAnalysis(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  type: json['type'] as String,
  content: json['content'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AIAnalysisToJson(AIAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'type': instance.type,
      'content': instance.content,
      'confidence': instance.confidence,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AIModelPerformance _$AIModelPerformanceFromJson(Map<String, dynamic> json) =>
    AIModelPerformance(
      modelId: json['modelId'] as String,
      totalTasks: (json['totalTasks'] as num).toInt(),
      successfulTasks: (json['successfulTasks'] as num).toInt(),
      averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$AIModelPerformanceToJson(AIModelPerformance instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'totalTasks': instance.totalTasks,
      'successfulTasks': instance.successfulTasks,
      'averageResponseTime': instance.averageResponseTime,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

AITaskResult _$AITaskResultFromJson(Map<String, dynamic> json) => AITaskResult(
  taskId: json['taskId'] as String,
  modelId: json['modelId'] as String,
  isSuccessful: json['isSuccessful'] as bool,
  responseTime: (json['responseTime'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$AITaskResultToJson(AITaskResult instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'modelId': instance.modelId,
      'isSuccessful': instance.isSuccessful,
      'responseTime': instance.responseTime,
      'timestamp': instance.timestamp.toIso8601String(),
    };

CasePriority _$CasePriorityFromJson(Map<String, dynamic> json) => CasePriority(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  caseTitle: json['caseTitle'] as String,
  priority: json['priority'] as String,
  riskLevel: json['riskLevel'] as String,
  aiConfidence: (json['aiConfidence'] as num).toDouble(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CasePriorityToJson(CasePriority instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'caseTitle': instance.caseTitle,
      'priority': instance.priority,
      'riskLevel': instance.riskLevel,
      'aiConfidence': instance.aiConfidence,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'notes': instance.notes,
    };

AICaseAnalysis _$AICaseAnalysisFromJson(Map<String, dynamic> json) =>
    AICaseAnalysis(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      type: json['type'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      summary: json['summary'] as String,
      insights: (json['insights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      data: json['data'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$AICaseAnalysisToJson(AICaseAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'type': instance.type,
      'confidence': instance.confidence,
      'summary': instance.summary,
      'insights': instance.insights,
      'riskFactors': instance.riskFactors,
      'recommendations': instance.recommendations,
      'data': instance.data,
      'notes': instance.notes,
      'isActive': instance.isActive,
    };

ProgressTracking _$ProgressTrackingFromJson(Map<String, dynamic> json) =>
    ProgressTracking(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      status: json['status'] as String,
      overallProgress: (json['overallProgress'] as num).toDouble(),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ProgressTrackingToJson(ProgressTracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caseId': instance.caseId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'status': instance.status,
      'overallProgress': instance.overallProgress,
      'data': instance.data,
    };
