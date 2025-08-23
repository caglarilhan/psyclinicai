import 'dart:async';
import 'package:psyclinicai/models/predictive_analytics_models.dart';
import 'package:psyclinicai/services/openai_gpt4_service.dart';

/// Crisis Detection Service for PsyClinicAI
/// Provides real-time crisis detection and intervention
class CrisisDetectionService {
  static final CrisisDetectionService _instance = CrisisDetectionService._internal();
  factory CrisisDetectionService() => _instance;
  CrisisDetectionService._internal();

  final OpenAIGPT4Service _gpt4Service = OpenAIGPT4Service();
  
  final Map<String, CrisisRiskProfile> _patientRiskProfiles = {};
  final StreamController<CrisisAlert> _crisisAlertController = StreamController<CrisisAlert>.broadcast();
  final StreamController<CrisisIntervention> _interventionController = StreamController<CrisisIntervention>.broadcast();

  Stream<CrisisAlert> get crisisAlertStream => _crisisAlertController.stream;
  Stream<CrisisIntervention> get interventionStream => _interventionController.stream;

  /// Initialize crisis detection for a patient
  Future<void> initializePatient(String patientId, Map<String, dynamic> baselineData, List<String> riskFactors) async {
    _patientRiskProfiles[patientId] = CrisisRiskProfile(
      patientId: patientId,
      baselineData: baselineData,
      riskFactors: riskFactors,
      alertHistory: [],
      lastAssessment: DateTime.now(),
      riskLevel: CrisisRiskLevel.low,
    );
  }

  /// Start monitoring for crisis indicators
  Future<void> startMonitoring(String patientId) async {
    print('🔍 Starting crisis monitoring for patient: $patientId');
    // In a real implementation, this would start continuous monitoring
  }

  /// Stop monitoring for crisis indicators
  Future<void> stopMonitoring(String patientId) async {
    print('⏹️ Stopping crisis monitoring for patient: $patientId');
    // In a real implementation, this would stop continuous monitoring
  }

  /// Analyze voice data for crisis indicators
  Future<List<CrisisIndicator>> analyzeVoiceData(String patientId, Map<String, dynamic> voiceData) async {
    final profile = _patientRiskProfiles[patientId];
    if (profile == null) return [];

    // Mock voice analysis
    final indicators = <CrisisIndicator>[];
    
    if (voiceData['tone'] == 'aggressive') {
      indicators.add(CrisisIndicator(
        type: CrisisIndicatorType.voice,
        severity: CrisisSeverity.high,
        description: 'Aggressive tone detected',
        timestamp: DateTime.now(),
        confidence: 0.85,
      ));
    }

    if (voiceData['volume'] == 'shouting') {
      indicators.add(CrisisIndicator(
        type: CrisisIndicatorType.voice,
        severity: CrisisSeverity.medium,
        description: 'Elevated voice volume',
        timestamp: DateTime.now(),
        confidence: 0.75,
      ));
    }

    return indicators;
  }

  /// Analyze facial data for crisis indicators
  Future<List<CrisisIndicator>> analyzeFacialData(String patientId, Map<String, dynamic> facialData) async {
    final profile = _patientRiskProfiles[patientId];
    if (profile == null) return [];

    // Mock facial analysis
    final indicators = <CrisisIndicator>[];
    
    if (facialData['emotion'] == 'anger') {
      indicators.add(CrisisIndicator(
        type: CrisisIndicatorType.facial,
        severity: CrisisSeverity.high,
        description: 'Anger expression detected',
        timestamp: DateTime.now(),
        confidence: 0.90,
      ));
    }

    if (facialData['tension'] == 'high') {
      indicators.add(CrisisIndicator(
        type: CrisisIndicatorType.facial,
        severity: CrisisSeverity.medium,
        description: 'High facial tension',
        timestamp: DateTime.now(),
        confidence: 0.80,
      ));
    }

    return indicators;
  }

