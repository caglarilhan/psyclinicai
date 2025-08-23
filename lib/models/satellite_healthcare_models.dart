import 'package:json_annotation/json_annotation.dart';

part 'satellite_healthcare_models.g.dart';

/// Satellite Healthcare Models for PsyClinicAI
/// Provides comprehensive satellite-based healthcare systems for space medicine

@JsonSerializable()
class SatelliteHealthcareSystem {
  final String id;
  final String name;
  final String description;
  final SatelliteType type;
  final String manufacturer;
  final String model;
  final DateTime launchDate;
  final DateTime? decommissionDate;
  final String orbit;
  final double altitude;
  final Map<String, dynamic> specifications;
  final List<String> capabilities;
  final SystemStatus status;
  final Map<String, double> performanceMetrics;
  final List<String> supportedServices;
  final Map<String, dynamic> metadata;

  const SatelliteHealthcareSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.launchDate,
    this.decommissionDate,
    required this.orbit,
    required this.altitude,
    required this.specifications,
    required this.capabilities,
    required this.status,
    required this.performanceMetrics,
    required this.supportedServices,
    required this.metadata,
  });

  factory SatelliteHealthcareSystem.fromJson(Map<String, dynamic> json) => _$SatelliteHealthcareSystemFromJson(json);
  Map<String, dynamic> toJson() => _$SatelliteHealthcareSystemToJson(this);

  bool get isActive => status == SystemStatus.active;
  bool get isOperational => status == SystemStatus.operational;
  Duration get operationalTime {
    if (decommissionDate != null) return decommissionDate!.difference(launchDate);
    return DateTime.now().difference(launchDate);
  }
  bool get isLongTerm => operationalTime.inDays > 365 * 5; // 5 years
  bool get isHighPerformance => performanceMetrics['reliability'] != null && performanceMetrics['reliability']! > 0.95;
}

enum SatelliteType { 
  communication, 
  navigation, 
  earthObservation, 
  scientific, 
  military, 
  commercial, 
  healthcare, 
  research 
}

enum SystemStatus { 
  planning, 
  development, 
  testing, 
  launch, 
  operational, 
  maintenance, 
  decommissioned, 
  failed 
}

@JsonSerializable()
class TelemedicineService {
  final String id;
  final String name;
  final String description;
  final ServiceType type;
  final String satelliteId;
  final List<String> supportedDevices;
  final Map<String, dynamic> parameters;
  final List<String> protocols;
  final ServiceStatus status;
  final DateTime activatedAt;
  final DateTime? deactivatedAt;
  final Map<String, double> qualityMetrics;
  final List<String> supportedRegions;
  final Map<String, dynamic> metadata;

  const TelemedicineService({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.satelliteId,
    required this.supportedDevices,
    required this.parameters,
    required this.protocols,
    required this.status,
    required this.activatedAt,
    this.deactivatedAt,
    required this.qualityMetrics,
    required this.supportedRegions,
    required this.metadata,
  });

  factory TelemedicineService.fromJson(Map<String, dynamic> json) => _$TelemedicineServiceFromJson(json);
  Map<String, dynamic> toJson() => _$TelemedicineServiceToJson(this);

  bool get isActive => status == ServiceStatus.active;
  bool get isOperational => status == ServiceStatus.operational;
  Duration get uptime {
    if (deactivatedAt != null) return deactivatedAt!.difference(activatedAt);
    return DateTime.now().difference(activatedAt);
  }
  double get qualityScore => qualityMetrics['overall_quality'] ?? 0.0;
  bool get isHighQuality => qualityScore > 0.8;
}

enum ServiceType { 
  consultation, 
  diagnosis, 
  monitoring, 
  emergency, 
  surgery, 
  training, 
  research, 
  support 
}

enum ServiceStatus { 
  inactive, 
  active, 
  operational, 
  maintenance, 
  degraded, 
  failed 
}

@JsonSerializable()
class RemoteDiagnosticSystem {
  final String id;
  final String name;
  final String description;
  final DiagnosticType type;
  final String satelliteId;
  final List<String> supportedDiagnostics;
  final Map<String, dynamic> capabilities;
  final List<String> requiredEquipment;
  final SystemStatus status;
  final DateTime lastCalibration;
  final Map<String, double> accuracyMetrics;
  final List<String> supportedConditions;
  final Map<String, dynamic> metadata;

  const RemoteDiagnosticSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.satelliteId,
    required this.supportedDiagnostics,
    required this.capabilities,
    required this.requiredEquipment,
    required this.status,
    required this.lastCalibration,
    required this.accuracyMetrics,
    required this.supportedConditions,
    required this.metadata,
  });

  factory RemoteDiagnosticSystem.fromJson(Map<String, dynamic> json) => _$RemoteDiagnosticSystemFromJson(json);
  Map<String, dynamic> toJson() => _$RemoteDiagnosticSystemToJson(this);

  bool get isOperational => status == SystemStatus.operational;
  bool get needsCalibration => DateTime.now().difference(lastCalibration).inDays > 30;
  double get accuracy => accuracyMetrics['overall_accuracy'] ?? 0.0;
  bool get isHighAccuracy => accuracy > 0.9;
  int get totalSupportedConditions => supportedConditions.length;
}

