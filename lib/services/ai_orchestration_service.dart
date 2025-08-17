import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';
import '../config/env_config.dart';
import '../models/ai_performance_metrics.dart';
import '../services/ai_cache_service.dart';
import '../services/ai_prompt_service.dart';
import '../utils/ai_logger.dart';

class AIOrchestrationService {
  static final AIOrchestrationService _instance = AIOrchestrationService._internal();
  factory AIOrchestrationService() => _instance;
  AIOrchestrationService._internal();

  final AILogger _logger = AILogger();
  final AICacheService _cacheService = AICacheService();
  final AIPromptService _promptService = AIPromptService();
  
  // AI Models Configuration
  static const Map<String, Map<String, dynamic>> _aiModels = {
    'openai': {
      'name': 'OpenAI GPT-4',
      'baseUrl': 'https://api.openai.com/v1',
      'model': 'gpt-4-turbo-preview',
      'maxTokens': 4000,
      'temperature': 0.7,
      'priority': 1,
    },
    'claude': {
      'name': 'Anthropic Claude',
      'baseUrl': 'https://api.anthropic.com/v1',
      'model': 'claude-3-sonnet-20240229',
      'maxTokens': 4000,
      'temperature': 0.7,
      'priority': 2,
    },
    'llama': {
      'name': 'Meta LLaMA',
      'baseUrl': 'https://api.meta.ai/v1',
      'model': 'llama-3-70b',
      'maxTokens': 4000,
      'temperature': 0.7,
      'priority': 3,
    },
  };

  // Performance tracking
  final Map<String, AIModelPerformance> _modelPerformance = {};
  final Map<String, List<AITaskResult>> _taskHistory = {};

  Future<void> initialize() async {
    try {
      await _cacheService.initialize();
      await _loadModelPerformance();
      _logger.info('AIOrchestrationService initialized successfully', context: 'AIOrchestrationService');
    } catch (e) {
      _logger.error('Failed to initialize AIOrchestrationService', context: 'AIOrchestrationService', error: e);
    }
  }

  Future<Map<String, dynamic>> processRequest({
    required String promptType,
    required Map<String, dynamic> parameters,
    required String taskId,
    List<String>? preferredModels,
    bool useCache = true,
    Duration? cacheExpiry,
  }) async {
    _logger.info('Processing AI request', context: 'AIOrchestrationService', data: {
      'taskId': taskId,
      'promptType': promptType,
      'useCache': useCache,
    });

    // Check cache first
    if (useCache) {
      final cachedResponse = await _getCachedResponse(promptType, parameters);
      if (cachedResponse != null) {
        _logger.info('Cache hit, returning cached response', context: 'AIOrchestrationService');
        return cachedResponse;
      }
    }

    // Generate prompt
    final prompt = _promptService.generatePrompt(promptType, parameters);
    if (prompt.isEmpty) {
      throw Exception('Failed to generate prompt');
    }

    // Select models to use
    final modelsToUse = _selectModels(preferredModels);
    
    // Process with multiple models in parallel
    final results = await _processWithMultipleModels(prompt, modelsToUse, taskId);
    
    // Select best result
    final bestResult = _selectBestResult(results);
    
    // Cache the result
    if (useCache) {
      await _cacheService.cacheResponse(
        promptType,
        bestResult['modelId'],
        parameters,
        bestResult['response'],
        cacheExpiry,
      );
    }

    // Update performance metrics
    await _updatePerformanceMetrics(results, taskId);

    return bestResult['response'];
  }

  Future<Map<String, dynamic>?> _getCachedResponse(
    String promptType,
    Map<String, dynamic> parameters,
  ) async {
    // Try to get from cache for any model
    for (final modelId in _aiModels.keys) {
      final cached = await _cacheService.getCachedResponse(promptType, modelId, parameters);
      if (cached != null) {
        return cached.response;
      }
    }
    return null;
  }

  List<String> _selectModels(List<String>? preferredModels) {
    if (preferredModels != null && preferredModels.isNotEmpty) {
      return preferredModels.where((id) => _aiModels.containsKey(id)).toList();
    }

    // Select models based on performance and priority
    final availableModels = _aiModels.keys.toList();
    availableModels.sort((a, b) {
      final aPerf = _modelPerformance[a];
      final bPerf = _modelPerformance[b];
      
      if (aPerf == null && bPerf == null) {
        return _aiModels[a]!['priority'].compareTo(_aiModels[b]!['priority']);
      }
      
      if (aPerf == null) return 1;
      if (bPerf == null) return -1;
      
      // Sort by accuracy first, then by response time
      final accuracyComparison = bPerf.accuracy.compareTo(aPerf.accuracy);
      if (accuracyComparison != 0) return accuracyComparison;
      
      return aPerf.responseTime.compareTo(bPerf.responseTime);
    });

    // Return top 2 models for redundancy
    return availableModels.take(2).toList();
  }

