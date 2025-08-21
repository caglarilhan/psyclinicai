import 'package:json_annotation/json_annotation.dart';

part 'ai_orchestration_models.g.dart';

// ===== AI ORKESTRASYON MODELLERİ =====

@JsonSerializable()
class AIWorkflow {
  final String id;
  final String name;
  final String description;
  final List<AIWorkflowStep> steps;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AIWorkflow({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AIWorkflow.fromJson(Map<String, dynamic> json) =>
      _$AIWorkflowFromJson(json);

  Map<String, dynamic> toJson() => _$AIWorkflowToJson(this);
}

@JsonSerializable()
class AIWorkflowStep {
  final String id;
  final String name;
  final String type;
  final int order;
  final List<String> dependencies;
  final Map<String, dynamic> parameters;
  final bool isCompleted;

  AIWorkflowStep({
    required this.id,
    required this.name,
    required this.type,
    required this.order,
    required this.dependencies,
    required this.parameters,
    this.isCompleted = false,
  });

  factory AIWorkflowStep.fromJson(Map<String, dynamic> json) =>
      _$AIWorkflowStepFromJson(json);

  Map<String, dynamic> toJson() => _$AIWorkflowStepToJson(this);

  AIWorkflowStep copyWith({
    String? id,
    String? name,
    String? type,
    int? order,
    List<String>? dependencies,
    Map<String, dynamic>? parameters,
    bool? isCompleted,
  }) {
    return AIWorkflowStep(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      order: order ?? this.order,
      dependencies: dependencies ?? this.dependencies,
      parameters: parameters ?? this.parameters,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@JsonSerializable()
class AIOrchestrationTask {
  final String id;
  final String workflowId;
  final String clientId;
  final String clinicianId;
  final String status;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> parameters;
  final int currentStep;
  final int totalSteps;
  final Map<String, dynamic>? outputData;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIOrchestrationTask({
    required this.id,
    required this.workflowId,
    required this.clientId,
    required this.clinicianId,
    required this.status,
    required this.inputData,
    required this.parameters,
    required this.currentStep,
    required this.totalSteps,
    this.outputData,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIOrchestrationTask.fromJson(Map<String, dynamic> json) =>
      _$AIOrchestrationTaskFromJson(json);

  Map<String, dynamic> toJson() => _$AIOrchestrationTaskToJson(this);

  AIOrchestrationTask copyWith({
    String? id,
    String? workflowId,
    String? clientId,
    String? clinicianId,
    String? status,
    Map<String, dynamic>? inputData,
    Map<String, dynamic>? parameters,
    int? currentStep,
    int? totalSteps,
    Map<String, dynamic>? outputData,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIOrchestrationTask(
      id: id ?? this.id,
      workflowId: workflowId ?? this.workflowId,
      clientId: clientId ?? this.clientId,
      clinicianId: clinicianId ?? this.clinicianId,
      status: status ?? this.status,
      inputData: inputData ?? this.inputData,
      parameters: parameters ?? this.parameters,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      outputData: outputData ?? this.outputData,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class AIOrchestrationResult {
  final String id;
  final String taskId;
  final String workflowId;
  final String status;
  final Map<String, dynamic>? outputData;
  final String? errorMessage;
  final Duration executionTime;
  final DateTime createdAt;

  AIOrchestrationResult({
    required this.id,
    required this.taskId,
    required this.workflowId,
    required this.status,
    this.outputData,
    this.errorMessage,
    required this.executionTime,
    required this.createdAt,
  });

  factory AIOrchestrationResult.fromJson(Map<String, dynamic> json) =>
      _$AIOrchestrationResultFromJson(json);

  Map<String, dynamic> toJson() => _$AIOrchestrationResultToJson(this);
}

enum WorkflowStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('running')
  running,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

enum StepType {
  @JsonValue('ai_analysis')
  aiAnalysis,
  @JsonValue('ai_monitoring')
  aiMonitoring,
  @JsonValue('data_processing')
  dataProcessing,
  @JsonValue('decision_making')
  decisionMaking,
  @JsonValue('notification')
  notification,
}
