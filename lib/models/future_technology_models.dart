import 'package:json_annotation/json_annotation.dart';

part 'future_technology_models.g.dart';

/// Future Technology Integration Models for PsyClinicAI
/// Provides comprehensive future technology integration for next-generation healthcare

@JsonSerializable()
class NextGenHealthcare {
  final String id;
  final String name;
  final String description;
  final HealthcareType type;
  final String version;
  final DateTime releaseDate;
  final List<String> capabilities;
  final Map<String, dynamic> specifications;
  final HealthcareStatus status;
  final Map<String, double> performanceMetrics;
  final List<String> supportedTechnologies;
  final Map<String, dynamic> metadata;

  const NextGenHealthcare({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.version,
    required this.releaseDate,
    required this.capabilities,
    required this.specifications,
    required this.status,
    required this.performanceMetrics,
    required this.supportedTechnologies,
    required this.metadata,
  });

  factory NextGenHealthcare.fromJson(Map<String, dynamic> json) => _$NextGenHealthcareFromJson(json);
  Map<String, dynamic> toJson() => _$NextGenHealthcareToJson(this);

  bool get isActive => status == HealthcareStatus.active;
  bool get isLatestVersion => version == '2.0.0';
  double get performanceScore => performanceMetrics['overall_score'] ?? 0.0;
  bool get isHighPerformance => performanceScore > 0.95;
  int get totalCapabilities => capabilities.length;
}

enum HealthcareType { 
  diagnostic, 
  therapeutic, 
  preventive, 
  rehabilitative, 
  emergency, 
  research, 
  experimental, 
  comprehensive 
}

enum HealthcareStatus { 
  development, 
  testing, 
  active, 
  maintenance, 
  deprecated, 
  experimental 
}

@JsonSerializable()
class AdvancedBiotechnology {
  final String id;
  final String name;
  final String description;
  final BiotechnologyType type;
  final BiotechnologyStatus status;
  final DateTime discoveryDate;
  final DateTime? implementationDate;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final List<String> researchers;
  final Map<String, double> readinessMetrics;
  final List<String> ethicalConsiderations;
  final Map<String, dynamic> metadata;

  const AdvancedBiotechnology({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.discoveryDate,
    this.implementationDate,
    required this.applications,
    required this.specifications,
    required this.researchers,
    required this.readinessMetrics,
    required this.ethicalConsiderations,
    required this.metadata,
  });

  factory AdvancedBiotechnology.fromJson(Map<String, dynamic> json) => _$AdvancedBiotechnologyFromJson(json);
  Map<String, dynamic> toJson() => _$AdvancedBiotechnologyToJson(this);

  bool get isImplemented => status == BiotechnologyStatus.implemented;
  bool get isResearch => status == BiotechnologyStatus.research;
  double get readinessLevel => readinessMetrics['readiness_level'] ?? 0.0;
  bool get isReady => readinessLevel > 0.8;
  bool get hasEthicalApproval => ethicalConsiderations.isEmpty;
  Duration get developmentTime {
    if (implementationDate != null) return implementationDate!.difference(discoveryDate);
    return DateTime.now().difference(discoveryDate);
  }
}

enum BiotechnologyType { 
  geneticEngineering, 
  syntheticBiology, 
  bioinformatics, 
  biopharmaceuticals, 
  tissueEngineering, 
  regenerativeMedicine, 
  bioelectronics, 
  biomanufacturing 
}

enum BiotechnologyStatus { 
  concept, 
  research, 
  development, 
  testing, 
  implemented, 
  commercialized, 
  regulated 
}

@JsonSerializable()
class NanotechnologyHealthcare {
  final String id;
  final String name;
  final String description;
  final NanotechType type;
  final NanotechStatus status;
  final DateTime developmentDate;
  final DateTime? clinicalTrialDate;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final List<String> researchers;
  final Map<String, double> safetyMetrics;
  final List<String> regulatoryApprovals;
  final Map<String, dynamic> metadata;

