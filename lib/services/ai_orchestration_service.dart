import 'package:flutter/foundation.dart';
import '../models/ai_orchestration_models.dart';
import 'ai_service.dart';

class AIOrchestrationService extends ChangeNotifier {
  static final AIOrchestrationService _instance = AIOrchestrationService._internal();
  factory AIOrchestrationService() => _instance;
  AIOrchestrationService._internal();

  AIService? _aiService;
  List<AIWorkflow> _workflows = [];
  List<AIOrchestrationTask> _tasks = [];
  List<AIOrchestrationResult> _results = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<AIWorkflow> get workflows => _workflows;
  List<AIOrchestrationTask> get tasks => _tasks;
  List<AIOrchestrationResult> get results => _results;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _aiService = AIService();
      await _loadWorkflows();
      _isInitialized = true;
      notifyListeners();
      print('AIOrchestrationService initialized successfully');
    } catch (e) {
      print('AIOrchestrationService initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _loadWorkflows() async {
    // Load predefined workflows
    _workflows.addAll([
      AIWorkflow(
        id: 'diagnosis_workflow',
        name: 'Diagnosis Workflow',
        description: 'Complete diagnostic workflow from symptoms to treatment',
        steps: [
          AIWorkflowStep(
            id: 'symptom_analysis',
            name: 'Symptom Analysis',
            type: 'ai_analysis',
            order: 1,
            dependencies: [],
            parameters: {'model': 'claude-3-sonnet', 'prompt_type': 'symptom_analysis'},
          ),
          AIWorkflowStep(
            id: 'diagnosis_generation',
            name: 'Diagnosis Generation',
            type: 'ai_analysis',
            order: 2,
            dependencies: ['symptom_analysis'],
            parameters: {'model': 'claude-3-sonnet', 'prompt_type': 'diagnosis_generation'},
          ),
          AIWorkflowStep(
            id: 'treatment_planning',
            name: 'Treatment Planning',
            type: 'ai_analysis',
            order: 3,
            dependencies: ['diagnosis_generation'],
            parameters: {'model': 'claude-3-sonnet', 'prompt_type': 'treatment_planning'},
          ),
        ],
        isActive: true,
      ),
      AIWorkflow(
        id: 'session_analysis_workflow',
        name: 'Session Analysis Workflow',
        description: 'Real-time session analysis and insights',
        steps: [
          AIWorkflowStep(
            id: 'real_time_monitoring',
            name: 'Real-time Monitoring',
            type: 'ai_monitoring',
            order: 1,
            dependencies: [],
            parameters: {'model': 'claude-3-haiku', 'prompt_type': 'real_time_analysis'},
          ),
          AIWorkflowStep(
            id: 'crisis_detection',
            name: 'Crisis Detection',
            type: 'ai_analysis',
            order: 2,
            dependencies: ['real_time_monitoring'],
            parameters: {'model': 'claude-3-sonnet', 'prompt_type': 'crisis_detection'},
          ),
        ],
        isActive: true,
      ),
    ]);
  }

  Future<AIOrchestrationTask> executeWorkflow({
    required String workflowId,
    required String clientId,
    required String clinicianId,
    required Map<String, dynamic> inputData,
    Map<String, dynamic>? parameters,
  }) async {
    final workflow = _workflows.firstWhere((w) => w.id == workflowId);
    
    final task = AIOrchestrationTask(
      id: _generateId(),
      workflowId: workflowId,
      clientId: clientId,
      clinicianId: clinicianId,
      status: 'running',
      inputData: inputData,
      parameters: parameters ?? {},
      currentStep: 0,
      totalSteps: workflow.steps.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _tasks.add(task);
    notifyListeners();

    // Execute workflow asynchronously
    _executeWorkflowAsync(task, workflow);

    return task;
  }

  Future<void> _executeWorkflowAsync(AIOrchestrationTask task, AIWorkflow workflow) async {
    try {
      for (int i = 0; i < workflow.steps.length; i++) {
        final step = workflow.steps[i];
        
        // Check dependencies
        if (!_checkStepDependencies(task, step)) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        // Execute step
        await _executeStep(task, step, i);
        
        // Update task progress
        task = task.copyWith(
          currentStep: i + 1,
          updatedAt: DateTime.now(),
        );
        notifyListeners();

        // Add delay between steps
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Complete task
      task = task.copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );
      notifyListeners();

      // Create result
      final result = AIOrchestrationResult(
        id: _generateId(),
        taskId: task.id,
        workflowId: workflow.id,
        status: 'success',
        outputData: task.outputData,
        executionTime: DateTime.now().difference(task.createdAt),
        createdAt: DateTime.now(),
      );

      _results.add(result);
      notifyListeners();

    } catch (e) {
      // Handle error
      task = task.copyWith(
        status: 'failed',
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();

      final result = AIOrchestrationResult(
        id: _generateId(),
        taskId: task.id,
        workflowId: workflow.id,
        status: 'failed',
        errorMessage: e.toString(),
        executionTime: DateTime.now().difference(task.createdAt),
        createdAt: DateTime.now(),
      );

      _results.add(result);
      notifyListeners();
    }
  }

  bool _checkStepDependencies(AIOrchestrationTask task, AIWorkflowStep step) {
    if (step.dependencies.isEmpty) return true;
    
    for (final dependency in step.dependencies) {
      final dependencyStep = _getStepByDependency(task, dependency);
      if (dependencyStep == null || !dependencyStep.isCompleted) {
        return false;
      }
    }
    
    return true;
  }

  AIWorkflowStep? _getStepByDependency(AIOrchestrationTask task, String dependency) {
    // This would need to be implemented based on your specific dependency tracking
    return null;
  }

  Future<void> _executeStep(AIOrchestrationTask task, AIWorkflowStep step, int stepIndex) async {
    if (_aiService == null) {
      throw Exception('AI Service not initialized');
    }

    try {
      switch (step.type) {
        case 'ai_analysis':
          await _executeAIAnalysisStep(task, step, stepIndex);
          break;
        case 'ai_monitoring':
          await _executeAIMonitoringStep(task, step, stepIndex);
          break;
        default:
          throw Exception('Unknown step type: ${step.type}');
      }
    } catch (e) {
      print('Step execution failed: $e');
      rethrow;
    }
  }

  Future<void> _executeAIAnalysisStep(AIOrchestrationTask task, AIWorkflowStep step, int stepIndex) async {
    final prompt = _buildStepPrompt(step, task.inputData);
    final response = await _aiService!.generateResponse(prompt);
    
    // Store step output
    final currentOutputData = task.outputData ?? {};
    final updatedOutputData = Map<String, dynamic>.from(currentOutputData);
    updatedOutputData['step_${stepIndex + 1}'] = {
      'step_id': step.id,
      'step_name': step.name,
      'output': response,
      'timestamp': DateTime.now().toIso8601String(),
    };
    task = task.copyWith(outputData: updatedOutputData);
  }

  Future<void> _executeAIMonitoringStep(AIOrchestrationTask task, AIWorkflowStep step, int stepIndex) async {
    // For monitoring steps, we might want to set up continuous monitoring
    // For now, just execute once
    await _executeAIAnalysisStep(task, step, stepIndex);
  }

  String _buildStepPrompt(AIWorkflowStep step, Map<String, dynamic> inputData) {
    final promptType = step.parameters['prompt_type'] ?? 'general';
    
    switch (promptType) {
      case 'symptom_analysis':
        return '''
        Analyze the following psychiatric symptoms and provide insights:
        
        Input Data: $inputData
        
        Please provide:
        1. Symptom severity assessment
        2. Potential risk factors
        3. Immediate concerns
        4. Recommended next steps
        ''';
      
      case 'diagnosis_generation':
        return '''
        Based on the symptom analysis, generate diagnostic suggestions:
        
        Previous Analysis: ${inputData['step_1']}
        
        Please provide:
        1. Primary diagnosis suggestions
        2. Differential diagnoses
        3. Confidence levels
        4. Supporting evidence
        ''';
      
      case 'treatment_planning':
        return '''
        Based on the diagnosis, create a treatment plan:
        
        Diagnosis: ${inputData['step_2']}
        
        Please provide:
        1. Treatment recommendations
        2. Medication options
        3. Therapy approaches
        4. Monitoring plan
        ''';
      
      case 'real_time_analysis':
        return '''
        Analyze the current session data in real-time:
        
        Session Data: $inputData
        
        Please provide:
        1. Current emotional state
        2. Risk indicators
        3. Intervention suggestions
        4. Session progress
        ''';
      
      case 'crisis_detection':
        return '''
        Assess for crisis indicators in the session:
        
        Session Analysis: ${inputData['step_1']}
        
        Please provide:
        1. Crisis risk level
        2. Immediate actions needed
        3. Safety assessment
        4. Emergency protocols
        ''';
      
      default:
        return '''
        Please analyze the following data:
        
        Input: $inputData
        
        Provide comprehensive analysis and recommendations.
        ''';
    }
  }

  Future<AIOrchestrationResult> processRequest({
    required String promptType,
    required Map<String, dynamic> parameters,
    required String taskId,
    bool useCache = true,
  }) async {
    try {
      // Create task
      var task = AIOrchestrationTask(
        id: taskId,
        workflowId: 'manual_request',
        clientId: parameters['clientId'] ?? 'unknown',
        clinicianId: parameters['clinicianId'] ?? 'unknown',
        status: 'running',
        inputData: parameters,
        parameters: parameters,
        currentStep: 0,
        totalSteps: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _tasks.add(task);
      notifyListeners();

      // Process with AI service
      final aiResponse = await _aiService?.generateResponse(
        _buildPrompt(promptType, parameters),
      ) ?? 'AI service not available';

      // Create result
      final result = AIOrchestrationResult(
        id: 'result_${taskId}',
        taskId: taskId,
        workflowId: 'manual_request',
        status: 'completed',
        outputData: {'ai_response': aiResponse},
        executionTime: Duration(milliseconds: DateTime.now().difference(task.createdAt).inMilliseconds),
        createdAt: DateTime.now(),
      );

      // Update task
      task = task.copyWith(
        status: 'completed',
        outputData: result.outputData,
      );

      _results.add(result);
      notifyListeners();

      return result;
    } catch (e) {
      // Create error result
      final result = AIOrchestrationResult(
        id: 'error_${taskId}',
        taskId: taskId,
        workflowId: 'manual_request',
        status: 'failed',
        outputData: {'error': e.toString()},
        executionTime: Duration.zero,
        createdAt: DateTime.now(),
      );

      _results.add(result);
      notifyListeners();

      rethrow;
    }
  }

  String _buildPrompt(String promptType, Map<String, dynamic> parameters) {
    switch (promptType) {
      case 'real_time_session_analysis':
        return '''
        Analyze the following real-time session data:
        Session ID: ${parameters['sessionId']}
        Client ID: ${parameters['clientId']}
        Session Duration: ${parameters['sessionDuration']} minutes
        Current Phase: ${parameters['currentPhase']}
        
        Provide insights on:
        1. Emotional state and progress
        2. Risk factors and alerts
        3. Intervention suggestions
        4. Session recommendations
        ''';
      
      case 'multimodal_session_analysis':
        return '''
        Analyze multimodal session data including voice, facial, and biometric data:
        ${parameters.toString()}
        
        Provide comprehensive analysis of:
        1. Voice patterns and emotional indicators
        2. Facial expressions and micro-expressions
        3. Biometric responses and stress levels
        4. Integrated insights and recommendations
        ''';
      
      case 'crisis_intervention_ai':
        return '''
        CRISIS INTERVENTION REQUIRED:
        Crisis Type: ${parameters['crisisType']}
        Crisis Level: ${parameters['crisisLevel']}
        Client Status: ${parameters['clientStatus']}
        Current Risks: ${parameters['currentRisks']}
        
        Provide immediate:
        1. Risk assessment and escalation protocols
        2. Crisis intervention strategies
        3. Safety measures and emergency contacts
        4. Follow-up recommendations
        ''';
      
      default:
        return '''
        Analyze the following data:
        ${parameters.toString()}
        
        Provide comprehensive analysis and recommendations.
        ''';
    }
  }

  AIOrchestrationTask? getTask(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  List<AIOrchestrationTask> getTasksByClient(String clientId) {
    return _tasks.where((t) => t.clientId == clientId).toList();
  }

  List<AIOrchestrationTask> getTasksByClinician(String clinicianId) {
    return _tasks.where((t) => t.clinicianId == clinicianId).toList();
  }

  List<AIOrchestrationTask> getTasksByStatus(String status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  AIOrchestrationResult? getResult(String resultId) {
    try {
      return _results.firstWhere((r) => r.id == resultId);
    } catch (e) {
      return null;
    }
  }

  List<AIOrchestrationResult> getResultsByTask(String taskId) {
    return _results.where((r) => r.taskId == taskId).toList();
  }

  List<AIOrchestrationResult> getResultsByWorkflow(String workflowId) {
    return _results.where((r) => r.workflowId == workflowId).toList();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Analytics methods
  Map<String, dynamic> getModelPerformance() {
    final models = <String, dynamic>{};
    
    // Group results by model
    for (final result in _results) {
      final modelId = result.outputData?['model'] ?? 'unknown';
      if (!models.containsKey(modelId)) {
        models[modelId] = {
          'totalTasks': 0,
          'successfulTasks': 0,
          'averageExecutionTime': 0.0,
          'errorRate': 0.0,
        };
      }
      
      models[modelId]['totalTasks']++;
      if (result.status == 'completed') {
        models[modelId]['successfulTasks']++;
      }
      models[modelId]['averageExecutionTime'] = 
          (models[modelId]['averageExecutionTime'] + result.executionTime.inMilliseconds) / models[modelId]['totalTasks'];
    }
    
    // Calculate error rates
    for (final model in models.keys) {
      final total = models[model]['totalTasks'];
      final successful = models[model]['successfulTasks'];
      models[model]['errorRate'] = total > 0 ? (total - successful) / total : 0.0;
    }
    
    return models;
  }

  Map<String, dynamic> getServiceStats() {
    return {
      'totalWorkflows': _workflows.length,
      'totalTasks': _tasks.length,
      'totalResults': _results.length,
      'activeTasks': _tasks.where((t) => t.status == 'in_progress').length,
      'completedTasks': _tasks.where((t) => t.status == 'completed').length,
      'failedTasks': _tasks.where((t) => t.status == 'failed').length,
      'averageTaskTime': _results.isNotEmpty 
          ? _results.map((r) => r.executionTime.inMilliseconds).reduce((a, b) => a + b) / _results.length 
          : 0.0,
    };
  }

  List<dynamic> getTaskHistory(String modelId) {
    return _results
        .where((r) => r.outputData?['model'] == modelId)
        .map((r) => {
          'id': r.id,
          'taskId': r.taskId,
          'workflowId': r.workflowId,
          'status': r.status,
          'executionTime': r.executionTime.inMilliseconds,
          'createdAt': r.createdAt.toIso8601String(),
        })
        .toList();
  }
}
