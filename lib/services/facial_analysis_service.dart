import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class FacialAnalysisService {
  static const String _sessionsKey = 'facial_sessions';
  static const String _configKey = 'facial_config';
  
  // Singleton pattern
  static final FacialAnalysisService _instance = FacialAnalysisService._internal();
  factory FacialAnalysisService() => _instance;
  FacialAnalysisService._internal();

  // Stream controllers for real-time updates
  final StreamController<FacialAnalysisResult> _analysisStreamController = 
      StreamController<FacialAnalysisResult>.broadcast();
  
  final StreamController<FacialAlert> _alertStreamController = 
      StreamController<FacialAlert>.broadcast();

  // Get streams
  Stream<FacialAnalysisResult> get analysisStream => _analysisStreamController.stream;
  Stream<FacialAlert> get alertStream => _alertStreamController.stream;

  // Start real-time facial analysis
  Future<void> startFacialAnalysis({
    required String sessionId,
    required String patientId,
    Map<String, dynamic>? config,
  }) async {
    final analysisConfig = config ?? _getDefaultConfig();
    
    // Simulate real-time facial analysis
    Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      try {
        final result = await _analyzeFacialFrame(sessionId, patientId, analysisConfig);
        _analysisStreamController.add(result);
        
        // Check for alerts
        for (final alert in result.alerts) {
          if (alert.severity == 'high' || alert.severity == 'critical') {
            _alertStreamController.add(alert);
          }
        }
      } catch (e) {
        print('Error in facial analysis: $e');
      }
    });
  }

  // Stop facial analysis
  void stopFacialAnalysis() {
    print('Facial analysis stopped');
  }

  // Analyze a facial frame
  Future<FacialAnalysisResult> _analyzeFacialFrame(
    String sessionId,
    String patientId,
    Map<String, dynamic> config,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final random = Random();
    final timestamp = DateTime.now();
    
    // Generate mock facial expressions
    final expressions = _generateFacialExpressions(random);
    
    // Generate mock micro-expressions
    final microExpressions = _generateMicroExpressions(random);
    
    // Generate mock stress indicators
    final stressIndicators = _generateStressIndicators(random);
    
    // Generate alerts
    final alerts = _generateFacialAlerts(expressions, microExpressions, stressIndicators);
    
    // Calculate confidence
    final confidence = 0.88 + (random.nextDouble() - 0.5) * 0.1;
    
    // Generate insights
    final insights = _generateFacialInsights(expressions, microExpressions, stressIndicators);
    
    return FacialAnalysisResult(
      id: 'facial_${timestamp.millisecondsSinceEpoch}',
      sessionId: sessionId,
      timestamp: timestamp,
      expressions: expressions,
      microExpressions: microExpressions,
      stressIndicators: stressIndicators,
      alerts: alerts,
      confidence: confidence.clamp(0.0, 1.0),
      insights: insights,
    );
  }

  // Generate mock facial expressions
  Map<String, double> _generateFacialExpressions(Random random) {
    return {
      'happiness': random.nextDouble(),
      'sadness': random.nextDouble(),
      'anger': random.nextDouble(),
      'fear': random.nextDouble(),
      'surprise': random.nextDouble(),
      'disgust': random.nextDouble(),
      'neutral': random.nextDouble(),
      'confusion': random.nextDouble(),
      'contempt': random.nextDouble(),
      'embarrassment': random.nextDouble(),
    };
  }

  // Generate mock micro-expressions
  List<Map<String, dynamic>> _generateMicroExpressions(Random random) {
    final microExpressions = <Map<String, dynamic>>[];
    
    if (random.nextDouble() > 0.7) {
      microExpressions.add({
        'type': 'micro_fear',
        'duration': 0.1 + random.nextDouble() * 0.2,
        'intensity': random.nextDouble(),
        'description': 'Brief fear expression detected',
      });
    }
    
    if (random.nextDouble() > 0.8) {
      microExpressions.add({
        'type': 'micro_anger',
        'duration': 0.05 + random.nextDouble() * 0.1,
        'intensity': random.nextDouble(),
        'description': 'Quick anger flash detected',
      });
    }
    
    return microExpressions;
  }

  // Generate mock stress indicators
  List<Map<String, dynamic>> _generateStressIndicators(Random random) {
    final indicators = <Map<String, dynamic>>[];
    
    if (random.nextDouble() > 0.6) {
      indicators.add({
        'type': 'eye_movement',
        'intensity': random.nextDouble(),
        'description': 'Rapid eye movement indicating stress',
      });
    }
    
    if (random.nextDouble() > 0.7) {
      indicators.add({
        'type': 'facial_tension',
        'intensity': random.nextDouble(),
        'description': 'Increased facial muscle tension',
      });
    }
    
    if (random.nextDouble() > 0.8) {
      indicators.add({
        'type': 'blinking_rate',
        'intensity': random.nextDouble(),
        'description': 'Increased blinking rate',
      });
    }
    
    return indicators;
  }

  // Generate facial alerts
  List<FacialAlert> _generateFacialAlerts(
    Map<String, double> expressions,
    List<Map<String, dynamic>> microExpressions,
    List<Map<String, dynamic>> stressIndicators,
  ) {
    final alerts = <FacialAlert>[];
    final timestamp = DateTime.now();
    
    // Expression alerts
    if (expressions['sadness']! > 0.8) {
      alerts.add(FacialAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_1',
        type: 'emotion_detected',
        severity: 'high',
        message: 'High level of sadness detected in facial expression',
        timestamp: timestamp,
        acknowledged: false,
      ));
    }
    
    if (expressions['anger']! > 0.7) {
      alerts.add(FacialAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_2',
        type: 'emotion_detected',
        severity: 'high',
        message: 'Significant anger detected in facial expression',
        timestamp: timestamp,
        acknowledged: false,
      ));
    }
    
    // Micro-expression alerts
    if (microExpressions.isNotEmpty) {
      alerts.add(FacialAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_3',
        type: 'micro_expression',
        severity: 'medium',
        message: 'Micro-expressions detected - potential emotional suppression',
        timestamp: timestamp,
        acknowledged: false,
      ));
    }
    
    // Stress alerts
    if (stressIndicators.length > 2) {
      alerts.add(FacialAlert(
        id: 'alert_${timestamp.millisecondsSinceEpoch}_4',
        type: 'stress_detected',
        severity: 'high',
        message: 'Multiple stress indicators detected in facial expression',
        timestamp: timestamp,
        acknowledged: false,
      ));
    }
    
    return alerts;
  }

  // Generate facial insights
  Map<String, dynamic> _generateFacialInsights(
    Map<String, double> expressions,
    List<Map<String, dynamic>> microExpressions,
    List<Map<String, dynamic>> stressIndicators,
  ) {
    final insights = <String, dynamic>{};
    
    // Dominant expression
    final dominantExpression = expressions.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    insights['dominant_expression'] = {
      'emotion': dominantExpression.key,
      'intensity': dominantExpression.value,
      'description': _getExpressionDescription(dominantExpression.key),
    };
    
    // Expression stability
    final expressionVariance = _calculateExpressionVariance(expressions);
    insights['expression_stability'] = {
      'variance': expressionVariance,
      'stability': expressionVariance < 0.1 ? 'stable' : 'variable',
      'description': _getStabilityDescription(expressionVariance),
    };
    
    // Stress analysis
    insights['stress_analysis'] = {
      'indicators_count': stressIndicators.length,
      'stress_level': _assessStressLevel(stressIndicators),
      'recommendations': _getStressRecommendations(stressIndicators.length),
    };
    
    // Micro-expression analysis
    insights['micro_expression_analysis'] = {
      'detected_count': microExpressions.length,
      'types': microExpressions.map((m) => m['type']).toList(),
      'significance': _assessMicroExpressionSignificance(microExpressions),
    };
    
    // Overall assessment
    insights['overall_assessment'] = {
      'emotional_state': _assessEmotionalState(expressions),
      'stress_level': _assessOverallStressLevel(stressIndicators),
      'attention_level': _assessAttentionLevel(expressions, stressIndicators),
      'risk_level': _assessRiskLevel(expressions, microExpressions),
    };
    
    return insights;
  }

  // Helper methods
  String _getExpressionDescription(String emotion) {
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
      case 'confusion':
        return 'Patient appears confused or uncertain';
      case 'contempt':
        return 'Patient shows contempt or disdain';
      case 'embarrassment':
        return 'Patient appears embarrassed or ashamed';
      default:
        return 'Emotional state unclear';
    }
  }

  double _calculateExpressionVariance(Map<String, double> expressions) {
    final values = expressions.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b) / values.length;
    return variance;
  }

  String _getStabilityDescription(double variance) {
    if (variance < 0.05) return 'Very stable emotional expression';
    if (variance < 0.1) return 'Stable emotional expression';
    if (variance < 0.2) return 'Moderately variable expression';
    return 'Highly variable emotional expression';
  }

  String _assessStressLevel(List<Map<String, dynamic>> stressIndicators) {
    if (stressIndicators.isEmpty) return 'low';
    if (stressIndicators.length == 1) return 'moderate';
    if (stressIndicators.length == 2) return 'high';
    return 'very_high';
  }

  List<String> _getStressRecommendations(int indicatorCount) {
    if (indicatorCount == 0) return ['Continue current approach'];
    
    if (indicatorCount == 1) {
      return [
        'Monitor patient stress levels',
        'Use calming techniques',
        'Consider stress management strategies',
      ];
    }
    
    if (indicatorCount == 2) {
      return [
        'Implement stress reduction techniques',
        'Consider crisis intervention',
        'Monitor patient closely',
      ];
    }
    
    return [
      'Immediate stress intervention needed',
      'Consider emergency protocols',
      'Patient safety is priority',
    ];
  }

  String _assessMicroExpressionSignificance(List<Map<String, dynamic>> microExpressions) {
    if (microExpressions.isEmpty) return 'none';
    
    final highIntensityCount = microExpressions
        .where((m) => m['intensity'] > 0.7)
        .length;
    
    if (highIntensityCount > 1) return 'high';
    if (highIntensityCount == 1) return 'moderate';
    return 'low';
  }

  String _assessEmotionalState(Map<String, double> expressions) {
    final positiveEmotions = expressions['happiness']! + expressions['surprise']!;
    final negativeEmotions = expressions['sadness']! + expressions['anger']! + 
                            expressions['fear']! + expressions['disgust']!;
    
    if (positiveEmotions > negativeEmotions + 0.2) return 'positive';
    if (negativeEmotions > positiveEmotions + 0.2) return 'negative';
    return 'neutral';
  }

  String _assessOverallStressLevel(List<Map<String, dynamic>> stressIndicators) {
    if (stressIndicators.isEmpty) return 'low';
    if (stressIndicators.length < 2) return 'moderate';
    return 'high';
  }

  String _assessAttentionLevel(
    Map<String, double> expressions,
    List<Map<String, dynamic>> stressIndicators,
  ) {
    if (expressions['neutral']! > 0.6 && stressIndicators.length < 2) {
      return 'high';
    }
    if (expressions['confusion']! > 0.5 || stressIndicators.length > 1) {
      return 'low';
    }
    return 'moderate';
  }

  String _assessRiskLevel(
    Map<String, double> expressions,
    List<Map<String, dynamic>> microExpressions,
  ) {
    if (expressions['sadness']! > 0.9 || expressions['anger']! > 0.8) {
      return 'critical';
    }
    if (expressions['fear']! > 0.7 || microExpressions.length > 2) {
      return 'high';
    }
    if (expressions['confusion']! > 0.6) {
      return 'moderate';
    }
    return 'low';
  }

  // Get default configuration
  Map<String, dynamic> _getDefaultConfig() {
    return {
      'real_time_analysis': true,
      'emotion_detection': true,
      'micro_expression_detection': true,
      'stress_monitoring': true,
      'analysis_interval': 1000,
      'sensitivity_threshold': 0.7,
    };
  }

  // Save facial analysis session
  Future<void> saveFacialAnalysisSession(Map<String, dynamic> session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsKey = '${_sessionsKey}_${session['patientId']}';
      
      final existingSessionsJson = prefs.getString(sessionsKey);
      List<Map<String, dynamic>> sessions = [];
      
      if (existingSessionsJson != null) {
        sessions = List<Map<String, dynamic>>.from(json.decode(existingSessionsJson));
      }
      
      sessions.add(session);
      
      // Keep only last 50 sessions
      if (sessions.length > 50) {
        sessions = sessions.sublist(sessions.length - 50);
      }
      
      await prefs.setString(sessionsKey, json.encode(sessions));
    } catch (e) {
      print('Error saving facial analysis session: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _analysisStreamController.close();
    _alertStreamController.close();
  }
}

// Data classes for facial analysis
class FacialAnalysisResult {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final Map<String, double> expressions;
  final List<Map<String, dynamic>> microExpressions;
  final List<Map<String, dynamic>> stressIndicators;
  final List<FacialAlert> alerts;
  final double confidence;
  final Map<String, dynamic> insights;

  const FacialAnalysisResult({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.expressions,
    required this.microExpressions,
    required this.stressIndicators,
    required this.alerts,
    required this.confidence,
    required this.insights,
  });
}

class FacialAlert {
  final String id;
  final String type;
  final String severity;
  final String message;
  final DateTime timestamp;
  final bool acknowledged;

  const FacialAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.acknowledged,
  });
}