  const NanotechnologyHealthcare({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.developmentDate,
    this.clinicalTrialDate,
    required this.applications,
    required this.specifications,
    required this.researchers,
    required this.safetyMetrics,
    required this.regulatoryApprovals,
    required this.metadata,
  });

  factory NanotechnologyHealthcare.fromJson(Map<String, dynamic> json) => _$NanotechnologyHealthcareFromJson(json);
  Map<String, dynamic> toJson() => _$NanotechnologyHealthcareToJson(this);

  bool get isClinical => status == NanotechStatus.clinicalTrial;
  bool get isApproved => status == NanotechStatus.approved;
  double get safetyScore => safetyMetrics['safety_score'] ?? 0.0;
  bool get isSafe => safetyScore > 0.9;
  bool get hasRegulatoryApproval => regulatoryApprovals.isNotEmpty;
  Duration get developmentTime {
    if (clinicalTrialDate != null) return clinicalTrialDate!.difference(developmentDate);
    return DateTime.now().difference(developmentDate);
  }
}

enum NanotechType { 
  drugDelivery, 
  imaging, 
  diagnostics, 
  therapeutics, 
  tissueEngineering, 
  biosensors, 
  medicalDevices, 
  regenerativeMedicine 
}

enum NanotechStatus { 
  research, 
  development, 
  preclinical, 
  clinicalTrial, 
  approved, 
  commercialized, 
  discontinued 
}

@JsonSerializable()
class RoboticsHealthcare {
  final String id;
  final String name;
  final String description;
  final RoboticsType type;
  final RoboticsStatus status;
  final DateTime developmentDate;
  final DateTime? deploymentDate;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final List<String> operators;
  final Map<String, double> performanceMetrics;
  final List<String> safetyProtocols;
  final Map<String, dynamic> metadata;

  const RoboticsHealthcare({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.developmentDate,
    this.deploymentDate,
    required this.applications,
    required this.specifications,
    required this.operators,
    required this.performanceMetrics,
    required this.safetyProtocols,
    required this.metadata,
  });

  factory RoboticsHealthcare.fromJson(Map<String, dynamic> json) => _$RoboticsHealthcareFromJson(json);
  Map<String, dynamic> toJson() => _$RoboticsHealthcareToJson(this);

  bool get isDeployed => status == RoboticsStatus.deployed;
  bool get isOperational => status == RoboticsStatus.operational;
  double get performanceScore => performanceMetrics['performance_score'] ?? 0.0;
  bool get isHighPerformance => performanceScore > 0.9;
  bool get hasSafetyProtocols => safetyProtocols.isNotEmpty;
  Duration get operationalTime {
    if (deploymentDate != null) return DateTime.now().difference(deploymentDate);
    return Duration.zero;
  }
}

enum RoboticsType { 
  surgical, 
  rehabilitation, 
  diagnostic, 
  therapeutic, 
  assistance, 
  telepresence, 
  autonomous, 
  collaborative 
}

enum RoboticsStatus { 
  development, 
  testing, 
  certified, 
  deployed, 
  operational, 
  maintenance, 
  decommissioned 
}

@JsonSerializable()
class ExtendedRealityHealthcare {
  final String id;
  final String name;
  final String description;
  final XRType type;
  final XRStatus status;
  final DateTime developmentDate;
  final DateTime? releaseDate;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final List<String> developers;
  final Map<String, double> qualityMetrics;
  final List<String> supportedDevices;
  final Map<String, dynamic> metadata;

  const ExtendedRealityHealthcare({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.developmentDate,
    this.releaseDate,
    required this.applications,
    required this.specifications,
    required this.developers,
    required this.qualityMetrics,
    required this.supportedDevices,
    required this.metadata,
  });

  factory ExtendedRealityHealthcare.fromJson(Map<String, dynamic> json) => _$ExtendedRealityHealthcareFromJson(json);
  Map<String, dynamic> toJson() => _$ExtendedRealityHealthcareToJson(this);

