import 'package:json_annotation/json_annotation.dart';

part 'facial_analysis_models.g.dart';

@JsonSerializable()
class FacialAnalysis {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final List<FacialExpression> expressions;
  final List<MicroExpression> microExpressions;
  final FacialStress stressIndicators;
  final List<FacialMovement> movements;
  final List<GazePattern> gazePatterns;
  final List<FacialTension> tensionAreas;
  final Map<String, dynamic> metadata;

  const FacialAnalysis({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.expressions,
    required this.microExpressions,
    required this.stressIndicators,
    required this.movements,
    required this.gazePatterns,
    required this.tensionAreas,
    required this.metadata,
  });

  factory FacialAnalysis.fromJson(Map<String, dynamic> json) =>
      _$FacialAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$FacialAnalysisToJson(this);

  bool get hasHighStress => stressIndicators.overallStress > 0.7;
  bool get hasEmotionalConflict => _detectEmotionalConflict();
  bool get hasAvoidanceBehavior => _detectAvoidanceBehavior();
}

@JsonSerializable()
class FacialExpression {
  final String id;
  final ExpressionType type;
  final double intensity;
  final double confidence;
  final DateTime detectedAt;
  final Duration duration;
  final List<FacialMuscle> involvedMuscles;
  final List<String> emotionalCorrelates;
  final bool isGenuine;
  final double authenticityScore;

  const FacialExpression({
    required this.id,
    required this.type,
    required this.intensity,
    required this.confidence,
    required this.detectedAt,
    required this.duration,
    required this.involvedMuscles,
    required this.emotionalCorrelates,
    required this.isGenuine,
    required this.authenticityScore,
  });

  factory FacialExpression.fromJson(Map<String, dynamic> json) =>
      _$FacialExpressionFromJson(json);

  Map<String, dynamic> toJson() => _$FacialExpressionToJson(this);
}

@JsonSerializable()
class MicroExpression {
  final String id;
  final ExpressionType type;
  final double intensity;
  final Duration duration;
  final DateTime detectedAt;
  final List<String> triggers;
  final bool isSuppressed;
  final double suppressionStrength;
  final String clinicalSignificance;

  const MicroExpression({
    required this.id,
    required this.type,
    required this.intensity,
    required this.duration,
    required this.detectedAt,
    required this.triggers,
    required this.isSuppressed,
    required this.suppressionStrength,
    required this.clinicalSignificance,
  });

  factory MicroExpression.fromJson(Map<String, dynamic> json) =>
      _$MicroExpressionFromJson(json);

  Map<String, dynamic> toJson() => _$MicroExpressionToJson(this);
}

@JsonSerializable()
class FacialStress {
  final String id;
  final double overallStress;
  final List<StressIndicator> indicators;
  final List<String> stressSignals;
  final double tensionLevel;
  final List<String> relaxationSuggestions;
  final DateTime stressOnset;

  const FacialStress({
    required this.id,
    required this.overallStress,
    required this.indicators,
    required this.stressSignals,
    required this.tensionLevel,
    required this.relaxationSuggestions,
    required this.stressOnset,
  });

  factory FacialStress.fromJson(Map<String, dynamic> json) =>
      _$FacialStressFromJson(json);

  Map<String, dynamic> toJson() => _$FacialStressToJson(this);
}

@JsonSerializable()
class FacialMovement {
  final String id;
  final MovementType type;
  final double frequency;
  final Duration averageDuration;
  final List<String> triggers;
  final bool isInvoluntary;
  final String clinicalRelevance;
  final List<String> interventions;

  const FacialMovement({
    required this.id,
    required this.type,
    required this.frequency,
    required this.averageDuration,
    required this.triggers,
    required this.isInvoluntary,
    required this.clinicalRelevance,
    required this.interventions,
  });

  factory FacialMovement.fromJson(Map<String, dynamic> json) =>
      _$FacialMovementFromJson(json);

  Map<String, dynamic> toJson() => _$FacialMovementToJson(this);
}

@JsonSerializable()
class GazePattern {
  final String id;
  final GazeType type;
  final Duration duration;
  final List<String> targetAreas;
  final bool isAvoidant;
  final List<String> avoidanceTargets;
  final double discomfortLevel;
  final List<String> therapeuticImplications;

