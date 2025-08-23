import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// Claude Integration Service for PsyClinicAI
/// Provides integration with Anthropic's Claude AI model
class ClaudeIntegrationService {
  static final ClaudeIntegrationService _instance = ClaudeIntegrationService._internal();
  factory ClaudeIntegrationService() => _instance;
  ClaudeIntegrationService._internal();

  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _model = 'claude-3-sonnet-20240229';

  String? _apiKey;
  String? _organizationId;

  final StreamController<String> _responseStreamController = StreamController<String>.broadcast();
  Stream<String> get responseStream => _responseStreamController.stream;

  /// Initialize the Claude service
  Future<void> initialize({required String apiKey, String? organizationId}) async {
    print('🤖 Initializing Claude Integration Service...');
    
    _apiKey = apiKey;
    _organizationId = organizationId;
    
    // Test API connection
    await _testConnection();
    
    print('✅ Claude Integration Service initialized successfully');
  }

  /// Test API connection
  Future<bool> _testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        print('✅ Claude API connection successful');
        return true;
      } else {
        print('❌ Claude API connection failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Claude API connection error: $e');
      return false;
    }
  }

  /// Get request headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': _apiKey ?? '',
      'anthropic-version': '2023-06-01',
    };
    
    if (_organizationId != null) {
      headers['anthropic-organization'] = _organizationId!;
    }
    
    return headers;
  }

  /// Generate diagnosis using Claude
  Future<ClaudeDiagnosisResponse> generateDiagnosis({
    required String patientSymptoms,
    required String patientHistory,
    String? additionalContext,
    Map<String, dynamic>? parameters,
  }) async {
    print('🔍 Generating diagnosis with Claude...');
    
    try {
      final prompt = _buildDiagnosisPrompt(
        patientSymptoms: patientSymptoms,
        patientHistory: patientHistory,
        additionalContext: additionalContext,
      );
      
      final response = await _makeClaudeRequest(
        prompt: prompt,
        parameters: parameters,
      );
      
      return _parseDiagnosisResponse(response);
    } catch (e) {
      print('❌ Diagnosis generation failed: $e');
      rethrow;
    }
  }

  /// Generate treatment recommendations using Claude
  Future<ClaudeTreatmentResponse> generateTreatmentRecommendations({
    required String diagnosis,
    required String patientProfile,
    String? previousTreatments,
    Map<String, dynamic>? parameters,
  }) async {
    print('💊 Generating treatment recommendations with Claude...');
    
    try {
      final prompt = _buildTreatmentPrompt(
        diagnosis: diagnosis,
        patientProfile: patientProfile,
        previousTreatments: previousTreatments,
      );
      
      final response = await _makeClaudeRequest(
        prompt: prompt,
        parameters: parameters,
      );
      
      return _parseTreatmentResponse(response);
    } catch (e) {
      print('❌ Treatment generation failed: $e');
      rethrow;
    }
  }

  /// Detect crisis using Claude
  Future<ClaudeCrisisResponse> detectCrisis({
    required String patientData,
    required String currentBehavior,
    String? riskFactors,
    Map<String, dynamic>? parameters,
  }) async {
    print('🚨 Detecting crisis with Claude...');
    
    try {
      final prompt = _buildCrisisPrompt(
        patientData: patientData,
        currentBehavior: currentBehavior,
        riskFactors: riskFactors,
      );
      
      final response = await _makeClaudeRequest(
        prompt: prompt,
        parameters: parameters,
      );
      
      return _parseCrisisResponse(response);
    } catch (e) {
      print('❌ Crisis detection failed: $e');
      rethrow;
    }
  }

  /// Generate therapy content using Claude
  Future<ClaudeTherapyResponse> generateTherapyContent({
    required String therapyType,
    required String patientNeeds,
    String? sessionGoals,
    Map<String, dynamic>? parameters,
  }) async {
    print('🧠 Generating therapy content with Claude...');
    
    try {
      final prompt = _buildTherapyPrompt(
        therapyType: therapyType,
        patientNeeds: patientNeeds,
        sessionGoals: sessionGoals,
      );
      
      final response = await _makeClaudeRequest(
        prompt: prompt,
        parameters: parameters,
      );
      
      return _parseTherapyResponse(response);
    } catch (e) {
      print('❌ Therapy content generation failed: $e');
      rethrow;
    }
  }

  /// Generate wellness plan using Claude
  Future<ClaudeWellnessResponse> generateWellnessPlan({
    required String patientGoals,
    required String currentLifestyle,
    String? healthConditions,
    Map<String, dynamic>? parameters,
  }) async {
    print('🌟 Generating wellness plan with Claude...');
    
    try {
      final prompt = _buildWellnessPrompt(
        patientGoals: patientGoals,
        currentLifestyle: currentLifestyle,
        healthConditions: healthConditions,
      );
      
      final response = await _makeClaudeRequest(
        prompt: prompt,
        parameters: parameters,
      );
      
      return _parseWellnessResponse(response);
    } catch (e) {
      print('❌ Wellness plan generation failed: $e');
      rethrow;
    }
  }

  /// Stream response from Claude
  Future<void> streamResponse({
    required String prompt,
    Map<String, dynamic>? parameters,
    Function(String)? onChunk,
  }) async {
    print('📡 Streaming response from Claude...');
    
    try {
      final requestBody = {
        'model': _model,
        'max_tokens': parameters?['max_tokens'] ?? 4000,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'stream': true,
      };
      
      final request = http.Request('POST', Uri.parse('$_baseUrl/messages'));
      request.headers.addAll(_getHeaders());
      request.body = jsonEncode(requestBody);
      
      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              if (data == '[DONE]') break;
              
              try {
                final jsonData = jsonDecode(data);
                if (jsonData['type'] == 'content_block_delta') {
                  final content = jsonData['delta']['text'] ?? '';
                  if (content.isNotEmpty) {
                    _responseStreamController.add(content);
                    onChunk?.call(content);
                  }
                }
              } catch (e) {
                // Skip malformed JSON
              }
            }
          }
        }
      } else {
        throw Exception('Streaming failed: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Streaming failed: $e');
      rethrow;
    }
  }

  /// Make Claude API request
  Future<Map<String, dynamic>> _makeClaudeRequest({
    required String prompt,
    Map<String, dynamic>? parameters,
  }) async {
    if (_apiKey == null) {
      throw Exception('Claude API key not initialized');
    }
    
    final requestBody = {
      'model': _model,
      'max_tokens': parameters?['max_tokens'] ?? 4000,
      'temperature': parameters?['temperature'] ?? 0.7,
      'top_p': parameters?['top_p'] ?? 1.0,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
    };
    
    final response = await http.post(
      Uri.parse('$_baseUrl/messages'),
      headers: _getHeaders(),
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Claude API request failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Build diagnosis prompt
  String _buildDiagnosisPrompt({
    required String patientSymptoms,
    required String patientHistory,
    String? additionalContext,
  }) {
    return '''
You are an expert clinical psychologist specializing in mental health diagnosis. Please analyze the following patient information and provide a comprehensive assessment.

Patient Symptoms:
$patientSymptoms

Patient History:
$patientHistory

${additionalContext != null ? 'Additional Context:\n$additionalContext\n' : ''}

Please provide:
1. Primary diagnosis with confidence level
2. Differential diagnoses to consider
3. Key symptoms that support your assessment
4. Risk factors to monitor
5. Recommended next steps for evaluation

Format your response as structured JSON with the following fields:
- primary_diagnosis: string
- confidence_level: number (0-1)
- differential_diagnoses: array of strings
- supporting_symptoms: array of strings
- risk_factors: array of strings
- next_steps: array of strings
- clinical_notes: string
- urgency_level: string (low/medium/high)
''';
  }

  /// Build treatment prompt
  String _buildTreatmentPrompt({
    required String diagnosis,
    required String patientProfile,
    String? previousTreatments,
  }) {
    return '''
You are an expert clinical psychologist specializing in evidence-based treatment planning. Please develop a comprehensive treatment plan for the following patient.

Diagnosis:
$diagnosis

Patient Profile:
$patientProfile

${previousTreatments != null ? 'Previous Treatments:\n$previousTreatments\n' : ''}

Please provide:
1. Recommended treatment approaches
2. Specific interventions and techniques
3. Expected timeline and milestones
4. Monitoring and assessment strategies
5. Potential challenges and solutions

Format your response as structured JSON with the following fields:
- treatment_approaches: array of strings
- interventions: array of objects with name, description, frequency
- timeline: object with phases and milestones
- monitoring_strategies: array of strings
- challenges: array of objects with challenge and solution
- success_metrics: array of strings
- clinical_recommendations: string
''';
  }

  /// Build crisis prompt
  String _buildCrisisPrompt({
    required String patientData,
    required String currentBehavior,
    String? riskFactors,
  }) {
    return '''
You are an expert crisis intervention specialist. Please assess the following situation for crisis indicators and provide immediate recommendations.

Patient Data:
$patientData

Current Behavior:
$currentBehavior

${riskFactors != null ? 'Risk Factors:\n$riskFactors\n' : ''}

Please provide:
1. Crisis level assessment
2. Immediate safety concerns
3. Recommended interventions
4. Emergency protocols if needed
5. Follow-up requirements

Format your response as structured JSON with the following fields:
- crisis_level: string (low/medium/high/critical)
- safety_concerns: array of strings
- immediate_actions: array of strings
- emergency_protocols: array of strings
- follow_up_requirements: array of strings
- risk_assessment: string
- intervention_priority: string
''';
  }

  /// Build therapy prompt
  String _buildTherapyPrompt({
    required String therapyType,
    required String patientNeeds,
    String? sessionGoals,
  }) {
    return '''
You are an expert therapist specializing in $therapyType. Please develop comprehensive therapy content for the following patient needs.

Therapy Type:
$therapyType

Patient Needs:
$patientNeeds

${sessionGoals != null ? 'Session Goals:\n$sessionGoals\n' : ''}

Please provide:
1. Session structure and flow
2. Therapeutic techniques and exercises
3. Discussion topics and questions
4. Homework assignments
5. Progress tracking methods

Format your response as structured JSON with the following fields:
- session_structure: object with phases and timing
- therapeutic_techniques: array of objects with name, description, instructions
- discussion_topics: array of strings
- homework_assignments: array of objects with task, purpose, deadline
- progress_tracking: array of strings
- session_notes: string
- next_session_prep: string
''';
  }

  /// Build wellness prompt
  String _buildWellnessPrompt({
    required String patientGoals,
    required String currentLifestyle,
    String? healthConditions,
  }) {
    return '''
You are an expert wellness coach specializing in mental health and lifestyle optimization. Please develop a comprehensive wellness plan for the following patient.

Patient Goals:
$patientGoals

Current Lifestyle:
$currentLifestyle

${healthConditions != null ? 'Health Conditions:\n$healthConditions\n' : ''}

Please provide:
1. Wellness goals and objectives
2. Lifestyle modifications
3. Self-care strategies
4. Progress tracking methods
5. Long-term maintenance plan

Format your response as structured JSON with the following fields:
- wellness_goals: array of objects with goal, timeline, metrics
- lifestyle_modifications: array of objects with area, current_state, target_state, steps
- self_care_strategies: array of objects with category, activities, frequency
- progress_tracking: array of strings
- maintenance_plan: object with strategies and checkpoints
- wellness_tips: array of strings
- motivation_strategies: array of strings
''';
  }

  /// Parse diagnosis response
  ClaudeDiagnosisResponse _parseDiagnosisResponse(Map<String, dynamic> response) {
    try {
      final content = response['content']?[0]?['text'] ?? '';
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return ClaudeDiagnosisResponse.fromJson(jsonData);
      } else {
        // Fallback parsing
        return ClaudeDiagnosisResponse(
          primaryDiagnosis: 'Unable to parse response',
          confidenceLevel: 0.0,
          differentialDiagnoses: [],
          supportingSymptoms: [],
          riskFactors: [],
          nextSteps: [],
          clinicalNotes: content,
          urgencyLevel: 'medium',
        );
      }
    } catch (e) {
      print('❌ Failed to parse diagnosis response: $e');
      return ClaudeDiagnosisResponse(
        primaryDiagnosis: 'Parsing error',
        confidenceLevel: 0.0,
        differentialDiagnoses: [],
        supportingSymptoms: [],
        riskFactors: [],
        nextSteps: [],
        clinicalNotes: 'Error parsing Claude response',
        urgencyLevel: 'medium',
      );
    }
  }

  /// Parse treatment response
  ClaudeTreatmentResponse _parseTreatmentResponse(Map<String, dynamic> response) {
    try {
      final content = response['content']?[0]?['text'] ?? '';
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return ClaudeTreatmentResponse.fromJson(jsonData);
      } else {
        // Fallback parsing
        return ClaudeTreatmentResponse(
          treatmentApproaches: [],
          interventions: [],
          timeline: {},
          monitoringStrategies: [],
          challenges: [],
          successMetrics: [],
          clinicalRecommendations: content,
        );
      }
    } catch (e) {
      print('❌ Failed to parse treatment response: $e');
      return ClaudeTreatmentResponse(
        treatmentApproaches: [],
        interventions: [],
        timeline: {},
        monitoringStrategies: [],
        challenges: [],
        successMetrics: [],
        clinicalRecommendations: 'Error parsing Claude response',
      );
    }
  }

  /// Parse crisis response
  ClaudeCrisisResponse _parseCrisisResponse(Map<String, dynamic> response) {
    try {
      final content = response['content']?[0]?['text'] ?? '';
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return ClaudeCrisisResponse.fromJson(jsonData);
      } else {
        // Fallback parsing
        return ClaudeCrisisResponse(
          crisisLevel: 'medium',
          safetyConcerns: [],
          immediateActions: [],
          emergencyProtocols: [],
          followUpRequirements: [],
          riskAssessment: content,
          interventionPriority: 'medium',
        );
      }
    } catch (e) {
      print('❌ Failed to parse crisis response: $e');
      return ClaudeCrisisResponse(
        crisisLevel: 'medium',
        safetyConcerns: [],
        immediateActions: [],
        emergencyProtocols: [],
        followUpRequirements: [],
        riskAssessment: 'Error parsing Claude response',
        interventionPriority: 'medium',
      );
    }
  }

  /// Parse therapy response
  ClaudeTherapyResponse _parseTherapyResponse(Map<String, dynamic> response) {
    try {
      final content = response['content']?[0]?['text'] ?? '';
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return ClaudeTherapyResponse.fromJson(jsonData);
      } else {
        // Fallback parsing
        return ClaudeTherapyResponse(
          sessionStructure: {},
          therapeuticTechniques: [],
          discussionTopics: [],
          homeworkAssignments: [],
          progressTracking: [],
          sessionNotes: content,
          nextSessionPrep: '',
        );
      }
    } catch (e) {
      print('❌ Failed to parse therapy response: $e');
      return ClaudeTherapyResponse(
        sessionStructure: {},
        therapeuticTechniques: [],
        discussionTopics: [],
        homeworkAssignments: [],
        progressTracking: [],
        sessionNotes: 'Error parsing Claude response',
        nextSessionPrep: '',
      );
    }
  }

  /// Parse wellness response
  ClaudeWellnessResponse _parseWellnessResponse(Map<String, dynamic> response) {
    try {
      final content = response['content']?[0]?['text'] ?? '';
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return ClaudeWellnessResponse.fromJson(jsonData);
      } else {
        // Fallback parsing
        return ClaudeWellnessResponse(
          wellnessGoals: [],
          lifestyleModifications: [],
          selfCareStrategies: [],
          progressTracking: [],
          maintenancePlan: {},
          wellnessTips: [],
          motivationStrategies: [],
        );
      }
    } catch (e) {
      print('❌ Failed to parse wellness response: $e');
      return ClaudeWellnessResponse(
        wellnessGoals: [],
        lifestyleModifications: [],
        selfCareStrategies: [],
        progressTracking: [],
        maintenancePlan: {},
        wellnessTips: [],
        motivationStrategies: [],
      );
    }
  }

  /// Get service status
  Map<String, dynamic> getStatus() {
    return {
      'service': 'Claude Integration Service',
      'status': _apiKey != null ? 'initialized' : 'not_initialized',
      'model': _model,
      'base_url': _baseUrl,
      'has_api_key': _apiKey != null,
      'has_organization': _organizationId != null,
      'stream_available': true,
    };
  }

  /// Clean up resources
  void dispose() {
    _responseStreamController.close();
  }
}

