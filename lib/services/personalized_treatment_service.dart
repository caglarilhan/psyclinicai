import 'dart:async';
import 'package:psyclinicai/models/predictive_analytics_models.dart';
import 'package:psyclinicai/services/openai_gpt4_service.dart';
import 'package:psyclinicai/services/claude_integration_service.dart';

/// Personalized Treatment Service for PsyClinicAI
/// Provides AI-driven personalized treatment recommendations
class PersonalizedTreatmentService {
  static final PersonalizedTreatmentService _instance = PersonalizedTreatmentService._internal();
  factory PersonalizedTreatmentService() => _instance;
  PersonalizedTreatmentService._internal();

  final OpenAIGPT4Service _gpt4Service = OpenAIGPT4Service();
  final ClaudeIntegrationService _claudeService = ClaudeIntegrationService();
  
  final Map<String, PatientTreatmentProfile> _patientProfiles = {};
  final StreamController<TreatmentPlan> _planUpdateController = StreamController<TreatmentPlan>.broadcast();
  final StreamController<TreatmentProgress> _progressController = StreamController<TreatmentProgress>.broadcast();

  Stream<TreatmentPlan> get planUpdateStream => _planUpdateController.stream;
  Stream<TreatmentProgress> get progressStream => _progressController.stream;

  /// Initialize patient treatment profile
  Future<void> initializePatient(String patientId, Map<String, dynamic> patientData) async {
    _patientProfiles[patientId] = PatientTreatmentProfile(
      patientId: patientId,
      patientData: patientData,
      treatmentPlans: [],
      progressHistory: [],
      lastAssessment: DateTime.now(),
      currentPlan: null,
    );
  }

  /// Generate personalized treatment plan
  Future<TreatmentPlan> generateTreatmentPlan(String patientId, {
    required String diagnosis,
    required List<String> symptoms,
    required Map<String, dynamic> patientHistory,
    required List<String> preferences,
  }) async {
    final profile = _patientProfiles[patientId];
    if (profile == null) {
      throw Exception('Patient profile not found: $patientId');
    }

    try {
      // Get recommendations from both AI models
      final gpt4Response = await _gpt4Service.generateTreatmentRecommendations(
        diagnosis: diagnosis,
        symptoms: symptoms,
        patientHistory: patientHistory,
        preferences: preferences,
      );

      final claudeResponse = await _claudeService.generateTreatmentRecommendations(
        diagnosis: diagnosis,
        symptoms: symptoms,
        patientHistory: patientHistory,
        preferences: preferences,
      );

      // Combine and prioritize recommendations
      final combinedRecommendations = _combineRecommendations(
        gpt4Response.recommendations,
        claudeResponse.recommendations,
      );

      // Create treatment plan
      final plan = TreatmentPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        diagnosis: diagnosis,
        symptoms: symptoms,
        recommendations: combinedRecommendations,
        medications: _extractMedications(combinedRecommendations),
        therapies: _extractTherapies(combinedRecommendations),
        lifestyleModifications: _extractLifestyleModifications(combinedRecommendations),
        timeline: _generateTimeline(combinedRecommendations),
        createdAt: DateTime.now(),
        status: TreatmentPlanStatus.active,
      );

      // Update profile
      profile.treatmentPlans.add(plan);
      profile.currentPlan = plan;
      profile.lastAssessment = DateTime.now();

      // Notify listeners
      _planUpdateController.add(plan);

      return plan;
    } catch (e) {
      print('❌ Treatment plan generation failed: $e');
      
      // Fallback plan
      return TreatmentPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        diagnosis: diagnosis,
        symptoms: symptoms,
        recommendations: [
          'Schedule follow-up appointment',
          'Monitor symptoms daily',
          'Contact clinician if symptoms worsen',
        ],
        medications: [],
        therapies: ['Standard therapy sessions'],
        lifestyleModifications: ['Regular sleep schedule', 'Exercise routine'],
        timeline: TreatmentTimeline(
          duration: const Duration(days: 30),
          milestones: ['Week 1: Initial assessment', 'Week 2: Progress review'],
        ),
        createdAt: DateTime.now(),
        status: TreatmentPlanStatus.active,
      );
    }
  }

  /// Track treatment progress
  Future<void> trackProgress(String patientId, Map<String, dynamic> progressData) async {
    final profile = _patientProfiles[patientId];
    if (profile == null) return;

    final progress = TreatmentProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      planId: profile.currentPlan?.id ?? '',
      metrics: progressData,
      timestamp: DateTime.now(),
      notes: progressData['notes'] ?? '',
    );

    profile.progressHistory.add(progress);
    _progressController.add(progress);
  }

  /// Check if treatment adjustment is needed
  Future<bool> needsAdjustment(String patientId) async {
    final profile = _patientProfiles[patientId];
    if (profile == null || profile.currentPlan == null) return false;

    // Analyze recent progress
    final recentProgress = profile.progressHistory
        .where((p) => p.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    if (recentProgress.isEmpty) return false;

    // Check for concerning trends
    for (final progress in recentProgress) {
      if (progress.metrics['symptomSeverity'] != null) {
        final severity = progress.metrics['symptomSeverity'] as double;
        if (severity > 7.0) return true; // High symptom severity
      }

      if (progress.metrics['adherence'] != null) {
        final adherence = progress.metrics['adherence'] as double;
        if (adherence < 0.6) return true; // Low adherence
      }
    }

    return false;
  }

  /// Get treatment recommendations
  Future<List<String>> getRecommendations(String patientId) async {
    final profile = _patientProfiles[patientId];
    if (profile?.currentPlan == null) return [];

    return profile!.currentPlan!.recommendations;
  }

  /// Get patient profile
  PatientTreatmentProfile? getPatientProfile(String patientId) {
    return _patientProfiles[patientId];
  }

  /// Get all active treatment plans
  List<TreatmentPlan> getActivePlans() {
    return _patientProfiles.values
        .where((profile) => profile.currentPlan != null)
        .map((profile) => profile.currentPlan!)
        .where((plan) => plan.status == TreatmentPlanStatus.active)
        .toList();
  }

  /// Combine recommendations from multiple AI models
  List<String> _combineRecommendations(List<String> gpt4Recs, List<String> claudeRecs) {
    final combined = <String>[];
    final allRecs = [...gpt4Recs, ...claudeRecs];
    
    // Remove duplicates and prioritize
    for (final rec in allRecs) {
      if (!combined.any((existing) => existing.toLowerCase().contains(rec.toLowerCase()))) {
        combined.add(rec);
      }
    }

    // Limit to top recommendations
    return combined.take(10).toList();
  }

  /// Extract medication recommendations
  List<String> _extractMedications(List<String> recommendations) {
    return recommendations
        .where((rec) => rec.toLowerCase().contains('medication') || 
                        rec.toLowerCase().contains('drug') ||
                        rec.toLowerCase().contains('prescription'))
        .toList();
  }

  /// Extract therapy recommendations
  List<String> _extractTherapies(List<String> recommendations) {
    return recommendations
        .where((rec) => rec.toLowerCase().contains('therapy') || 
                        rec.toLowerCase().contains('counseling') ||
                        rec.toLowerCase().contains('session'))
        .toList();
  }

  /// Extract lifestyle modification recommendations
  List<String> _extractLifestyleModifications(List<String> recommendations) {
    return recommendations
        .where((rec) => rec.toLowerCase().contains('exercise') || 
                        rec.toLowerCase().contains('diet') ||
                        rec.toLowerCase().contains('sleep') ||
                        rec.toLowerCase().contains('stress') ||
                        rec.toLowerCase().contains('routine'))
        .toList();
  }

  /// Generate treatment timeline
  TreatmentTimeline _generateTimeline(List<String> recommendations) {
    final duration = Duration(days: recommendations.length * 3); // 3 days per recommendation
    final milestones = <String>[];
    
    for (int i = 0; i < recommendations.length && i < 5; i++) {
      final week = (i + 1) * 7;
      milestones.add('Week ${i + 1}: ${recommendations[i].substring(0, recommendations[i].length > 50 ? 50 : recommendations[i].length)}...');
    }

    return TreatmentTimeline(
      duration: duration,
      milestones: milestones,
    );
  }

  /// Dispose resources
  void dispose() {
    _planUpdateController.close();
    _progressController.close();
  }
}

