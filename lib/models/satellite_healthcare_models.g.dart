// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'satellite_healthcare_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SatelliteHealthcareSystem _$SatelliteHealthcareSystemFromJson(
  Map<String, dynamic> json,
) => SatelliteHealthcareSystem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$SatelliteTypeEnumMap, json['type']),
  manufacturer: json['manufacturer'] as String,
  model: json['model'] as String,
  launchDate: DateTime.parse(json['launchDate'] as String),
  decommissionDate: json['decommissionDate'] == null
      ? null
      : DateTime.parse(json['decommissionDate'] as String),
  orbit: json['orbit'] as String,
  altitude: (json['altitude'] as num).toDouble(),
  specifications: json['specifications'] as Map<String, dynamic>,
  capabilities: (json['capabilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$SystemStatusEnumMap, json['status']),
  performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  supportedServices: (json['supportedServices'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SatelliteHealthcareSystemToJson(
  SatelliteHealthcareSystem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$SatelliteTypeEnumMap[instance.type]!,
  'manufacturer': instance.manufacturer,
  'model': instance.model,
  'launchDate': instance.launchDate.toIso8601String(),
  'decommissionDate': instance.decommissionDate?.toIso8601String(),
  'orbit': instance.orbit,
  'altitude': instance.altitude,
  'specifications': instance.specifications,
  'capabilities': instance.capabilities,
  'status': _$SystemStatusEnumMap[instance.status]!,
  'performanceMetrics': instance.performanceMetrics,
  'supportedServices': instance.supportedServices,
  'metadata': instance.metadata,
};

const _$SatelliteTypeEnumMap = {
  SatelliteType.communication: 'communication',
  SatelliteType.navigation: 'navigation',
  SatelliteType.earthObservation: 'earthObservation',
  SatelliteType.scientific: 'scientific',
  SatelliteType.military: 'military',
  SatelliteType.commercial: 'commercial',
  SatelliteType.healthcare: 'healthcare',
  SatelliteType.research: 'research',
};

const _$SystemStatusEnumMap = {
  SystemStatus.planning: 'planning',
  SystemStatus.development: 'development',
  SystemStatus.testing: 'testing',
  SystemStatus.launch: 'launch',
  SystemStatus.operational: 'operational',
  SystemStatus.maintenance: 'maintenance',
  SystemStatus.decommissioned: 'decommissioned',
  SystemStatus.failed: 'failed',
};

TelemedicineService _$TelemedicineServiceFromJson(Map<String, dynamic> json) =>
    TelemedicineService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ServiceTypeEnumMap, json['type']),
      satelliteId: json['satelliteId'] as String,
      supportedDevices: (json['supportedDevices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
      protocols: (json['protocols'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$ServiceStatusEnumMap, json['status']),
      activatedAt: DateTime.parse(json['activatedAt'] as String),
      deactivatedAt: json['deactivatedAt'] == null
          ? null
          : DateTime.parse(json['deactivatedAt'] as String),
      qualityMetrics: (json['qualityMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      supportedRegions: (json['supportedRegions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TelemedicineServiceToJson(
  TelemedicineService instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$ServiceTypeEnumMap[instance.type]!,
  'satelliteId': instance.satelliteId,
  'supportedDevices': instance.supportedDevices,
  'parameters': instance.parameters,
  'protocols': instance.protocols,
  'status': _$ServiceStatusEnumMap[instance.status]!,
  'activatedAt': instance.activatedAt.toIso8601String(),
  'deactivatedAt': instance.deactivatedAt?.toIso8601String(),
  'qualityMetrics': instance.qualityMetrics,
  'supportedRegions': instance.supportedRegions,
  'metadata': instance.metadata,
};

const _$ServiceTypeEnumMap = {
  ServiceType.consultation: 'consultation',
  ServiceType.diagnosis: 'diagnosis',
  ServiceType.monitoring: 'monitoring',
  ServiceType.emergency: 'emergency',
  ServiceType.surgery: 'surgery',
  ServiceType.training: 'training',
  ServiceType.research: 'research',
  ServiceType.support: 'support',
};

const _$ServiceStatusEnumMap = {
  ServiceStatus.inactive: 'inactive',
  ServiceStatus.active: 'active',
  ServiceStatus.operational: 'operational',
  ServiceStatus.maintenance: 'maintenance',
  ServiceStatus.degraded: 'degraded',
  ServiceStatus.failed: 'failed',
};

RemoteDiagnosticSystem _$RemoteDiagnosticSystemFromJson(
  Map<String, dynamic> json,
) => RemoteDiagnosticSystem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$DiagnosticTypeEnumMap, json['type']),
  satelliteId: json['satelliteId'] as String,
  supportedDiagnostics: (json['supportedDiagnostics'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  capabilities: json['capabilities'] as Map<String, dynamic>,
  requiredEquipment: (json['requiredEquipment'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$SystemStatusEnumMap, json['status']),
  lastCalibration: DateTime.parse(json['lastCalibration'] as String),
  accuracyMetrics: (json['accuracyMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  supportedConditions: (json['supportedConditions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteDiagnosticSystemToJson(
  RemoteDiagnosticSystem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$DiagnosticTypeEnumMap[instance.type]!,
  'satelliteId': instance.satelliteId,
  'supportedDiagnostics': instance.supportedDiagnostics,
  'capabilities': instance.capabilities,
  'requiredEquipment': instance.requiredEquipment,
  'status': _$SystemStatusEnumMap[instance.status]!,
  'lastCalibration': instance.lastCalibration.toIso8601String(),
  'accuracyMetrics': instance.accuracyMetrics,
  'supportedConditions': instance.supportedConditions,
  'metadata': instance.metadata,
};

const _$DiagnosticTypeEnumMap = {
  DiagnosticType.imaging: 'imaging',
  DiagnosticType.laboratory: 'laboratory',
  DiagnosticType.physiological: 'physiological',
  DiagnosticType.psychological: 'psychological',
  DiagnosticType.genetic: 'genetic',
  DiagnosticType.radiological: 'radiological',
  DiagnosticType.pathological: 'pathological',
  DiagnosticType.comprehensive: 'comprehensive',
};

EmergencyResponseSystem _$EmergencyResponseSystemFromJson(
  Map<String, dynamic> json,
) => EmergencyResponseSystem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$EmergencyTypeEnumMap, json['type']),
  satelliteId: json['satelliteId'] as String,
  supportedEmergencies: (json['supportedEmergencies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responseProtocols: json['responseProtocols'] as Map<String, dynamic>,
  requiredResources: (json['requiredResources'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$SystemStatusEnumMap, json['status']),
  lastTested: DateTime.parse(json['lastTested'] as String),
  responseMetrics: (json['responseMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  supportedLocations: (json['supportedLocations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$EmergencyResponseSystemToJson(
  EmergencyResponseSystem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$EmergencyTypeEnumMap[instance.type]!,
  'satelliteId': instance.satelliteId,
  'supportedEmergencies': instance.supportedEmergencies,
  'responseProtocols': instance.responseProtocols,
  'requiredResources': instance.requiredResources,
  'status': _$SystemStatusEnumMap[instance.status]!,
  'lastTested': instance.lastTested.toIso8601String(),
  'responseMetrics': instance.responseMetrics,
  'supportedLocations': instance.supportedLocations,
  'metadata': instance.metadata,
};

const _$EmergencyTypeEnumMap = {
  EmergencyType.medical: 'medical',
  EmergencyType.trauma: 'trauma',
  EmergencyType.cardiac: 'cardiac',
  EmergencyType.respiratory: 'respiratory',
  EmergencyType.neurological: 'neurological',
  EmergencyType.psychological: 'psychological',
  EmergencyType.environmental: 'environmental',
  EmergencyType.multiSystem: 'multiSystem',
};

HealthMonitoringNetwork _$HealthMonitoringNetworkFromJson(
  Map<String, dynamic> json,
) => HealthMonitoringNetwork(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$NetworkTypeEnumMap, json['type']),
  satelliteIds: (json['satelliteIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  groundStations: (json['groundStations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  networkTopology: json['networkTopology'] as Map<String, dynamic>,
  supportedProtocols: (json['supportedProtocols'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$NetworkStatusEnumMap, json['status']),
  establishedAt: DateTime.parse(json['establishedAt'] as String),
  networkMetrics: (json['networkMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  supportedServices: (json['supportedServices'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$HealthMonitoringNetworkToJson(
  HealthMonitoringNetwork instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$NetworkTypeEnumMap[instance.type]!,
  'satelliteIds': instance.satelliteIds,
  'groundStations': instance.groundStations,
  'networkTopology': instance.networkTopology,
  'supportedProtocols': instance.supportedProtocols,
  'status': _$NetworkStatusEnumMap[instance.status]!,
  'establishedAt': instance.establishedAt.toIso8601String(),
  'networkMetrics': instance.networkMetrics,
  'supportedServices': instance.supportedServices,
  'metadata': instance.metadata,
};

const _$NetworkTypeEnumMap = {
  NetworkType.global: 'global',
  NetworkType.regional: 'regional',
  NetworkType.local: 'local',
  NetworkType.specialized: 'specialized',
  NetworkType.emergency: 'emergency',
  NetworkType.research: 'research',
  NetworkType.commercial: 'commercial',
  NetworkType.military: 'military',
};

const _$NetworkStatusEnumMap = {
  NetworkStatus.planning: 'planning',
  NetworkStatus.development: 'development',
  NetworkStatus.testing: 'testing',
  NetworkStatus.operational: 'operational',
  NetworkStatus.maintenance: 'maintenance',
  NetworkStatus.degraded: 'degraded',
  NetworkStatus.failed: 'failed',
};

SatelliteCommunication _$SatelliteCommunicationFromJson(
  Map<String, dynamic> json,
) => SatelliteCommunication(
  id: json['id'] as String,
  satelliteId: json['satelliteId'] as String,
  groundStationId: json['groundStationId'] as String,
  type: $enumDecode(_$CommunicationTypeEnumMap, json['type']),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  signalStrength: (json['signalStrength'] as num).toDouble(),
  bandwidth: (json['bandwidth'] as num).toDouble(),
  latency: (json['latency'] as num).toDouble(),
  status: $enumDecode(_$CommunicationStatusEnumMap, json['status']),
  parameters: json['parameters'] as Map<String, dynamic>,
  protocols: (json['protocols'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SatelliteCommunicationToJson(
  SatelliteCommunication instance,
) => <String, dynamic>{
  'id': instance.id,
  'satelliteId': instance.satelliteId,
  'groundStationId': instance.groundStationId,
  'type': _$CommunicationTypeEnumMap[instance.type]!,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'signalStrength': instance.signalStrength,
  'bandwidth': instance.bandwidth,
  'latency': instance.latency,
  'status': _$CommunicationStatusEnumMap[instance.status]!,
  'parameters': instance.parameters,
  'protocols': instance.protocols,
  'metadata': instance.metadata,
};

const _$CommunicationTypeEnumMap = {
  CommunicationType.voice: 'voice',
  CommunicationType.data: 'data',
  CommunicationType.video: 'video',
  CommunicationType.telemetry: 'telemetry',
  CommunicationType.control: 'control',
  CommunicationType.emergency: 'emergency',
  CommunicationType.broadcast: 'broadcast',
  CommunicationType.multicast: 'multicast',
};

const _$CommunicationStatusEnumMap = {
  CommunicationStatus.inactive: 'inactive',
  CommunicationStatus.active: 'active',
  CommunicationStatus.stable: 'stable',
  CommunicationStatus.unstable: 'unstable',
  CommunicationStatus.failed: 'failed',
  CommunicationStatus.reconnecting: 'reconnecting',
};

GroundStation _$GroundStationFromJson(Map<String, dynamic> json) =>
    GroundStation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      supportedSatellites: (json['supportedSatellites'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      capabilities: json['capabilities'] as Map<String, dynamic>,
      status: $enumDecode(_$StationStatusEnumMap, json['status']),
      establishedAt: DateTime.parse(json['establishedAt'] as String),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      supportedServices: (json['supportedServices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GroundStationToJson(GroundStation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'supportedSatellites': instance.supportedSatellites,
      'capabilities': instance.capabilities,
      'status': _$StationStatusEnumMap[instance.status]!,
      'establishedAt': instance.establishedAt.toIso8601String(),
      'performanceMetrics': instance.performanceMetrics,
      'supportedServices': instance.supportedServices,
      'metadata': instance.metadata,
    };

const _$StationStatusEnumMap = {
  StationStatus.planning: 'planning',
  StationStatus.construction: 'construction',
  StationStatus.testing: 'testing',
  StationStatus.operational: 'operational',
  StationStatus.maintenance: 'maintenance',
  StationStatus.decommissioned: 'decommissioned',
  StationStatus.failed: 'failed',
};

HealthcareDataTransmission _$HealthcareDataTransmissionFromJson(
  Map<String, dynamic> json,
) => HealthcareDataTransmission(
  id: json['id'] as String,
  sourceId: json['sourceId'] as String,
  destinationId: json['destinationId'] as String,
  satelliteId: json['satelliteId'] as String,
  type: $enumDecode(_$DataTypeEnumMap, json['type']),
  dataSize: (json['dataSize'] as num).toInt(),
  dataFormat: json['dataFormat'] as String,
  transmissionStart: DateTime.parse(json['transmissionStart'] as String),
  transmissionEnd: json['transmissionEnd'] == null
      ? null
      : DateTime.parse(json['transmissionEnd'] as String),
  status: $enumDecode(_$TransmissionStatusEnumMap, json['status']),
  progress: (json['progress'] as num).toDouble(),
  parameters: json['parameters'] as Map<String, dynamic>,
  protocols: (json['protocols'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$HealthcareDataTransmissionToJson(
  HealthcareDataTransmission instance,
) => <String, dynamic>{
  'id': instance.id,
  'sourceId': instance.sourceId,
  'destinationId': instance.destinationId,
  'satelliteId': instance.satelliteId,
  'type': _$DataTypeEnumMap[instance.type]!,
  'dataSize': instance.dataSize,
  'dataFormat': instance.dataFormat,
  'transmissionStart': instance.transmissionStart.toIso8601String(),
  'transmissionEnd': instance.transmissionEnd?.toIso8601String(),
  'status': _$TransmissionStatusEnumMap[instance.status]!,
  'progress': instance.progress,
  'parameters': instance.parameters,
  'protocols': instance.protocols,
  'metadata': instance.metadata,
};

const _$DataTypeEnumMap = {
  DataType.patient: 'patient',
  DataType.diagnostic: 'diagnostic',
  DataType.treatment: 'treatment',
  DataType.monitoring: 'monitoring',
  DataType.emergency: 'emergency',
  DataType.research: 'research',
  DataType.administrative: 'administrative',
  DataType.system: 'system',
};

const _$TransmissionStatusEnumMap = {
  TransmissionStatus.queued: 'queued',
  TransmissionStatus.active: 'active',
  TransmissionStatus.paused: 'paused',
  TransmissionStatus.completed: 'completed',
  TransmissionStatus.failed: 'failed',
  TransmissionStatus.cancelled: 'cancelled',
};

SatelliteHealthcareReport _$SatelliteHealthcareReportFromJson(
  Map<String, dynamic> json,
) => SatelliteHealthcareReport(
  id: json['id'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  generatedBy: json['generatedBy'] as String,
  activeSatellites: (json['activeSatellites'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      SatelliteHealthcareSystem.fromJson(e as Map<String, dynamic>),
    ),
  ),
  activeServices: (json['activeServices'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, TelemedicineService.fromJson(e as Map<String, dynamic>)),
  ),
  diagnosticSystems: (json['diagnosticSystems'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, RemoteDiagnosticSystem.fromJson(e as Map<String, dynamic>)),
  ),
  emergencySystems: (json['emergencySystems'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      EmergencyResponseSystem.fromJson(e as Map<String, dynamic>),
    ),
  ),
  monitoringNetworks: (json['monitoringNetworks'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      HealthMonitoringNetwork.fromJson(e as Map<String, dynamic>),
    ),
  ),
  systemMetrics: (json['systemMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SatelliteHealthcareReportToJson(
  SatelliteHealthcareReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'generatedBy': instance.generatedBy,
  'activeSatellites': instance.activeSatellites,
  'activeServices': instance.activeServices,
  'diagnosticSystems': instance.diagnosticSystems,
  'emergencySystems': instance.emergencySystems,
  'monitoringNetworks': instance.monitoringNetworks,
  'systemMetrics': instance.systemMetrics,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
