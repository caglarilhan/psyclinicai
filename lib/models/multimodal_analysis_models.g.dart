// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multimodal_analysis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultimodalAnalysisSession _$MultimodalAnalysisSessionFromJson(
  Map<String, dynamic> json,
) => MultimodalAnalysisSession(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  sessionDate: DateTime.parse(json['sessionDate'] as String),
  sessionDuration: Duration(
    microseconds: (json['sessionDuration'] as num).toInt(),
  ),
  modalities: (json['modalities'] as List<dynamic>)
      .map((e) => ModalityData.fromJson(e as Map<String, dynamic>))
      .toList(),
  analysisResult: MultimodalAnalysisResult.fromJson(
    json['analysisResult'] as Map<String, dynamic>,
  ),
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$MultimodalAnalysisSessionToJson(
  MultimodalAnalysisSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'sessionDate': instance.sessionDate.toIso8601String(),
  'sessionDuration': instance.sessionDuration.inMicroseconds,
  'modalities': instance.modalities,
  'analysisResult': instance.analysisResult,
  'alerts': instance.alerts,
  'confidence': instance.confidence,
};

ModalityData _$ModalityDataFromJson(Map<String, dynamic> json) => ModalityData(
  id: json['id'] as String,
  type: $enumDecode(_$ModalityTypeEnumMap, json['type']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  rawData: json['rawData'] as Map<String, dynamic>,
  processedData: json['processedData'] as Map<String, dynamic>,
  quality: (json['quality'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ModalityDataToJson(ModalityData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ModalityTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'rawData': instance.rawData,
      'processedData': instance.processedData,
      'quality': instance.quality,
      'notes': instance.notes,
    };

const _$ModalityTypeEnumMap = {
  ModalityType.voice: 'voice',
  ModalityType.video: 'video',
  ModalityType.sleep: 'sleep',
  ModalityType.activity: 'activity',
  ModalityType.digitalPhenotype: 'digital_phenotype',
  ModalityType.biometric: 'biometric',
};

VoiceBiomarkerAnalysis _$VoiceBiomarkerAnalysisFromJson(
  Map<String, dynamic> json,
) => VoiceBiomarkerAnalysis(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  characteristics: VoiceCharacteristics.fromJson(
    json['characteristics'] as Map<String, dynamic>,
  ),
  emotionAnalysis: VoiceEmotionAnalysis.fromJson(
    json['emotionAnalysis'] as Map<String, dynamic>,
  ),
  speechPattern: SpeechPatternAnalysis.fromJson(
    json['speechPattern'] as Map<String, dynamic>,
  ),
  stressAnalysis: VoiceStressAnalysis.fromJson(
    json['stressAnalysis'] as Map<String, dynamic>,
  ),
  biomarkers: (json['biomarkers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  relapseRisk: (json['relapseRisk'] as num).toDouble(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$VoiceBiomarkerAnalysisToJson(
  VoiceBiomarkerAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'timestamp': instance.timestamp.toIso8601String(),
  'characteristics': instance.characteristics,
  'emotionAnalysis': instance.emotionAnalysis,
  'speechPattern': instance.speechPattern,
  'stressAnalysis': instance.stressAnalysis,
  'biomarkers': instance.biomarkers,
  'relapseRisk': instance.relapseRisk,
  'recommendations': instance.recommendations,
};

VoiceCharacteristics _$VoiceCharacteristicsFromJson(
  Map<String, dynamic> json,
) => VoiceCharacteristics(
  pitch: (json['pitch'] as num).toDouble(),
  volume: (json['volume'] as num).toDouble(),
  speakingRate: (json['speakingRate'] as num).toDouble(),
  articulation: (json['articulation'] as num).toDouble(),
  fluency: (json['fluency'] as num).toDouble(),
  disfluencies: (json['disfluencies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  prosody: (json['prosody'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$VoiceCharacteristicsToJson(
  VoiceCharacteristics instance,
) => <String, dynamic>{
  'pitch': instance.pitch,
  'volume': instance.volume,
  'speakingRate': instance.speakingRate,
  'articulation': instance.articulation,
  'fluency': instance.fluency,
  'disfluencies': instance.disfluencies,
  'prosody': instance.prosody,
};

VoiceEmotionAnalysis _$VoiceEmotionAnalysisFromJson(
  Map<String, dynamic> json,
) => VoiceEmotionAnalysis(
  emotionScores: (json['emotionScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  dominantEmotion: json['dominantEmotion'] as String,
  emotionIntensity: (json['emotionIntensity'] as num).toDouble(),
  emotionTransitions: (json['emotionTransitions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  emotionalStability: (json['emotionalStability'] as num).toDouble(),
);

Map<String, dynamic> _$VoiceEmotionAnalysisToJson(
  VoiceEmotionAnalysis instance,
) => <String, dynamic>{
  'emotionScores': instance.emotionScores,
  'dominantEmotion': instance.dominantEmotion,
  'emotionIntensity': instance.emotionIntensity,
  'emotionTransitions': instance.emotionTransitions,
  'emotionalStability': instance.emotionalStability,
};

SpeechPatternAnalysis _$SpeechPatternAnalysisFromJson(
  Map<String, dynamic> json,
) => SpeechPatternAnalysis(
  wordDensity: (json['wordDensity'] as num).toDouble(),
  sentenceComplexity: (json['sentenceComplexity'] as num).toDouble(),
  vocabularyLevel: (json['vocabularyLevel'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  coherence: (json['coherence'] as num).toDouble(),
  speechDisorders: (json['speechDisorders'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  linguisticFeatures: (json['linguisticFeatures'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$SpeechPatternAnalysisToJson(
  SpeechPatternAnalysis instance,
) => <String, dynamic>{
  'wordDensity': instance.wordDensity,
  'sentenceComplexity': instance.sentenceComplexity,
  'vocabularyLevel': instance.vocabularyLevel,
  'coherence': instance.coherence,
  'speechDisorders': instance.speechDisorders,
  'linguisticFeatures': instance.linguisticFeatures,
};

VoiceStressAnalysis _$VoiceStressAnalysisFromJson(Map<String, dynamic> json) =>
    VoiceStressAnalysis(
      stressLevel: (json['stressLevel'] as num).toDouble(),
      stressIndicators: (json['stressIndicators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      vocalFatigue: (json['vocalFatigue'] as num).toDouble(),
      stressPatterns: (json['stressPatterns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recoveryRate: (json['recoveryRate'] as num).toDouble(),
    );

Map<String, dynamic> _$VoiceStressAnalysisToJson(
  VoiceStressAnalysis instance,
) => <String, dynamic>{
  'stressLevel': instance.stressLevel,
  'stressIndicators': instance.stressIndicators,
  'vocalFatigue': instance.vocalFatigue,
  'stressPatterns': instance.stressPatterns,
  'recoveryRate': instance.recoveryRate,
};

VideoMicroexpressionAnalysis _$VideoMicroexpressionAnalysisFromJson(
  Map<String, dynamic> json,
) => VideoMicroexpressionAnalysis(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  expressions: (json['expressions'] as List<dynamic>)
      .map((e) => FacialExpression.fromJson(e as Map<String, dynamic>))
      .toList(),
  microexpressions: (json['microexpressions'] as List<dynamic>)
      .map((e) => Microexpression.fromJson(e as Map<String, dynamic>))
      .toList(),
  gazeAnalysis: GazeAnalysis.fromJson(
    json['gazeAnalysis'] as Map<String, dynamic>,
  ),
  emotionalStates: (json['emotionalStates'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dissociationRisk: (json['dissociationRisk'] as num).toDouble(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$VideoMicroexpressionAnalysisToJson(
  VideoMicroexpressionAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'timestamp': instance.timestamp.toIso8601String(),
  'expressions': instance.expressions,
  'microexpressions': instance.microexpressions,
  'gazeAnalysis': instance.gazeAnalysis,
  'emotionalStates': instance.emotionalStates,
  'dissociationRisk': instance.dissociationRisk,
  'recommendations': instance.recommendations,
};

FacialExpression _$FacialExpressionFromJson(Map<String, dynamic> json) =>
    FacialExpression(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      emotion: json['emotion'] as String,
      intensity: (json['intensity'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => FacialAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      coordinates: (json['coordinates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$FacialExpressionToJson(FacialExpression instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'emotion': instance.emotion,
      'intensity': instance.intensity,
      'confidence': instance.confidence,
      'actions': instance.actions,
      'coordinates': instance.coordinates,
    };

FacialAction _$FacialActionFromJson(Map<String, dynamic> json) => FacialAction(
  id: json['id'] as String,
  actionUnit: json['actionUnit'] as String,
  intensity: (json['intensity'] as num).toDouble(),
  description: json['description'] as String,
  duration: (json['duration'] as num).toDouble(),
);

Map<String, dynamic> _$FacialActionToJson(FacialAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actionUnit': instance.actionUnit,
      'intensity': instance.intensity,
      'description': instance.description,
      'duration': instance.duration,
    };

Microexpression _$MicroexpressionFromJson(Map<String, dynamic> json) =>
    Microexpression(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      emotion: json['emotion'] as String,
      intensity: (json['intensity'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      significance: json['significance'] as String,
      implications: (json['implications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MicroexpressionToJson(Microexpression instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'emotion': instance.emotion,
      'intensity': instance.intensity,
      'duration': instance.duration,
      'significance': instance.significance,
      'implications': instance.implications,
    };

GazeAnalysis _$GazeAnalysisFromJson(Map<String, dynamic> json) => GazeAnalysis(
  gazePoints: (json['gazePoints'] as List<dynamic>)
      .map((e) => GazePoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  attentionLevel: (json['attentionLevel'] as num).toDouble(),
  gazePatterns: (json['gazePatterns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  eyeContact: (json['eyeContact'] as num).toDouble(),
  avoidanceBehaviors: (json['avoidanceBehaviors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GazeAnalysisToJson(GazeAnalysis instance) =>
    <String, dynamic>{
      'gazePoints': instance.gazePoints,
      'attentionLevel': instance.attentionLevel,
      'gazePatterns': instance.gazePatterns,
      'eyeContact': instance.eyeContact,
      'avoidanceBehaviors': instance.avoidanceBehaviors,
    };

GazePoint _$GazePointFromJson(Map<String, dynamic> json) => GazePoint(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  duration: (json['duration'] as num).toDouble(),
  target: json['target'] as String,
);

Map<String, dynamic> _$GazePointToJson(GazePoint instance) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'x': instance.x,
  'y': instance.y,
  'duration': instance.duration,
  'target': instance.target,
};

SleepActivityCorrelation _$SleepActivityCorrelationFromJson(
  Map<String, dynamic> json,
) => SleepActivityCorrelation(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  analysisDate: DateTime.parse(json['analysisDate'] as String),
  sleepData: SleepData.fromJson(json['sleepData'] as Map<String, dynamic>),
  activityData: ActivityData.fromJson(
    json['activityData'] as Map<String, dynamic>,
  ),
  correlation: CorrelationAnalysis.fromJson(
    json['correlation'] as Map<String, dynamic>,
  ),
  insights: (json['insights'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SleepActivityCorrelationToJson(
  SleepActivityCorrelation instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'analysisDate': instance.analysisDate.toIso8601String(),
  'sleepData': instance.sleepData,
  'activityData': instance.activityData,
  'correlation': instance.correlation,
  'insights': instance.insights,
  'recommendations': instance.recommendations,
};

SleepData _$SleepDataFromJson(Map<String, dynamic> json) => SleepData(
  sleepDate: DateTime.parse(json['sleepDate'] as String),
  totalSleepTime: Duration(
    microseconds: (json['totalSleepTime'] as num).toInt(),
  ),
  deepSleepTime: Duration(microseconds: (json['deepSleepTime'] as num).toInt()),
  remSleepTime: Duration(microseconds: (json['remSleepTime'] as num).toInt()),
  lightSleepTime: Duration(
    microseconds: (json['lightSleepTime'] as num).toInt(),
  ),
  sleepEfficiency: (json['sleepEfficiency'] as num).toInt(),
  wakeUps: (json['wakeUps'] as num).toInt(),
  sleepQuality: (json['sleepQuality'] as num).toDouble(),
  sleepDisorders: (json['sleepDisorders'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SleepDataToJson(SleepData instance) => <String, dynamic>{
  'sleepDate': instance.sleepDate.toIso8601String(),
  'totalSleepTime': instance.totalSleepTime.inMicroseconds,
  'deepSleepTime': instance.deepSleepTime.inMicroseconds,
  'remSleepTime': instance.remSleepTime.inMicroseconds,
  'lightSleepTime': instance.lightSleepTime.inMicroseconds,
  'sleepEfficiency': instance.sleepEfficiency,
  'wakeUps': instance.wakeUps,
  'sleepQuality': instance.sleepQuality,
  'sleepDisorders': instance.sleepDisorders,
};

ActivityData _$ActivityDataFromJson(Map<String, dynamic> json) => ActivityData(
  activityDate: DateTime.parse(json['activityDate'] as String),
  steps: (json['steps'] as num).toInt(),
  distance: (json['distance'] as num).toDouble(),
  calories: (json['calories'] as num).toInt(),
  activeMinutes: (json['activeMinutes'] as num).toDouble(),
  sedentaryMinutes: (json['sedentaryMinutes'] as num).toDouble(),
  activities: (json['activities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  activityLevel: (json['activityLevel'] as num).toDouble(),
);

Map<String, dynamic> _$ActivityDataToJson(ActivityData instance) =>
    <String, dynamic>{
      'activityDate': instance.activityDate.toIso8601String(),
      'steps': instance.steps,
      'distance': instance.distance,
      'calories': instance.calories,
      'activeMinutes': instance.activeMinutes,
      'sedentaryMinutes': instance.sedentaryMinutes,
      'activities': instance.activities,
      'activityLevel': instance.activityLevel,
    };

CorrelationAnalysis _$CorrelationAnalysisFromJson(
  Map<String, dynamic> json,
) => CorrelationAnalysis(
  correlationCoefficient: (json['correlationCoefficient'] as num).toDouble(),
  correlationType: json['correlationType'] as String,
  patterns: (json['patterns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  anomalies: (json['anomalies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
  factors: (json['factors'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$CorrelationAnalysisToJson(
  CorrelationAnalysis instance,
) => <String, dynamic>{
  'correlationCoefficient': instance.correlationCoefficient,
  'correlationType': instance.correlationType,
  'patterns': instance.patterns,
  'anomalies': instance.anomalies,
  'confidence': instance.confidence,
  'factors': instance.factors,
};

DigitalPhenotyping _$DigitalPhenotypingFromJson(Map<String, dynamic> json) =>
    DigitalPhenotyping(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      phoneUsage: PhoneUsageData.fromJson(
        json['phoneUsage'] as Map<String, dynamic>,
      ),
      appUsage: AppUsageData.fromJson(json['appUsage'] as Map<String, dynamic>),
      communication: CommunicationData.fromJson(
        json['communication'] as Map<String, dynamic>,
      ),
      location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relapseRisk: (json['relapseRisk'] as num).toDouble(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DigitalPhenotypingToJson(DigitalPhenotyping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'phoneUsage': instance.phoneUsage,
      'appUsage': instance.appUsage,
      'communication': instance.communication,
      'location': instance.location,
      'patterns': instance.patterns,
      'relapseRisk': instance.relapseRisk,
      'recommendations': instance.recommendations,
    };

PhoneUsageData _$PhoneUsageDataFromJson(Map<String, dynamic> json) =>
    PhoneUsageData(
      totalScreenTime: Duration(
        microseconds: (json['totalScreenTime'] as num).toInt(),
      ),
      nightUsage: Duration(microseconds: (json['nightUsage'] as num).toInt()),
      unlockCount: (json['unlockCount'] as num).toInt(),
      usagePatterns: (json['usagePatterns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      usageVariability: (json['usageVariability'] as num).toDouble(),
    );

Map<String, dynamic> _$PhoneUsageDataToJson(PhoneUsageData instance) =>
    <String, dynamic>{
      'totalScreenTime': instance.totalScreenTime.inMicroseconds,
      'nightUsage': instance.nightUsage.inMicroseconds,
      'unlockCount': instance.unlockCount,
      'usagePatterns': instance.usagePatterns,
      'usageVariability': instance.usageVariability,
    };

AppUsageData _$AppUsageDataFromJson(Map<String, dynamic> json) => AppUsageData(
  appUsageTimes: (json['appUsageTimes'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Duration(microseconds: (e as num).toInt())),
  ),
  mostUsedApps: (json['mostUsedApps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  socialMediaUsage: (json['socialMediaUsage'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  productivityUsage: (json['productivityUsage'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  appDiversity: (json['appDiversity'] as num).toDouble(),
);

Map<String, dynamic> _$AppUsageDataToJson(AppUsageData instance) =>
    <String, dynamic>{
      'appUsageTimes': instance.appUsageTimes.map(
        (k, e) => MapEntry(k, e.inMicroseconds),
      ),
      'mostUsedApps': instance.mostUsedApps,
      'socialMediaUsage': instance.socialMediaUsage,
      'productivityUsage': instance.productivityUsage,
      'appDiversity': instance.appDiversity,
    };

CommunicationData _$CommunicationDataFromJson(Map<String, dynamic> json) =>
    CommunicationData(
      callsCount: (json['callsCount'] as num).toInt(),
      totalCallTime: Duration(
        microseconds: (json['totalCallTime'] as num).toInt(),
      ),
      messagesCount: (json['messagesCount'] as num).toInt(),
      communicationPatterns: (json['communicationPatterns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      socialEngagement: (json['socialEngagement'] as num).toDouble(),
    );

Map<String, dynamic> _$CommunicationDataToJson(CommunicationData instance) =>
    <String, dynamic>{
      'callsCount': instance.callsCount,
      'totalCallTime': instance.totalCallTime.inMicroseconds,
      'messagesCount': instance.messagesCount,
      'communicationPatterns': instance.communicationPatterns,
      'socialEngagement': instance.socialEngagement,
    };

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  locations: (json['locations'] as List<dynamic>)
      .map((e) => LocationPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  locationVariability: (json['locationVariability'] as num).toDouble(),
  frequentPlaces: (json['frequentPlaces'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  movementPatterns: (json['movementPatterns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  socialIsolation: (json['socialIsolation'] as num).toDouble(),
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'locations': instance.locations,
      'locationVariability': instance.locationVariability,
      'frequentPlaces': instance.frequentPlaces,
      'movementPatterns': instance.movementPatterns,
      'socialIsolation': instance.socialIsolation,
    };

LocationPoint _$LocationPointFromJson(Map<String, dynamic> json) =>
    LocationPoint(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      place: json['place'] as String,
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$LocationPointToJson(LocationPoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'place': instance.place,
      'duration': instance.duration.inMicroseconds,
    };

MultimodalAnalysisResult _$MultimodalAnalysisResultFromJson(
  Map<String, dynamic> json,
) => MultimodalAnalysisResult(
  id: json['id'] as String,
  analysisDate: DateTime.parse(json['analysisDate'] as String),
  modalityResults: (json['modalityResults'] as List<dynamic>)
      .map((e) => ModalityResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  integratedAnalysis: IntegratedAnalysis.fromJson(
    json['integratedAnalysis'] as Map<String, dynamic>,
  ),
  criticalFindings: (json['criticalFindings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  overallConfidence: (json['overallConfidence'] as num).toDouble(),
);

Map<String, dynamic> _$MultimodalAnalysisResultToJson(
  MultimodalAnalysisResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'analysisDate': instance.analysisDate.toIso8601String(),
  'modalityResults': instance.modalityResults,
  'integratedAnalysis': instance.integratedAnalysis,
  'criticalFindings': instance.criticalFindings,
  'recommendations': instance.recommendations,
  'overallConfidence': instance.overallConfidence,
};

ModalityResult _$ModalityResultFromJson(Map<String, dynamic> json) =>
    ModalityResult(
      type: $enumDecode(_$ModalityTypeEnumMap, json['type']),
      confidence: (json['confidence'] as num).toDouble(),
      findings: (json['findings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModalityResultToJson(ModalityResult instance) =>
    <String, dynamic>{
      'type': _$ModalityTypeEnumMap[instance.type]!,
      'confidence': instance.confidence,
      'findings': instance.findings,
      'alerts': instance.alerts,
      'metadata': instance.metadata,
    };

IntegratedAnalysis _$IntegratedAnalysisFromJson(Map<String, dynamic> json) =>
    IntegratedAnalysis(
      relapseRisk: (json['relapseRisk'] as num).toDouble(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      overallAssessment: json['overallAssessment'] as String,
      trends: (json['trends'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      predictionAccuracy: (json['predictionAccuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$IntegratedAnalysisToJson(IntegratedAnalysis instance) =>
    <String, dynamic>{
      'relapseRisk': instance.relapseRisk,
      'riskFactors': instance.riskFactors,
      'protectiveFactors': instance.protectiveFactors,
      'overallAssessment': instance.overallAssessment,
      'trends': instance.trends,
      'predictionAccuracy': instance.predictionAccuracy,
    };
