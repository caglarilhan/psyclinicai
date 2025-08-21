import 'package:json_annotation/json_annotation.dart';

part 'biometric_integration_models.g.dart';

@JsonSerializable()
class BiometricData {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final HeartRateData heartRate;
  final BloodPressureData bloodPressure;
  final GalvanicSkinResponse gsr;
  final RespirationData respiration;
  final TemperatureData temperature;
  final List<BiometricAlert> alerts;
  final BiometricStress stressLevel;
  final Map<String, dynamic> metadata;

  const BiometricData({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.heartRate,
    required this.bloodPressure,
    required this.gsr,
    required this.respiration,
    required this.temperature,
    required this.alerts,
    required this.stressLevel,
    required this.metadata,
  });

  factory BiometricData.fromJson(Map<String, dynamic> json) =>
      _$BiometricDataFromJson(json);

  Map<String, dynamic> toJson() => _$BiometricDataToJson(this);

  bool get hasCriticalVitals => _checkCriticalVitals();
  bool get showsStressResponse => stressLevel.overallStress > 0.7;
  bool get needsMedicalAttention => alerts.any((a) => a.severity == AlertSeverity.critical);
}

@JsonSerializable()
class HeartRateData {
  final String id;
  final double currentBPM;
  final double averageBPM;
  final double minBPM;
  final double maxBPM;
  final double heartRateVariability;
  final List<double> bpmHistory;
  final List<HeartRateEvent> events;
  final HeartRateStatus status;
  final List<String> anomalies;

  const HeartRateData({
    required this.id,
    required this.currentBPM,
    required this.averageBPM,
    required this.minBPM,
    required this.maxBPM,
    required this.heartRateVariability,
    required this.bpmHistory,
    required this.events,
    required this.status,
    required this.anomalies,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) =>
      _$HeartRateDataFromJson(json);

  Map<String, dynamic> toJson() => _$HeartRateDataToJson(this);

  bool get isElevated => currentBPM > 100;
  bool get isLow => currentBPM < 60;
  bool get isNormal => currentBPM >= 60 && currentBPM <= 100;
}

@JsonSerializable()
class BloodPressureData {
  final String id;
  final int systolic;
  final int diastolic;
  final int pulse;
  final BloodPressureStatus status;
  final List<BloodPressureReading> history;
  final List<String> riskFactors;
  final List<String> recommendations;

  const BloodPressureData({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.status,
    required this.history,
    required this.riskFactors,
    required this.recommendations,
  });

  factory BloodPressureData.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureDataFromJson(json);

  Map<String, dynamic> toJson() => _$BloodPressureDataToJson(this);

  bool get isHigh => systolic >= 140 || diastolic >= 90;
  bool get isLow => systolic < 90 || diastolic < 60;
  bool get isNormal => systolic < 140 && diastolic < 90 && systolic >= 90 && diastolic >= 60;
}

@JsonSerializable()
class GalvanicSkinResponse {
  final String id;
  final double currentResistance;
  final double baselineResistance;
  final double changeRate;
  final List<double> resistanceHistory;
  final List<GSREvent> events;
  final double stressCorrelation;
  final List<String> interpretations;

  const GalvanicSkinResponse({
    required this.id,
    required this.currentResistance,
    required this.baselineResistance,
    required this.changeRate,
    required this.resistanceHistory,
    required this.events,
    required this.stressCorrelation,
    required this.interpretations,
  });

  factory GalvanicSkinResponse.fromJson(Map<String, dynamic> json) =>
      _$GalvanicSkinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GalvanicSkinResponseToJson(this);

  bool get showsStress => stressCorrelation > 0.7;
  bool get hasSignificantChange => (currentResistance - baselineResistance).abs() > 1000;
}

@JsonSerializable()
class RespirationData {
  final String id;
  final double breathingRate;
  final double tidalVolume;
  final double respiratoryRate;
  final List<double> breathingPattern;
  final List<BreathingEvent> events;
  final RespirationStatus status;
  final List<String> patterns;

  const RespirationData({
    required this.id,
    required this.breathingRate,
    required this.tidalVolume,
    required this.respiratoryRate,
    required this.breathingPattern,
    required this.events,
    required this.status,
    required this.patterns,
  });

  factory RespirationData.fromJson(Map<String, dynamic> json) =>
      _$RespirationDataFromJson(json);

  Map<String, dynamic> toJson() => _$RespirationDataToJson(this);

  bool get isRapid => breathingRate > 20;
  bool get isSlow => breathingRate < 12;
  bool get isNormal => breathingRate >= 12 && breathingRate <= 20;
}

@JsonSerializable()
class TemperatureData {
  final String id;
  final double coreTemperature;
  final double skinTemperature;
  final double ambientTemperature;
  final List<double> temperatureHistory;
  final TemperatureStatus status;
  final List<String> factors;

  const TemperatureData({
    required this.id,
    required this.coreTemperature,
    required this.skinTemperature,
    required this.ambientTemperature,
    required this.temperatureHistory,
    required this.status,
    required this.factors,
  });

