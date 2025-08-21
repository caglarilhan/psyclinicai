import 'package:json_annotation/json_annotation.dart';

part 'ai_case_management_models.g.dart';

// ===== AI VAKA YÖNETİMİ MODELLERİ =====

@JsonSerializable()
class AICase {
  final String id;
  final String title;
  final String description;
  final String clientId;
  final String clinicianId;
  final String status;
  final String priority;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AICase({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    required this.clinicianId,
    required this.status,
    required this.priority,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AICase.fromJson(Map<String, dynamic> json) =>
      _$AICaseFromJson(json);

  Map<String, dynamic> toJson() => _$AICaseToJson(this);

  AICase copyWith({
    String? id,
    String? title,
    String? description,
    String? clientId,
    String? clinicianId,
    String? status,
    String? priority,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AICase(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      clinicianId: clinicianId ?? this.clinicianId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class AITask {
  final String id;
  final String caseId;
  final String title;
  final String description;
  final String type;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AITask({
    required this.id,
    required this.caseId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    this.dueDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AITask.fromJson(Map<String, dynamic> json) =>
      _$AITaskFromJson(json);

  Map<String, dynamic> toJson() => _$AITaskToJson(this);

  AITask copyWith({
    String? id,
    String? caseId,
    String? title,
    String? description,
    String? type,
    String? status,
    String? priority,
    DateTime? dueDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AITask(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class AIAnalysis {
  final String id;
  final String caseId;
  final String type;
  final String content;
  final double confidence;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  AIAnalysis({
    required this.id,
    required this.caseId,
    required this.type,
    required this.content,
    required this.confidence,
    this.metadata,
    required this.createdAt,
  });

  factory AIAnalysis.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$AIAnalysisToJson(this);
}

@JsonSerializable()
class AIModelPerformance {
  final String modelId;
  final int totalTasks;
  final int successfulTasks;
  final double averageResponseTime;
  final DateTime lastUpdated;

  AIModelPerformance({
    required this.modelId,
    required this.totalTasks,
    required this.successfulTasks,
    required this.averageResponseTime,
    required this.lastUpdated,
  });

  factory AIModelPerformance.fromJson(Map<String, dynamic> json) =>
      _$AIModelPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$AIModelPerformanceToJson(this);

  AIModelPerformance copyWith({
    String? modelId,
    int? totalTasks,
    int? successfulTasks,
    double? averageResponseTime,
    DateTime? lastUpdated,
  }) {
    return AIModelPerformance(
      modelId: modelId ?? this.modelId,
      totalTasks: totalTasks ?? this.totalTasks,
      successfulTasks: successfulTasks ?? this.successfulTasks,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

@JsonSerializable()
class AITaskResult {
  final String taskId;
  final String modelId;
  final bool isSuccessful;
  final double responseTime;
  final DateTime timestamp;

  AITaskResult({
    required this.taskId,
    required this.modelId,
    required this.isSuccessful,
    required this.responseTime,
    required this.timestamp,
  });

  factory AITaskResult.fromJson(Map<String, dynamic> json) =>
      _$AITaskResultFromJson(json);

  Map<String, dynamic> toJson() => _$AITaskResultToJson(this);
}

@JsonSerializable()
class CasePriority {
  final String id;
  final String caseId;
  final String caseTitle;
  final String priority;
  final String riskLevel;
  final double aiConfidence;
  final DateTime lastUpdated;
  final String? notes;

  CasePriority({
    required this.id,
    required this.caseId,
    required this.caseTitle,
    required this.priority,
    required this.riskLevel,
    required this.aiConfidence,
    required this.lastUpdated,
    this.notes,
  });

  factory CasePriority.fromJson(Map<String, dynamic> json) =>
      _$CasePriorityFromJson(json);

  Map<String, dynamic> toJson() => _$CasePriorityToJson(this);
}

@JsonSerializable()
class AICaseAnalysis {
  final String id;
  final String caseId;
  final String clientId;
  final String therapistId;
  final DateTime analysisDate;
  final String type;
  final double confidence;
  final String summary;
  final List<String> insights;
  final List<String> riskFactors;
  final List<String> recommendations;
  final Map<String, dynamic> data;
  final String? notes;
  final bool isActive;

  AICaseAnalysis({
    required this.id,
    required this.caseId,
    required this.clientId,
    required this.therapistId,
    required this.analysisDate,
    required this.type,
    required this.confidence,
    required this.summary,
    required this.insights,
    required this.riskFactors,
    required this.recommendations,
    required this.data,
    this.notes,
    required this.isActive,
  });

  factory AICaseAnalysis.fromJson(Map<String, dynamic> json) =>
      _$AICaseAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$AICaseAnalysisToJson(this);
}

@JsonSerializable()
class ProgressTracking {
  final String id;
  final String caseId;
  final String clientId;
  final String therapistId;
  final DateTime assessmentDate;
  final String status;
  final double overallProgress;
  final Map<String, dynamic> data;

  ProgressTracking({
    required this.id,
    required this.caseId,
    required this.clientId,
    required this.therapistId,
    required this.assessmentDate,
    required this.status,
    required this.overallProgress,
    required this.data,
  });

  factory ProgressTracking.fromJson(Map<String, dynamic> json) =>
      _$ProgressTrackingFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressTrackingToJson(this);
}