  bool get isReleased => status == XRStatus.released;
  bool get isActive => status == XRStatus.active;
  double get qualityScore => qualityMetrics['quality_score'] ?? 0.0;
  bool get isHighQuality => qualityScore > 0.9;
  int get totalSupportedDevices => supportedDevices.length;
  Duration get developmentTime {
    if (releaseDate != null) return releaseDate!.difference(developmentDate);
    return DateTime.now().difference(developmentDate);
  }
}

enum XRType { 
  virtualReality, 
  augmentedReality, 
  mixedReality, 
  extendedReality, 
  immersive, 
  interactive, 
  collaborative, 
  therapeutic 
}

enum XRStatus { 
  development, 
  testing, 
  beta, 
  released, 
  active, 
  maintenance, 
  deprecated 
}

@JsonSerializable()
class BlockchainHealthcare {
  final String id;
  final String name;
  final String description;
  final BlockchainType type;
  final BlockchainStatus status;
  final DateTime developmentDate;
  final DateTime? deploymentDate;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final List<String> developers;
  final Map<String, double> securityMetrics;
  final List<String> complianceStandards;
  final Map<String, dynamic> metadata;

  const BlockchainHealthcare({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.developmentDate,
    this.deploymentDate,
    required this.applications,
    required this.specifications,
    required this.developers,
    required this.securityMetrics,
    required this.complianceStandards,
    required this.metadata,
  });

  factory BlockchainHealthcare.fromJson(Map<String, dynamic> json) => _$BlockchainHealthcareFromJson(json);
  Map<String, dynamic> toJson() => _$BlockchainHealthcareToJson(this);

  bool get isDeployed => status == BlockchainStatus.deployed;
  bool get isActive => status == BlockchainStatus.active;
  double get securityScore => securityMetrics['security_score'] ?? 0.0;
  bool get isSecure => securityScore > 0.95;
  bool get isCompliant => complianceStandards.isNotEmpty;
  Duration get operationalTime {
    if (deploymentDate != null) return DateTime.now().difference(deploymentDate);
    return Duration.zero;
  }
}

enum BlockchainType { 
  medicalRecords, 
  supplyChain, 
  clinicalTrials, 
  insurance, 
  research, 
  identity, 
  consent, 
  payments 
}

enum BlockchainStatus { 
  development, 
  testing, 
  pilot, 
  deployed, 
  active, 
  maintenance, 
  deprecated 
}

@JsonSerializable()
class InternetOfThingsHealthcare {
  final String id;
  final String name;
  final String description;
  final IoTType type;
  final IoTStatus status;
  final DateTime developmentDate;
  final DateTime? deploymentDate;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final List<String> devices;
  final Map<String, double> connectivityMetrics;
  final List<String> securityProtocols;
  final Map<String, dynamic> metadata;

  const InternetOfThingsHealthcare({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.developmentDate,
    this.deploymentDate,
    required this.applications,
    required this.specifications,
    required this.devices,
    required this.connectivityMetrics,
    required this.securityProtocols,
    required this.metadata,
  });

  factory InternetOfThingsHealthcare.fromJson(Map<String, dynamic> json) => _$InternetOfThingsHealthcareFromJson(json);
  Map<String, dynamic> toJson() => _$InternetOfThingsHealthcareToJson(this);

  bool get isDeployed => status == IoTStatus.deployed;
  bool get isActive => status == IoTStatus.active;
  double get connectivityScore => connectivityMetrics['connectivity_score'] ?? 0.0;
  bool get isWellConnected => connectivityScore > 0.9;
  bool get hasSecurityProtocols => securityProtocols.isNotEmpty;
  int get totalDevices => devices.length;
  Duration get operationalTime {
    if (deploymentDate != null) return DateTime.now().difference(deploymentDate);
    return Duration.zero;
  }
}