/// Claude Diagnosis Response Model
class ClaudeDiagnosisResponse {
  final String primaryDiagnosis;
  final double confidenceLevel;
  final List<String> differentialDiagnoses;
  final List<String> supportingSymptoms;
  final List<String> riskFactors;
  final List<String> nextSteps;
  final String clinicalNotes;
  final String urgencyLevel;

  const ClaudeDiagnosisResponse({
    required this.primaryDiagnosis,
    required this.confidenceLevel,
    required this.differentialDiagnoses,
    required this.supportingSymptoms,
    required this.riskFactors,
    required this.nextSteps,
    required this.clinicalNotes,
    required this.urgencyLevel,
  });

  factory ClaudeDiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return ClaudeDiagnosisResponse(
      primaryDiagnosis: json['primary_diagnosis'] ?? '',
      confidenceLevel: (json['confidence_level'] ?? 0.0).toDouble(),
      differentialDiagnoses: List<String>.from(json['differential_diagnoses'] ?? []),
      supportingSymptoms: List<String>.from(json['supporting_symptoms'] ?? []),
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      nextSteps: List<String>.from(json['next_steps'] ?? []),
      clinicalNotes: json['clinical_notes'] ?? '',
      urgencyLevel: json['urgency_level'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_diagnosis': primaryDiagnosis,
      'confidence_level': confidenceLevel,
      'differential_diagnoses': differentialDiagnoses,
      'supporting_symptoms': supportingSymptoms,
      'risk_factors': riskFactors,
      'next_steps': nextSteps,
      'clinical_notes': clinicalNotes,
      'urgency_level': urgencyLevel,
    };
  }
}

