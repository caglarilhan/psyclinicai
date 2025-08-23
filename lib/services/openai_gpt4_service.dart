import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// OpenAI GPT-4 Integration Service for PsyClinicAI
class OpenAIGPT4Service {
  static final OpenAIGPT4Service _instance = OpenAIGPT4Service._internal();
  factory OpenAIGPT4Service() => _instance;
  OpenAIGPT4Service._internal();

  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4-turbo-preview';
  
  String? _apiKey;
  String? _organizationId;
  
  // Stream controllers for real-time responses
  final StreamController<String> _responseStreamController = StreamController<String>.broadcast();
  Stream<String> get responseStream => _responseStreamController.stream;

  /// Initialize the service with API credentials
  Future<void> initialize({required String apiKey, String? organizationId}) async {
    _apiKey = apiKey;
    _organizationId = organizationId;
    
    // Test connection
    await _testConnection();
  }

  /// Test API connection
  Future<bool> _testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        print('✅ OpenAI GPT-4 connection successful');
        return true;
      } else {
        print('❌ OpenAI GPT-4 connection failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ OpenAI GPT-4 connection error: $e');
      return false;
    }
  }

  /// Get authentication headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    
    if (_organizationId != null) {
      headers['OpenAI-Organization'] = _organizationId!;
    }
    
    return headers;
  }

  /// Generate AI diagnosis with GPT-4
  Future<GPT4DiagnosisResponse> generateDiagnosis({
    required String patientId,
    required List<String> symptoms,
    required String patientHistory,
    required String clinicianNotes,
    String? previousDiagnoses,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final prompt = _buildDiagnosisPrompt(
        symptoms: symptoms,
        patientHistory: patientHistory,
        clinicianNotes: clinicianNotes,
        previousDiagnoses: previousDiagnoses,
        additionalContext: additionalContext,
      );

      final response = await _makeChatCompletion(
        messages: [
          {
            'role': 'system',
            'content': _getSystemPrompt('diagnosis'),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        temperature: 0.3, // Lower temperature for medical accuracy
        maxTokens: 2000,
      );

      return GPT4DiagnosisResponse.fromJson(json.decode(response));
    } catch (e) {
      throw GPT4ServiceException('Diagnosis generation failed: $e');
    }
  }

  /// Generate treatment recommendations
  Future<GPT4TreatmentResponse> generateTreatmentRecommendations({
    required String diagnosis,
    required String patientId,
    required Map<String, dynamic> patientProfile,
    required List<String> currentMedications,
    required List<String> allergies,
    String? previousTreatments,
  }) async {
    try {
      final prompt = _buildTreatmentPrompt(
        diagnosis: diagnosis,
        patientProfile: patientProfile,
        currentMedications: currentMedications,
        allergies: allergies,
        previousTreatments: previousTreatments,
      );

      final response = await _makeChatCompletion(
        messages: [
          {
            'role': 'system',
            'content': _getSystemPrompt('treatment'),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        temperature: 0.4,
        maxTokens: 2500,
      );

      return GPT4TreatmentResponse.fromJson(json.decode(response));
    } catch (e) {
      throw GPT4ServiceException('Treatment recommendations failed: $e');
    }
  }

  /// Real-time crisis detection
  Future<GPT4CrisisResponse> detectCrisis({
    required String patientId,
    required String currentText,
    required Map<String, dynamic> patientHistory,
    required List<String> riskFactors,
    String? voiceAnalysis,
    String? facialAnalysis,
  }) async {
    try {
      final prompt = _buildCrisisPrompt(
        currentText: currentText,
        patientHistory: patientHistory,
        riskFactors: riskFactors,
        voiceAnalysis: voiceAnalysis,
        facialAnalysis: facialAnalysis,
      );

      final response = await _makeChatCompletion(
        messages: [
          {
            'role': 'system',
            'content': _getSystemPrompt('crisis'),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        temperature: 0.1, // Very low temperature for crisis detection
        maxTokens: 1000,
      );

      return GPT4CrisisResponse.fromJson(json.decode(response));
    } catch (e) {
      throw GPT4ServiceException('Crisis detection failed: $e');
    }
  }

  /// Generate personalized therapy session content
  Future<GPT4TherapyResponse> generateTherapyContent({
    required String patientId,
    required String diagnosis,
    required String sessionType,
    required int sessionNumber,
    required Map<String, dynamic> progressData,
    required List<String> sessionGoals,
  }) async {
    try {
      final prompt = _buildTherapyPrompt(
        diagnosis: diagnosis,
        sessionType: sessionType,
        sessionNumber: sessionNumber,
        progressData: progressData,
        sessionGoals: sessionGoals,
      );

      final response = await _makeChatCompletion(
        messages: [
          {
            'role': 'system',
            'content': _getSystemPrompt('therapy'),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        temperature: 0.6,
        maxTokens: 3000,
      );

      return GPT4TherapyResponse.fromJson(json.decode(response));
    } catch (e) {
      throw GPT4ServiceException('Therapy content generation failed: $e');
    }
  }

  /// Stream real-time responses
  Future<void> streamResponse({
    required String prompt,
    required String context,
    Function(String)? onChunk,
    Function(String)? onComplete,
  }) async {
    try {
      final response = await _makeChatCompletionStream(
        messages: [
          {
            'role': 'system',
            'content': _getSystemPrompt('general'),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        temperature: 0.7,
        maxTokens: 4000,
        onChunk: onChunk,
        onComplete: onComplete,
      );
    } catch (e) {
      throw GPT4ServiceException('Streaming failed: $e');
    }
  }

  /// Make chat completion request
  Future<String> _makeChatCompletion({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async {
    final requestBody = {
      'model': _model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': 1.0,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: _getHeaders(),
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw GPT4ServiceException('API request failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Make streaming chat completion request
  Future<void> _makeChatCompletionStream({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int maxTokens = 4000,
    Function(String)? onChunk,
    Function(String)? onComplete,
  }) async {
    final requestBody = {
      'model': _model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': true,
    };

    final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
    request.headers.addAll(_getHeaders());
    request.body = json.encode(requestBody);

    final streamedResponse = await request.send();
    
    if (streamedResponse.statusCode == 200) {
      String fullResponse = '';
      
      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            
            if (data == '[DONE]') {
              onComplete?.call(fullResponse);
              _responseStreamController.add(fullResponse);
              return;
            }
            
            try {
              final jsonData = json.decode(data);
              final content = jsonData['choices'][0]['delta']['content'];
              
              if (content != null) {
                fullResponse += content;
                onChunk?.call(content);
                _responseStreamController.add(content);
              }
            } catch (e) {
              // Skip invalid JSON lines
            }
          }
        }
      }
    } else {
      throw GPT4ServiceException('Streaming request failed: ${streamedResponse.statusCode}');
    }
  }

  /// Build diagnosis prompt
  String _buildDiagnosisPrompt({
    required List<String> symptoms,
    required String patientHistory,
    required String clinicianNotes,
    String? previousDiagnoses,
    Map<String, dynamic>? additionalContext,
  }) {
    return '''
Patient Diagnosis Analysis Request:

SYMPTOMS:
${symptoms.map((s) => '• $s').join('\n')}

PATIENT HISTORY:
$patientHistory

CLINICIAN NOTES:
$clinicianNotes

${previousDiagnoses != null ? 'PREVIOUS DIAGNOSES:\n$previousDiagnoses' : ''}

${additionalContext != null ? 'ADDITIONAL CONTEXT:\n${json.encode(additionalContext)}' : ''}

Please provide:
1. Primary diagnosis with confidence level
2. Differential diagnoses
3. Risk assessment
4. Recommended next steps
5. Clinical reasoning
''';
  }

  /// Build treatment prompt
  String _buildTreatmentPrompt({
    required String diagnosis,
    required Map<String, dynamic> patientProfile,
    required List<String> currentMedications,
    required List<String> allergies,
    String? previousTreatments,
  }) {
    return '''
Treatment Recommendations Request:

DIAGNOSIS:
$diagnosis

PATIENT PROFILE:
${json.encode(patientProfile)}

CURRENT MEDICATIONS:
${currentMedications.map((m) => '• $m').join('\n')}

ALLERGIES:
${allergies.map((a) => '• $a').join('\n')}

${previousTreatments != null ? 'PREVIOUS TREATMENTS:\n$previousTreatments' : ''}

Please provide:
1. Recommended treatment plan
2. Medication suggestions with dosages
3. Therapy approaches
4. Lifestyle modifications
5. Monitoring recommendations
6. Expected outcomes and timeline
''';
  }

  /// Build crisis prompt
  String _buildCrisisPrompt({
    required String currentText,
    required Map<String, dynamic> patientHistory,
    required List<String> riskFactors,
    String? voiceAnalysis,
    String? facialAnalysis,
  }) {
    return '''
CRISIS DETECTION ANALYSIS:

CURRENT TEXT/COMMUNICATION:
$currentText

PATIENT HISTORY:
${json.encode(patientHistory)}

RISK FACTORS:
${riskFactors.map((r) => '• $r').join('\n')}

${voiceAnalysis != null ? 'VOICE ANALYSIS:\n$voiceAnalysis' : ''}

${facialAnalysis != null ? 'FACIAL ANALYSIS:\n$facialAnalysis' : ''}

URGENT: Assess for:
1. Suicide risk level (LOW/MEDIUM/HIGH/CRITICAL)
2. Harm to self or others
3. Immediate intervention needed
4. Recommended actions
5. Safety planning
''';
  }

  /// Build therapy prompt
  String _buildTherapyPrompt({
    required String diagnosis,
    required String sessionType,
    required int sessionNumber,
    required Map<String, dynamic> progressData,
    required List<String> sessionGoals,
  }) {
    return '''
Therapy Session Content Generation:

DIAGNOSIS:
$diagnosis

SESSION TYPE:
$sessionType

SESSION NUMBER:
$sessionNumber

PROGRESS DATA:
${json.encode(progressData)}

SESSION GOALS:
${sessionGoals.map((g) => '• $g').join('\n')}

Please provide:
1. Session structure and flow
2. Therapeutic techniques to use
3. Discussion topics and questions
4. Homework assignments
5. Progress tracking methods
6. Next session preparation
''';
  }

  /// Get system prompt for different contexts
  String _getSystemPrompt(String context) {
    switch (context) {
      case 'diagnosis':
        return '''
You are an expert clinical psychologist and psychiatrist with 20+ years of experience. 
Your role is to assist clinicians in making accurate mental health diagnoses.
Always prioritize patient safety and recommend professional evaluation when needed.
Provide evidence-based assessments and clear clinical reasoning.
Format responses as structured JSON for easy parsing.
''';
      
      case 'treatment':
        return '''
You are a senior mental health treatment specialist with expertise in evidence-based interventions.
Your role is to provide comprehensive treatment recommendations.
Consider patient safety, contraindications, and best practices.
Always recommend consultation with qualified mental health professionals.
Format responses as structured JSON for easy parsing.
''';
      
      case 'crisis':
        return '''
You are a crisis intervention specialist trained in suicide prevention and emergency mental health.
Your role is to assess risk levels and provide immediate safety recommendations.
ALWAYS prioritize patient safety and immediate intervention when needed.
Provide clear, actionable steps for crisis management.
Format responses as structured JSON for easy parsing.
''';
      
      case 'therapy':
        return '''
You are an experienced psychotherapist specializing in evidence-based therapeutic approaches.
Your role is to help create effective therapy session content and structure.
Consider the patient's diagnosis, progress, and therapeutic goals.
Provide practical, implementable therapeutic techniques.
Format responses as structured JSON for easy parsing.
''';
      
      default:
        return '''
You are PsyClinicAI, an advanced AI assistant for mental health professionals.
You provide helpful, accurate, and clinically sound information.
Always prioritize patient safety and recommend professional consultation when needed.
Be supportive, informative, and clinically appropriate in all responses.
''';
    }
  }

  /// Get usage statistics
  Future<GPT4UsageStats> getUsageStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/usage'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return GPT4UsageStats.fromJson(json.decode(response.body));
      } else {
        throw GPT4ServiceException('Failed to get usage stats: ${response.statusCode}');
      }
    } catch (e) {
      throw GPT4ServiceException('Usage stats failed: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _responseStreamController.close();
  }
}

/// Response Models
class GPT4DiagnosisResponse {
  final String primaryDiagnosis;
  final double confidenceLevel;
  final List<String> differentialDiagnoses;
  final String riskAssessment;
  final List<String> recommendedSteps;
  final String clinicalReasoning;
  final DateTime generatedAt;

  GPT4DiagnosisResponse({
    required this.primaryDiagnosis,
    required this.confidenceLevel,
    required this.differentialDiagnoses,
    required this.riskAssessment,
    required this.recommendedSteps,
    required this.clinicalReasoning,
    required this.generatedAt,
  });

  factory GPT4DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return GPT4DiagnosisResponse(
      primaryDiagnosis: json['primaryDiagnosis'] ?? '',
      confidenceLevel: (json['confidenceLevel'] ?? 0.0).toDouble(),
      differentialDiagnoses: List<String>.from(json['differentialDiagnoses'] ?? []),
      riskAssessment: json['riskAssessment'] ?? '',
      recommendedSteps: List<String>.from(json['recommendedSteps'] ?? []),
      clinicalReasoning: json['clinicalReasoning'] ?? '',
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryDiagnosis': primaryDiagnosis,
      'confidenceLevel': confidenceLevel,
      'differentialDiagnoses': differentialDiagnoses,
      'riskAssessment': riskAssessment,
      'recommendedSteps': recommendedSteps,
      'clinicalReasoning': clinicalReasoning,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

class GPT4TreatmentResponse {
  final String treatmentPlan;
  final List<MedicationRecommendation> medications;
  final List<String> therapyApproaches;
  final List<String> lifestyleModifications;
  final List<String> monitoringRecommendations;
  final String expectedOutcomes;
  final String timeline;

  GPT4TreatmentResponse({
    required this.treatmentPlan,
    required this.medications,
    required this.therapyApproaches,
    required this.lifestyleModifications,
    required this.monitoringRecommendations,
    required this.expectedOutcomes,
    required this.timeline,
  });

  factory GPT4TreatmentResponse.fromJson(Map<String, dynamic> json) {
    return GPT4TreatmentResponse(
      treatmentPlan: json['treatmentPlan'] ?? '',
      medications: (json['medications'] as List? ?? [])
          .map((m) => MedicationRecommendation.fromJson(m))
          .toList(),
      therapyApproaches: List<String>.from(json['therapyApproaches'] ?? []),
      lifestyleModifications: List<String>.from(json['lifestyleModifications'] ?? []),
      monitoringRecommendations: List<String>.from(json['monitoringRecommendations'] ?? []),
      expectedOutcomes: json['expectedOutcomes'] ?? '',
      timeline: json['timeline'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatmentPlan': treatmentPlan,
      'medications': medications.map((m) => m.toJson()).toList(),
      'therapyApproaches': therapyApproaches,
      'lifestyleModifications': lifestyleModifications,
      'monitoringRecommendations': monitoringRecommendations,
      'expectedOutcomes': expectedOutcomes,
      'timeline': timeline,
    };
  }
}

class MedicationRecommendation {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final List<String> sideEffects;
  final List<String> contraindications;

  MedicationRecommendation({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.sideEffects,
    required this.contraindications,
  });

  factory MedicationRecommendation.fromJson(Map<String, dynamic> json) {
    return MedicationRecommendation(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'sideEffects': sideEffects,
      'contraindications': contraindications,
    };
  }
}

class GPT4CrisisResponse {
  final String riskLevel;
  final bool immediateIntervention;
  final List<String> recommendedActions;
  final String safetyPlan;
  final DateTime assessmentTime;

  GPT4CrisisResponse({
    required this.riskLevel,
    required this.immediateIntervention,
    required this.recommendedActions,
    required this.safetyPlan,
    required this.assessmentTime,
  });

  factory GPT4CrisisResponse.fromJson(Map<String, dynamic> json) {
    return GPT4CrisisResponse(
      riskLevel: json['riskLevel'] ?? 'UNKNOWN',
      immediateIntervention: json['immediateIntervention'] ?? false,
      recommendedActions: List<String>.from(json['recommendedActions'] ?? []),
      safetyPlan: json['safetyPlan'] ?? '',
      assessmentTime: DateTime.parse(json['assessmentTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'riskLevel': riskLevel,
      'immediateIntervention': immediateIntervention,
      'recommendedActions': recommendedActions,
      'safetyPlan': safetyPlan,
      'assessmentTime': assessmentTime.toIso8601String(),
    };
  }
}

class GPT4TherapyResponse {
  final String sessionStructure;
  final List<String> therapeuticTechniques;
  final List<String> discussionTopics;
  final List<String> homeworkAssignments;
  final List<String> progressTrackingMethods;
  final String nextSessionPreparation;

  GPT4TherapyResponse({
    required this.sessionStructure,
    required this.therapeuticTechniques,
    required this.discussionTopics,
    required this.homeworkAssignments,
    required this.progressTrackingMethods,
    required this.nextSessionPreparation,
  });

  factory GPT4TherapyResponse.fromJson(Map<String, dynamic> json) {
    return GPT4TherapyResponse(
      sessionStructure: json['sessionStructure'] ?? '',
      therapeuticTechniques: List<String>.from(json['therapeuticTechniques'] ?? []),
      discussionTopics: List<String>.from(json['discussionTopics'] ?? []),
      homeworkAssignments: List<String>.from(json['homeworkAssignments'] ?? []),
      progressTrackingMethods: List<String>.from(json['progressTrackingMethods'] ?? []),
      nextSessionPreparation: json['nextSessionPreparation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionStructure': sessionStructure,
      'therapeuticTechniques': therapeuticTechniques,
      'discussionTopics': discussionTopics,
      'homeworkAssignments': homeworkAssignments,
      'progressTrackingMethods': progressTrackingMethods,
      'nextSessionPreparation': nextSessionPreparation,
    };
  }
}

class GPT4UsageStats {
  final int totalUsage;
  final Map<String, int> usageByModel;
  final double totalCost;
  final DateTime periodStart;
  final DateTime periodEnd;

  GPT4UsageStats({
    required this.totalUsage,
    required this.usageByModel,
    required this.totalCost,
    required this.periodStart,
    required this.periodEnd,
  });

  factory GPT4UsageStats.fromJson(Map<String, dynamic> json) {
    return GPT4UsageStats(
      totalUsage: json['total_usage'] ?? 0,
      usageByModel: Map<String, int>.from(json['daily_costs'] ?? {}),
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
      periodStart: DateTime.parse(json['period_start'] ?? DateTime.now().toIso8601String()),
      periodEnd: DateTime.parse(json['period_end'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsage': totalUsage,
      'usageByModel': usageByModel,
      'totalCost': totalCost,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}

/// Custom Exceptions
class GPT4ServiceException implements Exception {
  final String message;
  GPT4ServiceException(this.message);

  @override
  String toString() => 'GPT4ServiceException: $message';
}