  const GazePattern({
    required this.id,
    required this.type,
    required this.duration,
    required this.targetAreas,
    required this.isAvoidant,
    required this.avoidanceTargets,
    required this.discomfortLevel,
    required this.therapeuticImplications,
  });

  factory GazePattern.fromJson(Map<String, dynamic> json) =>
      _$GazePatternFromJson(json);

  Map<String, dynamic> toJson() => _$GazePatternToJson(this);
}

@JsonSerializable()
class FacialTension {
  final String id;
  final String area;
  final double tensionLevel;
  final List<String> associatedEmotions;
  final List<String> physicalSymptoms;
  final List<String> relaxationTechniques;
  final bool isChronic;

  const FacialTension({
    required this.id,
    required this.area,
    required this.tensionLevel,
    required this.associatedEmotions,
    required this.physicalSymptoms,
    required this.relaxationTechniques,
    required this.isChronic,
  });

  factory FacialTension.fromJson(Map<String, dynamic> json) =>
      _$FacialTensionFromJson(json);

  Map<String, dynamic> toJson() => _$FacialTensionToJson(this);
}

@JsonSerializable()
class StressIndicator {
  final String id;
  final String type;
  final double severity;
  final String location;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> interventions;

  const StressIndicator({
    required this.id,
    required this.type,
    required this.severity,
    required this.location,
    required this.symptoms,
    required this.causes,
    required this.interventions,
  });

  factory StressIndicator.fromJson(Map<String, dynamic> json) =>
      _$StressIndicatorFromJson(json);

  Map<String, dynamic> toJson() => _$StressIndicatorToJson(this);
}

@JsonSerializable()
class FacialMuscle {
  final String id;
  final String name;
  final double activationLevel;
  final String function;
  final List<String> relatedExpressions;

  const FacialMuscle({
    required this.id,
    required this.name,
    required this.activationLevel,
    required this.function,
    required this.relatedExpressions,
  });

  factory FacialMuscle.fromJson(Map<String, dynamic> json) =>
      _$FacialMuscleFromJson(json);

  Map<String, dynamic> toJson() => _$FacialMuscleToJson(this);
}

// Enums
enum ExpressionType {
  happiness,
  sadness,
  anger,
  fear,
  surprise,
  disgust,
  contempt,
  confusion,
  anxiety,
  depression,
  excitement,
  calm,
  frustration,
  hope,
  despair,
  love,
  hate,
  guilt,
  shame,
  pride,
  envy,
  amusement,
  relief,
  satisfaction,
  disappointment,
  embarrassment,
  nervousness,
  confidence,
  uncertainty,
  concentration,
  boredom,
}

enum MovementType {
  eyebrowRaise,
  eyebrowFrown,
  eyeWidening,
  eyeNarrowing,
  noseWrinkle,
  lipPursing,
  lipBiting,
  jawClenching,
  cheekTension,
  foreheadWrinkles,
  mouthTwitching,
  eyeBlinking,
  headTilting,
  headNodding,
  headShaking,
  chinTrembling,
  nostrilFlaring,
  tongueMovement,
  swallowing,
  yawning,
}

enum GazeType {
  direct,
  averted,
  wandering,
  focused,
  avoidant,
  defensive,
  aggressive,
  submissive,
  curious,
  disinterested,
  anxious,
  confident,
  uncertain,
  suspicious,
  trusting,
}

// Helper methods
extension FacialAnalysisExtension on FacialAnalysis {
  bool _detectEmotionalConflict() {
    // Detect conflicting emotions (e.g., smile with sad eyes)
    final positiveExpressions = expressions.where((e) => 
      e.type == ExpressionType.happiness || 
      e.type == ExpressionType.excitement ||
      e.type == ExpressionType.satisfaction
    );
    
    final negativeExpressions = expressions.where((e) =>
      e.type == ExpressionType.sadness ||
      e.type == ExpressionType.anxiety ||
      e.type == ExpressionType.fear
    );
    
    return positiveExpressions.isNotEmpty && negativeExpressions.isNotEmpty;
  }

  bool _detectAvoidanceBehavior() {
    // Detect avoidance through gaze patterns and micro-expressions
    final avoidantGaze = gazePatterns.where((g) => g.isAvoidant);
    final suppressedExpressions = microExpressions.where((e) => e.isSuppressed);
    
    return avoidantGaze.isNotEmpty || suppressedExpressions.isNotEmpty;
  }
}