/// Claude Treatment Response Model
class ClaudeTreatmentResponse {
  final List<String> treatmentApproaches;
  final List<Map<String, dynamic>> interventions;
  final Map<String, dynamic> timeline;
  final List<String> monitoringStrategies;
  final List<Map<String, dynamic>> challenges;
  final List<String> successMetrics;
  final String clinicalRecommendations;

  const ClaudeTreatmentResponse({
    required this.treatmentApproaches,
    required this.interventions,
    required this.timeline,
    required this.monitoringStrategies,
    required this.challenges,
    required this.successMetrics,
    required this.clinicalRecommendations,
  });

  factory ClaudeTreatmentResponse.fromJson(Map<String, dynamic> json) {
    return ClaudeTreatmentResponse(
      treatmentApproaches: List<String>.from(json['treatment_approaches'] ?? []),
      interventions: List<Map<String, dynamic>>.from(json['interventions'] ?? []),
      timeline: Map<String, dynamic>.from(json['timeline'] ?? {}),
      monitoringStrategies: List<String>.from(json['monitoring_strategies'] ?? []),
      challenges: List<Map<String, dynamic>>.from(json['challenges'] ?? []),
      successMetrics: List<String>.from(json['success_metrics'] ?? []),
      clinicalRecommendations: json['clinical_recommendations'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatment_approaches': treatmentApproaches,
      'interventions': interventions,
      'timeline': timeline,
      'monitoring_strategies': monitoringStrategies,
      'challenges': challenges,
      'success_metrics': successMetrics,
      'clinical_recommendations': clinicalRecommendations,
    };
  }
}

/// Claude Crisis Response Model
class ClaudeCrisisResponse {
  final String crisisLevel;
  final List<String> safetyConcerns;
  final List<String> immediateActions;
  final List<String> emergencyProtocols;
  final List<String> followUpRequirements;
  final String riskAssessment;
  final String interventionPriority;

