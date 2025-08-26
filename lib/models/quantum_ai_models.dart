import 'package:json_annotation/json_annotation.dart';

part 'quantum_ai_models.g.dart';

/// Quantum Computing Type - Kuantum hesaplama türleri
enum QuantumComputingType {
  @JsonValue('superposition') superposition,     // Süperpozisyon
  @JsonValue('entanglement') entanglement,       // Dolanıklık
  @JsonValue('interference') interference,       // Girişim
  @JsonValue('tunneling') tunneling,             // Tünelleme
  @JsonValue('coherence') coherence,             // Tutarlılık
}

/// Quantum Algorithm Type - Kuantum algoritma türleri
enum QuantumAlgorithmType {
  @JsonValue('grover') grover,                   // Grover Arama Algoritması
  @JsonValue('shor') shor,                       // Shor Faktörizasyon
  @JsonValue('quantum_fourier') quantum_fourier, // Kuantum Fourier Dönüşümü
  @JsonValue('quantum_ml') quantum_ml,           // Kuantum Machine Learning
  @JsonValue('quantum_annealing') quantum_annealing, // Kuantum Tavlama
  @JsonValue('vqe') vqe,                         // Variational Quantum Eigensolver
  @JsonValue('qaoa') qaoa,                       // Quantum Approximate Optimization
}

/// Quantum Hardware Type - Kuantum donanım türleri
enum QuantumHardwareType {
  @JsonValue('superconducting') superconducting, // Süperiletken kubitler
  @JsonValue('trapped_ion') trapped_ion,         // Yakalanmış iyonlar
  @JsonValue('photonic') photonic,               // Fotonik kubitler
  @JsonValue('topological') topological,         // Topolojik kubitler
  @JsonValue('silicon') silicon,                 // Silikon kubitler
  @JsonValue('nitrogen_vacancy') nitrogen_vacancy, // Azot boşluğu
}

/// Quantum State - Kuantum durumu
enum QuantumState {
  @JsonValue('ground') ground,                   // Temel durum
  @JsonValue('excited') excited,                 // Uyarılmış durum
  @JsonValue('superposition') superposition,     // Süperpozisyon
  @JsonValue('entangled') entangled,             // Dolanık durum
  @JsonValue('mixed') mixed,                     // Karışık durum
}

/// Quantum Error Correction - Kuantum hata düzeltme
enum QuantumErrorCorrection {
  @JsonValue('surface_code') surface_code,       // Yüzey kodu
  @JsonValue('stabilizer_code') stabilizer_code, // Stabilizatör kodu
  @JsonValue('color_code') color_code,           // Renk kodu
  @JsonValue('steane_code') steane_code,         // Steane kodu
  @JsonValue('shor_code') shor_code,             // Shor kodu
}

/// Quantum AI Model - Kuantum AI modeli
@JsonSerializable()
class QuantumAIModel {
  final String id;
  final String name;
  final String description;
  final QuantumAlgorithmType algorithmType;
  final QuantumHardwareType hardwareType;
  final int qubitCount;
  final double coherenceTime; // microseconds
  final double gateFidelity;
  final double errorRate;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> performance;
  final bool isTrained;
  final bool isDeployed;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumAIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.algorithmType,
    required this.hardwareType,
    required this.qubitCount,
    required this.coherenceTime,
    required this.gateFidelity,
    required this.errorRate,
    required this.parameters,
    required this.performance,
    required this.isTrained,
    required this.isDeployed,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumAIModel.fromJson(Map<String, dynamic> json) =>
      _$QuantumAIModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumAIModelToJson(this);
}

