import 'package:json_annotation/json_annotation.dart';

part 'ar_vr_models.g.dart';

/// AR/VR Therapy Models for PsyClinicAI
/// Provides immersive therapy experiences using augmented and virtual reality

@JsonSerializable()
class VRTherapySession {
  final String id;
  final String patientId;
  final String therapistId;
  final String therapyType;
  final VRTherapyStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final Map<String, dynamic> environment;
  final List<VRInteraction> interactions;
  final Map<String, double> biometrics;
  final Map<String, dynamic> sessionData;
  final List<String> notes;
  final Map<String, dynamic> metadata;
  final double completionRate;
  final VRTherapyOutcome outcome;

  const VRTherapySession({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.therapyType,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.environment,
    required this.interactions,
    required this.biometrics,
    required this.sessionData,
    required this.notes,
    required this.metadata,
    required this.completionRate,
    required this.outcome,
  });

  factory VRTherapySession.fromJson(Map<String, dynamic> json) => _$VRTherapySessionFromJson(json);
  Map<String, dynamic> toJson() => _$VRTherapySessionToJson(this);

  bool get isActive => status == VRTherapyStatus.active;
  bool get isCompleted => status == VRTherapyStatus.completed;
  Duration get actualDuration {
    if (endTime != null) return endTime!.difference(startTime);
    return DateTime.now().difference(startTime);
  }
  bool get isSuccessful => outcome == VRTherapyOutcome.successful;
  double get progressPercentage => completionRate * 100;
}

enum VRTherapyStatus { 
  scheduled, 
  active, 
  paused, 
  completed, 
  cancelled, 
  failed 
}

enum VRTherapyOutcome { 
  successful, 
  partial, 
  failed, 
  needsFollowUp 
}

@JsonSerializable()
class VREnvironment {
  final String id;
  final String name;
  final String description;
  final VREnvironmentType type;
  final Map<String, dynamic> settings;
  final List<String> assets;
  final Map<String, dynamic> lighting;
  final Map<String, dynamic> audio;
  final Map<String, dynamic> physics;
  final Map<String, dynamic> interactions;
  final List<String> supportedDevices;
  final Map<String, double> performanceMetrics;
  final DateTime createdAt;
  final String createdBy;
  final VREnvironmentStatus status;

  const VREnvironment({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.settings,
    required this.assets,
    required this.lighting,
    required this.audio,
    required this.physics,
    required this.interactions,
    required this.supportedDevices,
    required this.performanceMetrics,
    required this.createdAt,
    required this.createdBy,
    required this.status,
  });

  factory VREnvironment.fromJson(Map<String, dynamic> json) => _$VREnvironmentFromJson(json);
  Map<String, dynamic> toJson() => _$VREnvironmentToJson(this);

  bool get isActive => status == VREnvironmentStatus.active;
  bool get isHighPerformance => performanceMetrics['fps'] != null && performanceMetrics['fps']! > 90;
  bool get supportsMultipleDevices => supportedDevices.length > 1;
}

enum VREnvironmentType { 
  nature, 
  urban, 
  fantasy, 
  therapeutic, 
  educational, 
  social, 
  meditation, 
  exposure, 
  relaxation, 
  cognitive 
}

enum VREnvironmentStatus { 
  development, 
  testing, 
  active, 
  maintenance, 
  deprecated 
}

@JsonSerializable()
class VRInteraction {
  final String id;
  final String name;
  final VRInteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> response;
  final double duration;
  final Map<String, double> metrics;
  final String patientId;
  final Map<String, dynamic> metadata;

  const VRInteraction({
    required this.id,
    required this.name,
    required this.type,
    required this.timestamp,
    required this.parameters,
    required this.response,
    required this.duration,
    required this.metrics,
    required this.patientId,
    required this.metadata,
  });

  factory VRInteraction.fromJson(Map<String, dynamic> json) => _$VRInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$VRInteractionToJson(this);

  bool get isSuccessful => metrics['success_rate'] != null && metrics['success_rate']! > 0.8;
  bool get isQuickResponse => duration < 2.0; // Less than 2 seconds
}

enum VRInteractionType { 
  gaze, 
  gesture, 
  voice, 
  touch, 
  movement, 
  selection, 
  manipulation, 
  navigation, 
  social, 
  therapeutic 
}

@JsonSerializable()
class ARTherapySession {
  final String id;
  final String patientId;
  final String therapistId;
  final String therapyType;
  final ARTherapyStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final Map<String, dynamic> realWorldContext;
  final List<AROverlay> overlays;
  final List<ARInteraction> interactions;
  final Map<String, double> biometrics;
  final Map<String, dynamic> sessionData;
  final List<String> notes;
  final Map<String, dynamic> metadata;
  final double completionRate;
  final ARTherapyOutcome outcome;

  const ARTherapySession({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.therapyType,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.realWorldContext,
    required this.overlays,
    required this.interactions,
    required this.biometrics,
    required this.sessionData,
    required this.notes,
    required this.metadata,
    required this.completionRate,
    required this.outcome,
  });