  Future<List<Map<String, dynamic>>> _processWithMultipleModels(
    String prompt,
    List<String> modelIds,
    String taskId,
  ) async {
    final futures = <Future<Map<String, dynamic>>>[];
    
    for (final modelId in modelIds) {
      futures.add(_processWithModel(prompt, modelId, taskId));
    }

    final results = await Future.wait(futures);
    return results.where((result) => result['success'] == true).toList();
  }

  Future<Map<String, dynamic>> _processWithModel(
    String prompt,
    String modelId,
    String taskId,
  ) async {
    final startTime = DateTime.now();
    
    try {
      final modelConfig = _aiModels[modelId]!;
      final response = await _callAIModel(prompt, modelId, modelConfig);
      
      final responseTime = DateTime.now().difference(startTime);
      
      return {
        'modelId': modelId,
        'modelName': modelConfig['name'],
        'success': true,
        'response': response,
        'responseTime': responseTime.inMilliseconds / 1000.0,
        'confidence': _calculateConfidence(response),
        'taskId': taskId,
      };
    } catch (e) {
      final responseTime = DateTime.now().difference(startTime);
      
      _logger.error('AI model request failed', context: 'AIOrchestrationService', data: {
        'modelId': modelId,
        'error': e.toString(),
      });

      return {
        'modelId': modelId,
        'modelName': _aiModels[modelId]!['name'],
        'success': false,
        'response': {},
        'responseTime': responseTime.inMilliseconds / 1000.0,
        'confidence': 0.0,
        'error': e.toString(),
        'taskId': taskId,
      };
    }
  }

