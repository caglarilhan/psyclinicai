import 'package:json_annotation/json_annotation.dart';

part 'voice_analysis_models.g.dart';

@JsonSerializable()
class VoiceAnalysis {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final VoiceEmotion voiceEmotion;
  final VoiceStress voiceStress;
  final VoiceClarity voiceClarity;
  final List<VoicePattern> patterns;
  final List<SpeechAnomaly> anomalies;
  final VoiceBiometrics biometrics;
  final Map<String, dynamic> metadata;

  const VoiceAnalysis({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.voiceEmotion,
    required this.voiceStress,
    required this.voiceClarity,
    required this.patterns,
    required this.anomalies,
    required this.biometrics,
    required this.metadata,
  });

  factory VoiceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$VoiceAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceAnalysisToJson(this);

  bool get hasHighStress => voiceStress.stressLevel > 0.7;
  bool get hasEmotionalInstability => voiceEmotion.instability > 0.6;
  bool get hasSpeechProblems => voiceClarity.clarity < 0.5;
}

@JsonSerializable()
class VoiceEmotion {
  final String id;
  final EmotionType primaryEmotion;
  final Map<EmotionType, double> emotionConfidence;
  final double intensity;
  final double instability;
  final List<String> emotionalTriggers;
  final VoiceTone tone;
  final VoicePitch pitch;
  final VoiceRhythm rhythm;

  const VoiceEmotion({
    required this.id,
    required this.primaryEmotion,
    required this.emotionConfidence,
    required this.intensity,
    required this.instability,
    required this.emotionalTriggers,
    required this.tone,
    required this.pitch,
    required this.rhythm,
  });

  factory VoiceEmotion.fromJson(Map<String, dynamic> json) =>
      _$VoiceEmotionFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceEmotionToJson(this);
}

@JsonSerializable()
class VoiceStress {
  final String id;
  final double stressLevel;
  final StressType stressType;
  final List<String> stressIndicators;
  final double cortisolLevel;
  final double heartRateVariability;
  final List<String> copingMechanisms;
  final DateTime stressOnset;

  const VoiceStress({
    required this.id,
    required this.stressLevel,
    required this.stressType,
    required this.stressIndicators,
    required this.cortisolLevel,
    required this.heartRateVariability,
    required this.copingMechanisms,
    required this.stressOnset,
  });

  factory VoiceStress.fromJson(Map<String, dynamic> json) =>
      _$VoiceStressFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceStressToJson(this);
}

@JsonSerializable()
class VoiceClarity {
  final String id;
  final double clarity;
  final double articulation;
  final double fluency;
  final List<SpeechDisorder> disorders;
  final List<String> improvementSuggestions;
  final double confidence;

  const VoiceClarity({
    required this.id,
    required this.clarity,
    required this.articulation,
    required this.fluency,
    required this.disorders,
    required this.improvementSuggestions,
    required this.confidence,
  });

  factory VoiceClarity.fromJson(Map<String, dynamic> json) =>
      _$VoiceClarityFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceClarityToJson(this);
}

@JsonSerializable()
class VoicePattern {
  final String id;
  final PatternType type;
  final String description;
  final double frequency;
  final List<String> triggers;
  final List<String> interventions;
  final bool isPathological;

  const VoicePattern({
    required this.id,
    required this.type,
    required this.description,
    required this.frequency,
    required this.triggers,
    required this.interventions,
    required this.isPathological,
  });

  factory VoicePattern.fromJson(Map<String, dynamic> json) =>
      _$VoicePatternFromJson(json);

  Map<String, dynamic> toJson() => _$VoicePatternToJson(this);
}

@JsonSerializable()
class SpeechAnomaly {
  final String id;
  final AnomalyType type;
  final String description;
  final double severity;
  final DateTime detectedAt;
  final List<String> symptoms;
  final List<String> possibleCauses;
  final List<String> recommendations;

  const SpeechAnomaly({
    required this.id,
    required this.type,
    required this.description,
    required this.severity,
    required this.detectedAt,
    required this.symptoms,
    required this.possibleCauses,
    required this.recommendations,
  });

