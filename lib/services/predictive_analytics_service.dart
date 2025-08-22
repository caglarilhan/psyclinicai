import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/predictive_analytics_models.dart';

class PredictiveAnalyticsService {
  static const String _predictionsKey = 'predictions';
  static const String _modelsKey = 'models';
  
  // Singleton pattern
  static final PredictiveAnalyticsService _instance = PredictiveAnalyticsService._internal();
  factory PredictiveAnalyticsService() => _instance;
  PredictiveAnalyticsService._internal();

  // Mock models for development
  final List<PredictiveModel> _mockModels = [
    PredictiveModel(
      id: 'model_001',
      name: 'Treatment Outcome Predictor',
      description: 'Predicts treatment success probability and duration',
      type: ModelType.regression,
      status: ModelStatus.active,
      accuracy: 0.87,
      lastTrained: DateTime.now().subtract(const Duration(days: 7)),
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      parameters: {
        'algorithm': 'Random Forest',
        'features': 45,
        'training_samples': 15000,
      },
    ),
    PredictiveModel(
      id: 'model_002',
      name: 'Relapse Risk Analyzer',
      description: 'Identifies patients at risk of relapse',
      type: ModelType.classification,
      status: ModelStatus.active,
      accuracy: 0.92,
      lastTrained: DateTime.now().subtract(const Duration(days: 14)),
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      parameters: {
        'algorithm': 'XGBoost',
        'features': 38,
        'training_samples': 12000,
      },
    ),
    PredictiveModel(
      id: 'model_003',
      name: 'Crisis Prediction Engine',
      description: 'Predicts potential crisis situations',
      type: ModelType.anomalyDetection,
      status: ModelStatus.active,
      accuracy: 0.89,
      lastTrained: DateTime.now().subtract(const Duration(days: 21)),
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      parameters: {
        'algorithm': 'Isolation Forest',
        'features': 52,
        'training_samples': 8000,
      },
    ),
  ];

  // Get all available models
  List<PredictiveModel> getAvailableModels() {
    return _mockModels;
  }

  // Get model by ID
  PredictiveModel? getModelById(String modelId) {
    try {
      return _mockModels.firstWhere((model) => model.id == modelId);
    } catch (e) {
      return null;
    }
  }