enum DiagnosticType { 
  imaging, 
  laboratory, 
  physiological, 
  psychological, 
  genetic, 
  radiological, 
  pathological, 
  comprehensive 
}

@JsonSerializable()
class EmergencyResponseSystem {
  final String id;
  final String name;
  final String description;
  final EmergencyType type;
  final String satelliteId;
  final List<String> supportedEmergencies;
  final Map<String, dynamic> responseProtocols;
  final List<String> requiredResources;
  final SystemStatus status;
  final DateTime lastTested;
  final Map<String, double> responseMetrics;
  final List<String> supportedLocations;
  final Map<String, dynamic> metadata;

  const EmergencyResponseSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.satelliteId,
    required this.supportedEmergencies,
    required this.responseProtocols,
    required this.requiredResources,
    required this.status,
    required this.lastTested,
    required this.responseMetrics,
    required this.supportedLocations,
    required this.metadata,
  });

  factory EmergencyResponseSystem.fromJson(Map<String, dynamic> json) => _$EmergencyResponseSystemFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyResponseSystemToJson(this);

  bool get isOperational => status == SystemStatus.operational;
  bool get needsTesting => DateTime.now().difference(lastTested).inDays > 90;
  double get responseTime => responseMetrics['average_response_time'] ?? 0.0;
  bool get isFastResponse => responseTime < 5.0; // Less than 5 minutes
  int get totalSupportedEmergencies => supportedEmergencies.length;
}

enum EmergencyType { 
  medical, 
  trauma, 
  cardiac, 
  respiratory, 
  neurological, 
  psychological, 
  environmental, 
  multiSystem 
}

@JsonSerializable()
class HealthMonitoringNetwork {
  final String id;
  final String name;
  final String description;
  final NetworkType type;
  final List<String> satelliteIds;
  final List<String> groundStations;
  final Map<String, dynamic> networkTopology;
  final List<String> supportedProtocols;
  final NetworkStatus status;
  final DateTime establishedAt;
  final Map<String, double> networkMetrics;
  final List<String> supportedServices;
  final Map<String, dynamic> metadata;

  const HealthMonitoringNetwork({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.satelliteIds,
    required this.groundStations,
    required this.networkTopology,
    required this.supportedProtocols,
    required this.status,
    required this.establishedAt,
    required this.networkMetrics,
    required this.supportedServices,
    required this.metadata,
  });

  factory HealthMonitoringNetwork.fromJson(Map<String, dynamic> json) => _$HealthMonitoringNetworkFromJson(json);
  Map<String, dynamic> toJson() => _$HealthMonitoringNetworkToJson(this);

  bool get isOperational => status == NetworkStatus.operational;
  int get totalSatellites => satelliteIds.length;
  int get totalGroundStations => groundStations.length;
  double get networkReliability => networkMetrics['reliability'] ?? 0.0;
  bool get isHighReliability => networkReliability > 0.99;
  Duration get operationalTime => DateTime.now().difference(establishedAt);
}

enum NetworkType { 
  global, 
  regional, 
  local, 
  specialized, 
  emergency, 
  research, 
  commercial, 
  military 
}

enum NetworkStatus { 
  planning, 
  development, 
  testing, 
  operational, 
  maintenance, 
  degraded, 
  failed 
}

@JsonSerializable()
class SatelliteCommunication {
  final String id;
  final String satelliteId;
  final String groundStationId;
  final CommunicationType type;
  final DateTime startTime;
  final DateTime? endTime;
  final double signalStrength;
  final double bandwidth;
  final double latency;
  final CommunicationStatus status;
  final Map<String, dynamic> parameters;
  final List<String> protocols;
  final Map<String, dynamic> metadata;

  const SatelliteCommunication({
    required this.id,
    required this.satelliteId,
    required this.groundStationId,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.signalStrength,
    required this.bandwidth,
    required this.latency,
    required this.status,
    required this.parameters,
    required this.protocols,
    required this.metadata,
  });

  factory SatelliteCommunication.fromJson(Map<String, dynamic> json) => _$SatelliteCommunicationFromJson(json);
  Map<String, dynamic> toJson() => _$SatelliteCommunicationToJson(this);

  bool get isActive => status == CommunicationStatus.active;
  bool get isStable => signalStrength > 0.8;
  bool get isHighBandwidth => bandwidth > 100.0; // Mbps
  bool get isLowLatency => latency < 100.0; // ms
  Duration get duration {
    if (endTime != null) return endTime!.difference(startTime);
    return DateTime.now().difference(startTime);
  }
}

