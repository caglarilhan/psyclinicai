import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/session_ai_models.dart' as session_ai;
import '../models/treatment_plan_models.dart';
import '../services/ai_orchestration_service.dart';
import '../utils/ai_logger.dart';

class RealTimeSessionAIService extends ChangeNotifier {
  static final RealTimeSessionAIService _instance = RealTimeSessionAIService._internal();
  factory RealTimeSessionAIService() => _instance;
  RealTimeSessionAIService._internal();

  final AILogger _logger = AILogger();
  final AIOrchestrationService _aiService = AIOrchestrationService();
  
  // Real-time analysis streams
  final StreamController<session_ai.RealTimeSessionAnalysis> _analysisController =
      StreamController<session_ai.RealTimeSessionAnalysis>.broadcast();
  final StreamController<session_ai.Alert> _alertController = 
      StreamController<session_ai.Alert>.broadcast();
  final StreamController<session_ai.InterventionSuggestion> _interventionController = 
      StreamController<session_ai.InterventionSuggestion>.broadcast();
  final StreamController<session_ai.RealTimeSessionAnalysis> _crisisController = 
      StreamController<session_ai.RealTimeSessionAnalysis>.broadcast();

  // Active sessions
  final Map<String, SessionAnalysisSession> _activeSessions = {};
  
  // Configuration
  bool _isEnabled = true;
  double _analysisFrequency = 30.0; // seconds
  double _alertThreshold = 0.8;
  double _interventionThreshold = 0.7;

  // Streams
  Stream<session_ai.RealTimeSessionAnalysis> get analysisStream => _analysisController.stream;
  Stream<session_ai.Alert> get alertStream => _alertController.stream;
  Stream<session_ai.InterventionSuggestion> get interventionStream => _interventionController.stream;
  Stream<session_ai.RealTimeSessionAnalysis> get crisisStream => _crisisController.stream;

  // Getters
  bool get isEnabled => _isEnabled;
  double get analysisFrequency => _analysisFrequency;
  double get alertThreshold => _alertThreshold;
  Map<String, SessionAnalysisSession> get activeSessions => Map.unmodifiable(_activeSessions);

  Future<void> initialize() async {
    try {
      await _aiService.initialize();
      _logger.info('RealTimeSessionAIService initialized successfully', context: 'RealTimeSessionAIService');
    } catch (e) {
      _logger.error('Failed to initialize RealTimeSessionAIService', context: 'RealTimeSessionAIService', error: e);
      rethrow;
    }
  }

  Future<void> startSessionAnalysis({
    required String sessionId,
    required String clientId,
    required String therapistId,
    required Map<String, dynamic> clientHistory,
    required List<String> sessionGoals,
  }) async {
    if (_activeSessions.containsKey(sessionId)) {
      _logger.warning('Session analysis already active', context: 'RealTimeSessionAIService', data: {'sessionId': sessionId});
      return;
    }

    try {
      final session = SessionAnalysisSession(
        sessionId: sessionId,
        clientId: clientId,
        therapistId: therapistId,
        clientHistory: clientHistory,
        sessionGoals: sessionGoals,
        startTime: DateTime.now(),
        isActive: true,
      );

      _activeSessions[sessionId] = session;
      
      // Start real-time analysis
      _startAnalysisLoop(sessionId);
      
      _logger.info('Session analysis started', context: 'RealTimeSessionAIService', data: {
        'sessionId': sessionId,
        'clientId': clientId,
        'therapistId': therapistId,
      });
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to start session analysis', context: 'RealTimeSessionAIService', error: e);
      rethrow;
    }
  }

  Future<void> stopSessionAnalysis(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    try {
      session.isActive = false;
      session.endTime = DateTime.now();
      
      // Generate final analysis
      await _generateFinalAnalysis(sessionId);
      
      _activeSessions.remove(sessionId);
      
      _logger.info('Session analysis stopped', context: 'RealTimeSessionAIService', data: {'sessionId': sessionId});
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to stop session analysis', context: 'RealTimeSessionAIService', error: e);
    }
  }

