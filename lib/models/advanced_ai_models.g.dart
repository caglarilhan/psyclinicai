// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictiveModel _$PredictiveModelFromJson(Map<String, dynamic> json) =>
    PredictiveModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ModelTypeEnumMap, json['type']),
      category: $enumDecode(_$ModelCategoryEnumMap, json['category']),
      status: $enumDecode(_$ModelStatusEnumMap, json['status']),
      version: json['version'] as String,
      trainedAt: DateTime.parse(json['trainedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      performance: ModelPerformance.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
      metadata: ModelMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      features: (json['features'] as List<dynamic>)
          .map((e) => ModelFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
      predictions: (json['predictions'] as List<dynamic>)
          .map((e) => ModelPrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
      trainingData: ModelTrainingData.fromJson(
        json['trainingData'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PredictiveModelToJson(PredictiveModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$ModelTypeEnumMap[instance.type]!,
      'category': _$ModelCategoryEnumMap[instance.category]!,
      'status': _$ModelStatusEnumMap[instance.status]!,
      'version': instance.version,
      'trainedAt': instance.trainedAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'performance': instance.performance,
      'metadata': instance.metadata,
      'features': instance.features,
      'predictions': instance.predictions,
      'trainingData': instance.trainingData,
    };

const _$ModelTypeEnumMap = {
  ModelType.classification: 'classification',
  ModelType.regression: 'regression',
  ModelType.clustering: 'clustering',
  ModelType.anomalyDetection: 'anomaly_detection',
  ModelType.timeSeries: 'time_series',
  ModelType.reinforcementLearning: 'reinforcement_learning',
};

const _$ModelCategoryEnumMap = {
  ModelCategory.clinical: 'clinical',
  ModelCategory.operational: 'operational',
  ModelCategory.financial: 'financial',
  ModelCategory.compliance: 'compliance',
  ModelCategory.research: 'research',
};

const _$ModelStatusEnumMap = {
  ModelStatus.training: 'training',
  ModelStatus.active: 'active',
  ModelStatus.inactive: 'inactive',
  ModelStatus.deprecated: 'deprecated',
  ModelStatus.error: 'error',
};

ModelPrediction _$ModelPredictionFromJson(Map<String, dynamic> json) =>
    ModelPrediction(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      patientId: json['patientId'] as String,
      predictionType: json['predictionType'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
      inputData: json['inputData'] as Map<String, dynamic>,
      outputData: json['outputData'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$PredictionStatusEnumMap, json['status']),
      explanation: json['explanation'] as String?,
      featureImportance: (json['featureImportance'] as List<dynamic>)
          .map((e) => PredictionFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
      isVerified: json['isVerified'] as bool,
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      verifiedBy: json['verifiedBy'] as String?,
    );

Map<String, dynamic> _$ModelPredictionToJson(ModelPrediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'patientId': instance.patientId,
      'predictionType': instance.predictionType,
      'confidence': instance.confidence,
      'probability': instance.probability,
      'inputData': instance.inputData,
      'outputData': instance.outputData,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$PredictionStatusEnumMap[instance.status]!,
      'explanation': instance.explanation,
      'featureImportance': instance.featureImportance,
      'isVerified': instance.isVerified,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'verifiedBy': instance.verifiedBy,
    };

const _$PredictionStatusEnumMap = {
  PredictionStatus.pending: 'pending',
  PredictionStatus.active: 'active',
  PredictionStatus.verified: 'verified',
  PredictionStatus.incorrect: 'incorrect',
  PredictionStatus.expired: 'expired',
};

RelapsePrediction _$RelapsePredictionFromJson(Map<String, dynamic> json) =>
    RelapsePrediction(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      relapseRisk: (json['relapseRisk'] as num).toDouble(),
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      predictedDate: DateTime.parse(json['predictedDate'] as String),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      modelVersion: json['modelVersion'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mitigations: (json['mitigations'] as List<dynamic>)
          .map((e) => RiskMitigation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RelapsePredictionToJson(RelapsePrediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'relapseRisk': instance.relapseRisk,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'predictedDate': instance.predictedDate.toIso8601String(),
      'riskFactors': instance.riskFactors,
      'protectiveFactors': instance.protectiveFactors,
      'confidence': instance.confidence,
      'modelVersion': instance.modelVersion,
      'createdAt': instance.createdAt.toIso8601String(),
      'mitigations': instance.mitigations,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

NLPModel _$NLPModelFromJson(Map<String, dynamic> json) => NLPModel(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$NLPModelTypeEnumMap, json['type']),
  version: json['version'] as String,
  supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  supportedTasks: (json['supportedTasks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performance: ModelPerformance.fromJson(
    json['performance'] as Map<String, dynamic>,
  ),
  trainedAt: DateTime.parse(json['trainedAt'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  configuration: json['configuration'] as Map<String, dynamic>,
);

Map<String, dynamic> _$NLPModelToJson(NLPModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$NLPModelTypeEnumMap[instance.type]!,
  'version': instance.version,
  'supportedLanguages': instance.supportedLanguages,
  'supportedTasks': instance.supportedTasks,
  'performance': instance.performance,
  'trainedAt': instance.trainedAt.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'configuration': instance.configuration,
};

const _$NLPModelTypeEnumMap = {
  NLPModelType.bert: 'bert',
  NLPModelType.gpt: 'gpt',
  NLPModelType.lstm: 'lstm',
  NLPModelType.transformer: 'transformer',
  NLPModelType.custom: 'custom',
};

ICDCodeExtraction _$ICDCodeExtractionFromJson(Map<String, dynamic> json) =>
    ICDCodeExtraction(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      patientId: json['patientId'] as String,
      therapistId: json['therapistId'] as String,
      originalText: json['originalText'] as String,
      extractedCodes: (json['extractedCodes'] as List<dynamic>)
          .map((e) => ExtractedICDCode.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      modelVersion: json['modelVersion'] as String,
      extractedAt: DateTime.parse(json['extractedAt'] as String),
      status: $enumDecode(_$ExtractionStatusEnumMap, json['status']),
      alternativeCodes: (json['alternativeCodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reasoning: json['reasoning'] as String?,
    );

Map<String, dynamic> _$ICDCodeExtractionToJson(ICDCodeExtraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'patientId': instance.patientId,
      'therapistId': instance.therapistId,
      'originalText': instance.originalText,
      'extractedCodes': instance.extractedCodes,
      'confidence': instance.confidence,
      'modelVersion': instance.modelVersion,
      'extractedAt': instance.extractedAt.toIso8601String(),
      'status': _$ExtractionStatusEnumMap[instance.status]!,
      'alternativeCodes': instance.alternativeCodes,
      'reasoning': instance.reasoning,
    };

const _$ExtractionStatusEnumMap = {
  ExtractionStatus.pending: 'pending',
  ExtractionStatus.completed: 'completed',
  ExtractionStatus.failed: 'failed',
  ExtractionStatus.reviewed: 'reviewed',
};

ExtractedICDCode _$ExtractedICDCodeFromJson(Map<String, dynamic> json) =>
    ExtractedICDCode(
      icdCode: json['icdCode'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      supportingText: (json['supportingText'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      severity: json['severity'] as String,
      modifier: json['modifier'] as String?,
    );

Map<String, dynamic> _$ExtractedICDCodeToJson(ExtractedICDCode instance) =>
    <String, dynamic>{
      'icdCode': instance.icdCode,
      'description': instance.description,
      'confidence': instance.confidence,
      'supportingText': instance.supportingText,
      'symptoms': instance.symptoms,
      'severity': instance.severity,
      'modifier': instance.modifier,
    };

SentimentAnalysis _$SentimentAnalysisFromJson(Map<String, dynamic> json) =>
    SentimentAnalysis(
      id: json['id'] as String,
      textId: json['textId'] as String,
      text: json['text'] as String,
      primarySentiment: $enumDecode(
        _$SentimentTypeEnumMap,
        json['primarySentiment'],
      ),
      sentimentScores: (json['sentimentScores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          $enumDecode(_$SentimentTypeEnumMap, k),
          (e as num).toDouble(),
        ),
      ),
      emotions: (json['emotions'] as List<dynamic>)
          .map((e) => Emotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      modelVersion: json['modelVersion'] as String,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      entities: (json['entities'] as List<dynamic>)
          .map((e) => SentimentEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SentimentAnalysisToJson(SentimentAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'textId': instance.textId,
      'text': instance.text,
      'primarySentiment': _$SentimentTypeEnumMap[instance.primarySentiment]!,
      'sentimentScores': instance.sentimentScores.map(
        (k, e) => MapEntry(_$SentimentTypeEnumMap[k]!, e),
      ),
      'emotions': instance.emotions,
      'confidence': instance.confidence,
      'modelVersion': instance.modelVersion,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'entities': instance.entities,
    };

const _$SentimentTypeEnumMap = {
  SentimentType.positive: 'positive',
  SentimentType.negative: 'negative',
  SentimentType.neutral: 'neutral',
  SentimentType.mixed: 'mixed',
};

ComputerVisionModel _$ComputerVisionModelFromJson(Map<String, dynamic> json) =>
    ComputerVisionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$VisionModelTypeEnumMap, json['type']),
      version: json['version'] as String,
      supportedTasks: (json['supportedTasks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performance: ModelPerformance.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
      trainedAt: DateTime.parse(json['trainedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      configuration: json['configuration'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ComputerVisionModelToJson(
  ComputerVisionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$VisionModelTypeEnumMap[instance.type]!,
  'version': instance.version,
  'supportedTasks': instance.supportedTasks,
  'performance': instance.performance,
  'trainedAt': instance.trainedAt.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'configuration': instance.configuration,
};

const _$VisionModelTypeEnumMap = {
  VisionModelType.cnn: 'cnn',
  VisionModelType.resnet: 'resnet',
  VisionModelType.yolo: 'yolo',
  VisionModelType.custom: 'custom',
};

FacialExpressionAnalysis _$FacialExpressionAnalysisFromJson(
  Map<String, dynamic> json,
) => FacialExpressionAnalysis(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  patientId: json['patientId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  emotions: (json['emotions'] as List<dynamic>)
      .map((e) => DetectedEmotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  actions: (json['actions'] as List<dynamic>)
      .map((e) => FacialAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  gazePoints: (json['gazePoints'] as List<dynamic>)
      .map((e) => GazePoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  microExpressions: (json['microExpressions'] as List<dynamic>)
      .map((e) => MicroExpression.fromJson(e as Map<String, dynamic>))
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
  modelVersion: json['modelVersion'] as String,
  qualityMetrics: (json['qualityMetrics'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$FacialExpressionAnalysisToJson(
  FacialExpressionAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'patientId': instance.patientId,
  'timestamp': instance.timestamp.toIso8601String(),
  'emotions': instance.emotions,
  'actions': instance.actions,
  'gazePoints': instance.gazePoints,
  'microExpressions': instance.microExpressions,
  'confidence': instance.confidence,
  'modelVersion': instance.modelVersion,
  'qualityMetrics': instance.qualityMetrics,
};

DetectedEmotion _$DetectedEmotionFromJson(Map<String, dynamic> json) =>
    DetectedEmotion(
      emotion: $enumDecode(_$EmotionTypeEnumMap, json['emotion']),
      confidence: (json['confidence'] as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DetectedEmotionToJson(DetectedEmotion instance) =>
    <String, dynamic>{
      'emotion': _$EmotionTypeEnumMap[instance.emotion]!,
      'confidence': instance.confidence,
      'intensity': instance.intensity,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'triggers': instance.triggers,
    };

const _$EmotionTypeEnumMap = {
  EmotionType.happy: 'happy',
  EmotionType.sad: 'sad',
  EmotionType.angry: 'angry',
  EmotionType.fearful: 'fearful',
  EmotionType.surprised: 'surprised',
  EmotionType.disgusted: 'disgusted',
  EmotionType.neutral: 'neutral',
  EmotionType.anxious: 'anxious',
  EmotionType.depressed: 'depressed',
  EmotionType.manic: 'manic',
};

FacialAction _$FacialActionFromJson(Map<String, dynamic> json) => FacialAction(
  actionUnit: json['actionUnit'] as String,
  description: json['description'] as String,
  intensity: (json['intensity'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$FacialActionToJson(FacialAction instance) =>
    <String, dynamic>{
      'actionUnit': instance.actionUnit,
      'description': instance.description,
      'intensity': instance.intensity,
      'timestamp': instance.timestamp.toIso8601String(),
      'confidence': instance.confidence,
    };

GazePoint _$GazePointFromJson(Map<String, dynamic> json) => GazePoint(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  confidence: (json['confidence'] as num).toDouble(),
  target: json['target'] as String?,
);

Map<String, dynamic> _$GazePointToJson(GazePoint instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
  'timestamp': instance.timestamp.toIso8601String(),
  'confidence': instance.confidence,
  'target': instance.target,
};

MicroExpression _$MicroExpressionFromJson(Map<String, dynamic> json) =>
    MicroExpression(
      emotion: $enumDecode(_$EmotionTypeEnumMap, json['emotion']),
      intensity: (json['intensity'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      trigger: json['trigger'] as String?,
    );

Map<String, dynamic> _$MicroExpressionToJson(MicroExpression instance) =>
    <String, dynamic>{
      'emotion': _$EmotionTypeEnumMap[instance.emotion]!,
      'intensity': instance.intensity,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'confidence': instance.confidence,
      'trigger': instance.trigger,
    };

VoiceAnalysisModel _$VoiceAnalysisModelFromJson(Map<String, dynamic> json) =>
    VoiceAnalysisModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$VoiceModelTypeEnumMap, json['type']),
      version: json['version'] as String,
      supportedLanguages: (json['supportedLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supportedFeatures: (json['supportedFeatures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performance: ModelPerformance.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
      trainedAt: DateTime.parse(json['trainedAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$VoiceAnalysisModelToJson(VoiceAnalysisModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$VoiceModelTypeEnumMap[instance.type]!,
      'version': instance.version,
      'supportedLanguages': instance.supportedLanguages,
      'supportedFeatures': instance.supportedFeatures,
      'performance': instance.performance,
      'trainedAt': instance.trainedAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$VoiceModelTypeEnumMap = {
  VoiceModelType.lstm: 'lstm',
  VoiceModelType.transformer: 'transformer',
  VoiceModelType.cnn: 'cnn',
  VoiceModelType.custom: 'custom',
};

VoiceAnalysis _$VoiceAnalysisFromJson(Map<String, dynamic> json) =>
    VoiceAnalysis(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      characteristics: VoiceCharacteristics.fromJson(
        json['characteristics'] as Map<String, dynamic>,
      ),
      emotions: (json['emotions'] as List<dynamic>)
          .map((e) => VoiceEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => SpeechPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      stressIndicators: (json['stressIndicators'] as List<dynamic>)
          .map((e) => VoiceStress.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      modelVersion: json['modelVersion'] as String,
      qualityMetrics: (json['qualityMetrics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$VoiceAnalysisToJson(VoiceAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'patientId': instance.patientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'characteristics': instance.characteristics,
      'emotions': instance.emotions,
      'patterns': instance.patterns,
      'stressIndicators': instance.stressIndicators,
      'confidence': instance.confidence,
      'modelVersion': instance.modelVersion,
      'qualityMetrics': instance.qualityMetrics,
    };

VoiceCharacteristics _$VoiceCharacteristicsFromJson(
  Map<String, dynamic> json,
) => VoiceCharacteristics(
  pitch: (json['pitch'] as num).toDouble(),
  speakingRate: (json['speakingRate'] as num).toDouble(),
  volume: (json['volume'] as num).toDouble(),
  clarity: (json['clarity'] as num).toDouble(),
  fluency: (json['fluency'] as num).toDouble(),
  speechDisorders: (json['speechDisorders'] as List<dynamic>)
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
  'speakingRate': instance.speakingRate,
  'volume': instance.volume,
  'clarity': instance.clarity,
  'fluency': instance.fluency,
  'speechDisorders': instance.speechDisorders,
  'prosody': instance.prosody,
};

VoiceEmotion _$VoiceEmotionFromJson(Map<String, dynamic> json) => VoiceEmotion(
  emotion: $enumDecode(_$EmotionTypeEnumMap, json['emotion']),
  confidence: (json['confidence'] as num).toDouble(),
  intensity: (json['intensity'] as num).toDouble(),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  emotionBlend: (json['emotionBlend'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$VoiceEmotionToJson(VoiceEmotion instance) =>
    <String, dynamic>{
      'emotion': _$EmotionTypeEnumMap[instance.emotion]!,
      'confidence': instance.confidence,
      'intensity': instance.intensity,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'emotionBlend': instance.emotionBlend,
    };

SpeechPattern _$SpeechPatternFromJson(Map<String, dynamic> json) =>
    SpeechPattern(
      patternType: json['patternType'] as String,
      description: json['description'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      occurrences: (json['occurrences'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      clinicalSignificance: json['clinicalSignificance'] as String?,
    );

Map<String, dynamic> _$SpeechPatternToJson(
  SpeechPattern instance,
) => <String, dynamic>{
  'patternType': instance.patternType,
  'description': instance.description,
  'frequency': instance.frequency,
  'occurrences': instance.occurrences.map((e) => e.toIso8601String()).toList(),
  'confidence': instance.confidence,
  'clinicalSignificance': instance.clinicalSignificance,
};

VoiceStress _$VoiceStressFromJson(Map<String, dynamic> json) => VoiceStress(
  type: $enumDecode(_$StressTypeEnumMap, json['type']),
  level: (json['level'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  confidence: (json['confidence'] as num).toDouble(),
  indicators: (json['indicators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$VoiceStressToJson(VoiceStress instance) =>
    <String, dynamic>{
      'type': _$StressTypeEnumMap[instance.type]!,
      'level': instance.level,
      'timestamp': instance.timestamp.toIso8601String(),
      'confidence': instance.confidence,
      'indicators': instance.indicators,
    };

const _$StressTypeEnumMap = {
  StressType.acute: 'acute',
  StressType.chronic: 'chronic',
  StressType.trauma: 'trauma',
  StressType.anxiety: 'anxiety',
};

XAIModel _$XAIModelFromJson(Map<String, dynamic> json) => XAIModel(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$XAITypeEnumMap, json['type']),
  version: json['version'] as String,
  supportedMethods: (json['supportedMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performance: ModelPerformance.fromJson(
    json['performance'] as Map<String, dynamic>,
  ),
  trainedAt: DateTime.parse(json['trainedAt'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$XAIModelToJson(XAIModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$XAITypeEnumMap[instance.type]!,
  'version': instance.version,
  'supportedMethods': instance.supportedMethods,
  'performance': instance.performance,
  'trainedAt': instance.trainedAt.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

const _$XAITypeEnumMap = {
  XAIType.featureImportance: 'feature_importance',
  XAIType.ruleBased: 'rule_based',
  XAIType.counterfactual: 'counterfactual',
  XAIType.gradientBased: 'gradient_based',
  XAIType.attentionBased: 'attention_based',
};

AIExplanation _$AIExplanationFromJson(Map<String, dynamic> json) =>
    AIExplanation(
      id: json['id'] as String,
      predictionId: json['predictionId'] as String,
      modelId: json['modelId'] as String,
      explanationType: json['explanationType'] as String,
      explanation: json['explanation'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      features: (json['features'] as List<dynamic>)
          .map((e) => ExplanationFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
      rules: (json['rules'] as List<dynamic>)
          .map((e) => ExplanationRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      modelVersion: json['modelVersion'] as String,
    );

Map<String, dynamic> _$AIExplanationToJson(AIExplanation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'predictionId': instance.predictionId,
      'modelId': instance.modelId,
      'explanationType': instance.explanationType,
      'explanation': instance.explanation,
      'confidence': instance.confidence,
      'features': instance.features,
      'rules': instance.rules,
      'metadata': instance.metadata,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'modelVersion': instance.modelVersion,
    };

ExplanationFeature _$ExplanationFeatureFromJson(Map<String, dynamic> json) =>
    ExplanationFeature(
      featureName: json['featureName'] as String,
      featureValue: json['featureValue'] as String,
      importance: (json['importance'] as num).toDouble(),
      contribution: (json['contribution'] as num).toDouble(),
      description: json['description'] as String?,
      relatedSymptoms: (json['relatedSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExplanationFeatureToJson(ExplanationFeature instance) =>
    <String, dynamic>{
      'featureName': instance.featureName,
      'featureValue': instance.featureValue,
      'importance': instance.importance,
      'contribution': instance.contribution,
      'description': instance.description,
      'relatedSymptoms': instance.relatedSymptoms,
    };

ExplanationRule _$ExplanationRuleFromJson(Map<String, dynamic> json) =>
    ExplanationRule(
      ruleId: json['ruleId'] as String,
      ruleDescription: json['ruleDescription'] as String,
      condition: json['condition'] as String,
      conclusion: json['conclusion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      supportingEvidence: (json['supportingEvidence'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExplanationRuleToJson(ExplanationRule instance) =>
    <String, dynamic>{
      'ruleId': instance.ruleId,
      'ruleDescription': instance.ruleDescription,
      'condition': instance.condition,
      'conclusion': instance.conclusion,
      'confidence': instance.confidence,
      'supportingEvidence': instance.supportingEvidence,
    };

ModelPerformance _$ModelPerformanceFromJson(Map<String, dynamic> json) =>
    ModelPerformance(
      accuracy: (json['accuracy'] as num).toDouble(),
      precision: (json['precision'] as num).toDouble(),
      recall: (json['recall'] as num).toDouble(),
      f1Score: (json['f1Score'] as num).toDouble(),
      auc: (json['auc'] as num).toDouble(),
      classMetrics: (json['classMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      confusionMatrices: (json['confusionMatrices'] as List<dynamic>)
          .map((e) => ConfusionMatrix.fromJson(e as Map<String, dynamic>))
          .toList(),
      rocCurves: (json['rocCurves'] as List<dynamic>)
          .map((e) => ROCCurve.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModelPerformanceToJson(ModelPerformance instance) =>
    <String, dynamic>{
      'accuracy': instance.accuracy,
      'precision': instance.precision,
      'recall': instance.recall,
      'f1Score': instance.f1Score,
      'auc': instance.auc,
      'classMetrics': instance.classMetrics,
      'confusionMatrices': instance.confusionMatrices,
      'rocCurves': instance.rocCurves,
    };

ModelMetadata _$ModelMetadataFromJson(Map<String, dynamic> json) =>
    ModelMetadata(
      algorithm: json['algorithm'] as String,
      hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
      preprocessingSteps: (json['preprocessingSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dataSource: json['dataSource'] as String,
      trainingSamples: (json['trainingSamples'] as num).toInt(),
      validationSamples: (json['validationSamples'] as num).toInt(),
      testSamples: (json['testSamples'] as num).toInt(),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ModelMetadataToJson(ModelMetadata instance) =>
    <String, dynamic>{
      'algorithm': instance.algorithm,
      'hyperparameters': instance.hyperparameters,
      'preprocessingSteps': instance.preprocessingSteps,
      'dataSource': instance.dataSource,
      'trainingSamples': instance.trainingSamples,
      'validationSamples': instance.validationSamples,
      'testSamples': instance.testSamples,
      'additionalInfo': instance.additionalInfo,
    };

ModelFeature _$ModelFeatureFromJson(Map<String, dynamic> json) => ModelFeature(
  name: json['name'] as String,
  type: json['type'] as String,
  description: json['description'] as String,
  importance: (json['importance'] as num).toDouble(),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  statistics: json['statistics'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ModelFeatureToJson(ModelFeature instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'importance': instance.importance,
      'categories': instance.categories,
      'statistics': instance.statistics,
    };

ModelTrainingData _$ModelTrainingDataFromJson(Map<String, dynamic> json) =>
    ModelTrainingData(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sampleCount: (json['sampleCount'] as num).toInt(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      classDistribution: Map<String, int>.from(
        json['classDistribution'] as Map,
      ),
      dataQuality: (json['dataQuality'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ModelTrainingDataToJson(ModelTrainingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'sampleCount': instance.sampleCount,
      'features': instance.features,
      'classDistribution': instance.classDistribution,
      'dataQuality': instance.dataQuality,
    };

RiskMitigation _$RiskMitigationFromJson(Map<String, dynamic> json) =>
    RiskMitigation(
      id: json['id'] as String,
      strategy: json['strategy'] as String,
      description: json['description'] as String,
      effectiveness: (json['effectiveness'] as num).toDouble(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendedAt: DateTime.parse(json['recommendedAt'] as String),
      isImplemented: json['isImplemented'] as bool,
    );

Map<String, dynamic> _$RiskMitigationToJson(RiskMitigation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'strategy': instance.strategy,
      'description': instance.description,
      'effectiveness': instance.effectiveness,
      'actions': instance.actions,
      'recommendedAt': instance.recommendedAt.toIso8601String(),
      'isImplemented': instance.isImplemented,
    };

ConfusionMatrix _$ConfusionMatrixFromJson(
  Map<String, dynamic> json,
) => ConfusionMatrix(
  id: json['id'] as String,
  matrix: (json['matrix'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  labels: (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ConfusionMatrixToJson(ConfusionMatrix instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matrix': instance.matrix,
      'labels': instance.labels,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ROCCurve _$ROCCurveFromJson(Map<String, dynamic> json) => ROCCurve(
  id: json['id'] as String,
  points: (json['points'] as List<dynamic>)
      .map((e) => ROCPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  auc: (json['auc'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ROCCurveToJson(ROCCurve instance) => <String, dynamic>{
  'id': instance.id,
  'points': instance.points,
  'auc': instance.auc,
  'createdAt': instance.createdAt.toIso8601String(),
};

ROCPoint _$ROCPointFromJson(Map<String, dynamic> json) => ROCPoint(
  falsePositiveRate: (json['falsePositiveRate'] as num).toDouble(),
  truePositiveRate: (json['truePositiveRate'] as num).toDouble(),
  threshold: (json['threshold'] as num).toDouble(),
);

Map<String, dynamic> _$ROCPointToJson(ROCPoint instance) => <String, dynamic>{
  'falsePositiveRate': instance.falsePositiveRate,
  'truePositiveRate': instance.truePositiveRate,
  'threshold': instance.threshold,
};

Emotion _$EmotionFromJson(Map<String, dynamic> json) => Emotion(
  type: $enumDecode(_$EmotionTypeEnumMap, json['type']),
  intensity: (json['intensity'] as num).toDouble(),
  confidence: (json['confidence'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$EmotionToJson(Emotion instance) => <String, dynamic>{
  'type': _$EmotionTypeEnumMap[instance.type]!,
  'intensity': instance.intensity,
  'confidence': instance.confidence,
  'timestamp': instance.timestamp.toIso8601String(),
  'triggers': instance.triggers,
};

SentimentEntity _$SentimentEntityFromJson(Map<String, dynamic> json) =>
    SentimentEntity(
      text: json['text'] as String,
      type: json['type'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SentimentEntityToJson(SentimentEntity instance) =>
    <String, dynamic>{
      'text': instance.text,
      'type': instance.type,
      'confidence': instance.confidence,
      'metadata': instance.metadata,
    };

PredictionFeature _$PredictionFeatureFromJson(Map<String, dynamic> json) =>
    PredictionFeature(
      name: json['name'] as String,
      value: json['value'] as String,
      importance: (json['importance'] as num).toDouble(),
      contribution: (json['contribution'] as num).toDouble(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PredictionFeatureToJson(PredictionFeature instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'importance': instance.importance,
      'contribution': instance.contribution,
      'description': instance.description,
    };
