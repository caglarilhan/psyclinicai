// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facial_analysis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacialAnalysis _$FacialAnalysisFromJson(Map<String, dynamic> json) =>
    FacialAnalysis(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      expressions: (json['expressions'] as List<dynamic>)
          .map((e) => FacialExpression.fromJson(e as Map<String, dynamic>))
          .toList(),
      microExpressions: (json['microExpressions'] as List<dynamic>)
          .map((e) => MicroExpression.fromJson(e as Map<String, dynamic>))
          .toList(),
      stressIndicators: FacialStress.fromJson(
        json['stressIndicators'] as Map<String, dynamic>,
      ),
      movements: (json['movements'] as List<dynamic>)
          .map((e) => FacialMovement.fromJson(e as Map<String, dynamic>))
          .toList(),
      gazePatterns: (json['gazePatterns'] as List<dynamic>)
          .map((e) => GazePattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      tensionAreas: (json['tensionAreas'] as List<dynamic>)
          .map((e) => FacialTension.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$FacialAnalysisToJson(FacialAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'timestamp': instance.timestamp.toIso8601String(),
      'expressions': instance.expressions,
      'microExpressions': instance.microExpressions,
      'stressIndicators': instance.stressIndicators,
      'movements': instance.movements,
      'gazePatterns': instance.gazePatterns,
      'tensionAreas': instance.tensionAreas,
      'metadata': instance.metadata,
    };

FacialExpression _$FacialExpressionFromJson(Map<String, dynamic> json) =>
    FacialExpression(
      id: json['id'] as String,
      type: $enumDecode(_$ExpressionTypeEnumMap, json['type']),
      intensity: (json['intensity'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      involvedMuscles: (json['involvedMuscles'] as List<dynamic>)
          .map((e) => FacialMuscle.fromJson(e as Map<String, dynamic>))
          .toList(),
      emotionalCorrelates: (json['emotionalCorrelates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isGenuine: json['isGenuine'] as bool,
      authenticityScore: (json['authenticityScore'] as num).toDouble(),
    );

Map<String, dynamic> _$FacialExpressionToJson(FacialExpression instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ExpressionTypeEnumMap[instance.type]!,
      'intensity': instance.intensity,
      'confidence': instance.confidence,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'involvedMuscles': instance.involvedMuscles,
      'emotionalCorrelates': instance.emotionalCorrelates,
      'isGenuine': instance.isGenuine,
      'authenticityScore': instance.authenticityScore,
    };

const _$ExpressionTypeEnumMap = {
  ExpressionType.happiness: 'happiness',
  ExpressionType.sadness: 'sadness',
  ExpressionType.anger: 'anger',
  ExpressionType.fear: 'fear',
  ExpressionType.surprise: 'surprise',
  ExpressionType.disgust: 'disgust',
  ExpressionType.contempt: 'contempt',
  ExpressionType.confusion: 'confusion',
  ExpressionType.anxiety: 'anxiety',
  ExpressionType.depression: 'depression',
  ExpressionType.excitement: 'excitement',
  ExpressionType.calm: 'calm',
  ExpressionType.frustration: 'frustration',
  ExpressionType.hope: 'hope',
  ExpressionType.despair: 'despair',
  ExpressionType.love: 'love',
  ExpressionType.hate: 'hate',
  ExpressionType.guilt: 'guilt',
  ExpressionType.shame: 'shame',
  ExpressionType.pride: 'pride',
  ExpressionType.envy: 'envy',
  ExpressionType.amusement: 'amusement',
  ExpressionType.relief: 'relief',
  ExpressionType.satisfaction: 'satisfaction',
  ExpressionType.disappointment: 'disappointment',
  ExpressionType.embarrassment: 'embarrassment',
  ExpressionType.nervousness: 'nervousness',
  ExpressionType.confidence: 'confidence',
  ExpressionType.uncertainty: 'uncertainty',
  ExpressionType.concentration: 'concentration',
  ExpressionType.boredom: 'boredom',
};

MicroExpression _$MicroExpressionFromJson(Map<String, dynamic> json) =>
    MicroExpression(
      id: json['id'] as String,
      type: $enumDecode(_$ExpressionTypeEnumMap, json['type']),
      intensity: (json['intensity'] as num).toDouble(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isSuppressed: json['isSuppressed'] as bool,
      suppressionStrength: (json['suppressionStrength'] as num).toDouble(),
      clinicalSignificance: json['clinicalSignificance'] as String,
    );

Map<String, dynamic> _$MicroExpressionToJson(MicroExpression instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ExpressionTypeEnumMap[instance.type]!,
      'intensity': instance.intensity,
      'duration': instance.duration.inMicroseconds,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'triggers': instance.triggers,
      'isSuppressed': instance.isSuppressed,
      'suppressionStrength': instance.suppressionStrength,
      'clinicalSignificance': instance.clinicalSignificance,
    };

FacialStress _$FacialStressFromJson(Map<String, dynamic> json) => FacialStress(
  id: json['id'] as String,
  overallStress: (json['overallStress'] as num).toDouble(),
  indicators: (json['indicators'] as List<dynamic>)
      .map((e) => StressIndicator.fromJson(e as Map<String, dynamic>))
      .toList(),
  stressSignals: (json['stressSignals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tensionLevel: (json['tensionLevel'] as num).toDouble(),
  relaxationSuggestions: (json['relaxationSuggestions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  stressOnset: DateTime.parse(json['stressOnset'] as String),
);

Map<String, dynamic> _$FacialStressToJson(FacialStress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'overallStress': instance.overallStress,
      'indicators': instance.indicators,
      'stressSignals': instance.stressSignals,
      'tensionLevel': instance.tensionLevel,
      'relaxationSuggestions': instance.relaxationSuggestions,
      'stressOnset': instance.stressOnset.toIso8601String(),
    };

FacialMovement _$FacialMovementFromJson(Map<String, dynamic> json) =>
    FacialMovement(
      id: json['id'] as String,
      type: $enumDecode(_$MovementTypeEnumMap, json['type']),
      frequency: (json['frequency'] as num).toDouble(),
      averageDuration: Duration(
        microseconds: (json['averageDuration'] as num).toInt(),
      ),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isInvoluntary: json['isInvoluntary'] as bool,
      clinicalRelevance: json['clinicalRelevance'] as String,
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$FacialMovementToJson(FacialMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MovementTypeEnumMap[instance.type]!,
      'frequency': instance.frequency,
      'averageDuration': instance.averageDuration.inMicroseconds,
      'triggers': instance.triggers,
      'isInvoluntary': instance.isInvoluntary,
      'clinicalRelevance': instance.clinicalRelevance,
      'interventions': instance.interventions,
    };

const _$MovementTypeEnumMap = {
  MovementType.eyebrowRaise: 'eyebrowRaise',
  MovementType.eyebrowFrown: 'eyebrowFrown',
  MovementType.eyeWidening: 'eyeWidening',
  MovementType.eyeNarrowing: 'eyeNarrowing',
  MovementType.noseWrinkle: 'noseWrinkle',
  MovementType.lipPursing: 'lipPursing',
  MovementType.lipBiting: 'lipBiting',
  MovementType.jawClenching: 'jawClenching',
  MovementType.cheekTension: 'cheekTension',
  MovementType.foreheadWrinkles: 'foreheadWrinkles',
  MovementType.mouthTwitching: 'mouthTwitching',
  MovementType.eyeBlinking: 'eyeBlinking',
  MovementType.headTilting: 'headTilting',
  MovementType.headNodding: 'headNodding',
  MovementType.headShaking: 'headShaking',
  MovementType.chinTrembling: 'chinTrembling',
  MovementType.nostrilFlaring: 'nostrilFlaring',
  MovementType.tongueMovement: 'tongueMovement',
  MovementType.swallowing: 'swallowing',
  MovementType.yawning: 'yawning',
};

GazePattern _$GazePatternFromJson(Map<String, dynamic> json) => GazePattern(
  id: json['id'] as String,
  type: $enumDecode(_$GazeTypeEnumMap, json['type']),
  duration: Duration(microseconds: (json['duration'] as num).toInt()),
  targetAreas: (json['targetAreas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isAvoidant: json['isAvoidant'] as bool,
  avoidanceTargets: (json['avoidanceTargets'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  discomfortLevel: (json['discomfortLevel'] as num).toDouble(),
  therapeuticImplications: (json['therapeuticImplications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GazePatternToJson(GazePattern instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$GazeTypeEnumMap[instance.type]!,
      'duration': instance.duration.inMicroseconds,
      'targetAreas': instance.targetAreas,
      'isAvoidant': instance.isAvoidant,
      'avoidanceTargets': instance.avoidanceTargets,
      'discomfortLevel': instance.discomfortLevel,
      'therapeuticImplications': instance.therapeuticImplications,
    };

const _$GazeTypeEnumMap = {
  GazeType.direct: 'direct',
  GazeType.averted: 'averted',
  GazeType.wandering: 'wandering',
  GazeType.focused: 'focused',
  GazeType.avoidant: 'avoidant',
  GazeType.defensive: 'defensive',
  GazeType.aggressive: 'aggressive',
  GazeType.submissive: 'submissive',
  GazeType.curious: 'curious',
  GazeType.disinterested: 'disinterested',
  GazeType.anxious: 'anxious',
  GazeType.confident: 'confident',
  GazeType.uncertain: 'uncertain',
  GazeType.suspicious: 'suspicious',
  GazeType.trusting: 'trusting',
};

FacialTension _$FacialTensionFromJson(Map<String, dynamic> json) =>
    FacialTension(
      id: json['id'] as String,
      area: json['area'] as String,
      tensionLevel: (json['tensionLevel'] as num).toDouble(),
      associatedEmotions: (json['associatedEmotions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      physicalSymptoms: (json['physicalSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relaxationTechniques: (json['relaxationTechniques'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isChronic: json['isChronic'] as bool,
    );

Map<String, dynamic> _$FacialTensionToJson(FacialTension instance) =>
    <String, dynamic>{
      'id': instance.id,
      'area': instance.area,
      'tensionLevel': instance.tensionLevel,
      'associatedEmotions': instance.associatedEmotions,
      'physicalSymptoms': instance.physicalSymptoms,
      'relaxationTechniques': instance.relaxationTechniques,
      'isChronic': instance.isChronic,
    };

StressIndicator _$StressIndicatorFromJson(Map<String, dynamic> json) =>
    StressIndicator(
      id: json['id'] as String,
      type: json['type'] as String,
      severity: (json['severity'] as num).toDouble(),
      location: json['location'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      causes: (json['causes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$StressIndicatorToJson(StressIndicator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'severity': instance.severity,
      'location': instance.location,
      'symptoms': instance.symptoms,
      'causes': instance.causes,
      'interventions': instance.interventions,
    };

FacialMuscle _$FacialMuscleFromJson(Map<String, dynamic> json) => FacialMuscle(
  id: json['id'] as String,
  name: json['name'] as String,
  activationLevel: (json['activationLevel'] as num).toDouble(),
  function: json['function'] as String,
  relatedExpressions: (json['relatedExpressions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$FacialMuscleToJson(FacialMuscle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'activationLevel': instance.activationLevel,
      'function': instance.function,
      'relatedExpressions': instance.relatedExpressions,
    };
