// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ar_vr_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VRTherapySession _$VRTherapySessionFromJson(Map<String, dynamic> json) =>
    VRTherapySession(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      therapistId: json['therapistId'] as String,
      therapyType: json['therapyType'] as String,
      status: $enumDecode(_$VRTherapyStatusEnumMap, json['status']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      environment: json['environment'] as Map<String, dynamic>,
      interactions: (json['interactions'] as List<dynamic>)
          .map((e) => VRInteraction.fromJson(e as Map<String, dynamic>))
          .toList(),
      biometrics: (json['biometrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      sessionData: json['sessionData'] as Map<String, dynamic>,
      notes: (json['notes'] as List<dynamic>).map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      completionRate: (json['completionRate'] as num).toDouble(),
      outcome: $enumDecode(_$VRTherapyOutcomeEnumMap, json['outcome']),
    );

Map<String, dynamic> _$VRTherapySessionToJson(VRTherapySession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'therapistId': instance.therapistId,
      'therapyType': instance.therapyType,
      'status': _$VRTherapyStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'environment': instance.environment,
      'interactions': instance.interactions,
      'biometrics': instance.biometrics,
      'sessionData': instance.sessionData,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'completionRate': instance.completionRate,
      'outcome': _$VRTherapyOutcomeEnumMap[instance.outcome]!,
    };

const _$VRTherapyStatusEnumMap = {
  VRTherapyStatus.scheduled: 'scheduled',
  VRTherapyStatus.active: 'active',
  VRTherapyStatus.paused: 'paused',
  VRTherapyStatus.completed: 'completed',
  VRTherapyStatus.cancelled: 'cancelled',
  VRTherapyStatus.failed: 'failed',
};

const _$VRTherapyOutcomeEnumMap = {
  VRTherapyOutcome.successful: 'successful',
  VRTherapyOutcome.partial: 'partial',
  VRTherapyOutcome.failed: 'failed',
  VRTherapyOutcome.needsFollowUp: 'needsFollowUp',
};

VREnvironment _$VREnvironmentFromJson(Map<String, dynamic> json) =>
    VREnvironment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$VREnvironmentTypeEnumMap, json['type']),
      settings: json['settings'] as Map<String, dynamic>,
      assets: (json['assets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lighting: json['lighting'] as Map<String, dynamic>,
      audio: json['audio'] as Map<String, dynamic>,
      physics: json['physics'] as Map<String, dynamic>,
      interactions: json['interactions'] as Map<String, dynamic>,
      supportedDevices: (json['supportedDevices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      status: $enumDecode(_$VREnvironmentStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$VREnvironmentToJson(VREnvironment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$VREnvironmentTypeEnumMap[instance.type]!,
      'settings': instance.settings,
      'assets': instance.assets,
      'lighting': instance.lighting,
      'audio': instance.audio,
      'physics': instance.physics,
      'interactions': instance.interactions,
      'supportedDevices': instance.supportedDevices,
      'performanceMetrics': instance.performanceMetrics,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'status': _$VREnvironmentStatusEnumMap[instance.status]!,
    };

const _$VREnvironmentTypeEnumMap = {
  VREnvironmentType.nature: 'nature',
  VREnvironmentType.urban: 'urban',
  VREnvironmentType.fantasy: 'fantasy',
  VREnvironmentType.therapeutic: 'therapeutic',
  VREnvironmentType.educational: 'educational',
  VREnvironmentType.social: 'social',
  VREnvironmentType.meditation: 'meditation',
  VREnvironmentType.exposure: 'exposure',
  VREnvironmentType.relaxation: 'relaxation',
  VREnvironmentType.cognitive: 'cognitive',
};

const _$VREnvironmentStatusEnumMap = {
  VREnvironmentStatus.development: 'development',
  VREnvironmentStatus.testing: 'testing',
  VREnvironmentStatus.active: 'active',
  VREnvironmentStatus.maintenance: 'maintenance',
  VREnvironmentStatus.deprecated: 'deprecated',
};

VRInteraction _$VRInteractionFromJson(Map<String, dynamic> json) =>
    VRInteraction(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$VRInteractionTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      parameters: json['parameters'] as Map<String, dynamic>,
      response: json['response'] as Map<String, dynamic>,
      duration: (json['duration'] as num).toDouble(),
      metrics: (json['metrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      patientId: json['patientId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$VRInteractionToJson(VRInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$VRInteractionTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'parameters': instance.parameters,
      'response': instance.response,
      'duration': instance.duration,
      'metrics': instance.metrics,
      'patientId': instance.patientId,
      'metadata': instance.metadata,
    };

const _$VRInteractionTypeEnumMap = {
  VRInteractionType.gaze: 'gaze',
  VRInteractionType.gesture: 'gesture',
  VRInteractionType.voice: 'voice',
  VRInteractionType.touch: 'touch',
  VRInteractionType.movement: 'movement',
  VRInteractionType.selection: 'selection',
  VRInteractionType.manipulation: 'manipulation',
  VRInteractionType.navigation: 'navigation',
  VRInteractionType.social: 'social',
  VRInteractionType.therapeutic: 'therapeutic',
};

ARTherapySession _$ARTherapySessionFromJson(Map<String, dynamic> json) =>
    ARTherapySession(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      therapistId: json['therapistId'] as String,
      therapyType: json['therapyType'] as String,
      status: $enumDecode(_$ARTherapyStatusEnumMap, json['status']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      realWorldContext: json['realWorldContext'] as Map<String, dynamic>,
      overlays: (json['overlays'] as List<dynamic>)
          .map((e) => AROverlay.fromJson(e as Map<String, dynamic>))
          .toList(),
      interactions: (json['interactions'] as List<dynamic>)
          .map((e) => ARInteraction.fromJson(e as Map<String, dynamic>))
          .toList(),
      biometrics: (json['biometrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      sessionData: json['sessionData'] as Map<String, dynamic>,
      notes: (json['notes'] as List<dynamic>).map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      completionRate: (json['completionRate'] as num).toDouble(),
      outcome: $enumDecode(_$ARTherapyOutcomeEnumMap, json['outcome']),
    );

Map<String, dynamic> _$ARTherapySessionToJson(ARTherapySession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'therapistId': instance.therapistId,
      'therapyType': instance.therapyType,
      'status': _$ARTherapyStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'realWorldContext': instance.realWorldContext,
      'overlays': instance.overlays,
      'interactions': instance.interactions,
      'biometrics': instance.biometrics,
      'sessionData': instance.sessionData,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'completionRate': instance.completionRate,
      'outcome': _$ARTherapyOutcomeEnumMap[instance.outcome]!,
    };

const _$ARTherapyStatusEnumMap = {
  ARTherapyStatus.scheduled: 'scheduled',
  ARTherapyStatus.active: 'active',
  ARTherapyStatus.paused: 'paused',
  ARTherapyStatus.completed: 'completed',
  ARTherapyStatus.cancelled: 'cancelled',
  ARTherapyStatus.failed: 'failed',
};

const _$ARTherapyOutcomeEnumMap = {
  ARTherapyOutcome.successful: 'successful',
  ARTherapyOutcome.partial: 'partial',
  ARTherapyOutcome.failed: 'failed',
  ARTherapyOutcome.needsFollowUp: 'needsFollowUp',
};

AROverlay _$AROverlayFromJson(Map<String, dynamic> json) => AROverlay(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$AROverlayTypeEnumMap, json['type']),
  content: json['content'] as Map<String, dynamic>,
  position: json['position'] as Map<String, dynamic>,
  size: json['size'] as Map<String, dynamic>,
  style: json['style'] as Map<String, dynamic>,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  activatedAt: json['activatedAt'] == null
      ? null
      : DateTime.parse(json['activatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AROverlayToJson(AROverlay instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$AROverlayTypeEnumMap[instance.type]!,
  'content': instance.content,
  'position': instance.position,
  'size': instance.size,
  'style': instance.style,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'activatedAt': instance.activatedAt?.toIso8601String(),
  'metadata': instance.metadata,
  'interactions': instance.interactions,
};

const _$AROverlayTypeEnumMap = {
  AROverlayType.text: 'text',
  AROverlayType.image: 'image',
  AROverlayType.video: 'video',
  AROverlayType.model3D: 'model3D',
  AROverlayType.animation: 'animation',
  AROverlayType.instruction: 'instruction',
  AROverlayType.feedback: 'feedback',
  AROverlayType.guidance: 'guidance',
  AROverlayType.visualization: 'visualization',
  AROverlayType.interactive: 'interactive',
};

ARInteraction _$ARInteractionFromJson(Map<String, dynamic> json) =>
    ARInteraction(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ARInteractionTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      parameters: json['parameters'] as Map<String, dynamic>,
      response: json['response'] as Map<String, dynamic>,
      duration: (json['duration'] as num).toDouble(),
      metrics: (json['metrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      patientId: json['patientId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ARInteractionToJson(ARInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ARInteractionTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'parameters': instance.parameters,
      'response': instance.response,
      'duration': instance.duration,
      'metrics': instance.metrics,
      'patientId': instance.patientId,
      'metadata': instance.metadata,
    };

const _$ARInteractionTypeEnumMap = {
  ARInteractionType.touch: 'touch',
  ARInteractionType.gesture: 'gesture',
  ARInteractionType.voice: 'voice',
  ARInteractionType.gaze: 'gaze',
  ARInteractionType.movement: 'movement',
  ARInteractionType.selection: 'selection',
  ARInteractionType.manipulation: 'manipulation',
  ARInteractionType.navigation: 'navigation',
  ARInteractionType.social: 'social',
  ARInteractionType.therapeutic: 'therapeutic',
};

VRDevice _$VRDeviceFromJson(Map<String, dynamic> json) => VRDevice(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$VRDeviceTypeEnumMap, json['type']),
  manufacturer: json['manufacturer'] as String,
  model: json['model'] as String,
  specifications: json['specifications'] as Map<String, dynamic>,
  supportedFeatures: (json['supportedFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  status: $enumDecode(_$VRDeviceStatusEnumMap, json['status']),
  lastCalibration: DateTime.parse(json['lastCalibration'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$VRDeviceToJson(VRDevice instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$VRDeviceTypeEnumMap[instance.type]!,
  'manufacturer': instance.manufacturer,
  'model': instance.model,
  'specifications': instance.specifications,
  'supportedFeatures': instance.supportedFeatures,
  'performanceMetrics': instance.performanceMetrics,
  'status': _$VRDeviceStatusEnumMap[instance.status]!,
  'lastCalibration': instance.lastCalibration.toIso8601String(),
  'metadata': instance.metadata,
};

const _$VRDeviceTypeEnumMap = {
  VRDeviceType.headset: 'headset',
  VRDeviceType.controller: 'controller',
  VRDeviceType.tracker: 'tracker',
  VRDeviceType.haptic: 'haptic',
  VRDeviceType.audio: 'audio',
  VRDeviceType.mixed: 'mixed',
};

const _$VRDeviceStatusEnumMap = {
  VRDeviceStatus.offline: 'offline',
  VRDeviceStatus.available: 'available',
  VRDeviceStatus.inUse: 'inUse',
  VRDeviceStatus.maintenance: 'maintenance',
  VRDeviceStatus.error: 'error',
  VRDeviceStatus.calibrating: 'calibrating',
};

ARDevice _$ARDeviceFromJson(Map<String, dynamic> json) => ARDevice(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$ARDeviceTypeEnumMap, json['type']),
  manufacturer: json['manufacturer'] as String,
  model: json['model'] as String,
  specifications: json['specifications'] as Map<String, dynamic>,
  supportedFeatures: (json['supportedFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  status: $enumDecode(_$ARDeviceStatusEnumMap, json['status']),
  lastCalibration: DateTime.parse(json['lastCalibration'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ARDeviceToJson(ARDevice instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$ARDeviceTypeEnumMap[instance.type]!,
  'manufacturer': instance.manufacturer,
  'model': instance.model,
  'specifications': instance.specifications,
  'supportedFeatures': instance.supportedFeatures,
  'performanceMetrics': instance.performanceMetrics,
  'status': _$ARDeviceStatusEnumMap[instance.status]!,
  'lastCalibration': instance.lastCalibration.toIso8601String(),
  'metadata': instance.metadata,
};

const _$ARDeviceTypeEnumMap = {
  ARDeviceType.glasses: 'glasses',
  ARDeviceType.phone: 'phone',
  ARDeviceType.tablet: 'tablet',
  ARDeviceType.headset: 'headset',
  ARDeviceType.projector: 'projector',
  ARDeviceType.mixed: 'mixed',
};

const _$ARDeviceStatusEnumMap = {
  ARDeviceStatus.offline: 'offline',
  ARDeviceStatus.available: 'available',
  ARDeviceStatus.inUse: 'inUse',
  ARDeviceStatus.maintenance: 'maintenance',
  ARDeviceStatus.error: 'error',
  ARDeviceStatus.calibrating: 'calibrating',
};

VRTherapyProgram _$VRTherapyProgramFromJson(Map<String, dynamic> json) =>
    VRTherapyProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$VRTherapyTypeEnumMap, json['type']),
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      targetConditions: (json['targetConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
      environments: (json['environments'] as List<dynamic>)
          .map((e) => VREnvironment.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredDevices: (json['requiredDevices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      effectivenessMetrics:
          (json['effectivenessMetrics'] as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      status: $enumDecode(_$VRTherapyProgramStatusEnumMap, json['status']),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$VRTherapyProgramToJson(VRTherapyProgram instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$VRTherapyTypeEnumMap[instance.type]!,
      'objectives': instance.objectives,
      'targetConditions': instance.targetConditions,
      'parameters': instance.parameters,
      'environments': instance.environments,
      'requiredDevices': instance.requiredDevices,
      'effectivenessMetrics': instance.effectivenessMetrics,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'status': _$VRTherapyProgramStatusEnumMap[instance.status]!,
      'certifications': instance.certifications,
      'metadata': instance.metadata,
    };

const _$VRTherapyTypeEnumMap = {
  VRTherapyType.exposure: 'exposure',
  VRTherapyType.cognitive: 'cognitive',
  VRTherapyType.behavioral: 'behavioral',
  VRTherapyType.relaxation: 'relaxation',
  VRTherapyType.mindfulness: 'mindfulness',
  VRTherapyType.social: 'social',
  VRTherapyType.physical: 'physical',
  VRTherapyType.educational: 'educational',
  VRTherapyType.assessment: 'assessment',
  VRTherapyType.rehabilitation: 'rehabilitation',
};

const _$VRTherapyProgramStatusEnumMap = {
  VRTherapyProgramStatus.development: 'development',
  VRTherapyProgramStatus.testing: 'testing',
  VRTherapyProgramStatus.validation: 'validation',
  VRTherapyProgramStatus.active: 'active',
  VRTherapyProgramStatus.maintenance: 'maintenance',
  VRTherapyProgramStatus.deprecated: 'deprecated',
};

ARTherapyProgram _$ARTherapyProgramFromJson(Map<String, dynamic> json) =>
    ARTherapyProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ARTherapyTypeEnumMap, json['type']),
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      targetConditions: (json['targetConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
      defaultOverlays: (json['defaultOverlays'] as List<dynamic>)
          .map((e) => AROverlay.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredDevices: (json['requiredDevices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      effectivenessMetrics:
          (json['effectivenessMetrics'] as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      status: $enumDecode(_$ARTherapyProgramStatusEnumMap, json['status']),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ARTherapyProgramToJson(ARTherapyProgram instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$ARTherapyTypeEnumMap[instance.type]!,
      'objectives': instance.objectives,
      'targetConditions': instance.targetConditions,
      'parameters': instance.parameters,
      'defaultOverlays': instance.defaultOverlays,
      'requiredDevices': instance.requiredDevices,
      'effectivenessMetrics': instance.effectivenessMetrics,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'status': _$ARTherapyProgramStatusEnumMap[instance.status]!,
      'certifications': instance.certifications,
      'metadata': instance.metadata,
    };

const _$ARTherapyTypeEnumMap = {
  ARTherapyType.guidance: 'guidance',
  ARTherapyType.instruction: 'instruction',
  ARTherapyType.feedback: 'feedback',
  ARTherapyType.visualization: 'visualization',
  ARTherapyType.monitoring: 'monitoring',
  ARTherapyType.assistance: 'assistance',
  ARTherapyType.education: 'education',
  ARTherapyType.assessment: 'assessment',
  ARTherapyType.rehabilitation: 'rehabilitation',
  ARTherapyType.support: 'support',
};

const _$ARTherapyProgramStatusEnumMap = {
  ARTherapyProgramStatus.development: 'development',
  ARTherapyProgramStatus.testing: 'testing',
  ARTherapyProgramStatus.validation: 'validation',
  ARTherapyProgramStatus.active: 'active',
  ARTherapyProgramStatus.maintenance: 'maintenance',
  ARTherapyProgramStatus.deprecated: 'deprecated',
};

VRARPerformanceReport _$VRARPerformanceReportFromJson(
  Map<String, dynamic> json,
) => VRARPerformanceReport(
  id: json['id'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  generatedBy: json['generatedBy'] as String,
  vrSessions: (json['vrSessions'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, VRTherapySession.fromJson(e as Map<String, dynamic>)),
  ),
  arSessions: (json['arSessions'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, ARTherapySession.fromJson(e as Map<String, dynamic>)),
  ),
  vrDevices: (json['vrDevices'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, VRDevice.fromJson(e as Map<String, dynamic>)),
  ),
  arDevices: (json['arDevices'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, ARDevice.fromJson(e as Map<String, dynamic>)),
  ),
  vrPrograms: (json['vrPrograms'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, VRTherapyProgram.fromJson(e as Map<String, dynamic>)),
  ),
  arPrograms: (json['arPrograms'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, ARTherapyProgram.fromJson(e as Map<String, dynamic>)),
  ),
  systemMetrics: (json['systemMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$VRARPerformanceReportToJson(
  VRARPerformanceReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'generatedBy': instance.generatedBy,
  'vrSessions': instance.vrSessions,
  'arSessions': instance.arSessions,
  'vrDevices': instance.vrDevices,
  'arDevices': instance.arDevices,
  'vrPrograms': instance.vrPrograms,
  'arPrograms': instance.arPrograms,
  'systemMetrics': instance.systemMetrics,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