  Future<void> addSessionData({
    required String sessionId,
    required String dataType,
    required Map<String, dynamic> data,
    required DateTime timestamp,
  }) async {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    try {
      session.sessionData.add(SessionData(
        type: dataType,
        data: data,
        timestamp: timestamp,
      ));

      // Trigger immediate analysis if critical data
      if (_isCriticalData(dataType, data)) {
        await _analyzeSessionData(sessionId);
      }
      
      _logger.debug('Session data added', context: 'RealTimeSessionAIService', data: {
        'sessionId': sessionId,
        'dataType': dataType,
        'timestamp': timestamp.toIso8601String(),
      });
    } catch (e) {
      _logger.error('Failed to add session data', context: 'RealTimeSessionAIService', error: e);
    }
  }

  void _startAnalysisLoop(String sessionId) {
    Timer.periodic(Duration(seconds: _analysisFrequency.round()), (timer) async {
      final session = _activeSessions[sessionId];
      if (session == null || !session.isActive) {
        timer.cancel();
        return;
      }

      try {
        await _analyzeSessionData(sessionId);
      } catch (e) {
        _logger.error('Analysis loop error', context: 'RealTimeSessionAIService', error: e);
      }
    });
  }

  Future<void> _analyzeSessionData(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    try {
      // Prepare data for AI analysis
      final analysisData = _prepareAnalysisData(session);
      
      // Generate task ID
      final taskId = 'session_analysis_${sessionId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Determine analysis type based on available data
      String promptType = 'real_time_session_analysis';
      
      // Check if we have multimodal data for advanced analysis
      if (_hasMultimodalData(session)) {
        promptType = 'multimodal_session_analysis';
        analysisData['voiceAnalysis'] = _extractVoiceData(session);
        analysisData['facialAnalysis'] = _extractFacialData(session);
        analysisData['biometricData'] = _extractBiometricData(session);
      }
      
      // Check for crisis indicators
      if (_detectCrisisIndicators(session)) {
        promptType = 'crisis_intervention_ai';
        analysisData['crisisType'] = _determineCrisisType(session);
        analysisData['crisisLevel'] = _assessCrisisLevel(session);
        analysisData['clientStatus'] = _assessClientStatus(session);
        analysisData['currentRisks'] = _identifyCurrentRisks(session);
        analysisData['previousInterventions'] = _getPreviousInterventions(session);
      }
      
      // Process with AI
      final aiResult = await _aiService.processRequest(
        promptType: promptType,
        parameters: analysisData,
        taskId: taskId,
        useCache: false, // Real-time analysis should not use cache
      );

      // Convert AI result to expected format
      final response = aiResult.outputData ?? {};

      // Process AI response
      final analysis = _processAIResponse(response, session);
      
      // Update session
      session.lastAnalysis = analysis;
      session.analysisHistory.add(analysis);
      
      // Emit analysis
      _analysisController.add(analysis);
      
      // Check for alerts
      _checkForAlerts(analysis);
      
      // Check for intervention suggestions
      _checkForInterventions(analysis);
      
      // Check for crisis escalation
      if (promptType == 'crisis_intervention_ai') {
        _handleCrisisEscalation(analysis, session);
      }
      
      _logger.debug('Session data analyzed', context: 'RealTimeSessionAIService', data: {
        'sessionId': sessionId,
        'analysisId': analysis.id,
        'timestamp': analysis.timestamp.toIso8601String(),
        'analysisType': promptType,
      });
      
    } catch (e) {
      _logger.error('Failed to analyze session data', context: 'RealTimeSessionAIService', error: e);
    }
  }

  Map<String, dynamic> _prepareAnalysisData(SessionAnalysisSession session) {
    return {
      'sessionId': session.sessionId,
      'clientId': session.clientId,
      'therapistId': session.therapistId,
      'sessionDuration': DateTime.now().difference(session.startTime).inMinutes,
      'sessionGoals': session.sessionGoals,
      'clientHistory': session.clientHistory,
      'recentSessionData': session.sessionData
          .skip(session.sessionData.length - 10).take(10) // Last 10 data points
          .map((d) => {
                'type': d.type,
                'data': d.data,
                'timestamp': d.timestamp.toIso8601String(),
              })
          .toList(),
      'currentPhase': _determineSessionPhase(session),
      'emotionalIndicators': _extractEmotionalIndicators(session),
      'riskFactors': _extractRiskFactors(session),
      'progressIndicators': _extractProgressIndicators(session),
    };
  }