/// Quantum Circuit - Kuantum devre
@JsonSerializable()
class QuantumCircuit {
  final String id;
  final String name;
  final String description;
  final int qubitCount;
  final int depth;
  final List<QuantumGate> gates;
  final Map<String, dynamic> parameters;
  final QuantumState initialState;
  final QuantumState targetState;
  final Map<String, dynamic> metadata;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuantumCircuit({
    required this.id,
    required this.name,
    required this.description,
    required this.qubitCount,
    required this.depth,
    required this.gates,
    required this.parameters,
    required this.initialState,
    required this.targetState,
    required this.metadata,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuantumCircuit.fromJson(Map<String, dynamic> json) =>
      _$QuantumCircuitFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumCircuitToJson(this);
}

/// Quantum Gate - Kuantum kapı
@JsonSerializable()
class QuantumGate {
  final String id;
  final String name;
  final String type;
  final List<int> qubits;
  final Map<String, dynamic> parameters;
  final double duration; // nanoseconds
  final double fidelity;
  final Map<String, dynamic> metadata;

  const QuantumGate({
    required this.id,
    required this.name,
    required this.type,
    required this.qubits,
    required this.parameters,
    required this.duration,
    required this.fidelity,
    required this.metadata,
  });

  factory QuantumGate.fromJson(Map<String, dynamic> json) =>
      _$QuantumGateFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumGateToJson(this);
}

/// Quantum Training Session - Kuantum eğitim oturumu
@JsonSerializable()
class QuantumTrainingSession {
  final String id;
  final String modelId;
  final String name;
  final String description;
  final QuantumAlgorithmType algorithmType;
  final Map<String, dynamic> hyperparameters;
  final int iterationCount;
  final double learningRate;
  final double convergenceThreshold;
  final Map<String, dynamic> trainingData;
  final Map<String, dynamic> validationData;
  final Map<String, dynamic> results;
  final bool isCompleted;
  final bool isSuccessful;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // seconds
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumTrainingSession({
    required this.id,
    required this.modelId,
    required this.name,
    required this.description,
    required this.algorithmType,
    required this.hyperparameters,
    required this.iterationCount,
    required this.learningRate,
    required this.convergenceThreshold,
    required this.trainingData,
    required this.validationData,
    required this.results,
    required this.isCompleted,
    required this.isSuccessful,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumTrainingSession.fromJson(Map<String, dynamic> json) =>
      _$QuantumTrainingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumTrainingSessionToJson(this);
}

/// Quantum Optimization Problem - Kuantum optimizasyon problemi
@JsonSerializable()
class QuantumOptimizationProblem {
  final String id;
  final String name;
  final String description;
  final String problemType;
  final int variableCount;
  final Map<String, dynamic> constraints;
  final Map<String, dynamic> objectiveFunction;
  final Map<String, dynamic> parameters;
  final QuantumAlgorithmType algorithmType;
  final Map<String, dynamic> solution;
  final double optimalValue;
  final bool isSolved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumOptimizationProblem({
    required this.id,
    required this.name,
    required this.description,
    required this.problemType,
    required this.variableCount,
    required this.constraints,
    required this.objectiveFunction,
    required this.parameters,
    required this.algorithmType,
    required this.solution,
    required this.optimalValue,
    required this.isSolved,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumOptimizationProblem.fromJson(Map<String, dynamic> json) =>
      _$QuantumOptimizationProblemFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumOptimizationProblemToJson(this);
}

/// Quantum Encryption - Kuantum şifreleme
@JsonSerializable()
class QuantumEncryption {
  final String id;
  final String name;
  final String description;
  final String encryptionType;
  final int keyLength;
  final String keyDistributionMethod;
  final double securityLevel;
  final Map<String, dynamic> parameters;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumEncryption({
    required this.id,
    required this.name,
    required this.description,
    required this.encryptionType,
    required this.keyLength,
    required this.keyDistributionMethod,
    required this.securityLevel,
    required this.parameters,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumEncryption.fromJson(Map<String, dynamic> json) =>
      _$QuantumEncryptionFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumEncryptionToJson(this);
}

/// Quantum Machine Learning Model - Kuantum Machine Learning modeli
@JsonSerializable()
class QuantumMLModel {
  final String id;
  final String name;
  final String description;
  final String modelType;
  final QuantumAlgorithmType algorithmType;
  final int featureCount;
  final int outputClasses;
  final Map<String, dynamic> architecture;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> trainingMetrics;
  final Map<String, dynamic> validationMetrics;
  final bool isTrained;
  final bool isDeployed;
  final DateTime lastTrained;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumMLModel({
    required this.id,
    required this.name,
    required this.description,
    required this.modelType,
    required this.algorithmType,
    required this.featureCount,
    required this.outputClasses,
    required this.architecture,
    required this.hyperparameters,
    required this.trainingMetrics,
    required this.validationMetrics,
    required this.isTrained,
    required this.isDeployed,
    required this.lastTrained,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumMLModel.fromJson(Map<String, dynamic> json) =>
      _$QuantumMLModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumMLModelToJson(this);
}

/// Quantum Hardware Configuration - Kuantum donanım konfigürasyonu
@JsonSerializable()
class QuantumHardwareConfig {
  final String id;
  final String name;
  final String description;
  final QuantumHardwareType hardwareType;
  final int qubitCount;
  final double coherenceTime;
  final double gateFidelity;
  final double errorRate;
  final Map<String, dynamic> specifications;
  final Map<String, dynamic> calibration;
  final bool isOnline;
  final bool isCalibrated;
  final DateTime lastCalibration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumHardwareConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.hardwareType,
    required this.qubitCount,
    required this.coherenceTime,
    required this.gateFidelity,
    required this.errorRate,
    required this.specifications,
    required this.calibration,
    required this.isOnline,
    required this.isCalibrated,
    required this.lastCalibration,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumHardwareConfig.fromJson(Map<String, dynamic> json) =>
      _$QuantumHardwareConfigFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumHardwareConfigToJson(this);
}

/// Quantum Error Correction Code - Kuantum hata düzeltme kodu
@JsonSerializable()
class QuantumErrorCorrectionCode {
  final String id;
  final String name;
  final String description;
  final QuantumErrorCorrection codeType;
  final int logicalQubits;
  final int physicalQubits;
  final int distance;
  final double errorThreshold;
  final Map<String, dynamic> parameters;
  final bool isImplemented;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumErrorCorrectionCode({
    required this.id,
    required this.name,
    required this.description,
    required this.codeType,
    required this.logicalQubits,
    required this.physicalQubits,
    required this.distance,
    required this.errorThreshold,
    required this.parameters,
    required this.isImplemented,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumErrorCorrectionCode.fromJson(Map<String, dynamic> json) =>
      _$QuantumErrorCorrectionCodeFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumErrorCorrectionCodeToJson(this);
}

/// Quantum Simulation Result - Kuantum simülasyon sonucu
@JsonSerializable()
class QuantumSimulationResult {
  final String id;
  final String simulationId;
  final String name;
  final String description;
  final Map<String, dynamic> inputParameters;
  final Map<String, dynamic> outputResults;
  final double executionTime;
  final int iterationCount;
  final double accuracy;
  final bool isSuccessful;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumSimulationResult({
    required this.id,
    required this.simulationId,
    required this.name,
    required this.description,
    required this.inputParameters,
    required this.outputResults,
    required this.executionTime,
    required this.iterationCount,
    required this.accuracy,
    required this.isSuccessful,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumSimulationResult.fromJson(Map<String, dynamic> json) =>
      _$QuantumSimulationResultFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumSimulationResultToJson(this);
}

/// Quantum Research Project - Kuantum araştırma projesi
@JsonSerializable()
class QuantumResearchProject {
  final String id;
  final String name;
  final String description;
  final String researchArea;
  final List<String> researchers;
  final List<String> collaborators;
  final Map<String, dynamic> objectives;
  final Map<String, dynamic> methodology;
  final Map<String, dynamic> results;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final double budget;
  final String fundingSource;
  final List<String> publications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const QuantumResearchProject({
    required this.id,
    required this.name,
    required this.description,
    required this.researchArea,
    required this.researchers,
    required this.collaborators,
    required this.objectives,
    required this.methodology,
    required this.results,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.budget,
    required this.fundingSource,
    required this.publications,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory QuantumResearchProject.fromJson(Map<String, dynamic> json) =>
      _$QuantumResearchProjectFromJson(json);

  Map<String, dynamic> toJson() => _$QuantumResearchProjectToJson(this);
}
