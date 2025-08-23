import 'package:json_annotation/json_annotation.dart';

part 'quantum_ai_models.g.dart';

/// Quantum AI Models for PsyClinicAI
/// Provides cutting-edge quantum computing integration for healthcare AI

@JsonSerializable()
class QuantumCircuit {
  final String id;
  final String name;
  final String description;
  final int qubitCount;
  final int depth;
  final List<QuantumGate> gates;
  final QuantumCircuitType type;
  final Map<String, dynamic> parameters;
  final DateTime createdAt;
  final DateTime lastModified;
  final String createdBy;
  final QuantumCircuitStatus status;
  final Map<String, double> performanceMetrics;

  const QuantumCircuit({
    required this.id,
    required this.name,
    required this.description,
    required this.qubitCount,
    required this.depth,
    required this.gates,
    required this.type,
    required this.parameters,
    required this.createdAt,
    required this.lastModified,
    required this.createdBy,
    required this.status,
    required this.performanceMetrics,
  });

  factory QuantumCircuit.fromJson(Map<String, dynamic> json) => _$QuantumCircuitFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumCircuitToJson(this);

  bool get isOptimized => performanceMetrics['fidelity'] != null && performanceMetrics['fidelity']! > 0.95;
  bool get isProductionReady => status == QuantumCircuitStatus.production;
  double get estimatedRuntime => (qubitCount * depth * 0.001); // Estimated runtime in seconds
}

enum QuantumCircuitType { 
  variational, 
  quantumFourier, 
  quantumPhase, 
  quantumAmplitude, 
  quantumMachineLearning,
  quantumOptimization,
  quantumSimulation,
  quantumErrorCorrection,
  quantumRandomWalk,
  quantumTeleportation
}

enum QuantumCircuitStatus { 
  design, 
  testing, 
  optimization, 
  validation, 
  production, 
  deprecated 
}

@JsonSerializable()
class QuantumGate {
  final String id;
  final String name;
  final QuantumGateType type;
  final List<int> qubits;
  final Map<String, dynamic> parameters;
  final double duration;
  final double errorRate;
  final Map<String, dynamic> metadata;

  const QuantumGate({
    required this.id,
    required this.name,
    required this.type,
    required this.qubits,
    required this.parameters,
    required this.duration,
    required this.errorRate,
    required this.metadata,
  });

  factory QuantumGate.fromJson(Map<String, dynamic> json) => _$QuantumGateFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumGateToJson(this);

  bool get isSingleQubit => qubits.length == 1;
  bool get isMultiQubit => qubits.length > 1;
  bool get isHighFidelity => errorRate < 0.001;
}

enum QuantumGateType { 
  hadamard, 
  pauliX, 
  pauliY, 
  pauliZ, 
  phase, 
  rotationX, 
  rotationY, 
  rotationZ, 
  cnot, 
  swap, 
  toffoli, 
  fredkin,
  controlledPhase,
  controlledRotation,
  custom
}

@JsonSerializable()
class QuantumProcessor {
  final String id;
  final String name;
  final String manufacturer;
  final QuantumProcessorType type;
  final int qubitCount;
  final int maxQubits;
  final double coherenceTime;
  final double gateFidelity;
  final double readoutFidelity;
  final List<String> supportedGates;
  final Map<String, dynamic> specifications;
  final QuantumProcessorStatus status;
  final DateTime lastCalibration;
  final Map<String, double> performanceMetrics;

  const QuantumProcessor({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.type,
    required this.qubitCount,
    required this.maxQubits,
    required this.coherenceTime,
    required this.gateFidelity,
    required this.readoutFidelity,
    required this.supportedGates,
    required this.specifications,
    required this.status,
    required this.lastCalibration,
    required this.performanceMetrics,
  });

  factory QuantumProcessor.fromJson(Map<String, dynamic> json) => _$QuantumProcessorFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumProcessorToJson(this);

  bool get isAvailable => status == QuantumProcessorStatus.available;
  bool get needsCalibration => DateTime.now().difference(lastCalibration).inDays > 7;
  double get quantumVolume => qubitCount * (gateFidelity * readoutFidelity);
  bool get isHighPerformance => quantumVolume > 100;
}

enum QuantumProcessorType { 
  superconducting, 
  trappedIon, 
  topological, 
  photonic, 
  neutralAtom, 
  silicon, 
  diamondNV, 
  hybrid 
}

