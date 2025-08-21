// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_orchestration_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIWorkflow _$AIWorkflowFromJson(Map<String, dynamic> json) => AIWorkflow(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  steps: (json['steps'] as List<dynamic>)
      .map((e) => AIWorkflowStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AIWorkflowToJson(AIWorkflow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'steps': instance.steps,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

AIWorkflowStep _$AIWorkflowStepFromJson(Map<String, dynamic> json) =>
    AIWorkflowStep(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      order: (json['order'] as num).toInt(),
      dependencies: (json['dependencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$AIWorkflowStepToJson(AIWorkflowStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'order': instance.order,
      'dependencies': instance.dependencies,
      'parameters': instance.parameters,
      'isCompleted': instance.isCompleted,
    };

AIOrchestrationTask _$AIOrchestrationTaskFromJson(Map<String, dynamic> json) =>
    AIOrchestrationTask(
      id: json['id'] as String,
      workflowId: json['workflowId'] as String,
      clientId: json['clientId'] as String,
      clinicianId: json['clinicianId'] as String,
      status: json['status'] as String,
      inputData: json['inputData'] as Map<String, dynamic>,
      parameters: json['parameters'] as Map<String, dynamic>,
      currentStep: (json['currentStep'] as num).toInt(),
      totalSteps: (json['totalSteps'] as num).toInt(),
      outputData: json['outputData'] as Map<String, dynamic>?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AIOrchestrationTaskToJson(
  AIOrchestrationTask instance,
) => <String, dynamic>{
  'id': instance.id,
  'workflowId': instance.workflowId,
  'clientId': instance.clientId,
  'clinicianId': instance.clinicianId,
  'status': instance.status,
  'inputData': instance.inputData,
  'parameters': instance.parameters,
  'currentStep': instance.currentStep,
  'totalSteps': instance.totalSteps,
  'outputData': instance.outputData,
  'errorMessage': instance.errorMessage,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

AIOrchestrationResult _$AIOrchestrationResultFromJson(
  Map<String, dynamic> json,
) => AIOrchestrationResult(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  workflowId: json['workflowId'] as String,
  status: json['status'] as String,
  outputData: json['outputData'] as Map<String, dynamic>?,
  errorMessage: json['errorMessage'] as String?,
  executionTime: Duration(microseconds: (json['executionTime'] as num).toInt()),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AIOrchestrationResultToJson(
  AIOrchestrationResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'workflowId': instance.workflowId,
  'status': instance.status,
  'outputData': instance.outputData,
  'errorMessage': instance.errorMessage,
  'executionTime': instance.executionTime.inMicroseconds,
  'createdAt': instance.createdAt.toIso8601String(),
};
