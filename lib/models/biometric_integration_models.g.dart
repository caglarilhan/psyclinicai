// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_integration_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiometricData _$BiometricDataFromJson(Map<String, dynamic> json) =>
    BiometricData(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: HeartRateData.fromJson(
        json['heartRate'] as Map<String, dynamic>,
      ),
      bloodPressure: BloodPressureData.fromJson(
        json['bloodPressure'] as Map<String, dynamic>,
      ),
      gsr: GalvanicSkinResponse.fromJson(json['gsr'] as Map<String, dynamic>),
      respiration: RespirationData.fromJson(
        json['respiration'] as Map<String, dynamic>,
      ),
      temperature: TemperatureData.fromJson(
        json['temperature'] as Map<String, dynamic>,
      ),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => BiometricAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      stressLevel: BiometricStress.fromJson(
        json['stressLevel'] as Map<String, dynamic>,
      ),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$BiometricDataToJson(BiometricData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'timestamp': instance.timestamp.toIso8601String(),
      'heartRate': instance.heartRate,
      'bloodPressure': instance.bloodPressure,
      'gsr': instance.gsr,
      'respiration': instance.respiration,
      'temperature': instance.temperature,
      'alerts': instance.alerts,
      'stressLevel': instance.stressLevel,
      'metadata': instance.metadata,
    };

HeartRateData _$HeartRateDataFromJson(Map<String, dynamic> json) =>
    HeartRateData(
      id: json['id'] as String,
      currentBPM: (json['currentBPM'] as num).toDouble(),
      averageBPM: (json['averageBPM'] as num).toDouble(),
      minBPM: (json['minBPM'] as num).toDouble(),
      maxBPM: (json['maxBPM'] as num).toDouble(),
      heartRateVariability: (json['heartRateVariability'] as num).toDouble(),
      bpmHistory: (json['bpmHistory'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => HeartRateEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$HeartRateStatusEnumMap, json['status']),
      anomalies: (json['anomalies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HeartRateDataToJson(HeartRateData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentBPM': instance.currentBPM,
      'averageBPM': instance.averageBPM,
      'minBPM': instance.minBPM,
      'maxBPM': instance.maxBPM,
      'heartRateVariability': instance.heartRateVariability,
      'bpmHistory': instance.bpmHistory,
      'events': instance.events,
      'status': _$HeartRateStatusEnumMap[instance.status]!,
      'anomalies': instance.anomalies,
    };

const _$HeartRateStatusEnumMap = {
  HeartRateStatus.normal: 'normal',
  HeartRateStatus.elevated: 'elevated',
  HeartRateStatus.high: 'high',
  HeartRateStatus.veryHigh: 'veryHigh',
  HeartRateStatus.low: 'low',
  HeartRateStatus.veryLow: 'veryLow',
  HeartRateStatus.irregular: 'irregular',
};

BloodPressureData _$BloodPressureDataFromJson(Map<String, dynamic> json) =>
    BloodPressureData(
      id: json['id'] as String,
      systolic: (json['systolic'] as num).toInt(),
      diastolic: (json['diastolic'] as num).toInt(),
      pulse: (json['pulse'] as num).toInt(),
      status: $enumDecode(_$BloodPressureStatusEnumMap, json['status']),
      history: (json['history'] as List<dynamic>)
          .map((e) => BloodPressureReading.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BloodPressureDataToJson(BloodPressureData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'systolic': instance.systolic,
      'diastolic': instance.diastolic,
      'pulse': instance.pulse,
      'status': _$BloodPressureStatusEnumMap[instance.status]!,
      'history': instance.history,
      'riskFactors': instance.riskFactors,
      'recommendations': instance.recommendations,
    };

const _$BloodPressureStatusEnumMap = {
  BloodPressureStatus.normal: 'normal',
  BloodPressureStatus.elevated: 'elevated',
  BloodPressureStatus.stage1Hypertension: 'stage1Hypertension',
  BloodPressureStatus.stage2Hypertension: 'stage2Hypertension',
  BloodPressureStatus.hypertensiveCrisis: 'hypertensiveCrisis',
  BloodPressureStatus.low: 'low',
  BloodPressureStatus.veryLow: 'veryLow',
};

GalvanicSkinResponse _$GalvanicSkinResponseFromJson(
  Map<String, dynamic> json,
) => GalvanicSkinResponse(
  id: json['id'] as String,
  currentResistance: (json['currentResistance'] as num).toDouble(),
  baselineResistance: (json['baselineResistance'] as num).toDouble(),
  changeRate: (json['changeRate'] as num).toDouble(),
  resistanceHistory: (json['resistanceHistory'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  events: (json['events'] as List<dynamic>)
      .map((e) => GSREvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  stressCorrelation: (json['stressCorrelation'] as num).toDouble(),
  interpretations: (json['interpretations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GalvanicSkinResponseToJson(
  GalvanicSkinResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'currentResistance': instance.currentResistance,
  'baselineResistance': instance.baselineResistance,
  'changeRate': instance.changeRate,
  'resistanceHistory': instance.resistanceHistory,
  'events': instance.events,
  'stressCorrelation': instance.stressCorrelation,
  'interpretations': instance.interpretations,
};

RespirationData _$RespirationDataFromJson(Map<String, dynamic> json) =>
    RespirationData(
      id: json['id'] as String,
      breathingRate: (json['breathingRate'] as num).toDouble(),
      tidalVolume: (json['tidalVolume'] as num).toDouble(),
      respiratoryRate: (json['respiratoryRate'] as num).toDouble(),
      breathingPattern: (json['breathingPattern'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => BreathingEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$RespirationStatusEnumMap, json['status']),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RespirationDataToJson(RespirationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'breathingRate': instance.breathingRate,
      'tidalVolume': instance.tidalVolume,
      'respiratoryRate': instance.respiratoryRate,
      'breathingPattern': instance.breathingPattern,
      'events': instance.events,
      'status': _$RespirationStatusEnumMap[instance.status]!,
      'patterns': instance.patterns,
    };

const _$RespirationStatusEnumMap = {
  RespirationStatus.normal: 'normal',
  RespirationStatus.rapid: 'rapid',
  RespirationStatus.slow: 'slow',
  RespirationStatus.irregular: 'irregular',
  RespirationStatus.shallow: 'shallow',
  RespirationStatus.deep: 'deep',
  RespirationStatus.labored: 'labored',
};

TemperatureData _$TemperatureDataFromJson(Map<String, dynamic> json) =>
    TemperatureData(
      id: json['id'] as String,
      coreTemperature: (json['coreTemperature'] as num).toDouble(),
      skinTemperature: (json['skinTemperature'] as num).toDouble(),
      ambientTemperature: (json['ambientTemperature'] as num).toDouble(),
      temperatureHistory: (json['temperatureHistory'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      status: $enumDecode(_$TemperatureStatusEnumMap, json['status']),
      factors: (json['factors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TemperatureDataToJson(TemperatureData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coreTemperature': instance.coreTemperature,
      'skinTemperature': instance.skinTemperature,
      'ambientTemperature': instance.ambientTemperature,
      'temperatureHistory': instance.temperatureHistory,
      'status': _$TemperatureStatusEnumMap[instance.status]!,
      'factors': instance.factors,
    };

const _$TemperatureStatusEnumMap = {
  TemperatureStatus.normal: 'normal',
  TemperatureStatus.elevated: 'elevated',
  TemperatureStatus.fever: 'fever',
  TemperatureStatus.highFever: 'highFever',
  TemperatureStatus.low: 'low',
  TemperatureStatus.hypothermic: 'hypothermic',
};

BiometricAlert _$BiometricAlertFromJson(Map<String, dynamic> json) =>
    BiometricAlert(
      id: json['id'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      description: json['description'] as String,
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isAcknowledged: json['isAcknowledged'] as bool,
    );

Map<String, dynamic> _$BiometricAlertToJson(BiometricAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'triggeredAt': instance.triggeredAt.toIso8601String(),
      'symptoms': instance.symptoms,
      'actions': instance.actions,
      'isAcknowledged': instance.isAcknowledged,
    };

const _$AlertTypeEnumMap = {
  AlertType.heartRate: 'heartRate',
  AlertType.bloodPressure: 'bloodPressure',
  AlertType.respiration: 'respiration',
  AlertType.temperature: 'temperature',
  AlertType.stress: 'stress',
  AlertType.gsr: 'gsr',
  AlertType.combined: 'combined',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

BiometricStress _$BiometricStressFromJson(Map<String, dynamic> json) =>
    BiometricStress(
      id: json['id'] as String,
      overallStress: (json['overallStress'] as num).toDouble(),
      components: (json['components'] as List<dynamic>)
          .map((e) => StressComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      stressSignals: (json['stressSignals'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      copingMechanisms: (json['copingMechanisms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stressOnset: DateTime.parse(json['stressOnset'] as String),
    );

Map<String, dynamic> _$BiometricStressToJson(BiometricStress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'overallStress': instance.overallStress,
      'components': instance.components,
      'stressSignals': instance.stressSignals,
      'copingMechanisms': instance.copingMechanisms,
      'stressOnset': instance.stressOnset.toIso8601String(),
    };

HeartRateEvent _$HeartRateEventFromJson(Map<String, dynamic> json) =>
    HeartRateEvent(
      id: json['id'] as String,
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      bpm: (json['bpm'] as num).toDouble(),
      description: json['description'] as String,
      significance: (json['significance'] as num).toDouble(),
    );

Map<String, dynamic> _$HeartRateEventToJson(HeartRateEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'bpm': instance.bpm,
      'description': instance.description,
      'significance': instance.significance,
    };

const _$EventTypeEnumMap = {
  EventType.spike: 'spike',
  EventType.drop: 'drop',
  EventType.irregular: 'irregular',
  EventType.pattern: 'pattern',
  EventType.anomaly: 'anomaly',
  EventType.stress: 'stress',
  EventType.relaxation: 'relaxation',
};

BloodPressureReading _$BloodPressureReadingFromJson(
  Map<String, dynamic> json,
) => BloodPressureReading(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  systolic: (json['systolic'] as num).toInt(),
  diastolic: (json['diastolic'] as num).toInt(),
  pulse: (json['pulse'] as num).toInt(),
  notes: json['notes'] as String? ?? '',
);

Map<String, dynamic> _$BloodPressureReadingToJson(
  BloodPressureReading instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'systolic': instance.systolic,
  'diastolic': instance.diastolic,
  'pulse': instance.pulse,
  'notes': instance.notes,
};

GSREvent _$GSREventFromJson(Map<String, dynamic> json) => GSREvent(
  id: json['id'] as String,
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  resistance: (json['resistance'] as num).toDouble(),
  trigger: json['trigger'] as String,
  intensity: (json['intensity'] as num).toDouble(),
);

Map<String, dynamic> _$GSREventToJson(GSREvent instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$EventTypeEnumMap[instance.type]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'resistance': instance.resistance,
  'trigger': instance.trigger,
  'intensity': instance.intensity,
};

BreathingEvent _$BreathingEventFromJson(Map<String, dynamic> json) =>
    BreathingEvent(
      id: json['id'] as String,
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      rate: (json['rate'] as num).toDouble(),
      pattern: json['pattern'] as String,
      duration: (json['duration'] as num).toDouble(),
    );

Map<String, dynamic> _$BreathingEventToJson(BreathingEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'rate': instance.rate,
      'pattern': instance.pattern,
      'duration': instance.duration,
    };

StressComponent _$StressComponentFromJson(Map<String, dynamic> json) =>
    StressComponent(
      id: json['id'] as String,
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$StressComponentToJson(StressComponent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'weight': instance.weight,
      'description': instance.description,
    };