enum CommunicationType { 
  voice, 
  data, 
  video, 
  telemetry, 
  control, 
  emergency, 
  broadcast, 
  multicast 
}

enum CommunicationStatus { 
  inactive, 
  active, 
  stable, 
  unstable, 
  failed, 
  reconnecting 
}

@JsonSerializable()
class GroundStation {
  final String id;
  final String name;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final double altitude;
  final List<String> supportedSatellites;
  final Map<String, dynamic> capabilities;
  final StationStatus status;
  final DateTime establishedAt;
  final Map<String, double> performanceMetrics;
  final List<String> supportedServices;
  final Map<String, dynamic> metadata;

  const GroundStation({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.supportedSatellites,
    required this.capabilities,
    required this.status,
    required this.establishedAt,
    required this.performanceMetrics,
    required this.supportedServices,
    required this.metadata,
  });

  factory GroundStation.fromJson(Map<String, dynamic> json) => _$GroundStationFromJson(json);
  Map<String, dynamic> toJson() => _$GroundStationToJson(this);

  bool get isOperational => status == StationStatus.operational;
  int get totalSupportedSatellites => supportedSatellites.length;
  double get reliability => performanceMetrics['reliability'] ?? 0.0;
  bool get isHighReliability => reliability > 0.95;
  Duration get operationalTime => DateTime.now().difference(establishedAt);
}

enum StationStatus { 
  planning, 
  construction, 
  testing, 
  operational, 
  maintenance, 
  decommissioned, 
  failed 
}

@JsonSerializable()
class HealthcareDataTransmission {
  final String id;
  final String sourceId;
  final String destinationId;
  final String satelliteId;
  final DataType type;
  final int dataSize;
  final String dataFormat;
  final DateTime transmissionStart;
  final DateTime? transmissionEnd;
  final TransmissionStatus status;
  final double progress;
  final Map<String, dynamic> parameters;
  final List<String> protocols;
  final Map<String, dynamic> metadata;

  const HealthcareDataTransmission({
    required this.id,
    required this.sourceId,
    required this.destinationId,
    required this.satelliteId,
    required this.type,
    required this.dataSize,
    required this.dataFormat,
    required this.transmissionStart,
    this.transmissionEnd,
    required this.status,
    required this.progress,
    required this.parameters,
    required this.protocols,
    required this.metadata,
  });

  factory HealthcareDataTransmission.fromJson(Map<String, dynamic> json) => _$HealthcareDataTransmissionFromJson(json);
  Map<String, dynamic> toJson() => _$HealthcareDataTransmissionToJson(this);

  bool get isCompleted => status == TransmissionStatus.completed;
  bool get isActive => status == TransmissionStatus.active;
  bool get isFailed => status == TransmissionStatus.failed;
  Duration get transmissionTime {
    if (transmissionEnd != null) return transmissionEnd!.difference(transmissionStart);
    return DateTime.now().difference(transmissionStart);
  }
  double get completionPercentage => progress * 100;
}

enum DataType { 
  patient, 
  diagnostic, 
  treatment, 
  monitoring, 
  emergency, 
  research, 
  administrative, 
  system 
}

enum TransmissionStatus { 
  queued, 
  active, 
  paused, 
  completed, 
  failed, 
  cancelled 
}

@JsonSerializable()
class SatelliteHealthcareReport {
  final String id;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, SatelliteHealthcareSystem> activeSatellites;
  final Map<String, TelemedicineService> activeServices;
  final Map<String, RemoteDiagnosticSystem> diagnosticSystems;
  final Map<String, EmergencyResponseSystem> emergencySystems;
  final Map<String, HealthMonitoringNetwork> monitoringNetworks;
  final Map<String, double> systemMetrics;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const SatelliteHealthcareReport({
    required this.id,
    required this.generatedAt,
    required this.generatedBy,
    required this.activeSatellites,
    required this.activeServices,
    required this.diagnosticSystems,
    required this.emergencySystems,
    required this.monitoringNetworks,
    required this.systemMetrics,
    required this.recommendations,
    required this.metadata,
  });

  factory SatelliteHealthcareReport.fromJson(Map<String, dynamic> json) => _$SatelliteHealthcareReportFromJson(json);
  Map<String, dynamic> toJson() => _$SatelliteHealthcareReportToJson(this);

  int get totalActiveSatellites => activeSatellites.length;
  int get totalActiveServices => activeServices.length;
  int get totalDiagnosticSystems => diagnosticSystems.length;
  int get totalEmergencySystems => emergencySystems.length;
  int get totalMonitoringNetworks => monitoringNetworks.length;
  double get overallSystemHealth => systemMetrics['system_health'] ?? 0.0;
  bool get systemNeedsAttention => overallSystemHealth < 0.7;
}