enum QuantumProcessorStatus { 
  offline, 
  maintenance, 
  available, 
  busy, 
  error, 
  calibrating 
}

@JsonSerializable()
class QuantumAlgorithm {
  final String id;
  final String name;
  final String description;
  final QuantumAlgorithmType type;
  final List<String> applications;
  final int complexityClass;
  final Map<String, dynamic> parameters;
  final List<QuantumCircuit> circuits;
  final Map<String, double> performanceMetrics;
  final DateTime createdAt;
  final String createdBy;
  final QuantumAlgorithmStatus status;
  final List<String> references;
  final Map<String, dynamic> metadata;

  const QuantumAlgorithm({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.applications,
    required this.complexityClass,
    required this.parameters,
    required this.circuits,
    required this.performanceMetrics,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    required this.references,
    required this.metadata,
  });

  factory QuantumAlgorithm.fromJson(Map<String, dynamic> json) => _$QuantumAlgorithmFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumAlgorithmToJson(this);

  bool get isQuantumSupremacy => complexityClass == 1;
  bool get isHybrid => type == QuantumAlgorithmType.hybrid;
  double get successRate => performanceMetrics['success_rate'] ?? 0.0;
  bool get isProductionReady => status == QuantumAlgorithmStatus.production;
}

enum QuantumAlgorithmType { 
  quantumMachineLearning, 
  quantumOptimization, 
  quantumSimulation, 
  quantumCryptography, 
  quantumErrorCorrection,
  quantumChemistry,
  quantumFinance,
  quantumLogistics,
  hybrid,
  custom
}

enum QuantumAlgorithmStatus { 
  research, 
  development, 
  testing, 
  validation, 
  production, 
  deprecated 
}

@JsonSerializable()
class QuantumJob {
  final String id;
  final String name;
  final String description;
  final QuantumJobType type;
  final String algorithmId;
  final String processorId;
  final Map<String, dynamic> parameters;
  final QuantumJobStatus status;
  final DateTime submittedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final Map<String, dynamic> results;
  final Map<String, double> metrics;
  final List<String> logs;
  final String submittedBy;
  final int priority;
  final Map<String, dynamic> metadata;

  const QuantumJob({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.algorithmId,
    required this.processorId,
    required this.parameters,
    required this.status,
    required this.submittedAt,
    this.startedAt,
    this.completedAt,
    this.failedAt,
    required this.results,
    required this.metrics,
    required this.logs,
    required this.submittedBy,
    required this.priority,
    required this.metadata,
  });

  factory QuantumJob.fromJson(Map<String, dynamic> json) => _$QuantumJobFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumJobToJson(this);

  bool get isCompleted => status == QuantumJobStatus.completed;
  bool get isFailed => status == QuantumJobStatus.failed;
  bool get isRunning => status == QuantumJobStatus.running;
  Duration get runtime {
    if (startedAt == null || completedAt == null) return Duration.zero;
    return completedAt!.difference(startedAt!);
  }
  double get successRate => metrics['success_rate'] ?? 0.0;
}

enum QuantumJobType { 
  training, 
  inference, 
  optimization, 
  simulation, 
  analysis, 
  research 
}

enum QuantumJobStatus { 
  queued, 
  running, 
  completed, 
  failed, 
  cancelled, 
  paused 
}

@JsonSerializable()
class QuantumModel {
  final String id;
  final String name;
  final String description;
  final QuantumModelType type;
  final String algorithmId;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> weights;
  final Map<String, double> performanceMetrics;
  final DateTime trainedAt;
  final String trainedBy;
  final QuantumModelStatus status;
  final List<String> supportedTasks;
  final Map<String, dynamic> metadata;
  final int version;
  final String parentModelId;

  const QuantumModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.algorithmId,
    required this.hyperparameters,
    required this.weights,
    required this.performanceMetrics,
    required this.trainedAt,
    required this.trainedBy,
    required this.status,
    required this.supportedTasks,
    required this.metadata,
    required this.version,
    required this.parentModelId,
  });

  factory QuantumModel.fromJson(Map<String, dynamic> json) => _$QuantumModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumModelToJson(this);

  bool get isProductionReady => status == QuantumModelStatus.production;
  bool get isLatestVersion => version > 0;
  double get accuracy => performanceMetrics['accuracy'] ?? 0.0;
  bool get isQuantumEnhanced => type == QuantumModelType.quantumEnhanced;
}