  // Predict treatment outcome
  Future<TreatmentOutcomePrediction> predictTreatmentOutcome({
    required String patientId,
    required String treatmentId,
    required Map<String, dynamic> patientData,
    required Map<String, dynamic> treatmentData,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock prediction logic
    final random = Random();
    final baseSuccessRate = 0.75;
    final patientFactors = _calculatePatientFactors(patientData);
    final treatmentFactors = _calculateTreatmentFactors(treatmentData);
    
    final successProbability = (baseSuccessRate * patientFactors * treatmentFactors)
        .clamp(0.1, 0.95);
    
    final estimatedDuration = _estimateTreatmentDuration(patientData, treatmentData);
    final riskFactors = _identifyRiskFactors(patientData);
    final adjustments = _recommendAdjustments(patientData, treatmentData);
    
    return TreatmentOutcomePrediction(
      id: 'pred_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      treatmentId: treatmentId,
      successProbability: successProbability,
      estimatedDurationWeeks: estimatedDuration,
      riskFactors: riskFactors,
      recommendedAdjustments: adjustments,
      confidenceIntervals: {
        'success_probability': [successProbability - 0.1, successProbability + 0.1],
        'duration_weeks': [estimatedDuration - 2, estimatedDuration + 2],
      },
    );
  }

  // Predict relapse risk
  Future<RelapseRiskPrediction> predictRelapseRisk({
    required String patientId,
    required Map<String, dynamic> patientData,
    required Map<String, dynamic> clinicalHistory,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final random = Random();
    final baseRisk = 0.3;
    final historyFactors = _calculateHistoryFactors(clinicalHistory);
    final currentFactors = _calculateCurrentFactors(patientData);
    
    final relapseRisk = (baseRisk * historyFactors * currentFactors)
        .clamp(0.05, 0.85);
    
    final riskLevel = _determineRiskLevel(relapseRisk);
    final riskFactors = _identifyRelapseRiskFactors(patientData, clinicalHistory);
    final protectiveFactors = _identifyProtectiveFactors(patientData, clinicalHistory);
    final preventionStrategies = _generatePreventionStrategies(riskFactors);
    
    return RelapseRiskPrediction(
      id: 'relapse_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      relapseRisk: relapseRisk,
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      protectiveFactors: protectiveFactors,
      predictedRiskPeriod: DateTime.now().add(Duration(days: 30 + random.nextInt(60))),
      preventionStrategies: preventionStrategies,
    );
  }

  // Predict patient progress
  Future<PatientProgressPrediction> predictPatientProgress({
    required String patientId,
    required Map<String, dynamic> patientData,
    required Map<String, dynamic> treatmentHistory,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    final random = Random();
    final baseImprovement = 0.6;
    final patientFactors = _calculateProgressFactors(patientData);
    final treatmentFactors = _calculateTreatmentProgressFactors(treatmentHistory);
    
    final improvementScore = (baseImprovement * patientFactors * treatmentFactors)
        .clamp(0.2, 0.9);
    
    final recoveryWeeks = _estimateRecoveryTime(patientData, treatmentHistory);
    final milestones = _generateMilestones(improvementScore, recoveryWeeks);
    final challenges = _identifyChallenges(patientData, treatmentHistory);
    
    return PatientProgressPrediction(
      id: 'progress_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      predictionDate: DateTime.now(),
      improvementScore: improvementScore,
      estimatedRecoveryWeeks: recoveryWeeks,
      milestones: milestones,
      challenges: challenges,
      confidenceMetrics: {
        'improvement_score': 0.85,
        'recovery_time': 0.78,
        'milestone_accuracy': 0.82,
      },
    );
  }

  // Predict crisis situations
  Future<CrisisPrediction> predictCrisis({
    required String patientId,
    required Map<String, dynamic> patientData,
    required Map<String, dynamic> recentBehavior,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final random = Random();
    final baseCrisisRisk = 0.15;
    final behaviorFactors = _calculateBehaviorFactors(recentBehavior);
    final patientFactors = _calculateCrisisFactors(patientData);
    
    final crisisProbability = (baseCrisisRisk * behaviorFactors * patientFactors)
        .clamp(0.01, 0.7);
    
    final crisisType = _determineCrisisType(patientData, recentBehavior);
    final urgency = _determineUrgency(crisisProbability, crisisType);
    final warningSigns = _identifyWarningSigns(patientData, recentBehavior);
    final interventions = _generateInterventionStrategies(crisisType, urgency);
    
    return CrisisPrediction(
      id: 'crisis_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      crisisType: crisisType,
      crisisProbability: crisisProbability,
      predictedTimeframe: DateTime.now().add(Duration(days: 1 + random.nextInt(14))),
      warningSigns: warningSigns,
      interventionStrategies: interventions,
      urgency: urgency,
    );
  }

  // Get model performance metrics
  Future<ModelPerformanceMetrics> getModelPerformance(String modelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final model = getModelById(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    final random = Random();
    final baseAccuracy = model.accuracy;
    final variation = 0.05;
    
    return ModelPerformanceMetrics(
      id: 'metrics_${DateTime.now().millisecondsSinceEpoch}',
      modelId: modelId,
      evaluationDate: DateTime.now(),
      accuracy: (baseAccuracy + (random.nextDouble() - 0.5) * variation).clamp(0.0, 1.0),
      precision: (baseAccuracy + (random.nextDouble() - 0.5) * variation).clamp(0.0, 1.0),
      recall: (baseAccuracy + (random.nextDouble() - 0.5) * variation).clamp(0.0, 1.0),
      f1Score: (baseAccuracy + (random.nextDouble() - 0.5) * variation).clamp(0.0, 1.0),
      auc: (baseAccuracy + (random.nextDouble() - 0.5) * variation).clamp(0.0, 1.0),
      classMetrics: {
        'class_0': random.nextDouble(),
        'class_1': random.nextDouble(),
      },
      confusionMatrix: {
        'true_positive': random.nextInt(100),
        'false_positive': random.nextInt(20),
        'true_negative': random.nextInt(80),
        'false_negative': random.nextInt(15),
      },
    );
  }

  // Get feature importance for a model
  Future<List<FeatureImportance>> getFeatureImportance(String modelId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final features = [
      'age', 'gender', 'diagnosis', 'symptom_severity', 'treatment_history',
      'medication_compliance', 'social_support', 'stress_level', 'sleep_quality',
      'exercise_frequency', 'substance_use', 'family_history', 'trauma_history'
    ];
    
    final random = Random();
    final importanceList = <FeatureImportance>[];
    
    for (final feature in features) {
      final importance = random.nextDouble();
      final stdDev = random.nextDouble() * 0.1;
      final history = List.generate(10, (index) => 
          importance + (random.nextDouble() - 0.5) * 0.2);
      
      importanceList.add(FeatureImportance(
        featureName: feature,
        importance: importance,
        standardDeviation: stdDev,
        importanceHistory: history,
      ));
    }
    
    // Sort by importance
    importanceList.sort((a, b) => b.importance.compareTo(a.importance));
    
    return importanceList;
  }

  // Start model training
  Future<ModelTrainingJob> startModelTraining({
    required String modelId,
    required Map<String, dynamic> hyperparameters,
    required Map<String, dynamic> trainingData,
  }) async {
    final job = ModelTrainingJob(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      modelId: modelId,
      status: TrainingStatus.pending,
      startTime: DateTime.now(),
      progress: 0.0,
      hyperparameters: hyperparameters,
      trainingMetrics: {},
    );
    
    // Simulate training process
    _simulateTraining(job);
    
    return job;
  }

  // Helper methods for mock predictions
  double _calculatePatientFactors(Map<String, dynamic> patientData) {
    final random = Random();
    double factor = 1.0;
    
    if (patientData['age'] != null) {
      final age = patientData['age'] as int;
      if (age < 25) factor *= 0.9;
      else if (age > 65) factor *= 0.85;
    }
    
    if (patientData['compliance'] != null) {
      factor *= (patientData['compliance'] as double);
    }
    
    return factor + (random.nextDouble() - 0.5) * 0.2;
  }

  double _calculateTreatmentFactors(Map<String, dynamic> treatmentData) {
    final random = Random();
    double factor = 1.0;
    
    if (treatmentData['evidence_level'] != null) {
      factor *= (treatmentData['evidence_level'] as double);
    }
    
    if (treatmentData['duration'] != null) {
      final duration = treatmentData['duration'] as int;
      if (duration > 12) factor *= 1.1;
    }
    
    return factor + (random.nextDouble() - 0.5) * 0.15;
  }

  int _estimateTreatmentDuration(Map<String, dynamic> patientData, Map<String, dynamic> treatmentData) {
    final random = Random();
    int baseDuration = 8;
    
    if (patientData['severity'] != null) {
      final severity = patientData['severity'] as double;
      baseDuration += (severity * 4).round();
    }
    
    return (baseDuration + random.nextInt(6)).clamp(4, 24);
  }

  List<String> _identifyRiskFactors(Map<String, dynamic> patientData) {
    final factors = <String>[];
    
    if (patientData['substance_use'] == true) factors.add('Substance use');
    if (patientData['social_isolation'] == true) factors.add('Social isolation');
    if (patientData['financial_stress'] == true) factors.add('Financial stress');
    if (patientData['family_conflict'] == true) factors.add('Family conflict');
    if (patientData['work_stress'] == true) factors.add('Work stress');
    
    if (factors.isEmpty) factors.add('Low risk profile');
    
    return factors;
  }

  List<String> _recommendAdjustments(Map<String, dynamic> patientData, Map<String, dynamic> treatmentData) {
    final adjustments = <String>[];
    
    if (patientData['sleep_issues'] == true) {
      adjustments.add('Implement sleep hygiene protocols');
    }
    
    if (patientData['medication_side_effects'] == true) {
      adjustments.add('Review medication dosage and timing');
    }
    
    if (patientData['therapy_resistance'] == true) {
      adjustments.add('Consider alternative therapeutic approaches');
    }
    
    if (adjustments.isEmpty) {
      adjustments.add('Continue current treatment plan');
    }
    
    return adjustments;
  }

  double _calculateHistoryFactors(Map<String, dynamic> clinicalHistory) {
    double factor = 1.0;
    
    if (clinicalHistory['previous_relapses'] != null) {
      final relapses = clinicalHistory['previous_relapses'] as int;
      factor *= (1.0 + relapses * 0.2);
    }
    
    if (clinicalHistory['treatment_compliance'] != null) {
      factor *= (2.0 - clinicalHistory['treatment_compliance'] as double);
    }
    
    return factor.clamp(0.5, 2.0);
  }

  double _calculateCurrentFactors(Map<String, dynamic> patientData) {
    double factor = 1.0;
    
    if (patientData['stress_level'] != null) {
      factor *= (1.0 + (patientData['stress_level'] as double) * 0.3);
    }
    
    if (patientData['social_support'] != null) {
      factor *= (1.5 - (patientData['social_support'] as double) * 0.5);
    }
    
    return factor.clamp(0.5, 2.0);
  }

  RiskLevel _determineRiskLevel(double risk) {
    if (risk < 0.25) return RiskLevel.low;
    if (risk < 0.5) return RiskLevel.moderate;
    if (risk < 0.75) return RiskLevel.high;
    return RiskLevel.critical;
  }

  List<String> _identifyRelapseRiskFactors(Map<String, dynamic> patientData, Map<String, dynamic> clinicalHistory) {
    final factors = <String>[];
    
    if (patientData['recent_stress'] == true) factors.add('Recent stress events');
    if (patientData['medication_skipped'] == true) factors.add('Medication non-compliance');
    if (patientData['therapy_missed'] == true) factors.add('Missed therapy sessions');
    if (clinicalHistory['previous_relapses'] != null) factors.add('History of relapses');
    
    return factors;
  }

  List<String> _identifyProtectiveFactors(Map<String, dynamic> patientData, Map<String, dynamic> clinicalHistory) {
    final factors = <String>[];
    
    if (patientData['strong_support'] == true) factors.add('Strong social support');
    if (patientData['coping_skills'] == true) factors.add('Good coping skills');
    if (patientData['stable_environment'] == true) factors.add('Stable environment');
    if (patientData['motivation'] == true) factors.add('High motivation');
    
    return factors;
  }

  List<String> _generatePreventionStrategies(List<String> riskFactors) {
    final strategies = <String>[];
    
    if (riskFactors.contains('Recent stress events')) {
      strategies.add('Implement stress management techniques');
    }
    
    if (riskFactors.contains('Medication non-compliance')) {
      strategies.add('Set up medication reminders and monitoring');
    }
    
    if (riskFactors.contains('Missed therapy sessions')) {
      strategies.add('Schedule regular check-ins and follow-ups');
    }
    
    strategies.add('Increase monitoring frequency');
    strategies.add('Provide crisis intervention resources');
    
    return strategies;
  }

  double _calculateProgressFactors(Map<String, dynamic> patientData) {
    double factor = 1.0;
    
    if (patientData['motivation'] != null) {
      factor *= (1.0 + (patientData['motivation'] as double) * 0.3);
    }
    
    if (patientData['support_system'] != null) {
      factor *= (1.0 + (patientData['support_system'] as double) * 0.2);
    }
    
    return factor.clamp(0.7, 1.5);
  }

  double _calculateTreatmentProgressFactors(Map<String, dynamic> treatmentHistory) {
    double factor = 1.0;
    
    if (treatmentHistory['consistency'] != null) {
      factor *= (treatmentHistory['consistency'] as double);
    }
    
    if (treatmentHistory['response'] != null) {
      factor *= (1.0 + (treatmentHistory['response'] as double) * 0.4);
    }
    
    return factor.clamp(0.6, 1.4);
  }

  int _estimateRecoveryTime(Map<String, dynamic> patientData, Map<String, dynamic> treatmentHistory) {
    final random = Random();
    int baseTime = 12;
    
    if (patientData['severity'] != null) {
      final severity = patientData['severity'] as double;
      baseTime += (severity * 6).round();
    }
    
    if (treatmentHistory['previous_treatments'] != null) {
      final previous = treatmentHistory['previous_treatments'] as int;
      if (previous > 2) baseTime += 4;
    }
    
    return (baseTime + random.nextInt(8)).clamp(8, 36);
  }

  List<String> _generateMilestones(double improvementScore, int recoveryWeeks) {
    final milestones = <String>[];
    final weeks = recoveryWeeks ~/ 4;
    
    if (weeks >= 1) milestones.add('Week 4: Initial symptom reduction');
    if (weeks >= 2) milestones.add('Week 8: Improved daily functioning');
    if (weeks >= 3) milestones.add('Week 12: Significant mood improvement');
    if (weeks >= 4) milestones.add('Week 16: Stable recovery state');
    
    return milestones;
  }

  List<String> _identifyChallenges(Map<String, dynamic> patientData, Map<String, dynamic> treatmentHistory) {
    final challenges = <String>[];
    
    if (patientData['complex_diagnosis'] == true) {
      challenges.add('Complex diagnosis requiring multiple approaches');
    }
    
    if (patientData['co_morbidity'] == true) {
      challenges.add('Co-morbid conditions');
    }
    
    if (treatmentHistory['resistance'] == true) {
      challenges.add('Treatment resistance');
    }
    
    if (challenges.isEmpty) {
      challenges.add('Standard treatment progression');
    }
    
    return challenges;
  }

  double _calculateBehaviorFactors(Map<String, dynamic> recentBehavior) {
    double factor = 1.0;
    
    if (recentBehavior['agitation'] == true) factor *= 1.5;
    if (recentBehavior['isolation'] == true) factor *= 1.3;
    if (recentBehavior['risk_behavior'] == true) factor *= 2.0;
    if (recentBehavior['verbal_threats'] == true) factor *= 1.8;
    
    return factor.clamp(0.5, 3.0);
  }

  double _calculateCrisisFactors(Map<String, dynamic> patientData) {
    double factor = 1.0;
    
    if (patientData['suicide_history'] == true) factor *= 2.5;
    if (patientData['violence_history'] == true) factor *= 2.0;
    if (patientData['psychosis'] == true) factor *= 1.8;
    if (patientData['substance_abuse'] == true) factor *= 1.6;
    
    return factor.clamp(0.5, 4.0);
  }

  CrisisType _determineCrisisType(Map<String, dynamic> patientData, Map<String, dynamic> recentBehavior) {
    if (recentBehavior['suicidal_thoughts'] == true || patientData['suicide_history'] == true) {
      return CrisisType.suicidal;
    }
    
    if (recentBehavior['violent_behavior'] == true || patientData['violence_history'] == true) {
      return CrisisType.violent;
    }
    
    if (recentBehavior['psychotic_symptoms'] == true || patientData['psychosis'] == true) {
      return CrisisType.psychotic;
    }
    
    if (recentBehavior['substance_use'] == true || patientData['substance_abuse'] == true) {
      return CrisisType.substanceAbuse;
    }
    
    if (recentBehavior['self_harm'] == true) {
      return CrisisType.selfHarm;
    }
    
    return CrisisType.other;
  }

  UrgencyLevel _determineUrgency(double crisisProbability, CrisisType crisisType) {
    if (crisisProbability > 0.6 || crisisType == CrisisType.suicidal) {
      return UrgencyLevel.immediate;
    }
    
    if (crisisProbability > 0.4 || crisisType == CrisisType.violent) {
      return UrgencyLevel.high;
    }
    
    if (crisisProbability > 0.2) {
      return UrgencyLevel.medium;
    }
    
    return UrgencyLevel.low;
  }

  List<String> _identifyWarningSigns(Map<String, dynamic> patientData, Map<String, dynamic> recentBehavior) {
    final signs = <String>[];
    
    if (recentBehavior['mood_changes'] == true) signs.add('Significant mood changes');
    if (recentBehavior['sleep_disturbance'] == true) signs.add('Sleep disturbance');
    if (recentBehavior['appetite_changes'] == true) signs.add('Appetite changes');
    if (recentBehavior['social_withdrawal'] == true) signs.add('Social withdrawal');
    if (recentBehavior['increased_anxiety'] == true) signs.add('Increased anxiety');
    
    return signs;
  }

  List<String> _generateInterventionStrategies(CrisisType crisisType, UrgencyLevel urgency) {
    final strategies = <String>[];
    
    if (urgency == UrgencyLevel.immediate) {
      strategies.add('Immediate crisis intervention');
      strategies.add('Contact emergency services if needed');
      strategies.add('24/7 monitoring');
    }
    
    if (crisisType == CrisisType.suicidal) {
      strategies.add('Suicide risk assessment');
      strategies.add('Safety planning');
      strategies.add('Remove access to means');
    }
    
    if (crisisType == CrisisType.violent) {
      strategies.add('Violence risk assessment');
      strategies.add('Environmental safety measures');
      strategies.add('Behavioral intervention');
    }
    
    strategies.add('Increase therapy frequency');
    strategies.add('Medication review');
    strategies.add('Family involvement');
    
    return strategies;
  }

  void _simulateTraining(ModelTrainingJob job) async {
    // Simulate training progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (i == 100) {
        job = ModelTrainingJob(
          id: job.id,
          modelId: job.modelId,
          status: TrainingStatus.completed,
          startTime: job.startTime,
          endTime: DateTime.now(),
          progress: 1.0,
          hyperparameters: job.hyperparameters,
          trainingMetrics: {
            'final_accuracy': 0.89,
            'training_time': '2h 15m',
            'epochs': 150,
          },
        );
      } else {
        job = ModelTrainingJob(
          id: job.id,
          modelId: job.modelId,
          status: TrainingStatus.running,
          startTime: job.startTime,
          progress: i / 100,
          hyperparameters: job.hyperparameters,
          trainingMetrics: {
            'current_accuracy': 0.75 + (i / 100) * 0.14,
            'epoch': i * 1.5,
          },
        );
      }
    }
  }
}
