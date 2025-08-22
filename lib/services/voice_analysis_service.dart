import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voice_analysis_models.dart';

class VoiceAnalysisService {
  static const String _sessionsKey = 'voice_sessions';
  static const String _configKey = 'voice_config';
  
  // Singleton pattern
  static final VoiceAnalysisService _instance = VoiceAnalysisService._internal();
  factory VoiceAnalysisService() => _instance;
  VoiceAnalysisService._internal();

  // Stream controllers for real-time updates
  final StreamController<VoiceAnalysisResult> _analysisStreamController = 
      StreamController<VoiceAnalysisResult>.broadcast();
  
  final StreamController<VoiceAlert> _alertStreamController = 
      StreamController<VoiceAlert>.broadcast();

  // Get streams
  Stream<VoiceAnalysisResult> get analysisStream => _analysisStreamController.stream;
  Stream<VoiceAlert> get alertStream => _alertStreamController.stream;

  // Default configuration
  VoiceAnalysisConfig get defaultConfig => const VoiceAnalysisConfig(
    realTimeAnalysis: true,
    emotionDetection: true,
    stressMonitoring: true,
    patternAnalysis: true,
    anomalyDetection: true,
    analysisInterval: 1000, // 1 second
    sensitivityThreshold: 0.7,
    enabledFeatures: [
      'emotion_detection',
      'stress_monitoring',
      'pattern_analysis',
      'anomaly_detection',
    ],
  );

  // Start real-time voice analysis
  Future<void> startVoiceAnalysis({
    required String sessionId,
    required String patientId,
    VoiceAnalysisConfig? config,
  }) async {
    final analysisConfig = config ?? defaultConfig;
    
    if (!analysisConfig.realTimeAnalysis) return;

    // Simulate real-time voice analysis
    Timer.periodic(Duration(milliseconds: analysisConfig.analysisInterval), (timer) async {
      try {
        final result = await _analyzeVoiceChunk(sessionId, patientId, analysisConfig);
        _analysisStreamController.add(result);
        
        // Check for alerts
        for (final alert in result.alerts) {
          if (alert.severity == AlertSeverity.high || alert.severity == AlertSeverity.critical) {
            _alertStreamController.add(alert);
          }
        }
      } catch (e) {
        print('Error in voice analysis: $e');
      }
    });
  }

  // Stop voice analysis
  void stopVoiceAnalysis() {
    // In real implementation, this would stop the audio stream
    print('Voice analysis stopped');
  }

  // Analyze a chunk of voice data
  Future<VoiceAnalysisResult> _analyzeVoiceChunk(
    String sessionId,
    String patientId,
    VoiceAnalysisConfig config,
  ) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    final random = Random();
    final timestamp = DateTime.now();
    
    // Generate mock emotion data
    final emotionData = _generateEmotionData(random, config);
    
    // Generate mock stress data
    final stressData = _generateStressData(random, config);
    
    // Generate mock pattern data
    final patternData = _generatePatternData(random, config);
    
    // Generate alerts based on analysis
    final alerts = _generateAlerts(emotionData, stressData, patternData, config);
    
    // Calculate overall confidence
    final confidence = 0.85 + (random.nextDouble() - 0.5) * 0.1;
    
    // Generate insights
    final insights = _generateInsights(emotionData, stressData, patternData);
    