  factory ARTherapySession.fromJson(Map<String, dynamic> json) => _$ARTherapySessionFromJson(json);
  Map<String, dynamic> toJson() => _$ARTherapySessionToJson(this);

  bool get isActive => status == ARTherapyStatus.active;
  bool get isCompleted => status == ARTherapyStatus.completed;
  Duration get actualDuration {
    if (endTime != null) return endTime!.difference(startTime);
    return DateTime.now().difference(startTime);
  }
  bool get isSuccessful => outcome == ARTherapyOutcome.successful;
  int get totalOverlays => overlays.length;
  int get activeOverlays => overlays.where((overlay) => overlay.isActive).length;
}

enum ARTherapyStatus { 
  scheduled, 
  active, 
  paused, 
  completed, 
  cancelled, 
  failed 
}

enum ARTherapyOutcome { 
  successful, 
  partial, 
  failed, 
  needsFollowUp 
}

@JsonSerializable()
class AROverlay {
  final String id;
  final String name;
  final AROverlayType type;
  final Map<String, dynamic> content;
  final Map<String, dynamic> position;
  final Map<String, dynamic> size;
  final Map<String, dynamic> style;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final Map<String, dynamic> metadata;
  final List<String> interactions;

  const AROverlay({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    required this.position,
    required this.size,
    required this.style,
    required this.isActive,
    required this.createdAt,
    this.activatedAt,
    required this.metadata,
    required this.interactions,
  });

  factory AROverlay.fromJson(Map<String, dynamic> json) => _$AROverlayFromJson(json);
  Map<String, dynamic> toJson() => _$AROverlayToJson(this);

  bool get isVisible => isActive;
  Duration get activeDuration {
    if (activatedAt == null) return Duration.zero;
    return DateTime.now().difference(activatedAt!);
  }
}

enum AROverlayType { 
  text, 
  image, 
  video, 
  model3D, 
  animation, 
  instruction, 
  feedback, 
  guidance, 
  visualization, 
  interactive 
}

@JsonSerializable()
class ARInteraction {
  final String id;
  final String name;
  final ARInteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> response;
  final double duration;
  final Map<String, double> metrics;
  final String patientId;
  final Map<String, dynamic> metadata;

  const ARInteraction({
    required this.id,
    required this.name,
    required this.type,
    required this.timestamp,
    required this.parameters,
    required this.response,
    required this.duration,
    required this.metrics,
    required this.patientId,
    required this.metadata,
  });

  factory ARInteraction.fromJson(Map<String, dynamic> json) => _$ARInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$ARInteractionToJson(this);

  bool get isSuccessful => metrics['success_rate'] != null && metrics['success_rate']! > 0.8;
  bool get isQuickResponse => duration < 1.5; // Less than 1.5 seconds
}

enum ARInteractionType { 
  touch, 
  gesture, 
  voice, 
  gaze, 
  movement, 
  selection, 
  manipulation, 
  navigation, 
  social, 
  therapeutic 
}

@JsonSerializable()
class VRDevice {
  final String id;
  final String name;
  final VRDeviceType type;
  final String manufacturer;
  final String model;
  final Map<String, dynamic> specifications;
  final List<String> supportedFeatures;
  final Map<String, double> performanceMetrics;
  final VRDeviceStatus status;
  final DateTime lastCalibration;
  final Map<String, dynamic> metadata;

  const VRDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.specifications,
    required this.supportedFeatures,
    required this.performanceMetrics,
    required this.status,
    required this.lastCalibration,
    required this.metadata,
  });

  factory VRDevice.fromJson(Map<String, dynamic> json) => _$VRDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$VRDeviceToJson(this);

  bool get isAvailable => status == VRDeviceStatus.available;
  bool get needsCalibration => DateTime.now().difference(lastCalibration).inDays > 30;
  bool get isHighResolution => specifications['resolution'] != null && specifications['resolution']['width'] > 2000;
  bool get isHighRefreshRate => specifications['refresh_rate'] != null && specifications['refresh_rate'] > 90;
}

enum VRDeviceType { 
  headset, 
  controller, 
  tracker, 
  haptic, 
  audio, 
  mixed 
}

enum VRDeviceStatus { 
  offline, 
  available, 
  inUse, 
  maintenance, 
  error, 
  calibrating 
}

@JsonSerializable()
class ARDevice {
  final String id;
  final String name;
  final ARDeviceType type;
  final String manufacturer;
  final String model;
  final Map<String, dynamic> specifications;
  final List<String> supportedFeatures;
  final Map<String, double> performanceMetrics;
  final ARDeviceStatus status;
  final DateTime lastCalibration;
  final Map<String, dynamic> metadata;

  const ARDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.specifications,
    required this.supportedFeatures,
    required this.performanceMetrics,
    required this.status,
    required this.lastCalibration,
    required this.metadata,
  });

  factory ARDevice.fromJson(Map<String, dynamic> json) => _$ARDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$ARDeviceToJson(this);

  bool get isAvailable => status == ARDeviceStatus.available;
  bool get needsCalibration => DateTime.now().difference(lastCalibration).inDays > 30;
  bool get isHighAccuracy => specifications['accuracy'] != null && specifications['accuracy'] < 0.01;
  bool get supportsSLAM => supportedFeatures.contains('slam');
}