enum QuantumModelType { 
  classical, 
  quantum, 
  quantumEnhanced, 
  hybrid, 
  ensemble 
}

enum QuantumModelStatus { 
  training, 
  testing, 
  validation, 
  production, 
  deprecated 
}

@JsonSerializable()
class QuantumExperiment {
  final String id;
  final String name;
  final String description;
  final String hypothesis;
  final List<String> objectives;
  final Map<String, dynamic> parameters;
  final List<QuantumJob> jobs;
  final QuantumExperimentStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String researcherId;
  final List<String> collaborators;
  final Map<String, dynamic> results;
  final Map<String, double> metrics;
  final List<String> conclusions;
  final Map<String, dynamic> metadata;

  const QuantumExperiment({
    required this.id,
    required this.name,
    required this.description,
    required this.hypothesis,
    required this.objectives,
    required this.parameters,
    required this.jobs,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.researcherId,
    required this.collaborators,
    required this.results,
    required this.metrics,
    required this.conclusions,
    required this.metadata,
  });

  factory QuantumExperiment.fromJson(Map<String, dynamic> json) => _$QuantumExperimentFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumExperimentToJson(this);

  bool get isCompleted => status == QuantumExperimentStatus.completed;
  bool get isActive => status == QuantumExperimentStatus.active;
  Duration get duration {
    if (endDate == null) return DateTime.now().difference(startDate);
    return endDate!.difference(startDate);
  }
  int get totalJobs => jobs.length;
  int get completedJobs => jobs.where((job) => job.isCompleted).length;
  double get completionRate => totalJobs > 0 ? completedJobs / totalJobs : 0.0;
}

enum QuantumExperimentStatus { 
  planning, 
  active, 
  paused, 
  completed, 
  cancelled, 
  failed 
}

@JsonSerializable()
class QuantumResource {
  final String id;
  final String name;
  final QuantumResourceType type;
  final String location;
  final Map<String, dynamic> specifications;
  final QuantumResourceStatus status;
  final DateTime lastMaintenance;
  final Map<String, double> utilizationMetrics;
  final List<String> supportedOperations;
  final Map<String, dynamic> metadata;

  const QuantumResource({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.specifications,
    required this.status,
    required this.lastMaintenance,
    required this.utilizationMetrics,
    required this.supportedOperations,
    required this.metadata,
  });

  factory QuantumResource.fromJson(Map<String, dynamic> json) => _$QuantumResourceFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumResourceToJson(this);

  bool get isAvailable => status == QuantumResourceStatus.available;
  bool get needsMaintenance => DateTime.now().difference(lastMaintenance).inDays > 30;
  double get utilizationRate => utilizationMetrics['utilization_rate'] ?? 0.0;
  bool get isOverutilized => utilizationRate > 0.9;
}

enum QuantumResourceType { 
  processor, 
  memory, 
  network, 
  storage, 
  cooling, 
  power, 
  control, 
  measurement 
}

enum QuantumResourceStatus { 
  offline, 
  available, 
  busy, 
  maintenance, 
  error, 
  reserved 
}

@JsonSerializable()
class QuantumPerformanceReport {
  final String id;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, QuantumProcessor> processors;
  final Map<String, QuantumAlgorithm> algorithms;
  final Map<String, QuantumModel> models;
  final Map<String, QuantumJob> recentJobs;
  final Map<String, double> systemMetrics;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const QuantumPerformanceReport({
    required this.id,
    required this.generatedAt,
    required this.generatedBy,
    required this.processors,
    required this.algorithms,
    required this.models,
    required this.recentJobs,
    required this.systemMetrics,
    required this.recommendations,
    required this.metadata,
  });

  factory QuantumPerformanceReport.fromJson(Map<String, dynamic> json) => _$QuantumPerformanceReportFromJson(json);
  Map<String, dynamic> toJson() => _$QuantumPerformanceReportToJson(this);

  int get totalProcessors => processors.length;
  int get totalAlgorithms => algorithms.length;
  int get totalModels => models.length;
  int get totalJobs => recentJobs.length;
  double get overallSystemHealth => systemMetrics['system_health'] ?? 0.0;
  bool get systemNeedsAttention => overallSystemHealth < 0.7;
}