  String _determineSessionPhase(SessionAnalysisSession session) {
    final duration = DateTime.now().difference(session.startTime).inMinutes;
    
    if (duration < 5) return 'introduction';
    if (duration < 20) return 'exploration';
    if (duration < 40) return 'intervention';
    if (duration < 50) return 'integration';
    if (duration < 55) return 'closure';
    return 'followUp';
  }

  List<String> _extractEmotionalIndicators(SessionAnalysisSession session) {
    final indicators = <String>[];
    
    for (final data in session.sessionData) {
      if (data.type == 'voice_tone' || data.type == 'facial_expression' || data.type == 'body_language') {
        indicators.addAll(data.data.values.whereType<String>());
      }
    }
    
    return indicators;
  }

  List<String> _extractRiskFactors(SessionAnalysisSession session) {
    final factors = <String>[];
    
    for (final data in session.sessionData) {
      if (data.type == 'risk_assessment' || data.type == 'crisis_indicator') {
        factors.addAll(data.data.values.whereType<String>());
      }
    }
    
    return factors;
  }

  List<String> _extractProgressIndicators(SessionAnalysisSession session) {
    final indicators = <String>[];
    
    for (final data in session.sessionData) {
      if (data.type == 'goal_progress' || data.type == 'milestone' || data.type == 'breakthrough') {
        indicators.addAll(data.data.values.whereType<String>());
      }
    }
    
    return indicators;
  }

  session_ai.RealTimeSessionAnalysis _processAIResponse(Map<String, dynamic> response, SessionAnalysisSession session) {
    // Process AI response and create analysis object
    // This is a simplified version - in real implementation, you'd parse the AI response more carefully
    
    final emotionalStates = _parseEmotionalStates(response['emotionalStates'] ?? []);
    final riskIndicators = _parseRiskIndicators(response['riskIndicators'] ?? []);
    final interventionSuggestions = _parseInterventionSuggestions(response['interventionSuggestions'] ?? []);
    final insights = _parseSessionInsights(response['insights'] ?? []);
    final progress = _parseSessionProgress(response['progress'] ?? {});
    final alerts = _parseAlerts(response['alerts'] ?? []);

    return session_ai.RealTimeSessionAnalysis(
      id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: session.sessionId,
      clientId: session.clientId,
      therapistId: session.therapistId,
      timestamp: DateTime.now(),
      phase: _parseSessionPhase(_determineSessionPhase(session)),
      emotionalStates: emotionalStates,
      riskIndicators: riskIndicators,
      interventionSuggestions: interventionSuggestions,
      insights: insights,
      progress: progress,
      alerts: alerts,
      metadata: response,
    );
  }

  List<session_ai.EmotionalState> _parseEmotionalStates(List<dynamic> data) {
    return data.map((item) => session_ai.EmotionalState(
      id: item['id'] ?? '',
      emotion: _parseEmotionType(item['emotion'] ?? ''),
      intensity: (item['intensity'] ?? 0.0).toDouble(),
      confidence: (item['confidence'] ?? 0.0).toDouble(),
      detectedAt: DateTime.now(),
      trigger: item['trigger'] ?? '',
      physicalSigns: List<String>.from(item['physicalSigns'] ?? []),
      behavioralSigns: List<String>.from(item['behavioralSigns'] ?? []),
      context: item['context'] ?? '',
    )).toList();
  }

  List<session_ai.RiskIndicator> _parseRiskIndicators(List<dynamic> data) {
    return data.map((item) => session_ai.RiskIndicator(
      id: item['id'] ?? '',
      type: _parseRiskType(item['type'] ?? ''),
      severity: _parseRiskSeverity(item['severity'] ?? ''),
      description: item['description'] ?? '',
      evidence: List<String>.from(item['evidence'] ?? []),
      detectedAt: DateTime.now(),
      confidence: (item['confidence'] ?? 0.0).toDouble(),
      recommendedAction: item['recommendedAction'] ?? '',
      requiresImmediateAttention: item['requiresImmediateAttention'] ?? false,
    )).toList();
  }