  factory TemperatureData.fromJson(Map<String, dynamic> json) =>
      _$TemperatureDataFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureDataToJson(this);

  bool get hasFever => coreTemperature > 37.5;
  bool get isHypothermic => coreTemperature < 35.0;
  bool get isNormal => coreTemperature >= 35.0 && coreTemperature <= 37.5;
}

@JsonSerializable()
class BiometricAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String description;
  final DateTime triggeredAt;
  final List<String> symptoms;
  final List<String> actions;
  final bool isAcknowledged;

  const BiometricAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.triggeredAt,
    required this.symptoms,
    required this.actions,
    required this.isAcknowledged,
  });

  factory BiometricAlert.fromJson(Map<String, dynamic> json) =>
      _$BiometricAlertFromJson(json);

  Map<String, dynamic> toJson() => _$BiometricAlertToJson(this);
}

@JsonSerializable()
class BiometricStress {
  final String id;
  final double overallStress;
  final List<StressComponent> components;
  final List<String> stressSignals;
  final List<String> copingMechanisms;
  final DateTime stressOnset;

  const BiometricStress({
    required this.id,
    required this.overallStress,
    required this.components,
    required this.stressSignals,
    required this.copingMechanisms,
    required this.stressOnset,
  });

  factory BiometricStress.fromJson(Map<String, dynamic> json) =>
      _$BiometricStressFromJson(json);

  Map<String, dynamic> toJson() => _$BiometricStressToJson(this);
}

@JsonSerializable()
class HeartRateEvent {
  final String id;
  final EventType type;
  final DateTime timestamp;
  final double bpm;
  final String description;
  final double significance;

  const HeartRateEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.bpm,
    required this.description,
    required this.significance,
  });

  factory HeartRateEvent.fromJson(Map<String, dynamic> json) =>
      _$HeartRateEventFromJson(json);

  Map<String, dynamic> toJson() => _$HeartRateEventToJson(this);
}

@JsonSerializable()
class BloodPressureReading {
  final String id;
  final DateTime timestamp;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String notes;

  const BloodPressureReading({
    required this.id,
    required this.timestamp,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.notes = '',
  });

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureReadingFromJson(json);

  Map<String, dynamic> toJson() => _$BloodPressureReadingToJson(this);
}

@JsonSerializable()
class GSREvent {
  final String id;
  final EventType type;
  final DateTime timestamp;
  final double resistance;
  final String trigger;
  final double intensity;

  const GSREvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.resistance,
    required this.trigger,
    required this.intensity,
  });

  factory GSREvent.fromJson(Map<String, dynamic> json) =>
      _$GSREventFromJson(json);

  Map<String, dynamic> toJson() => _$GSREventToJson(this);
}

@JsonSerializable()
class BreathingEvent {
  final String id;
  final EventType type;
  final DateTime timestamp;
  final double rate;
  final String pattern;
  final double duration;

  const BreathingEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.rate,
    required this.pattern,
    required this.duration,
  });

  factory BreathingEvent.fromJson(Map<String, dynamic> json) =>
      _$BreathingEventFromJson(json);

  Map<String, dynamic> toJson() => _$BreathingEventToJson(this);
}

@JsonSerializable()
class StressComponent {
  final String id;
  final String name;
  final double value;
  final double weight;
  final String description;

  const StressComponent({
    required this.id,
    required this.name,
    required this.value,
    required this.weight,
    required this.description,
  });

  factory StressComponent.fromJson(Map<String, dynamic> json) =>
      _$StressComponentFromJson(json);

  Map<String, dynamic> toJson() => _$StressComponentToJson(this);
}

// Enums
enum HeartRateStatus {
  normal,
  elevated,
  high,
  veryHigh,
  low,
  veryLow,
  irregular,
}

enum BloodPressureStatus {
  normal,
  elevated,
  stage1Hypertension,
  stage2Hypertension,
  hypertensiveCrisis,
  low,
  veryLow,
}

enum RespirationStatus {
  normal,
  rapid,
  slow,
  irregular,
  shallow,
  deep,
  labored,
}

enum TemperatureStatus {
  normal,
  elevated,
  fever,
  highFever,
  low,
  hypothermic,
}

enum AlertType {
  heartRate,
  bloodPressure,
  respiration,
  temperature,
  stress,
  gsr,
  combined,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum EventType {
  spike,
  drop,
  irregular,
  pattern,
  anomaly,
  stress,
  relaxation,
}

// Helper methods
extension BiometricDataExtension on BiometricData {
  bool _checkCriticalVitals() {
    return heartRate.currentBPM > 120 || 
           heartRate.currentBPM < 50 ||
           bloodPressure.systolic > 180 ||
           bloodPressure.diastolic > 110 ||
           bloodPressure.systolic < 80 ||
           bloodPressure.diastolic < 50 ||
           temperature.coreTemperature > 38.5 ||
           temperature.coreTemperature < 34.0;
  }
}