    return VoiceAnalysisResult(
      id: 'result_${timestamp.millisecondsSinceEpoch}',
      sessionId: sessionId,
      timestamp: timestamp,
      emotionData: emotionData,
      stressData: stressData,
      patternData: patternData,
      alerts: alerts,
      confidence: confidence.clamp(0.0, 1.0),
      insights: insights,
    );
  }

  // Generate mock emotion data
  VoiceEmotionData _generateEmotionData(Random random, VoiceAnalysisConfig config) {
    if (!config.emotionDetection) {
      return const VoiceEmotionData(
        happiness: 0.0,
        sadness: 0.0,
        anger: 0.0,
        fear: 0.0,
        surprise: 0.0,
        disgust: 0.0,
        neutral: 1.0,
      );
    }
    
    final emotions = <String, double>{
      'happiness': random.nextDouble(),
      'sadness': random.nextDouble(),
      'anger': random.nextDouble(),
      'fear': random.nextDouble(),
      'surprise': random.nextDouble(),
      'disgust': random.nextDouble(),
      'neutral': random.nextDouble(),
    };
    
    // Normalize emotions
    final total = emotions.values.reduce((a, b) => a + b);
    final normalizedEmotions = emotions.map((key, value) => MapEntry(key, value / total));
    
    // Generate timeline
    final timeline = <EmotionTimeline>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 5; i++) {
      final timestamp = now.subtract(Duration(seconds: i * 2));
      final dominantEmotion = normalizedEmotions.entries
          .reduce((a, b) => a.value > b.value ? a : b).key;
      
      timeline.add(EmotionTimeline(
        timestamp: timestamp,
        dominantEmotion: dominantEmotion,
        confidence: 0.8 + random.nextDouble() * 0.2,
        emotionScores: Map.from(normalizedEmotions),
      ));
    }
    
    return VoiceEmotionData(
      happiness: normalizedEmotions['happiness']!,
      sadness: normalizedEmotions['sadness']!,
      anger: normalizedEmotions['anger']!,
      fear: normalizedEmotions['fear']!,
      surprise: normalizedEmotions['surprise']!,
      disgust: normalizedEmotions['disgust']!,
      neutral: normalizedEmotions['neutral']!,
      timeline: timeline,
    );
  }

  // Generate mock stress data
  VoiceStressData _generateStressData(Random random, VoiceAnalysisConfig config) {
    if (!config.stressMonitoring) {
      return const VoiceStressData(
        stressLevel: 0.0,
        category: StressCategory.low,
        indicators: [],
        triggers: [],
      );
    }
    
    final stressLevel = random.nextDouble();
    final category = _determineStressCategory(stressLevel);
    
    // Generate stress indicators
    final indicators = <StressIndicator>[];
    if (stressLevel > 0.3) {
      indicators.add(StressIndicator(
        type: 'voice_tremor',
        intensity: stressLevel,
        description: 'Voice shows signs of stress and anxiety',
        detectedAt: DateTime.now(),
      ));
    }
    
    if (stressLevel > 0.5) {
      indicators.add(StressIndicator(
        type: 'rapid_speech',
        intensity: stressLevel,
        description: 'Speaking rate increased due to stress',
        detectedAt: DateTime.now(),
      ));
    }
    
    // Generate stress triggers
    final triggers = <StressTrigger>[];
    if (stressLevel > 0.4) {
      triggers.add(StressTrigger(
        trigger: 'discussion_topic',
        impact: stressLevel,
        context: 'Patient showed increased stress when discussing specific topics',
        timestamp: DateTime.now(),
      ));
    }
    
    return VoiceStressData(
      stressLevel: stressLevel,
      category: category,
      indicators: indicators,
      triggers: triggers,
    );
  }

  // Generate mock pattern data
  VoicePatternData _generatePatternData(Random random, VoiceAnalysisConfig config) {
    if (!config.patternAnalysis) {
      return const VoicePatternData(
        speakingRate: 0.0,
        volumeVariation: 0.0,
        pitchVariation: 0.0,
        patterns: [],
        anomalies: [],
      );
    }
    
    final speakingRate = 0.5 + random.nextDouble() * 0.5; // 0.5 to 1.0
    final volumeVariation = random.nextDouble();
    final pitchVariation = random.nextDouble();
    
    // Generate speech patterns
    final patterns = <SpeechPattern>[];
    if (random.nextDouble() > 0.7) {
      patterns.add(SpeechPattern(
        type: 'filler_words',
        frequency: random.nextDouble(),
        description: 'Patient uses filler words frequently',
        occurrences: [DateTime.now()],
      ));
    }
    
    if (random.nextDouble() > 0.8) {
      patterns.add(SpeechPattern(
        type: 'pause_patterns',
        frequency: random.nextDouble(),
        description: 'Unusual pause patterns detected',
        occurrences: [DateTime.now()],
      ));
    }
    
    // Generate anomalies
    final anomalies = <Anomaly>[];
    if (random.nextDouble() > 0.9) {
      anomalies.add(Anomaly(
        type: 'speech_disruption',
        severity: random.nextDouble(),
        description: 'Sudden speech disruption detected',
        detectedAt: DateTime.now(),
        context: {'duration': '2.3s', 'type': 'stuttering'},
      ));
    }
    
    return VoicePatternData(
      speakingRate: speakingRate,
      volumeVariation: volumeVariation,
      pitchVariation: pitchVariation,
      patterns: patterns,
      anomalies: anomalies,
    );
  }

  // Generate alerts based on analysis
  List<VoiceAlert> _generateAlerts(
    VoiceEmotionData emotionData,
    VoiceStressData stressData,
    VoicePatternData patternData,
    VoiceAnalysisConfig config,
  ) {
    final alerts = <VoiceAlert>[];
    final timestamp = DateTime.now();
    
    // Stress alerts
    if (stressData.stressLevel > config.sensitivityThreshold) {
      alerts.add(VoiceAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_1',
        type: AlertType.stressSpike,
        severity: stressData.stressLevel > 0.8 ? AlertSeverity.critical : AlertSeverity.high,
        message: 'High stress level detected in patient voice',
        timestamp: timestamp,
      ));
    }
    
    // Emotion alerts
    if (emotionData.sadness > 0.7 || emotionData.anger > 0.7) {
      alerts.add(VoiceAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_2',
        type: AlertType.emotionChange,
        severity: AlertSeverity.high,
        message: 'Significant emotional distress detected',
        timestamp: timestamp,
      ));
    }
    
    // Crisis indicators
    if (emotionData.sadness > 0.8 || stressData.stressLevel > 0.9) {
      alerts.add(VoiceAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_3',
        type: AlertType.crisisIndicator,
        severity: AlertSeverity.critical,
        message: 'CRISIS ALERT: Immediate attention required',
        timestamp: timestamp,
      ));
    }
    
    // Pattern alerts
    if (patternData.anomalies.isNotEmpty) {
      alerts.add(VoiceAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_4',
        type: AlertType.speechPattern,
        severity: AlertSeverity.medium,
        message: 'Unusual speech patterns detected',
        timestamp: timestamp,
      ));
    }
    
    return alerts;
  }

  // Generate insights from analysis
  Map<String, dynamic> _generateInsights(
    VoiceEmotionData emotionData,
    VoiceStressData stressData,
    VoicePatternData patternData,
  ) {
    final insights = <String, dynamic>{};
    
    // Emotion insights
    final dominantEmotion = {
      'happiness': emotionData.happiness,
      'sadness': emotionData.sadness,
      'anger': emotionData.anger,
      'fear': emotionData.fear,
      'surprise': emotionData.surprise,
      'disgust': emotionData.disgust,
      'neutral': emotionData.neutral,
    }.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    insights['dominant_emotion'] = {
      'emotion': dominantEmotion.key,
      'confidence': dominantEmotion.value,
      'description': _getEmotionDescription(dominantEmotion.key),
    };
    
    // Stress insights
    insights['stress_analysis'] = {
      'level': stressData.stressLevel,
      'category': stressData.category.name,
      'trend': stressData.stressLevel > 0.6 ? 'increasing' : 'stable',
      'recommendations': _getStressRecommendations(stressData.stressLevel),
    };
    
    // Pattern insights
    insights['speech_patterns'] = {
      'speaking_rate': patternData.speakingRate > 0.7 ? 'fast' : 'normal',
      'volume_stability': patternData.volumeVariation < 0.3 ? 'stable' : 'variable',
      'pitch_stability': patternData.pitchVariation < 0.3 ? 'stable' : 'variable',
    };
    
    // Overall assessment
    insights['overall_assessment'] = {
      'mood': _assessOverallMood(emotionData),
      'stress_level': _assessStressLevel(stressData.stressLevel),
      'communication_quality': _assessCommunicationQuality(patternData),
      'risk_level': _assessRiskLevel(emotionData, stressData),
    };
    
    return insights;
  }

  // Helper methods
  StressCategory _determineStressCategory(double stressLevel) {
    if (stressLevel < 0.25) return StressCategory.low;
    if (stressLevel < 0.5) return StressCategory.moderate;
    if (stressLevel < 0.75) return StressCategory.high;
    return StressCategory.critical;
  }

  String _getEmotionDescription(String emotion) {
    switch (emotion) {
      case 'happiness':
        return 'Patient shows positive emotional state';
      case 'sadness':
        return 'Patient exhibits signs of depression or grief';
      case 'anger':
        return 'Patient shows frustration or anger';
      case 'fear':
        return 'Patient appears anxious or fearful';
      case 'surprise':
        return 'Patient shows unexpected emotional response';
      case 'disgust':
        return 'Patient shows aversion or disgust';
      case 'neutral':
        return 'Patient maintains emotional stability';
      default:
        return 'Emotional state unclear';
    }
  }

  List<String> _getStressRecommendations(double stressLevel) {
    if (stressLevel < 0.3) return ['Continue current approach'];
    
    if (stressLevel < 0.6) {
      return [
        'Implement breathing exercises',
        'Use calming techniques',
        'Consider stress management strategies',
      ];
    }
    
    if (stressLevel < 0.8) {
      return [
        'Immediate stress reduction needed',
        'Consider crisis intervention',
        'Monitor patient closely',
      ];
    }
    
    return [
      'CRITICAL: Immediate intervention required',
      'Consider emergency protocols',
      'Patient safety is priority',
    ];
  }

  String _assessOverallMood(VoiceEmotionData emotionData) {
    final positiveEmotions = emotionData.happiness + emotionData.surprise;
    final negativeEmotions = emotionData.sadness + emotionData.anger + emotionData.fear + emotionData.disgust;
    
    if (positiveEmotions > negativeEmotions + 0.2) return 'positive';
    if (negativeEmotions > positiveEmotions + 0.2) return 'negative';
    return 'neutral';
  }

  String _assessStressLevel(double stressLevel) {
    if (stressLevel < 0.3) return 'low';
    if (stressLevel < 0.6) return 'moderate';
    if (stressLevel < 0.8) return 'high';
    return 'critical';
  }

  String _assessCommunicationQuality(VoicePatternData patternData) {
    if (patternData.speakingRate > 0.7 && patternData.volumeVariation < 0.3) {
      return 'excellent';
    }
    if (patternData.speakingRate > 0.5 && patternData.volumeVariation < 0.5) {
      return 'good';
    }
    if (patternData.speakingRate > 0.3) {
      return 'fair';
    }
    return 'poor';
  }

  String _assessRiskLevel(VoiceEmotionData emotionData, VoiceStressData stressData) {
    if (emotionData.sadness > 0.9 || stressData.stressLevel > 0.9) {
      return 'critical';
    }
    if (emotionData.sadness > 0.8 || stressData.stressLevel > 0.7) {
      return 'high';
    }
    if (emotionData.anger > 0.6 || stressData.stressLevel > 0.5) {
      return 'moderate';
    }
    return 'low';
  }

  // Save voice analysis session
  Future<void> saveVoiceAnalysisSession(VoiceAnalysisSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsKey = '${_sessionsKey}_${session.patientId}';
      
      final existingSessionsJson = prefs.getString(sessionsKey);
      List<Map<String, dynamic>> sessions = [];
      
      if (existingSessionsJson != null) {
        sessions = List<Map<String, dynamic>>.from(json.decode(existingSessionsJson));
      }
      
      sessions.add(session.toJson());
      
      // Keep only last 50 sessions
      if (sessions.length > 50) {
        sessions = sessions.sublist(sessions.length - 50);
      }
      
      await prefs.setString(sessionsKey, json.encode(sessions));
    } catch (e) {
      print('Error saving voice analysis session: $e');
    }
  }

  // Get voice analysis sessions for a patient
  Future<List<VoiceAnalysisSession>> getVoiceAnalysisSessions(String patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsKey = '${_sessionsKey}_$patientId';
      
      final sessionsJson = prefs.getString(sessionsKey);
      if (sessionsJson == null) return [];
      
      final sessions = List<Map<String, dynamic>>.from(json.decode(sessionsJson));
      return sessions.map((json) => VoiceAnalysisSession.fromJson(json)).toList();
    } catch (e) {
      print('Error getting voice analysis sessions: $e');
      return [];
    }
  }

  // Save voice analysis configuration
  Future<void> saveVoiceAnalysisConfig(VoiceAnalysisConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, json.encode(config.toJson()));
    } catch (e) {
      print('Error saving voice analysis config: $e');
    }
  }

  // Get voice analysis configuration
  Future<VoiceAnalysisConfig> getVoiceAnalysisConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);
      
      if (configJson != null) {
        return VoiceAnalysisConfig.fromJson(json.decode(configJson));
      }
      
      return defaultConfig;
    } catch (e) {
      print('Error getting voice analysis config: $e');
      return defaultConfig;
    }
  }

  // Dispose resources
  void dispose() {
    _analysisStreamController.close();
    _alertStreamController.close();
  }
}