  List<session_ai.InterventionSuggestion> _parseInterventionSuggestions(List<dynamic> data) {
    return data.map((item) => session_ai.InterventionSuggestion(
      id: item['id'] ?? '',
      type: _parseInterventionType(item['type'] ?? ''),
      title: item['title'] ?? '',
      description: item['description'] ?? '',
      rationale: item['rationale'] ?? '',
      techniques: List<String>.from(item['techniques'] ?? []),
      resources: List<String>.from(item['resources'] ?? []),
      confidence: (item['confidence'] ?? 0.0).toDouble(),
      timing: _parseInterventionTiming(item['timing'] ?? ''),
      contraindications: List<String>.from(item['contraindications'] ?? []),
      expectedOutcome: item['expectedOutcome'] ?? '',
    )).toList();
  }

  List<session_ai.SessionInsight> _parseSessionInsights(List<dynamic> data) {
    return data.map((item) => session_ai.SessionInsight(
      id: item['id'] ?? '',
      type: _parseInsightType(item['type'] ?? ''),
      title: item['title'] ?? '',
      description: item['description'] ?? '',
      confidence: (item['confidence'] ?? 0.0).toDouble(),
      generatedAt: DateTime.now(),
      supportingEvidence: List<String>.from(item['supportingEvidence'] ?? []),
      clinicalRelevance: item['clinicalRelevance'] ?? '',
      relatedTopics: List<String>.from(item['relatedTopics'] ?? []),
      isActionable: item['isActionable'] ?? false,
    )).toList();
  }

  session_ai.SessionProgress _parseSessionProgress(Map<String, dynamic> data) {
    return session_ai.SessionProgress(
      id: data['id'] ?? '',
      overallProgress: (data['overallProgress'] ?? 0.0).toDouble(),
      goalProgress: _parseGoalProgress(data['goalProgress'] ?? []),
      milestones: _parseMilestones(data['milestones'] ?? []),
      challenges: _parseChallenges(data['challenges'] ?? []),
      breakthroughs: _parseBreakthroughs(data['breakthroughs'] ?? []),
      nextSteps: data['nextSteps'] ?? '',
      lastAssessment: DateTime.now(),
    );
  }

  List<session_ai.GoalProgress> _parseGoalProgress(List<dynamic> data) {
    return data.map((item) => session_ai.GoalProgress(
      id: item['id'] ?? '',
      goalId: item['goalId'] ?? '',
      goalTitle: item['goalTitle'] ?? '',
      progress: (item['progress'] ?? 0.0).toDouble(),
      achievements: List<String>.from(item['achievements'] ?? []),
      obstacles: List<String>.from(item['obstacles'] ?? []),
      status: item['status'] ?? '',
      lastUpdated: DateTime.now(),
    )).toList();
  }

  List<session_ai.Milestone> _parseMilestones(List<dynamic> data) {
    return data.map((item) => session_ai.Milestone(
      id: item['id'] ?? '',
      title: item['title'] ?? '',
      description: item['description'] ?? '',
      achievedAt: DateTime.tryParse(item['achievedAt'] ?? '') ?? DateTime.now(),
      significance: (item['significance'] ?? 0.0).toDouble(),
      contributingFactors: List<String>.from(item['contributingFactors'] ?? []),
      celebrationNote: item['celebrationNote'] ?? '',
    )).toList();
  }

