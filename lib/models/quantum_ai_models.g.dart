// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantum_ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuantumCircuit _$QuantumCircuitFromJson(Map<String, dynamic> json) =>
    QuantumCircuit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      qubitCount: (json['qubitCount'] as num).toInt(),
      depth: (json['depth'] as num).toInt(),
      gates: (json['gates'] as List<dynamic>)
          .map((e) => QuantumGate.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: $enumDecode(_$QuantumCircuitTypeEnumMap, json['type']),
      parameters: json['parameters'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      createdBy: json['createdBy'] as String,
      status: $enumDecode(_$QuantumCircuitStatusEnumMap, json['status']),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
    );

Map<String, dynamic> _$QuantumCircuitToJson(QuantumCircuit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'qubitCount': instance.qubitCount,
      'depth': instance.depth,
      'gates': instance.gates,
      'type': _$QuantumCircuitTypeEnumMap[instance.type]!,
      'parameters': instance.parameters,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastModified': instance.lastModified.toIso8601String(),
      'createdBy': instance.createdBy,
      'status': _$QuantumCircuitStatusEnumMap[instance.status]!,
      'performanceMetrics': instance.performanceMetrics,
    };

const _$QuantumCircuitTypeEnumMap = {
  QuantumCircuitType.variational: 'variational',
  QuantumCircuitType.quantumFourier: 'quantumFourier',
  QuantumCircuitType.quantumPhase: 'quantumPhase',
  QuantumCircuitType.quantumAmplitude: 'quantumAmplitude',
  QuantumCircuitType.quantumMachineLearning: 'quantumMachineLearning',
  QuantumCircuitType.quantumOptimization: 'quantumOptimization',
  QuantumCircuitType.quantumSimulation: 'quantumSimulation',
  QuantumCircuitType.quantumErrorCorrection: 'quantumErrorCorrection',
  QuantumCircuitType.quantumRandomWalk: 'quantumRandomWalk',
  QuantumCircuitType.quantumTeleportation: 'quantumTeleportation',
};

const _$QuantumCircuitStatusEnumMap = {
  QuantumCircuitStatus.design: 'design',
  QuantumCircuitStatus.testing: 'testing',
  QuantumCircuitStatus.optimization: 'optimization',
  QuantumCircuitStatus.validation: 'validation',
  QuantumCircuitStatus.production: 'production',
  QuantumCircuitStatus.deprecated: 'deprecated',
};

QuantumGate _$QuantumGateFromJson(Map<String, dynamic> json) => QuantumGate(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$QuantumGateTypeEnumMap, json['type']),
  qubits: (json['qubits'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  parameters: json['parameters'] as Map<String, dynamic>,
  duration: (json['duration'] as num).toDouble(),
  errorRate: (json['errorRate'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumGateToJson(QuantumGate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$QuantumGateTypeEnumMap[instance.type]!,
      'qubits': instance.qubits,
      'parameters': instance.parameters,
      'duration': instance.duration,
      'errorRate': instance.errorRate,
      'metadata': instance.metadata,
    };

const _$QuantumGateTypeEnumMap = {
  QuantumGateType.hadamard: 'hadamard',
  QuantumGateType.pauliX: 'pauliX',
  QuantumGateType.pauliY: 'pauliY',
  QuantumGateType.pauliZ: 'pauliZ',
  QuantumGateType.phase: 'phase',
  QuantumGateType.rotationX: 'rotationX',
  QuantumGateType.rotationY: 'rotationY',
  QuantumGateType.rotationZ: 'rotationZ',
  QuantumGateType.cnot: 'cnot',
  QuantumGateType.swap: 'swap',
  QuantumGateType.toffoli: 'toffoli',
  QuantumGateType.fredkin: 'fredkin',
  QuantumGateType.controlledPhase: 'controlledPhase',
  QuantumGateType.controlledRotation: 'controlledRotation',
  QuantumGateType.custom: 'custom',
};

QuantumProcessor _$QuantumProcessorFromJson(Map<String, dynamic> json) =>
    QuantumProcessor(
      id: json['id'] as String,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String,
      type: $enumDecode(_$QuantumProcessorTypeEnumMap, json['type']),
      qubitCount: (json['qubitCount'] as num).toInt(),
      maxQubits: (json['maxQubits'] as num).toInt(),
      coherenceTime: (json['coherenceTime'] as num).toDouble(),
      gateFidelity: (json['gateFidelity'] as num).toDouble(),
      readoutFidelity: (json['readoutFidelity'] as num).toDouble(),
      supportedGates: (json['supportedGates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specifications: json['specifications'] as Map<String, dynamic>,
      status: $enumDecode(_$QuantumProcessorStatusEnumMap, json['status']),
      lastCalibration: DateTime.parse(json['lastCalibration'] as String),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
    );

Map<String, dynamic> _$QuantumProcessorToJson(QuantumProcessor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'manufacturer': instance.manufacturer,
      'type': _$QuantumProcessorTypeEnumMap[instance.type]!,
      'qubitCount': instance.qubitCount,
      'maxQubits': instance.maxQubits,
      'coherenceTime': instance.coherenceTime,
      'gateFidelity': instance.gateFidelity,
      'readoutFidelity': instance.readoutFidelity,
      'supportedGates': instance.supportedGates,
      'specifications': instance.specifications,
      'status': _$QuantumProcessorStatusEnumMap[instance.status]!,
      'lastCalibration': instance.lastCalibration.toIso8601String(),
      'performanceMetrics': instance.performanceMetrics,
    };

const _$QuantumProcessorTypeEnumMap = {
  QuantumProcessorType.superconducting: 'superconducting',
  QuantumProcessorType.trappedIon: 'trappedIon',
  QuantumProcessorType.topological: 'topological',
  QuantumProcessorType.photonic: 'photonic',
  QuantumProcessorType.neutralAtom: 'neutralAtom',
  QuantumProcessorType.silicon: 'silicon',
  QuantumProcessorType.diamondNV: 'diamondNV',
  QuantumProcessorType.hybrid: 'hybrid',
};

const _$QuantumProcessorStatusEnumMap = {
  QuantumProcessorStatus.offline: 'offline',
  QuantumProcessorStatus.maintenance: 'maintenance',
  QuantumProcessorStatus.available: 'available',
  QuantumProcessorStatus.busy: 'busy',
  QuantumProcessorStatus.error: 'error',
  QuantumProcessorStatus.calibrating: 'calibrating',
};

QuantumAlgorithm _$QuantumAlgorithmFromJson(Map<String, dynamic> json) =>
    QuantumAlgorithm(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$QuantumAlgorithmTypeEnumMap, json['type']),
      applications: (json['applications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      complexityClass: (json['complexityClass'] as num).toInt(),
      parameters: json['parameters'] as Map<String, dynamic>,
      circuits: (json['circuits'] as List<dynamic>)
          .map((e) => QuantumCircuit.fromJson(e as Map<String, dynamic>))
          .toList(),
      performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      status: $enumDecode(_$QuantumAlgorithmStatusEnumMap, json['status']),
      references: (json['references'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QuantumAlgorithmToJson(QuantumAlgorithm instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$QuantumAlgorithmTypeEnumMap[instance.type]!,
      'applications': instance.applications,
      'complexityClass': instance.complexityClass,
      'parameters': instance.parameters,
      'circuits': instance.circuits,
      'performanceMetrics': instance.performanceMetrics,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'status': _$QuantumAlgorithmStatusEnumMap[instance.status]!,
      'references': instance.references,
      'metadata': instance.metadata,
    };

const _$QuantumAlgorithmTypeEnumMap = {
  QuantumAlgorithmType.quantumMachineLearning: 'quantumMachineLearning',
  QuantumAlgorithmType.quantumOptimization: 'quantumOptimization',
  QuantumAlgorithmType.quantumSimulation: 'quantumSimulation',
  QuantumAlgorithmType.quantumCryptography: 'quantumCryptography',
  QuantumAlgorithmType.quantumErrorCorrection: 'quantumErrorCorrection',
  QuantumAlgorithmType.quantumChemistry: 'quantumChemistry',
  QuantumAlgorithmType.quantumFinance: 'quantumFinance',
  QuantumAlgorithmType.quantumLogistics: 'quantumLogistics',
  QuantumAlgorithmType.hybrid: 'hybrid',
  QuantumAlgorithmType.custom: 'custom',
};

const _$QuantumAlgorithmStatusEnumMap = {
  QuantumAlgorithmStatus.research: 'research',
  QuantumAlgorithmStatus.development: 'development',
  QuantumAlgorithmStatus.testing: 'testing',
  QuantumAlgorithmStatus.validation: 'validation',
  QuantumAlgorithmStatus.production: 'production',
  QuantumAlgorithmStatus.deprecated: 'deprecated',
};

QuantumJob _$QuantumJobFromJson(Map<String, dynamic> json) => QuantumJob(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$QuantumJobTypeEnumMap, json['type']),
  algorithmId: json['algorithmId'] as String,
  processorId: json['processorId'] as String,
  parameters: json['parameters'] as Map<String, dynamic>,
  status: $enumDecode(_$QuantumJobStatusEnumMap, json['status']),
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  failedAt: json['failedAt'] == null
      ? null
      : DateTime.parse(json['failedAt'] as String),
  results: json['results'] as Map<String, dynamic>,
  metrics: (json['metrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  logs: (json['logs'] as List<dynamic>).map((e) => e as String).toList(),
  submittedBy: json['submittedBy'] as String,
  priority: (json['priority'] as num).toInt(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumJobToJson(QuantumJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$QuantumJobTypeEnumMap[instance.type]!,
      'algorithmId': instance.algorithmId,
      'processorId': instance.processorId,
      'parameters': instance.parameters,
      'status': _$QuantumJobStatusEnumMap[instance.status]!,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'failedAt': instance.failedAt?.toIso8601String(),
      'results': instance.results,
      'metrics': instance.metrics,
      'logs': instance.logs,
      'submittedBy': instance.submittedBy,
      'priority': instance.priority,
      'metadata': instance.metadata,
    };

const _$QuantumJobTypeEnumMap = {
  QuantumJobType.training: 'training',
  QuantumJobType.inference: 'inference',
  QuantumJobType.optimization: 'optimization',
  QuantumJobType.simulation: 'simulation',
  QuantumJobType.analysis: 'analysis',
  QuantumJobType.research: 'research',
};

const _$QuantumJobStatusEnumMap = {
  QuantumJobStatus.queued: 'queued',
  QuantumJobStatus.running: 'running',
  QuantumJobStatus.completed: 'completed',
  QuantumJobStatus.failed: 'failed',
  QuantumJobStatus.cancelled: 'cancelled',
  QuantumJobStatus.paused: 'paused',
};

QuantumModel _$QuantumModelFromJson(Map<String, dynamic> json) => QuantumModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$QuantumModelTypeEnumMap, json['type']),
  algorithmId: json['algorithmId'] as String,
  hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
  weights: json['weights'] as Map<String, dynamic>,
  performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  trainedAt: DateTime.parse(json['trainedAt'] as String),
  trainedBy: json['trainedBy'] as String,
  status: $enumDecode(_$QuantumModelStatusEnumMap, json['status']),
  supportedTasks: (json['supportedTasks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  version: (json['version'] as num).toInt(),
  parentModelId: json['parentModelId'] as String,
);

Map<String, dynamic> _$QuantumModelToJson(QuantumModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$QuantumModelTypeEnumMap[instance.type]!,
      'algorithmId': instance.algorithmId,
      'hyperparameters': instance.hyperparameters,
      'weights': instance.weights,
      'performanceMetrics': instance.performanceMetrics,
      'trainedAt': instance.trainedAt.toIso8601String(),
      'trainedBy': instance.trainedBy,
      'status': _$QuantumModelStatusEnumMap[instance.status]!,
      'supportedTasks': instance.supportedTasks,
      'metadata': instance.metadata,
      'version': instance.version,
      'parentModelId': instance.parentModelId,
    };

const _$QuantumModelTypeEnumMap = {
  QuantumModelType.classical: 'classical',
  QuantumModelType.quantum: 'quantum',
  QuantumModelType.quantumEnhanced: 'quantumEnhanced',
  QuantumModelType.hybrid: 'hybrid',
  QuantumModelType.ensemble: 'ensemble',
};

const _$QuantumModelStatusEnumMap = {
  QuantumModelStatus.training: 'training',
  QuantumModelStatus.testing: 'testing',
  QuantumModelStatus.validation: 'validation',
  QuantumModelStatus.production: 'production',
  QuantumModelStatus.deprecated: 'deprecated',
};

QuantumExperiment _$QuantumExperimentFromJson(Map<String, dynamic> json) =>
    QuantumExperiment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      hypothesis: json['hypothesis'] as String,
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => QuantumJob.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$QuantumExperimentStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      researcherId: json['researcherId'] as String,
      collaborators: (json['collaborators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      results: json['results'] as Map<String, dynamic>,
      metrics: (json['metrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      conclusions: (json['conclusions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QuantumExperimentToJson(QuantumExperiment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'hypothesis': instance.hypothesis,
      'objectives': instance.objectives,
      'parameters': instance.parameters,
      'jobs': instance.jobs,
      'status': _$QuantumExperimentStatusEnumMap[instance.status]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'researcherId': instance.researcherId,
      'collaborators': instance.collaborators,
      'results': instance.results,
      'metrics': instance.metrics,
      'conclusions': instance.conclusions,
      'metadata': instance.metadata,
    };

const _$QuantumExperimentStatusEnumMap = {
  QuantumExperimentStatus.planning: 'planning',
  QuantumExperimentStatus.active: 'active',
  QuantumExperimentStatus.paused: 'paused',
  QuantumExperimentStatus.completed: 'completed',
  QuantumExperimentStatus.cancelled: 'cancelled',
  QuantumExperimentStatus.failed: 'failed',
};

QuantumResource _$QuantumResourceFromJson(Map<String, dynamic> json) =>
    QuantumResource(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$QuantumResourceTypeEnumMap, json['type']),
      location: json['location'] as String,
      specifications: json['specifications'] as Map<String, dynamic>,
      status: $enumDecode(_$QuantumResourceStatusEnumMap, json['status']),
      lastMaintenance: DateTime.parse(json['lastMaintenance'] as String),
      utilizationMetrics: (json['utilizationMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      supportedOperations: (json['supportedOperations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QuantumResourceToJson(QuantumResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$QuantumResourceTypeEnumMap[instance.type]!,
      'location': instance.location,
      'specifications': instance.specifications,
      'status': _$QuantumResourceStatusEnumMap[instance.status]!,
      'lastMaintenance': instance.lastMaintenance.toIso8601String(),
      'utilizationMetrics': instance.utilizationMetrics,
      'supportedOperations': instance.supportedOperations,
      'metadata': instance.metadata,
    };

const _$QuantumResourceTypeEnumMap = {
  QuantumResourceType.processor: 'processor',
  QuantumResourceType.memory: 'memory',
  QuantumResourceType.network: 'network',
  QuantumResourceType.storage: 'storage',
  QuantumResourceType.cooling: 'cooling',
  QuantumResourceType.power: 'power',
  QuantumResourceType.control: 'control',
  QuantumResourceType.measurement: 'measurement',
};

const _$QuantumResourceStatusEnumMap = {
  QuantumResourceStatus.offline: 'offline',
  QuantumResourceStatus.available: 'available',
  QuantumResourceStatus.busy: 'busy',
  QuantumResourceStatus.maintenance: 'maintenance',
  QuantumResourceStatus.error: 'error',
  QuantumResourceStatus.reserved: 'reserved',
};

QuantumPerformanceReport _$QuantumPerformanceReportFromJson(
  Map<String, dynamic> json,
) => QuantumPerformanceReport(
  id: json['id'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  generatedBy: json['generatedBy'] as String,
  processors: (json['processors'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, QuantumProcessor.fromJson(e as Map<String, dynamic>)),
  ),
  algorithms: (json['algorithms'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, QuantumAlgorithm.fromJson(e as Map<String, dynamic>)),
  ),
  models: (json['models'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, QuantumModel.fromJson(e as Map<String, dynamic>)),
  ),
  recentJobs: (json['recentJobs'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, QuantumJob.fromJson(e as Map<String, dynamic>)),
  ),
  systemMetrics: (json['systemMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumPerformanceReportToJson(
  QuantumPerformanceReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'generatedBy': instance.generatedBy,
  'processors': instance.processors,
  'algorithms': instance.algorithms,
  'models': instance.models,
  'recentJobs': instance.recentJobs,
  'systemMetrics': instance.systemMetrics,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