  factory SpeechAnomaly.fromJson(Map<String, dynamic> json) =>
      _$SpeechAnomalyFromJson(json);

  Map<String, dynamic> toJson() => _$SpeechAnomalyToJson(this);
}

@JsonSerializable()
class VoiceBiometrics {
  final String id;
  final double pitch;
  final double volume;
  final double tempo;
  final double rhythm;
  final double breathingRate;
  final double pauseFrequency;
  final double fillerWordUsage;
  final Map<String, double> biomarkers;

  const VoiceBiometrics({
    required this.id,
    required this.pitch,
    required this.volume,
    required this.tempo,
    required this.rhythm,
    required this.breathingRate,
    required this.pauseFrequency,
    required this.fillerWordUsage,
    required this.biomarkers,
  });

  factory VoiceBiometrics.fromJson(Map<String, dynamic> json) =>
      _$VoiceBiometricsFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceBiometricsToJson(this);
}

@JsonSerializable()
class VoiceTone {
  final String id;
  final ToneType type;
  final double warmth;
  final double harshness;
  final double monotony;
  final double expressiveness;
  final List<String> characteristics;

  const VoiceTone({
    required this.id,
    required this.type,
    required this.warmth,
    required this.harshness,
    required this.monotony,
    required this.expressiveness,
    required this.characteristics,
  });

  factory VoiceTone.fromJson(Map<String, dynamic> json) =>
      _$VoiceToneFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceToneToJson(this);
}

@JsonSerializable()
class VoicePitch {
  final String id;
  final double averagePitch;
  final double pitchRange;
  final double pitchVariability;
  final List<double> pitchHistory;
  final PitchPattern pattern;

  const VoicePitch({
    required this.id,
    required this.averagePitch,
    required this.pitchRange,
    required this.pitchVariability,
    required this.pitchHistory,
    required this.pattern,
  });

  factory VoicePitch.fromJson(Map<String, dynamic> json) =>
      _$VoicePitchFromJson(json);

  Map<String, dynamic> toJson() => _$VoicePitchToJson(this);
}

@JsonSerializable()
class VoiceRhythm {
  final String id;
  final double speakingRate;
  final double pauseDuration;
  final double rhythmRegularity;
  final List<String> rhythmPatterns;
  final bool isRhythmic;

  const VoiceRhythm({
    required this.id,
    required this.speakingRate,
    required this.pauseDuration,
    required this.rhythmRegularity,
    required this.rhythmPatterns,
    required this.isRhythmic,
  });

  factory VoiceRhythm.fromJson(Map<String, dynamic> json) =>
      _$VoiceRhythmFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceRhythmToJson(this);
}

// Enums
enum EmotionType {
  joy,
  sadness,
  anger,
  fear,
  surprise,
  disgust,
  anxiety,
  depression,
  excitement,
  calm,
  confusion,
  frustration,
  hope,
  despair,
  love,
  hate,
  guilt,
  shame,
  pride,
  envy,
  contempt,
  amusement,
  relief,
  satisfaction,
  disappointment,
}

enum StressType {
  acute,
  chronic,
  episodic,
  situational,
  performance,
  social,
  financial,
  health,
  relationship,
  work,
}

enum PatternType {
  stuttering,
  repetition,
  hesitation,
  rapidSpeech,
  slowSpeech,
  monotone,
  emotionalOutbursts,
  defensiveResponses,
  avoidancePatterns,
  compulsiveBehaviors,
}

enum AnomalyType {
  stuttering,
  slurredSpeech,
  rapidSpeech,
  slowSpeech,
  monotone,
  breathlessness,
  hoarseness,
  nasality,
  articulationProblems,
  fluencyIssues,
}

enum ToneType {
  warm,
  cold,
  harsh,
  soft,
  monotone,
  expressive,
  flat,
  animated,
  tense,
  relaxed,
}

enum PitchPattern {
  rising,
  falling,
  flat,
  variable,
  monotone,
  expressive,
  nervous,
  confident,
  uncertain,
  aggressive,
}