  String _parseGoalStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'active';
      case 'on_hold':
        return 'onHold';
      case 'completed':
        return 'completed';
      default:
        return 'active';
    }
  }



  List<session_ai.Challenge> _parseChallenges(List<dynamic> data) {
    return data.map((item) => session_ai.Challenge(
      id: item['id'] ?? '',
      title: item['title'] ?? '',
      description: item['description'] ?? '',
      type: _parseChallengeType(item['type'] ?? ''),
      difficulty: (item['difficulty'] ?? 0.0).toDouble(),
      copingStrategies: List<String>.from(item['copingStrategies'] ?? []),
      currentStatus: item['currentStatus'] ?? '',
      identifiedAt: DateTime.now(),
    )).toList();
  }

  List<session_ai.Breakthrough> _parseBreakthroughs(List<dynamic> data) {
    return data.map((item) => session_ai.Breakthrough(
      id: item['id'] ?? '',
      title: item['title'] ?? '',
      description: item['description'] ?? '',
      significance: (item['significance'] ?? 0.0).toDouble(),
      contributingFactors: List<String>.from(item['contributingFactors'] ?? []),
      impact: item['impact'] ?? '',
      occurredAt: DateTime.now(),
      celebrationNote: item['celebrationNote'] ?? '',
    )).toList();
  }

  session_ai.ChallengeType _parseChallengeType(String type) {
    switch (type.toLowerCase()) {
      case 'emotional':
        return session_ai.ChallengeType.emotional;
      case 'cognitive':
        return session_ai.ChallengeType.cognitive;
      case 'behavioral':
        return session_ai.ChallengeType.behavioral;
      case 'interpersonal':
        return session_ai.ChallengeType.interpersonal;
      default:
        return session_ai.ChallengeType.emotional;
    }
  }

  double _parseChallengeDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 1.0;
      case 'moderate':
        return 2.0;
      case 'hard':
        return 3.0;
      case 'very_hard':
        return 4.0;
      default:
        return 2.0;
    }
  }



  List<session_ai.Alert> _parseAlerts(List<dynamic> data) {
    return data.map((item) => session_ai.Alert(
      id: item['id'] ?? '',
      type: _parseAlertType(item['type'] ?? ''),
      priority: _parseAlertPriority(item['priority'] ?? ''),
      title: item['title'] ?? '',
      description: item['description'] ?? '',
      triggeredAt: DateTime.now(),
      isAcknowledged: false,
      recommendedActions: List<String>.from(item['recommendedActions'] ?? []),
      requiresEscalation: item['requiresEscalation'] ?? false,
    )).toList();
  }

  void _checkForAlerts(session_ai.RealTimeSessionAnalysis analysis) {
    for (final alert in analysis.alerts) {
      if (alert.priority == session_ai.AlertPriority.critical || alert.priority == session_ai.AlertPriority.high) {
        _alertController.add(alert);
        
        _logger.warning('High priority alert triggered', context: 'RealTimeSessionAIService', data: {
          'sessionId': analysis.sessionId,
          'alertId': alert.id,
          'priority': alert.priority.toString(),
          'title': alert.title,
        });
      }
    }
  }

  void _checkForInterventions(session_ai.RealTimeSessionAnalysis analysis) {
    for (final intervention in analysis.interventionSuggestions) {
      if (intervention.confidence >= _interventionThreshold) {
        _interventionController.add(intervention);
        
        _logger.info('Intervention suggestion generated', context: 'RealTimeSessionAIService', data: {
          'sessionId': analysis.sessionId,
          'interventionId': intervention.id,
          'type': intervention.type.toString(),
          'confidence': intervention.confidence,
        });
      }
    }
  }

  Future<void> _generateFinalAnalysis(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null) return;

    try {
      // Generate comprehensive final analysis
      final finalAnalysis = await _generateComprehensiveAnalysis(session);
      
      // Store final analysis
      session.finalAnalysis = finalAnalysis;
      
      _logger.info('Final analysis generated', context: 'RealTimeSessionAIService', data: {
        'sessionId': sessionId,
        'analysisId': finalAnalysis.id,
      });
      
    } catch (e) {
      _logger.error('Failed to generate final analysis', context: 'RealTimeSessionAIService', error: e);
    }
  }

  Future<session_ai.RealTimeSessionAnalysis> _generateComprehensiveAnalysis(SessionAnalysisSession session) async {
    // This would generate a comprehensive analysis of the entire session
    // Implementation would be similar to real-time analysis but with full session data
    
    return session_ai.RealTimeSessionAnalysis(
      id: 'final_analysis_${session.sessionId}',
      sessionId: session.sessionId,
      clientId: session.clientId,
      therapistId: session.therapistId,
      timestamp: DateTime.now(),
      phase: _parseSessionPhase('followUp'),
      emotionalStates: [],
      riskIndicators: [],
      interventionSuggestions: [],
      insights: [],
      progress: session_ai.SessionProgress(
        id: '',
        overallProgress: 0.0,
        goalProgress: [],
        milestones: [],
        challenges: [],
        breakthroughs: [],
        nextSteps: '',
        lastAssessment: DateTime.now(),
      ),
      alerts: [],
      metadata: {},
    );
  }

  bool _isCriticalData(String dataType, Map<String, dynamic> data) {
    // Check if data requires immediate analysis
    return dataType == 'crisis_indicator' || 
           dataType == 'risk_assessment' || 
           dataType == 'suicidal_thoughts' ||
           dataType == 'harm_to_others';
  }

  // Helper methods for multimodal data analysis
  bool _hasMultimodalData(SessionAnalysisSession session) {
    return session.sessionData.any((data) => 
      data.type == 'voice' || 
      data.type == 'facial' || 
      data.type == 'biometric'
    );
  }

  Map<String, dynamic> _extractVoiceData(SessionAnalysisSession session) {
    final voiceData = session.sessionData
        .where((data) => data.type == 'voice')
        .map((data) => data.data)
        .toList();
    
    return {
      'hasVoiceData': voiceData.isNotEmpty,
      'dataPoints': voiceData.length,
      'lastUpdate': voiceData.isNotEmpty ? voiceData.last['timestamp'] : null,
    };
  }

  Map<String, dynamic> _extractFacialData(SessionAnalysisSession session) {
    final facialData = session.sessionData
        .where((data) => data.type == 'facial')
        .map((data) => data.data)
        .toList();
    
    return {
      'hasFacialData': facialData.isNotEmpty,
      'dataPoints': facialData.length,
      'lastUpdate': facialData.isNotEmpty ? facialData.last['timestamp'] : null,
    };
  }

  Map<String, dynamic> _extractBiometricData(SessionAnalysisSession session) {
    final biometricData = session.sessionData
        .where((data) => data.type == 'biometric')
        .map((data) => data.data)
        .toList();
    
    return {
      'hasBiometricData': biometricData.isNotEmpty,
      'dataPoints': biometricData.length,
      'lastUpdate': biometricData.isNotEmpty ? biometricData.last['timestamp'] : null,
    };
  }

  bool _detectCrisisIndicators(SessionAnalysisSession session) {
    // Check for crisis indicators in session data
    return session.sessionData.any((data) {
      if (data.type == 'risk_assessment') {
        final riskData = data.data as Map<String, dynamic>;
        return riskData['riskLevel'] == 'high' || riskData['riskLevel'] == 'critical';
      }
      return false;
    });
  }

  String _determineCrisisType(SessionAnalysisSession session) {
    // Analyze session data to determine crisis type
    if (session.sessionData.any((data) => 
        data.type == 'risk_assessment' && 
        (data.data as Map<String, dynamic>)['riskType'] == 'suicidal')) {
      return 'suicidal_ideation';
    }
    if (session.sessionData.any((data) => 
        data.type == 'risk_assessment' && 
        (data.data as Map<String, dynamic>)['riskType'] == 'violent')) {
      return 'violent_behavior';
    }
    return 'general_crisis';
  }

  String _assessCrisisLevel(SessionAnalysisSession session) {
    // Assess crisis level based on session data
    final highRiskData = session.sessionData
        .where((data) => 
            data.type == 'risk_assessment' && 
            (data.data as Map<String, dynamic>)['riskLevel'] == 'critical')
        .length;
    
    if (highRiskData > 3) return 'critical';
    if (highRiskData > 1) return 'high';
    return 'moderate';
  }

  String _assessClientStatus(SessionAnalysisSession session) {
    // Assess overall client status
    final riskData = session.sessionData
        .where((data) => data.type == 'risk_assessment')
        .map((data) => data.data as Map<String, dynamic>)
        .toList();
    
    if (riskData.any((r) => r['riskLevel'] == 'critical')) {
      return 'critical_condition';
    }
    if (riskData.any((r) => r['riskLevel'] == 'high')) {
      return 'high_risk';
    }
    return 'stable';
  }

  List<String> _identifyCurrentRisks(SessionAnalysisSession session) {
    // Identify current risks from session data
    final risks = <String>[];
    for (final data in session.sessionData) {
      if (data.type == 'risk_assessment') {
        final riskData = data.data as Map<String, dynamic>;
        if (riskData['riskType'] != null) {
          risks.add(riskData['riskType']);
        }
      }
    }
    return risks.toSet().toList();
  }

  List<String> _getPreviousInterventions(SessionAnalysisSession session) {
    // Get previous interventions from client history
    return session.clientHistory['interventions']?.cast<String>() ?? [];
  }

  void _handleCrisisEscalation(session_ai.RealTimeSessionAnalysis analysis, SessionAnalysisSession session) {
    // Handle crisis escalation
    _logger.warning('Crisis escalation detected', context: 'RealTimeSessionAIService', data: {
      'sessionId': session.sessionId,
      'crisisType': analysis.metadata['crisisType'] ?? 'unknown',
      'crisisLevel': analysis.metadata['crisisLevel'] ?? 'unknown',
    });
    
    // Emit crisis alert
    _crisisController.add(analysis);
  }



  session_ai.SessionPhase _parseSessionPhase(String phase) {
    switch (phase) {
      case 'introduction':
        return session_ai.SessionPhase.introduction;
      case 'exploration':
        return session_ai.SessionPhase.exploration;
      case 'intervention':
        return session_ai.SessionPhase.intervention;
      case 'integration':
        return session_ai.SessionPhase.integration;
      case 'closure':
        return session_ai.SessionPhase.closure;
      case 'followUp':
        return session_ai.SessionPhase.followUp;
      default:
        return session_ai.SessionPhase.exploration;
    }
  }

  // Helper methods for parsing enums
  session_ai.EmotionType _parseEmotionType(String value) {
    try {
      return session_ai.EmotionType.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.EmotionType.calm; // Default
    }
  }

  session_ai.RiskType _parseRiskType(String value) {
    try {
      return session_ai.RiskType.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.RiskType.values.first; // Default to first value
    }
  }

  session_ai.RiskSeverity _parseRiskSeverity(String value) {
    try {
      return session_ai.RiskSeverity.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.RiskSeverity.low; // Default
    }
  }

  session_ai.InterventionType _parseInterventionType(String value) {
    try {
      return session_ai.InterventionType.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.InterventionType.psychoeducation; // Default
    }
  }

  session_ai.InterventionTiming _parseInterventionTiming(String value) {
    try {
      return session_ai.InterventionTiming.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.InterventionTiming.duringSession; // Default
    }
  }

  session_ai.InsightType _parseInsightType(String value) {
    try {
      return session_ai.InsightType.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.InsightType.pattern; // Default
    }
  }

  session_ai.AlertType _parseAlertType(String value) {
    try {
      return session_ai.AlertType.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.AlertType.information; // Default
    }
  }

  session_ai.AlertPriority _parseAlertPriority(String value) {
    try {
      return session_ai.AlertPriority.values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return session_ai.AlertPriority.medium; // Default
    }
  }

  // Configuration methods
  void setAnalysisFrequency(double frequency) {
    _analysisFrequency = frequency;
    notifyListeners();
  }

  void setAlertThreshold(double threshold) {
    _alertThreshold = threshold;
    notifyListeners();
  }

  void setInterventionThreshold(double threshold) {
    _interventionThreshold = threshold;
    notifyListeners();
  }

  void enable() {
    _isEnabled = true;
    notifyListeners();
  }

  void disable() {
    _isEnabled = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _analysisController.close();
    _alertController.close();
    _interventionController.close();
    _crisisController.close();
    super.dispose();
  }
}

// Helper classes
class SessionAnalysisSession {
  String sessionId;
  String clientId;
  String therapistId;
  Map<String, dynamic> clientHistory;
  List<String> sessionGoals;
  DateTime startTime;
  DateTime? endTime;
  bool isActive;
  session_ai.RealTimeSessionAnalysis? lastAnalysis;
  session_ai.RealTimeSessionAnalysis? finalAnalysis;
  List<SessionData> sessionData;
  List<session_ai.RealTimeSessionAnalysis> analysisHistory;

  SessionAnalysisSession({
    required this.sessionId,
    required this.clientId,
    required this.therapistId,
    required this.clientHistory,
    required this.sessionGoals,
    required this.startTime,
    required this.isActive,
    this.endTime,
    this.lastAnalysis,
    this.finalAnalysis,
    List<SessionData>? sessionData,
    List<session_ai.RealTimeSessionAnalysis>? analysisHistory,
  }) : sessionData = sessionData ?? [],
       analysisHistory = analysisHistory ?? [];
}

class SessionData {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SessionData({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}