  Future<Map<String, dynamic>> _callAIModel(
    String prompt,
    String modelId,
    Map<String, dynamic> modelConfig,
  ) async {
    final apiKey = _getApiKey(modelId);
    if (apiKey.isEmpty) {
      throw Exception('API key not found for model: $modelId');
    }

    final headers = _getHeaders(modelId, apiKey);
    final body = _getRequestBody(prompt, modelId, modelConfig);

    final response = await http.post(
      Uri.parse('${modelConfig['baseUrl']}/chat/completions'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(Duration(seconds: EnvConfig.timeoutSeconds));

    if (response.statusCode != 200) {
      throw Exception('API request failed: ${response.statusCode} - ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    return _parseResponse(responseData, modelId);
  }

  String _getApiKey(String modelId) {
    switch (modelId) {
      case 'openai':
        return EnvConfig.openaiApiKey;
      case 'claude':
        return EnvConfig.claudeApiKey;
      case 'llama':
        return 'YOUR_LLAMA_API_KEY'; // TODO: Add to env config
      default:
        return '';
    }
  }

  Map<String, String> _getHeaders(String modelId, String apiKey) {
    switch (modelId) {
      case 'openai':
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };
      case 'claude':
        return {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        };
      case 'llama':
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };
      default:
        return {'Content-Type': 'application/json'};
    }
  }

  Map<String, dynamic> _getRequestBody(
    String prompt,
    String modelId,
    Map<String, dynamic> modelConfig,
  ) {
    switch (modelId) {
      case 'openai':
        return {
          'model': modelConfig['model'],
          'messages': [
            {'role': 'system', 'content': 'Sen deneyimli bir klinik psikologsun.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': modelConfig['maxTokens'],
          'temperature': modelConfig['temperature'],
        };
      case 'claude':
        return {
          'model': modelConfig['model'],
          'max_tokens': modelConfig['maxTokens'],
          'temperature': modelConfig['temperature'],
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        };
      case 'llama':
        return {
          'model': modelConfig['model'],
          'prompt': prompt,
          'max_tokens': modelConfig['maxTokens'],
          'temperature': modelConfig['temperature'],
        };
      default:
        return {'prompt': prompt};
    }
  }

  Map<String, dynamic> _parseResponse(Map<String, dynamic> responseData, String modelId) {
    try {
      switch (modelId) {
        case 'openai':
          final content = responseData['choices']?[0]?['message']?['content'];
          if (content != null) {
            return _parseJsonResponse(content);
          }
          break;
        case 'claude':
          final content = responseData['content']?[0]?['text'];
          if (content != null) {
            return _parseJsonResponse(content);
          }
          break;
        case 'llama':
          final content = responseData['choices']?[0]?['text'];
          if (content != null) {
            return _parseJsonResponse(content);
          }
          break;
      }
    } catch (e) {
      _logger.warning('Failed to parse AI response', context: 'AIOrchestrationService', error: e);
    }

    return {'error': 'Failed to parse response'};
  }

  Map<String, dynamic> _parseJsonResponse(String content) {
    try {
      // Try to extract JSON from the response
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        return jsonDecode(jsonString);
      }
      
      // If no JSON found, return the raw content
      return {'content': content};
    } catch (e) {
      return {'content': content, 'parseError': e.toString()};
    }
  }

  double _calculateConfidence(Map<String, dynamic> response) {
    // Try to extract confidence from response
    if (response.containsKey('confidence')) {
      final conf = response['confidence'];
      if (conf is num) return conf.toDouble();
      if (conf is String) {
        final parsed = double.tryParse(conf);
        if (parsed != null) return parsed;
      }
    }
    
    // Default confidence based on response structure
    if (response.containsKey('error')) return 0.0;
    if (response.keys.length > 3) return 0.8;
    if (response.keys.length > 1) return 0.6;
    return 0.4;
  }

  Map<String, dynamic> _selectBestResult(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      throw Exception('No successful AI model responses');
    }

    // Sort by confidence, then by response time
    results.sort((a, b) {
      final confidenceComparison = b['confidence'].compareTo(a['confidence']);
      if (confidenceComparison != 0) return confidenceComparison;
      
      return a['responseTime'].compareTo(b['responseTime']);
    });

    return results.first;
  }

  Future<void> _updatePerformanceMetrics(
    List<Map<String, dynamic>> results,
    String taskId,
  ) async {
    for (final result in results) {
      final modelId = result['modelId'];
      final taskResult = AITaskResult(
        taskId: taskId,
        modelId: modelId,
        taskType: 'ai_request',
        success: result['success'],
        confidence: result['confidence'],
        responseTime: Duration(milliseconds: (result['responseTime'] * 1000).round()),
        errorMessage: result['error'],
        result: result['response'],
        timestamp: DateTime.now(),
      );

      // Update task history
      _taskHistory.putIfAbsent(modelId, () => []).add(taskResult);

      // Update model performance
      await _updateModelPerformance(modelId, taskResult);
    }
  }

  Future<void> _updateModelPerformance(String modelId, AITaskResult taskResult) async {
    final current = _modelPerformance[modelId];
    final modelConfig = _aiModels[modelId]!;

    if (current == null) {
      // Initialize performance for new model
      _modelPerformance[modelId] = AIModelPerformance(
        modelId: modelId,
        modelName: modelConfig['name'],
        taskType: 'general',
        accuracy: taskResult.success ? 1.0 : 0.0,
        responseTime: taskResult.responseTime.inMilliseconds / 1000.0,
        confidenceScore: taskResult.confidence,
        totalRequests: 1,
        successfulRequests: taskResult.success ? 1 : 0,
        failedRequests: taskResult.success ? 0 : 1,
        lastUsed: DateTime.now(),
      );
    } else {
      // Update existing performance
      final totalRequests = current.totalRequests + 1;
      final successfulRequests = current.successfulRequests + (taskResult.success ? 1 : 0);
      final failedRequests = current.failedRequests + (taskResult.success ? 0 : 1);
      
      // Calculate new accuracy
      final newAccuracy = successfulRequests / totalRequests;
      
      // Calculate new response time (weighted average)
      final newResponseTime = (current.responseTime * current.totalRequests + 
                              taskResult.responseTime.inMilliseconds / 1000.0) / totalRequests;
      
      // Calculate new confidence score (weighted average)
      final newConfidence = (current.confidenceScore * current.totalRequests + 
                            taskResult.confidence) / totalRequests;

      _modelPerformance[modelId] = current.copyWith(
        accuracy: newAccuracy,
        responseTime: newResponseTime,
        confidenceScore: newConfidence,
        totalRequests: totalRequests,
        successfulRequests: successfulRequests,
        failedRequests: failedRequests,
        lastUsed: DateTime.now(),
      );
    }
  }

  Future<void> _loadModelPerformance() async {
    // TODO: Load from persistent storage
    _logger.info('Model performance loaded', context: 'AIOrchestrationService');
  }

  Future<void> saveModelPerformance() async {
    // TODO: Save to persistent storage
    _logger.info('Model performance saved', context: 'AIOrchestrationService');
  }

  Map<String, AIModelPerformance> getModelPerformance() => Map.unmodifiable(_modelPerformance);
  
  List<AITaskResult> getTaskHistory(String modelId) => 
      List.unmodifiable(_taskHistory[modelId] ?? []);
  
  Map<String, dynamic> getServiceStats() {
    final totalRequests = _modelPerformance.values.fold<int>(
      0, (sum, model) => sum + model.totalRequests);
    
    final totalSuccessful = _modelPerformance.values.fold<int>(
      0, (sum, model) => sum + model.successfulRequests);
    
    return {
      'totalRequests': totalRequests,
      'totalSuccessful': totalSuccessful,
      'overallSuccessRate': totalRequests > 0 ? totalSuccessful / totalRequests : 0.0,
      'activeModels': _modelPerformance.length,
      'cacheStats': _cacheService.getCacheStats(),
    };
  }
}