  const ClaudeCrisisResponse({
    required this.crisisLevel,
    required this.safetyConcerns,
    required this.immediateActions,
    required this.emergencyProtocols,
    required this.followUpRequirements,
    required this.riskAssessment,
    required this.interventionPriority,
  });

  factory ClaudeCrisisResponse.fromJson(Map<String, dynamic> json) {
    return ClaudeCrisisResponse(
      crisisLevel: json['crisis_level'] ?? 'medium',
      safetyConcerns: List<String>.from(json['safety_concerns'] ?? []),
      immediateActions: List<String>.from(json['immediate_actions'] ?? []),
      emergencyProtocols: List<String>.from(json['emergency_protocols'] ?? []),
      followUpRequirements: List<String>.from(json['follow_up_requirements'] ?? []),
      riskAssessment: json['risk_assessment'] ?? '',
      interventionPriority: json['intervention_priority'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crisis_level': crisisLevel,
      'safety_concerns': safetyConcerns,
      'immediate_actions': immediateActions,
      'emergency_protocols': emergencyProtocols,
      'follow_up_requirements': followUpRequirements,
      'risk_assessment': riskAssessment,
      'intervention_priority': interventionPriority,
    };
  }
}

/// Claude Therapy Response Model
class ClaudeTherapyResponse {
  final Map<String, dynamic> sessionStructure;
  final List<Map<String, dynamic>> therapeuticTechniques;
  final List<String> discussionTopics;
  final List<Map<String, dynamic>> homeworkAssignments;
  final List<String> progressTracking;
  final String sessionNotes;
  final String nextSessionPrep;