enum ARDeviceType { 
  glasses, 
  phone, 
  tablet, 
  headset, 
  projector, 
  mixed 
}

enum ARDeviceStatus { 
  offline, 
  available, 
  inUse, 
  maintenance, 
  error, 
  calibrating 
}

@JsonSerializable()
class VRTherapyProgram {
  final String id;
  final String name;
  final String description;
  final VRTherapyType type;
  final List<String> objectives;
  final List<String> targetConditions;
  final Map<String, dynamic> parameters;
  final List<VREnvironment> environments;
  final List<String> requiredDevices;
  final Map<String, double> effectivenessMetrics;
  final DateTime createdAt;
  final String createdBy;
  final VRTherapyProgramStatus status;
  final List<String> certifications;
  final Map<String, dynamic> metadata;

  const VRTherapyProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.objectives,
    required this.targetConditions,
    required this.parameters,
    required this.environments,
    required this.requiredDevices,
    required this.effectivenessMetrics,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    required this.certifications,
    required this.metadata,
  });

  factory VRTherapyProgram.fromJson(Map<String, dynamic> json) => _$VRTherapyProgramFromJson(json);
  Map<String, dynamic> toJson() => _$VRTherapyProgramToJson(this);

  bool get isActive => status == VRTherapyProgramStatus.active;
  bool get isCertified => certifications.isNotEmpty;
  double get effectivenessScore => effectivenessMetrics['overall_effectiveness'] ?? 0.0;
  bool get isHighEffectiveness => effectivenessScore > 0.8;
}

enum VRTherapyType { 
  exposure, 
  cognitive, 
  behavioral, 
  relaxation, 
  mindfulness, 
  social, 
  physical, 
  educational, 
  assessment, 
  rehabilitation 
}

enum VRTherapyProgramStatus { 
  development, 
  testing, 
  validation, 
  active, 
  maintenance, 
  deprecated 
}

@JsonSerializable()
class ARTherapyProgram {
  final String id;
  final String name;
  final String description;
  final ARTherapyType type;
  final List<String> objectives;
  final List<String> targetConditions;
  final Map<String, dynamic> parameters;
  final List<AROverlay> defaultOverlays;
  final List<String> requiredDevices;
  final Map<String, double> effectivenessMetrics;
  final DateTime createdAt;
  final String createdBy;
  final ARTherapyProgramStatus status;
  final List<String> certifications;
  final Map<String, dynamic> metadata;

  const ARTherapyProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.objectives,
    required this.targetConditions,
    required this.parameters,
    required this.defaultOverlays,
    required this.requiredDevices,
    required this.effectivenessMetrics,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    required this.certifications,
    required this.metadata,
  });

  factory ARTherapyProgram.fromJson(Map<String, dynamic> json) => _$ARTherapyProgramFromJson(json);
  Map<String, dynamic> toJson() => _$ARTherapyProgramToJson(this);

  bool get isActive => status == ARTherapyProgramStatus.active;
  bool get isCertified => certifications.isNotEmpty;
  double get effectivenessScore => effectivenessMetrics['overall_effectiveness'] ?? 0.0;
  bool get isHighEffectiveness => effectivenessScore > 0.8;
}

enum ARTherapyType { 
  guidance, 
  instruction, 
  feedback, 
  visualization, 
  monitoring, 
  assistance, 
  education, 
  assessment, 
  rehabilitation, 
  support 
}

enum ARTherapyProgramStatus { 
  development, 
  testing, 
  validation, 
  active, 
  maintenance, 
  deprecated 
}

@JsonSerializable()
class VRARPerformanceReport {
  final String id;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, VRTherapySession> vrSessions;
  final Map<String, ARTherapySession> arSessions;
  final Map<String, VRDevice> vrDevices;
  final Map<String, ARDevice> arDevices;
  final Map<String, VRTherapyProgram> vrPrograms;
  final Map<String, ARTherapyProgram> arPrograms;
  final Map<String, double> systemMetrics;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const VRARPerformanceReport({
    required this.id,
    required this.generatedAt,
    required this.generatedBy,
    required this.vrSessions,
    required this.arSessions,
    required this.vrDevices,
    required this.arDevices,
    required this.vrPrograms,
    required this.arPrograms,
    required this.systemMetrics,
    required this.recommendations,
    required this.metadata,
  });

  factory VRARPerformanceReport.fromJson(Map<String, dynamic> json) => _$VRARPerformanceReportFromJson(json);
  Map<String, dynamic> toJson() => _$VRARPerformanceReportToJson(this);

  int get totalVRSessions => vrSessions.length;
  int get totalARSessions => arSessions.length;
  int get totalVRDevices => vrDevices.length;
  int get totalARDevices => arDevices.length;
  int get totalVRPrograms => vrPrograms.length;
  int get totalARPrograms => arPrograms.length;
  double get overallSystemHealth => systemMetrics['system_health'] ?? 0.0;
  bool get systemNeedsAttention => overallSystemHealth < 0.7;
}