  /// Analyze text data for crisis indicators
  Future<List<CrisisIndicator>> analyzeTextData(String patientId, String text) async {
    final profile = _patientRiskProfiles[patientId];
    if (profile == null) return [];

    // Mock text analysis
    final indicators = <CrisisIndicator>[];
    
    if (text.toLowerCase().contains('kill myself') || text.toLowerCase().contains('suicide')) {
      indicators.add(CrisisIndicator(
        type: CrisisIndicatorType.text,
        severity: CrisisSeverity.critical,
        description: 'Suicidal ideation detected',
        timestamp: DateTime.now(),
        confidence: 0.95,
      ));
    }

    if (text.toLowerCase().contains('hurt someone') || text.toLowerCase().contains('violence')) {
      indicators.add(CrisisIndicator(
        type: CrisisIndicatorType.text,
        severity: CrisisSeverity.high,
        description: 'Violent ideation detected',
        timestamp: DateTime.now(),
        confidence: 0.88,
      ));
    }

    return indicators;
  }

  /// Assess overall crisis risk
  Future<CrisisRiskLevel> assessCrisisRisk(String patientId, List<CrisisIndicator> indicators) async {
    final profile = _patientRiskProfiles[patientId];
    if (profile == null) return CrisisRiskLevel.low;

    if (indicators.isEmpty) return CrisisRiskLevel.low;

    // Calculate risk based on indicators
    double totalRisk = 0;
    for (final indicator in indicators) {
      switch (indicator.severity) {
        case CrisisSeverity.low:
          totalRisk += 1;
          break;
        case CrisisSeverity.medium:
          totalRisk += 2;
          break;
        case CrisisSeverity.high:
          totalRisk += 3;
          break;
        case CrisisSeverity.critical:
          totalRisk += 4;
          break;
      }
    }

    // Update profile
    profile.riskLevel = _calculateRiskLevel(totalRisk, indicators.length);
    profile.lastAssessment = DateTime.now();
    profile.alertHistory.addAll(indicators.map((i) => i.toAlert()));

    return profile.riskLevel;
  }

  /// Generate crisis intervention plan
  Future<CrisisIntervention> generateIntervention(String patientId, CrisisRiskLevel riskLevel) async {
    final profile = _patientRiskProfiles[patientId];
    if (profile == null) {
      return CrisisIntervention(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        riskLevel: riskLevel,
        recommendations: ['Patient profile not found'],
        immediateActions: ['Contact administrator'],
        followUpActions: ['Review patient setup'],
        timestamp: DateTime.now(),
      );
    }

    try {
      // Use GPT-4 for crisis intervention planning
      final response = await _gpt4Service.detectCrisis(
        patientData: profile.baselineData,
        currentBehavior: 'Crisis detected - Risk level: ${riskLevel.name}',
        riskFactors: profile.riskFactors.join(', '),
      );

      return CrisisIntervention(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        riskLevel: riskLevel,
        recommendations: response.recommendations,
        immediateActions: response.immediateActions,
        followUpActions: response.followUpActions,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('❌ Crisis intervention generation failed: $e');
      
      // Fallback intervention
      return CrisisIntervention(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        riskLevel: riskLevel,
        recommendations: [
          'Assess immediate safety',
          'Contact emergency services if needed',
          'Notify supervising clinician',
        ],
        immediateActions: [
          'Ensure patient safety',
          'Remove any dangerous objects',
          'Maintain calm environment',
        ],
        followUpActions: [
          'Schedule crisis evaluation',
          'Update treatment plan',
          'Increase monitoring frequency',
        ],
        timestamp: DateTime.now(),
      );
    }
  }

  /// Send crisis alert
  void _sendCrisisAlert(String patientId, CrisisRiskLevel riskLevel, List<CrisisIndicator> indicators) {
    final alert = CrisisAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      riskLevel: riskLevel,
      indicators: indicators,
      timestamp: DateTime.now(),
      status: CrisisAlertStatus.active,
    );

    _crisisAlertController.add(alert);
  }