  const ClaudeTherapyResponse({
    required this.sessionStructure,
    required this.therapeuticTechniques,
    required this.discussionTopics,
    required this.homeworkAssignments,
    required this.progressTracking,
    required this.sessionNotes,
    required this.nextSessionPrep,
  });

  factory ClaudeTherapyResponse.fromJson(Map<String, dynamic> json) {
    return ClaudeTherapyResponse(
      sessionStructure: Map<String, dynamic>.from(json['session_structure'] ?? {}),
      therapeuticTechniques: List<Map<String, dynamic>>.from(json['therapeutic_techniques'] ?? []),
      discussionTopics: List<String>.from(json['discussion_topics'] ?? []),
      homeworkAssignments: List<Map<String, dynamic>>.from(json['homework_assignments'] ?? []),
      progressTracking: List<String>.from(json['progress_tracking'] ?? []),
      sessionNotes: json['session_notes'] ?? '',
      nextSessionPrep: json['next_session_prep'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_structure': sessionStructure,
      'therapeutic_techniques': therapeuticTechniques,
      'discussion_topics': discussionTopics,
      'homework_assignments': homeworkAssignments,
      'progress_tracking': progressTracking,
      'session_notes': sessionNotes,
      'next_session_prep': nextSessionPrep,
    };
  }
}

/// Claude Wellness Response Model
class ClaudeWellnessResponse {
  final List<Map<String, dynamic>> wellnessGoals;
  final List<Map<String, dynamic>> lifestyleModifications;
  final List<Map<String, dynamic>> selfCareStrategies;
  final List<String> progressTracking;
  final Map<String, dynamic> maintenancePlan;
  final List<String> wellnessTips;
  final List<String> motivationStrategies;