enum IoTType { 
  wearable, 
  implantable, 
  environmental, 
  diagnostic, 
  therapeutic, 
  monitoring, 
  emergency, 
  preventive 
}

enum IoTStatus { 
  development, 
  testing, 
  pilot, 
  deployed, 
  active, 
  maintenance, 
  deprecated 
}

@JsonSerializable()
class RenewableEnergyHealthcare {
  final String id;
  final String name;
  final String description;
  final EnergyType type;
  final EnergyStatus status;
  final DateTime developmentDate;
  final DateTime? implementationDate;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final List<String> engineers;
  final Map<String, double> efficiencyMetrics;
  final List<String> environmentalBenefits;
  final Map<String, dynamic> metadata;

  const RenewableEnergyHealthcare({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.developmentDate,
    this.implementationDate,
    required this.applications,
    required this.specifications,
    required this.engineers,
    required this.efficiencyMetrics,
    required this.environmentalBenefits,
    required this.metadata,
  });

  factory RenewableEnergyHealthcare.fromJson(Map<String, dynamic> json) => _$RenewableEnergyHealthcareFromJson(json);
  Map<String, dynamic> toJson() => _$RenewableEnergyHealthcareFromJson(this);

  bool get isImplemented => status == EnergyStatus.implemented;
  bool get isActive => status == EnergyStatus.active;
  double get efficiencyScore => efficiencyMetrics['efficiency_score'] ?? 0.0;
  bool get isEfficient => efficiencyScore > 0.8;
  bool get hasEnvironmentalBenefits => environmentalBenefits.isNotEmpty;
  Duration get operationalTime {
    if (implementationDate != null) return DateTime.now().difference(implementationDate);
    return Duration.zero;
  }
}

enum EnergyType { 
  solar, 
  wind, 
  hydroelectric, 
  geothermal, 
  biomass, 
  hydrogen, 
  nuclear, 
  hybrid 
}

enum EnergyStatus { 
  development, 
  testing, 
  pilot, 
  implemented, 
  active, 
  maintenance, 
  decommissioned 
}

@JsonSerializable()
class FutureTechnologyReport {
  final String id;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, NextGenHealthcare> activeHealthcare;
  final Map<String, AdvancedBiotechnology> emergingBiotech;
  final Map<String, NanotechnologyHealthcare> activeNanotech;
  final Map<String, RoboticsHealthcare> operationalRobotics;
  final Map<String, ExtendedRealityHealthcare> activeXR;
  final Map<String, BlockchainHealthcare> activeBlockchain;
  final Map<String, InternetOfThingsHealthcare> activeIoT;
  final Map<String, RenewableEnergyHealthcare> activeEnergy;
  final Map<String, double> systemMetrics;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const FutureTechnologyReport({
    required this.id,
    required this.generatedAt,
    required this.generatedBy,
    required this.activeHealthcare,
    required this.emergingBiotech,
    required this.activeNanotech,
    required this.operationalRobotics,
    required this.activeXR,
    required this.activeBlockchain,
    required this.activeIoT,
    required this.activeEnergy,
    required this.systemMetrics,
    required this.recommendations,
    required this.metadata,
  });

  factory FutureTechnologyReport.fromJson(Map<String, dynamic> json) => _$FutureTechnologyReportFromJson(json);
  Map<String, dynamic> toJson() => _$FutureTechnologyReportToJson(this);

  int get totalActiveHealthcare => activeHealthcare.length;
  int get totalEmergingBiotech => emergingBiotech.length;
  int get totalActiveNanotech => activeNanotech.length;
  int get totalOperationalRobotics => operationalRobotics.length;
  int get totalActiveXR => activeXR.length;
  int get totalActiveBlockchain => activeBlockchain.length;
  int get totalActiveIoT => activeIoT.length;
  int get totalActiveEnergy => activeEnergy.length;
  double get overallSystemHealth => systemMetrics['system_health'] ?? 0.0;
  bool get systemNeedsAttention => overallSystemHealth < 0.7;
}