  /// Calculate risk level based on indicators
  CrisisRiskLevel _calculateRiskLevel(double totalRisk, int indicatorCount) {
    final averageRisk = totalRisk / indicatorCount;
    
    if (averageRisk >= 3.5) return CrisisRiskLevel.critical;
    if (averageRisk >= 2.5) return CrisisRiskLevel.high;
    if (averageRisk >= 1.5) return CrisisRiskLevel.medium;
    return CrisisRiskLevel.low;
  }

  /// Get patient risk profile
  CrisisRiskProfile? getPatientProfile(String patientId) {
    return _patientRiskProfiles[patientId];
  }

  /// Get all active crisis alerts
  List<CrisisAlert> getActiveAlerts() {
    return _patientRiskProfiles.values
        .where((profile) => profile.riskLevel != CrisisRiskLevel.low)
        .map((profile) => CrisisAlert(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              patientId: profile.patientId,
              riskLevel: profile.riskLevel,
              indicators: profile.alertHistory.take(5).toList(),
              timestamp: profile.lastAssessment,
              status: CrisisAlertStatus.active,
            ))
        .toList();
  }

  /// Dispose resources
  void dispose() {
    _crisisAlertController.close();
    _interventionController.close();
  }
}

/// Crisis Risk Profile
class CrisisRiskProfile {
  final String patientId;
  final Map<String, dynamic> baselineData;
  final List<String> riskFactors;
  final List<CrisisAlert> alertHistory;
  DateTime lastAssessment;
  CrisisRiskLevel riskLevel;

  CrisisRiskProfile({
    required this.patientId,
    required this.baselineData,
    required this.riskFactors,
    required this.alertHistory,
    required this.lastAssessment,
    required this.riskLevel,
  });
}

/// Crisis Indicator
class CrisisIndicator {
  final CrisisIndicatorType type;
  final CrisisSeverity severity;
  final String description;
  final DateTime timestamp;
  final double confidence;

  CrisisIndicator({
    required this.type,
    required this.severity,
    required this.description,
    required this.timestamp,
    required this.confidence,
  });

  CrisisAlert toAlert() {
    return CrisisAlert(
      id: timestamp.millisecondsSinceEpoch.toString(),
      patientId: '', // Will be set by caller
      riskLevel: _severityToRiskLevel(severity),
      indicators: [this],
      timestamp: timestamp,
      status: CrisisAlertStatus.active,
    );
  }

  CrisisRiskLevel _severityToRiskLevel(CrisisSeverity severity) {
    switch (severity) {
      case CrisisSeverity.low:
        return CrisisRiskLevel.low;
      case CrisisSeverity.medium:
        return CrisisRiskLevel.medium;
      case CrisisSeverity.high:
        return CrisisRiskLevel.high;
      case CrisisSeverity.critical:
        return CrisisRiskLevel.critical;
    }
  }
}

/// Crisis Alert
class CrisisAlert {
  final String id;
  final String patientId;
  final CrisisRiskLevel riskLevel;
  final List<CrisisIndicator> indicators;
  final DateTime timestamp;
  final CrisisAlertStatus status;

  CrisisAlert({
    required this.id,
    required this.patientId,
    required this.riskLevel,
    required this.indicators,
    required this.timestamp,
    required this.status,
  });
}

/// Crisis Intervention
class CrisisIntervention {
  final String id;
  final String patientId;
  final CrisisRiskLevel riskLevel;
  final List<String> recommendations;
  final List<String> immediateActions;
  final List<String> followUpActions;
  final DateTime timestamp;

  CrisisIntervention({
    required this.id,
    required this.patientId,
    required this.riskLevel,
    required this.recommendations,
    required this.immediateActions,
    required this.followUpActions,
    required this.timestamp,
  });
}

/// Enums
enum CrisisIndicatorType { voice, facial, text, behavioral, physiological }
enum CrisisSeverity { low, medium, high, critical }
enum CrisisAlertStatus { active, resolved, escalated }
enum CrisisRiskLevel { low, medium, high, critical }