  const ClaudeWellnessResponse({
    required this.wellnessGoals,
    required this.lifestyleModifications,
    required this.selfCareStrategies,
    required this.progressTracking,
    required this.maintenancePlan,
    required this.wellnessTips,
    required this.motivationStrategies,
  });

  factory ClaudeWellnessResponse.fromJson(Map<String, dynamic> json) {
    return ClaudeWellnessResponse(
      wellnessGoals: List<Map<String, dynamic>>.from(json['wellness_goals'] ?? []),
      lifestyleModifications: List<Map<String, dynamic>>.from(json['lifestyle_modifications'] ?? []),
      selfCareStrategies: List<Map<String, dynamic>>.from(json['self_care_strategies'] ?? []),
      progressTracking: List<String>.from(json['progress_tracking'] ?? []),
      maintenancePlan: Map<String, dynamic>.from(json['maintenance_plan'] ?? {}),
      wellnessTips: List<String>.from(json['wellness_tips'] ?? []),
      motivationStrategies: List<String>.from(json['motivation_strategies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wellness_goals': wellnessGoals,
      'lifestyle_modifications': lifestyleModifications,
      'self_care_strategies': selfCareStrategies,
      'progress_tracking': progressTracking,
      'maintenance_plan': maintenancePlan,
      'wellness_tips': wellnessTips,
      'motivation_strategies': motivationStrategies,
    };
  }
}
