// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'future_technology_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextGenHealthcare _$NextGenHealthcareFromJson(Map<String, dynamic> json) =>
    NextGenHealthcare(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$HealthcareTypeEnumMap, json['type']),
      version: json['version'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      capabilities: (json['capabilities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specifications: json['specifications'] as Map<String, dynamic>,
      status: $enumDecode(_$HealthcareStatusEnumMap, json['status']),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      supportedTechnologies: (json['supportedTechnologies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$NextGenHealthcareToJson(NextGenHealthcare instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$HealthcareTypeEnumMap[instance.type]!,
      'version': instance.version,
      'releaseDate': instance.releaseDate.toIso8601String(),
      'capabilities': instance.capabilities,
      'specifications': instance.specifications,
      'status': _$HealthcareStatusEnumMap[instance.status]!,
      'performanceMetrics': instance.performanceMetrics,
      'supportedTechnologies': instance.supportedTechnologies,
      'metadata': instance.metadata,
    };

const _$HealthcareTypeEnumMap = {
  HealthcareType.diagnostic: 'diagnostic',
  HealthcareType.therapeutic: 'therapeutic',
  HealthcareType.preventive: 'preventive',
  HealthcareType.rehabilitative: 'rehabilitative',
  HealthcareType.emergency: 'emergency',
  HealthcareType.research: 'research',
  HealthcareType.experimental: 'experimental',
  HealthcareType.comprehensive: 'comprehensive',
};

const _$HealthcareStatusEnumMap = {
  HealthcareStatus.development: 'development',
  HealthcareStatus.testing: 'testing',
  HealthcareStatus.active: 'active',
  HealthcareStatus.maintenance: 'maintenance',
  HealthcareStatus.deprecated: 'deprecated',
  HealthcareStatus.experimental: 'experimental',
};

AdvancedBiotechnology _$AdvancedBiotechnologyFromJson(
  Map<String, dynamic> json,
) => AdvancedBiotechnology(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$BiotechnologyTypeEnumMap, json['type']),
  status: $enumDecode(_$BiotechnologyStatusEnumMap, json['status']),
  discoveryDate: DateTime.parse(json['discoveryDate'] as String),
  implementationDate: json['implementationDate'] == null
      ? null
      : DateTime.parse(json['implementationDate'] as String),
  applications: (json['applications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  specifications: json['specifications'] as Map<String, dynamic>,
  researchers: (json['researchers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  readinessMetrics: (json['readinessMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  ethicalConsiderations: (json['ethicalConsiderations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AdvancedBiotechnologyToJson(
  AdvancedBiotechnology instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$BiotechnologyTypeEnumMap[instance.type]!,
  'status': _$BiotechnologyStatusEnumMap[instance.status]!,
  'discoveryDate': instance.discoveryDate.toIso8601String(),
  'implementationDate': instance.implementationDate?.toIso8601String(),
  'applications': instance.applications,
  'specifications': instance.specifications,
  'researchers': instance.researchers,
  'readinessMetrics': instance.readinessMetrics,
  'ethicalConsiderations': instance.ethicalConsiderations,
  'metadata': instance.metadata,
};

const _$BiotechnologyTypeEnumMap = {
  BiotechnologyType.geneticEngineering: 'geneticEngineering',
  BiotechnologyType.syntheticBiology: 'syntheticBiology',
  BiotechnologyType.bioinformatics: 'bioinformatics',
  BiotechnologyType.biopharmaceuticals: 'biopharmaceuticals',
  BiotechnologyType.tissueEngineering: 'tissueEngineering',
  BiotechnologyType.regenerativeMedicine: 'regenerativeMedicine',
  BiotechnologyType.bioelectronics: 'bioelectronics',
  BiotechnologyType.biomanufacturing: 'biomanufacturing',
};

const _$BiotechnologyStatusEnumMap = {
  BiotechnologyStatus.concept: 'concept',
  BiotechnologyStatus.research: 'research',
  BiotechnologyStatus.development: 'development',
  BiotechnologyStatus.testing: 'testing',
  BiotechnologyStatus.implemented: 'implemented',
  BiotechnologyStatus.commercialized: 'commercialized',
  BiotechnologyStatus.regulated: 'regulated',
};

NanotechnologyHealthcare _$NanotechnologyHealthcareFromJson(
  Map<String, dynamic> json,
) => NanotechnologyHealthcare(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$NanotechTypeEnumMap, json['type']),
  status: $enumDecode(_$NanotechStatusEnumMap, json['status']),
  developmentDate: DateTime.parse(json['developmentDate'] as String),
  clinicalTrialDate: json['clinicalTrialDate'] == null
      ? null
      : DateTime.parse(json['clinicalTrialDate'] as String),
  applications: (json['applications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  specifications: json['specifications'] as Map<String, dynamic>,
  researchers: (json['researchers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  safetyMetrics: (json['safetyMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  regulatoryApprovals: (json['regulatoryApprovals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$NanotechnologyHealthcareToJson(
  NanotechnologyHealthcare instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$NanotechTypeEnumMap[instance.type]!,
  'status': _$NanotechStatusEnumMap[instance.status]!,
  'developmentDate': instance.developmentDate.toIso8601String(),
  'clinicalTrialDate': instance.clinicalTrialDate?.toIso8601String(),
  'applications': instance.applications,
  'specifications': instance.specifications,
  'researchers': instance.researchers,
  'safetyMetrics': instance.safetyMetrics,
  'regulatoryApprovals': instance.regulatoryApprovals,
  'metadata': instance.metadata,
};

const _$NanotechTypeEnumMap = {
  NanotechType.drugDelivery: 'drugDelivery',
  NanotechType.imaging: 'imaging',
  NanotechType.diagnostics: 'diagnostics',
  NanotechType.therapeutics: 'therapeutics',
  NanotechType.tissueEngineering: 'tissueEngineering',
  NanotechType.biosensors: 'biosensors',
  NanotechType.medicalDevices: 'medicalDevices',
  NanotechType.regenerativeMedicine: 'regenerativeMedicine',
};

const _$NanotechStatusEnumMap = {
  NanotechStatus.research: 'research',
  NanotechStatus.development: 'development',
  NanotechStatus.preclinical: 'preclinical',
  NanotechStatus.clinicalTrial: 'clinicalTrial',
  NanotechStatus.approved: 'approved',
  NanotechStatus.commercialized: 'commercialized',
  NanotechStatus.discontinued: 'discontinued',
};

RoboticsHealthcare _$RoboticsHealthcareFromJson(Map<String, dynamic> json) =>
    RoboticsHealthcare(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$RoboticsTypeEnumMap, json['type']),
      status: $enumDecode(_$RoboticsStatusEnumMap, json['status']),
      developmentDate: DateTime.parse(json['developmentDate'] as String),
      deploymentDate: json['deploymentDate'] == null
          ? null
          : DateTime.parse(json['deploymentDate'] as String),
      applications: (json['applications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specifications: json['specifications'] as Map<String, dynamic>,
      operators: (json['operators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      safetyProtocols: (json['safetyProtocols'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RoboticsHealthcareToJson(RoboticsHealthcare instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$RoboticsTypeEnumMap[instance.type]!,
      'status': _$RoboticsStatusEnumMap[instance.status]!,
      'developmentDate': instance.developmentDate.toIso8601String(),
      'deploymentDate': instance.deploymentDate?.toIso8601String(),
      'applications': instance.applications,
      'specifications': instance.specifications,
      'operators': instance.operators,
      'performanceMetrics': instance.performanceMetrics,
      'safetyProtocols': instance.safetyProtocols,
      'metadata': instance.metadata,
    };

const _$RoboticsTypeEnumMap = {
  RoboticsType.surgical: 'surgical',
  RoboticsType.rehabilitation: 'rehabilitation',
  RoboticsType.diagnostic: 'diagnostic',
  RoboticsType.therapeutic: 'therapeutic',
  RoboticsType.assistance: 'assistance',
  RoboticsType.telepresence: 'telepresence',
  RoboticsType.autonomous: 'autonomous',
  RoboticsType.collaborative: 'collaborative',
};

const _$RoboticsStatusEnumMap = {
  RoboticsStatus.development: 'development',
  RoboticsStatus.testing: 'testing',
  RoboticsStatus.certified: 'certified',
  RoboticsStatus.deployed: 'deployed',
  RoboticsStatus.operational: 'operational',
  RoboticsStatus.maintenance: 'maintenance',
  RoboticsStatus.decommissioned: 'decommissioned',
};

ExtendedRealityHealthcare _$ExtendedRealityHealthcareFromJson(
  Map<String, dynamic> json,
) => ExtendedRealityHealthcare(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$XRTypeEnumMap, json['type']),
  status: $enumDecode(_$XRStatusEnumMap, json['status']),
  developmentDate: DateTime.parse(json['developmentDate'] as String),
  releaseDate: json['releaseDate'] == null
      ? null
      : DateTime.parse(json['releaseDate'] as String),
  applications: (json['applications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  specifications: json['specifications'] as Map<String, dynamic>,
  developers: (json['developers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  qualityMetrics: (json['qualityMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  supportedDevices: (json['supportedDevices'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ExtendedRealityHealthcareToJson(
  ExtendedRealityHealthcare instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$XRTypeEnumMap[instance.type]!,
  'status': _$XRStatusEnumMap[instance.status]!,
  'developmentDate': instance.developmentDate.toIso8601String(),
  'releaseDate': instance.releaseDate?.toIso8601String(),
  'applications': instance.applications,
  'specifications': instance.specifications,
  'developers': instance.developers,
  'qualityMetrics': instance.qualityMetrics,
  'supportedDevices': instance.supportedDevices,
  'metadata': instance.metadata,
};

const _$XRTypeEnumMap = {
  XRType.virtualReality: 'virtualReality',
  XRType.augmentedReality: 'augmentedReality',
  XRType.mixedReality: 'mixedReality',
  XRType.extendedReality: 'extendedReality',
  XRType.immersive: 'immersive',
  XRType.interactive: 'interactive',
  XRType.collaborative: 'collaborative',
  XRType.therapeutic: 'therapeutic',
};

const _$XRStatusEnumMap = {
  XRStatus.development: 'development',
  XRStatus.testing: 'testing',
  XRStatus.beta: 'beta',
  XRStatus.released: 'released',
  XRStatus.active: 'active',
  XRStatus.maintenance: 'maintenance',
  XRStatus.deprecated: 'deprecated',
};

BlockchainHealthcare _$BlockchainHealthcareFromJson(
  Map<String, dynamic> json,
) => BlockchainHealthcare(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$BlockchainTypeEnumMap, json['type']),
  status: $enumDecode(_$BlockchainStatusEnumMap, json['status']),
  developmentDate: DateTime.parse(json['developmentDate'] as String),
  deploymentDate: json['deploymentDate'] == null
      ? null
      : DateTime.parse(json['deploymentDate'] as String),
  applications: (json['applications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  specifications: json['specifications'] as Map<String, dynamic>,
  developers: (json['developers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  securityMetrics: (json['securityMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  complianceStandards: (json['complianceStandards'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$BlockchainHealthcareToJson(
  BlockchainHealthcare instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$BlockchainTypeEnumMap[instance.type]!,
  'status': _$BlockchainStatusEnumMap[instance.status]!,
  'developmentDate': instance.developmentDate.toIso8601String(),
  'deploymentDate': instance.deploymentDate?.toIso8601String(),
  'applications': instance.applications,
  'specifications': instance.specifications,
  'developers': instance.developers,
  'securityMetrics': instance.securityMetrics,
  'complianceStandards': instance.complianceStandards,
  'metadata': instance.metadata,
};

const _$BlockchainTypeEnumMap = {
  BlockchainType.medicalRecords: 'medicalRecords',
  BlockchainType.supplyChain: 'supplyChain',
  BlockchainType.clinicalTrials: 'clinicalTrials',
  BlockchainType.insurance: 'insurance',
  BlockchainType.research: 'research',
  BlockchainType.identity: 'identity',
  BlockchainType.consent: 'consent',
  BlockchainType.payments: 'payments',
};

const _$BlockchainStatusEnumMap = {
  BlockchainStatus.development: 'development',
  BlockchainStatus.testing: 'testing',
  BlockchainStatus.pilot: 'pilot',
  BlockchainStatus.deployed: 'deployed',
  BlockchainStatus.active: 'active',
  BlockchainStatus.maintenance: 'maintenance',
  BlockchainStatus.deprecated: 'deprecated',
};

InternetOfThingsHealthcare _$InternetOfThingsHealthcareFromJson(
  Map<String, dynamic> json,
) => InternetOfThingsHealthcare(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$IoTTypeEnumMap, json['type']),
  status: $enumDecode(_$IoTStatusEnumMap, json['status']),
  developmentDate: DateTime.parse(json['developmentDate'] as String),
  deploymentDate: json['deploymentDate'] == null
      ? null
      : DateTime.parse(json['deploymentDate'] as String),
  applications: (json['applications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  specifications: json['specifications'] as Map<String, dynamic>,
  devices: (json['devices'] as List<dynamic>).map((e) => e as String).toList(),
  connectivityMetrics: (json['connectivityMetrics'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  securityProtocols: (json['securityProtocols'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$InternetOfThingsHealthcareToJson(
  InternetOfThingsHealthcare instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$IoTTypeEnumMap[instance.type]!,
  'status': _$IoTStatusEnumMap[instance.status]!,
  'developmentDate': instance.developmentDate.toIso8601String(),
  'deploymentDate': instance.deploymentDate?.toIso8601String(),
  'applications': instance.applications,
  'specifications': instance.specifications,
  'devices': instance.devices,
  'connectivityMetrics': instance.connectivityMetrics,
  'securityProtocols': instance.securityProtocols,
  'metadata': instance.metadata,
};

const _$IoTTypeEnumMap = {
  IoTType.wearable: 'wearable',
  IoTType.implantable: 'implantable',
  IoTType.environmental: 'environmental',
  IoTType.diagnostic: 'diagnostic',
  IoTType.therapeutic: 'therapeutic',
  IoTType.monitoring: 'monitoring',
  IoTType.emergency: 'emergency',
  IoTType.preventive: 'preventive',
};

const _$IoTStatusEnumMap = {
  IoTStatus.development: 'development',
  IoTStatus.testing: 'testing',
  IoTStatus.pilot: 'pilot',
  IoTStatus.deployed: 'deployed',
  IoTStatus.active: 'active',
  IoTStatus.maintenance: 'maintenance',
  IoTStatus.deprecated: 'deprecated',
};

RenewableEnergyHealthcare _$RenewableEnergyHealthcareFromJson(
  Map<String, dynamic> json,
) => RenewableEnergyHealthcare(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$EnergyTypeEnumMap, json['type']),
  status: $enumDecode(_$EnergyStatusEnumMap, json['status']),
  developmentDate: DateTime.parse(json['developmentDate'] as String),
  implementationDate: json['implementationDate'] == null
      ? null
      : DateTime.parse(json['implementationDate'] as String),
  applications: (json['applications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  specifications: json['specifications'] as Map<String, dynamic>,
  engineers: (json['engineers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  efficiencyMetrics: (json['efficiencyMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  environmentalBenefits: (json['environmentalBenefits'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RenewableEnergyHealthcareToJson(
  RenewableEnergyHealthcare instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$EnergyTypeEnumMap[instance.type]!,
  'status': _$EnergyStatusEnumMap[instance.status]!,
  'developmentDate': instance.developmentDate.toIso8601String(),
  'implementationDate': instance.implementationDate?.toIso8601String(),
  'applications': instance.applications,
  'specifications': instance.specifications,
  'engineers': instance.engineers,
  'efficiencyMetrics': instance.efficiencyMetrics,
  'environmentalBenefits': instance.environmentalBenefits,
  'metadata': instance.metadata,
};

const _$EnergyTypeEnumMap = {
  EnergyType.solar: 'solar',
  EnergyType.wind: 'wind',
  EnergyType.hydroelectric: 'hydroelectric',
  EnergyType.geothermal: 'geothermal',
  EnergyType.biomass: 'biomass',
  EnergyType.hydrogen: 'hydrogen',
  EnergyType.nuclear: 'nuclear',
  EnergyType.hybrid: 'hybrid',
};

const _$EnergyStatusEnumMap = {
  EnergyStatus.development: 'development',
  EnergyStatus.testing: 'testing',
  EnergyStatus.pilot: 'pilot',
  EnergyStatus.implemented: 'implemented',
  EnergyStatus.active: 'active',
  EnergyStatus.maintenance: 'maintenance',
  EnergyStatus.decommissioned: 'decommissioned',
};

FutureTechnologyReport _$FutureTechnologyReportFromJson(
  Map<String, dynamic> json,
) => FutureTechnologyReport(
  id: json['id'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  generatedBy: json['generatedBy'] as String,
  activeHealthcare: (json['activeHealthcare'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, NextGenHealthcare.fromJson(e as Map<String, dynamic>)),
  ),
  emergingBiotech: (json['emergingBiotech'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, AdvancedBiotechnology.fromJson(e as Map<String, dynamic>)),
  ),
  activeNanotech: (json['activeNanotech'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      NanotechnologyHealthcare.fromJson(e as Map<String, dynamic>),
    ),
  ),
  operationalRobotics: (json['operationalRobotics'] as Map<String, dynamic>)
      .map(
        (k, e) =>
            MapEntry(k, RoboticsHealthcare.fromJson(e as Map<String, dynamic>)),
      ),
  activeXR: (json['activeXR'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      ExtendedRealityHealthcare.fromJson(e as Map<String, dynamic>),
    ),
  ),
  activeBlockchain: (json['activeBlockchain'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, BlockchainHealthcare.fromJson(e as Map<String, dynamic>)),
  ),
  activeIoT: (json['activeIoT'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      InternetOfThingsHealthcare.fromJson(e as Map<String, dynamic>),
    ),
  ),
  activeEnergy: (json['activeEnergy'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      RenewableEnergyHealthcare.fromJson(e as Map<String, dynamic>),
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

Map<String, dynamic> _$FutureTechnologyReportToJson(
  FutureTechnologyReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'generatedBy': instance.generatedBy,
  'activeHealthcare': instance.activeHealthcare,
  'emergingBiotech': instance.emergingBiotech,
  'activeNanotech': instance.activeNanotech,
  'operationalRobotics': instance.operationalRobotics,
  'activeXR': instance.activeXR,
  'activeBlockchain': instance.activeBlockchain,
  'activeIoT': instance.activeIoT,
  'activeEnergy': instance.activeEnergy,
  'systemMetrics': instance.systemMetrics,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