/// Patient Treatment Profile
class PatientTreatmentProfile {
  final String patientId;
  final Map<String, dynamic> patientData;
  final List<TreatmentPlan> treatmentPlans;
  final List<TreatmentProgress> progressHistory;
  DateTime lastAssessment;
  TreatmentPlan? currentPlan;

  PatientTreatmentProfile({
    required this.patientId,
    required this.patientData,
    required this.treatmentPlans,
    required this.progressHistory,
    required this.lastAssessment,
    this.currentPlan,
  });
}

/// Treatment Plan
class TreatmentPlan {
  final String id;
  final String patientId;
  final String diagnosis;
  final List<String> symptoms;
  final List<String> recommendations;
  final List<String> medications;
  final List<String> therapies;
  final List<String> lifestyleModifications;
  final TreatmentTimeline timeline;
  final DateTime createdAt;
  final TreatmentPlanStatus status;

  TreatmentPlan({
    required this.id,
    required this.patientId,
    required this.diagnosis,
    required this.symptoms,
    required this.recommendations,
    required this.medications,
    required this.therapies,
    required this.lifestyleModifications,
    required this.timeline,
    required this.createdAt,
    required this.status,
  });
}

/// Treatment Progress
class TreatmentProgress {
  final String id;
  final String patientId;
  final String planId;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;
  final String notes;

  TreatmentProgress({
    required this.id,
    required this.patientId,
    required this.planId,
    required this.metrics,
    required this.timestamp,
    required this.notes,
  });
}

/// Treatment Timeline
class TreatmentTimeline {
  final Duration duration;
  final List<String> milestones;

  TreatmentTimeline({
    required this.duration,
    required this.milestones,
  });
}

/// Enums
enum TreatmentPlanStatus { active, completed, suspended, cancelled }
