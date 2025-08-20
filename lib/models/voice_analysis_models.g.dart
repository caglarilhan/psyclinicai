// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_analysis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoiceAnalysis _$VoiceAnalysisFromJson(Map<String, dynamic> json) =>
    VoiceAnalysis(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      voiceEmotion: VoiceEmotion.fromJson(
        json['voiceEmotion'] as Map<String, dynamic>,
      ),
      voiceStress: VoiceStress.fromJson(
        json['voiceStress'] as Map<String, dynamic>,
      ),
      voiceClarity: VoiceClarity.fromJson(
        json['voiceClarity'] as Map<String, dynamic>,
      ),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => VoicePattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      anomalies: (json['anomalies'] as List<dynamic>)
          .map((e) => SpeechAnomaly.fromJson(e as Map<String, dynamic>))
          .toList(),
      biometrics: VoiceBiometrics.fromJson(
        json['biometrics'] as Map<String, dynamic>,
      ),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$VoiceAnalysisToJson(VoiceAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'timestamp': instance.timestamp.toIso8601String(),
      'voiceEmotion': instance.voiceEmotion,
      'voiceStress': instance.voiceStress,
      'voiceClarity': instance.voiceClarity,
      'patterns': instance.patterns,
      'anomalies': instance.anomalies,
      'biometrics': instance.biometrics,
      'metadata': instance.metadata,
    };

VoiceEmotion _$VoiceEmotionFromJson(Map<String, dynamic> json) => VoiceEmotion(
  id: json['id'] as String,
  primaryEmotion: $enumDecode(_$EmotionTypeEnumMap, json['primaryEmotion']),
  emotionConfidence: (json['emotionConfidence'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  intensity: (json['intensity'] as num).toDouble(),
  instability: (json['instability'] as num).toDouble(),
  emotionalTriggers: (json['emotionalTriggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tone: VoiceTone.fromJson(json['tone'] as Map<String, dynamic>),
  pitch: VoicePitch.fromJson(json['pitch'] as Map<String, dynamic>),
  rhythm: VoiceRhythm.fromJson(json['rhythm'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VoiceEmotionToJson(VoiceEmotion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'primaryEmotion': _$EmotionTypeEnumMap[instance.primaryEmotion]!,
      'emotionConfidence': instance.emotionConfidence,
      'intensity': instance.intensity,
      'instability': instance.instability,
      'emotionalTriggers': instance.emotionalTriggers,
      'tone': instance.tone,
      'pitch': instance.pitch,
      'rhythm': instance.rhythm,
    };

const _$EmotionTypeEnumMap = {
  EmotionType.joy: 'joy',
  EmotionType.sadness: 'sadness',
  EmotionType.anger: 'anger',
  EmotionType.fear: 'fear',
  EmotionType.surprise: 'surprise',
  EmotionType.disgust: 'disgust',
  EmotionType.anxiety: 'anxiety',
  EmotionType.depression: 'depression',
  EmotionType.excitement: 'excitement',
  EmotionType.calm: 'calm',
  EmotionType.confusion: 'confusion',
  EmotionType.frustration: 'frustration',
  EmotionType.hope: 'hope',
  EmotionType.despair: 'despair',
  EmotionType.love: 'love',
  EmotionType.hate: 'hate',
  EmotionType.guilt: 'guilt',
  EmotionType.shame: 'shame',
  EmotionType.pride: 'pride',
  EmotionType.envy: 'envy',
  EmotionType.contempt: 'contempt',
  EmotionType.amusement: 'amusement',
  EmotionType.relief: 'relief',
  EmotionType.satisfaction: 'satisfaction',
  EmotionType.disappointment: 'disappointment',
};

VoiceStress _$VoiceStressFromJson(Map<String, dynamic> json) => VoiceStress(
  id: json['id'] as String,
  stressLevel: (json['stressLevel'] as num).toDouble(),
  stressType: $enumDecode(_$StressTypeEnumMap, json['stressType']),
  stressIndicators: (json['stressIndicators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  cortisolLevel: (json['cortisolLevel'] as num).toDouble(),
  heartRateVariability: (json['heartRateVariability'] as num).toDouble(),
  copingMechanisms: (json['copingMechanisms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  stressOnset: DateTime.parse(json['stressOnset'] as String),
);

Map<String, dynamic> _$VoiceStressToJson(VoiceStress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stressLevel': instance.stressLevel,
      'stressType': _$StressTypeEnumMap[instance.stressType]!,
      'stressIndicators': instance.stressIndicators,
      'cortisolLevel': instance.cortisolLevel,
      'heartRateVariability': instance.heartRateVariability,
      'copingMechanisms': instance.copingMechanisms,
      'stressOnset': instance.stressOnset.toIso8601String(),
    };

const _$StressTypeEnumMap = {
  StressType.acute: 'acute',
  StressType.chronic: 'chronic',
  StressType.episodic: 'episodic',
  StressType.situational: 'situational',
  StressType.performance: 'performance',
  StressType.social: 'social',
  StressType.financial: 'financial',
  StressType.health: 'health',
  StressType.relationship: 'relationship',
  StressType.work: 'work',
};

VoiceClarity _$VoiceClarityFromJson(Map<String, dynamic> json) => VoiceClarity(
  id: json['id'] as String,
  clarity: (json['clarity'] as num).toDouble(),
  articulation: (json['articulation'] as num).toDouble(),
  fluency: (json['fluency'] as num).toDouble(),
  disorders: (json['disorders'] as List<dynamic>)
      .map((e) => $enumDecode(_$SpeechDisorderEnumMap, e))
      .toList(),
  improvementSuggestions: (json['improvementSuggestions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$VoiceClarityToJson(VoiceClarity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clarity': instance.clarity,
      'articulation': instance.articulation,
      'fluency': instance.fluency,
      'disorders': instance.disorders
          .map((e) => _$SpeechDisorderEnumMap[e]!)
          .toList(),
      'improvementSuggestions': instance.improvementSuggestions,
      'confidence': instance.confidence,
    };

const _$SpeechDisorderEnumMap = {
  SpeechDisorder.none: 'none',
  SpeechDisorder.stuttering: 'stuttering',
  SpeechDisorder.dysarthria: 'dysarthria',
  SpeechDisorder.apraxia: 'apraxia',
  SpeechDisorder.articulation: 'articulation',
  SpeechDisorder.phonological: 'phonological',
  SpeechDisorder.fluency: 'fluency',
};

VoicePattern _$VoicePatternFromJson(Map<String, dynamic> json) => VoicePattern(
  id: json['id'] as String,
  type: $enumDecode(_$PatternTypeEnumMap, json['type']),
  description: json['description'] as String,
  frequency: (json['frequency'] as num).toDouble(),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interventions: (json['interventions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isPathological: json['isPathological'] as bool,
);

Map<String, dynamic> _$VoicePatternToJson(VoicePattern instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PatternTypeEnumMap[instance.type]!,
      'description': instance.description,
      'frequency': instance.frequency,
      'triggers': instance.triggers,
      'interventions': instance.interventions,
      'isPathological': instance.isPathological,
    };

const _$PatternTypeEnumMap = {
  PatternType.stuttering: 'stuttering',
  PatternType.repetition: 'repetition',
  PatternType.hesitation: 'hesitation',
  PatternType.rapidSpeech: 'rapidSpeech',
  PatternType.slowSpeech: 'slowSpeech',
  PatternType.monotone: 'monotone',
  PatternType.emotionalOutbursts: 'emotionalOutbursts',
  PatternType.defensiveResponses: 'defensiveResponses',
  PatternType.avoidancePatterns: 'avoidancePatterns',
  PatternType.compulsiveBehaviors: 'compulsiveBehaviors',
};

SpeechAnomaly _$SpeechAnomalyFromJson(Map<String, dynamic> json) =>
    SpeechAnomaly(
      id: json['id'] as String,
      type: $enumDecode(_$AnomalyTypeEnumMap, json['type']),
      description: json['description'] as String,
      severity: (json['severity'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      possibleCauses: (json['possibleCauses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SpeechAnomalyToJson(SpeechAnomaly instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AnomalyTypeEnumMap[instance.type]!,
      'description': instance.description,
      'severity': instance.severity,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'symptoms': instance.symptoms,
      'possibleCauses': instance.possibleCauses,
      'recommendations': instance.recommendations,
    };

const _$AnomalyTypeEnumMap = {
  AnomalyType.stuttering: 'stuttering',
  AnomalyType.slurredSpeech: 'slurredSpeech',
  AnomalyType.rapidSpeech: 'rapidSpeech',
  AnomalyType.slowSpeech: 'slowSpeech',
  AnomalyType.monotone: 'monotone',
  AnomalyType.breathlessness: 'breathlessness',
  AnomalyType.hoarseness: 'hoarseness',
  AnomalyType.nasality: 'nasality',
  AnomalyType.articulationProblems: 'articulationProblems',
  AnomalyType.fluencyIssues: 'fluencyIssues',
};

VoiceBiometrics _$VoiceBiometricsFromJson(Map<String, dynamic> json) =>
    VoiceBiometrics(
      id: json['id'] as String,
      pitch: (json['pitch'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      tempo: (json['tempo'] as num).toDouble(),
      rhythm: (json['rhythm'] as num).toDouble(),
      breathingRate: (json['breathingRate'] as num).toDouble(),
      pauseFrequency: (json['pauseFrequency'] as num).toDouble(),
      fillerWordUsage: (json['fillerWordUsage'] as num).toDouble(),
      biomarkers: (json['biomarkers'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$VoiceBiometricsToJson(VoiceBiometrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pitch': instance.pitch,
      'volume': instance.volume,
      'tempo': instance.tempo,
      'rhythm': instance.rhythm,
      'breathingRate': instance.breathingRate,
      'pauseFrequency': instance.pauseFrequency,
      'fillerWordUsage': instance.fillerWordUsage,
      'biomarkers': instance.biomarkers,
    };

VoiceTone _$VoiceToneFromJson(Map<String, dynamic> json) => VoiceTone(
  id: json['id'] as String,
  type: $enumDecode(_$ToneTypeEnumMap, json['type']),
  warmth: (json['warmth'] as num).toDouble(),
  harshness: (json['harshness'] as num).toDouble(),
  monotony: (json['monotony'] as num).toDouble(),
  expressiveness: (json['expressiveness'] as num).toDouble(),
  characteristics: (json['characteristics'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$VoiceToneToJson(VoiceTone instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ToneTypeEnumMap[instance.type]!,
  'warmth': instance.warmth,
  'harshness': instance.harshness,
  'monotony': instance.monotony,
  'expressiveness': instance.expressiveness,
  'characteristics': instance.characteristics,
};

const _$ToneTypeEnumMap = {
  ToneType.warm: 'warm',
  ToneType.cold: 'cold',
  ToneType.harsh: 'harsh',
  ToneType.soft: 'soft',
  ToneType.monotone: 'monotone',
  ToneType.expressive: 'expressive',
  ToneType.flat: 'flat',
  ToneType.animated: 'animated',
  ToneType.tense: 'tense',
  ToneType.relaxed: 'relaxed',
};

VoicePitch _$VoicePitchFromJson(Map<String, dynamic> json) => VoicePitch(
  id: json['id'] as String,
  averagePitch: (json['averagePitch'] as num).toDouble(),
  pitchRange: (json['pitchRange'] as num).toDouble(),
  pitchVariability: (json['pitchVariability'] as num).toDouble(),
  pitchHistory: (json['pitchHistory'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  pattern: $enumDecode(_$PitchPatternEnumMap, json['pattern']),
);

Map<String, dynamic> _$VoicePitchToJson(VoicePitch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'averagePitch': instance.averagePitch,
      'pitchRange': instance.pitchRange,
      'pitchVariability': instance.pitchVariability,
      'pitchHistory': instance.pitchHistory,
      'pattern': _$PitchPatternEnumMap[instance.pattern]!,
    };

const _$PitchPatternEnumMap = {
  PitchPattern.rising: 'rising',
  PitchPattern.falling: 'falling',
  PitchPattern.flat: 'flat',
  PitchPattern.variable: 'variable',
  PitchPattern.monotone: 'monotone',
  PitchPattern.expressive: 'expressive',
  PitchPattern.nervous: 'nervous',
  PitchPattern.confident: 'confident',
  PitchPattern.uncertain: 'uncertain',
  PitchPattern.aggressive: 'aggressive',
};

VoiceRhythm _$VoiceRhythmFromJson(Map<String, dynamic> json) => VoiceRhythm(
  id: json['id'] as String,
  speakingRate: (json['speakingRate'] as num).toDouble(),
  pauseDuration: (json['pauseDuration'] as num).toDouble(),
  rhythmRegularity: (json['rhythmRegularity'] as num).toDouble(),
  rhythmPatterns: (json['rhythmPatterns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isRhythmic: json['isRhythmic'] as bool,
);

Map<String, dynamic> _$VoiceRhythmToJson(VoiceRhythm instance) =>
    <String, dynamic>{
      'id': instance.id,
      'speakingRate': instance.speakingRate,
      'pauseDuration': instance.pauseDuration,
      'rhythmRegularity': instance.rhythmRegularity,
      'rhythmPatterns': instance.rhythmPatterns,
      'isRhythmic': instance.isRhythmic,
    };
