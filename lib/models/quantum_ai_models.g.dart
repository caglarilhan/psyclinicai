// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantum_ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuantumAIModel _$QuantumAIModelFromJson(Map<String, dynamic> json) =>
    QuantumAIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      algorithmType: $enumDecode(
        _$QuantumAlgorithmTypeEnumMap,
        json['algorithmType'],
      ),
      hardwareType: $enumDecode(
        _$QuantumHardwareTypeEnumMap,
        json['hardwareType'],
      ),
      qubitCount: (json['qubitCount'] as num).toInt(),
      coherenceTime: (json['coherenceTime'] as num).toDouble(),
      gateFidelity: (json['gateFidelity'] as num).toDouble(),
      errorRate: (json['errorRate'] as num).toDouble(),
      parameters: json['parameters'] as Map<String, dynamic>,
      performance: json['performance'] as Map<String, dynamic>,
      isTrained: json['isTrained'] as bool,
      isDeployed: json['isDeployed'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QuantumAIModelToJson(QuantumAIModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'algorithmType': _$QuantumAlgorithmTypeEnumMap[instance.algorithmType]!,
      'hardwareType': _$QuantumHardwareTypeEnumMap[instance.hardwareType]!,
      'qubitCount': instance.qubitCount,
      'coherenceTime': instance.coherenceTime,
      'gateFidelity': instance.gateFidelity,
      'errorRate': instance.errorRate,
      'parameters': instance.parameters,
      'performance': instance.performance,
      'isTrained': instance.isTrained,
      'isDeployed': instance.isDeployed,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$QuantumAlgorithmTypeEnumMap = {
  QuantumAlgorithmType.grover: 'grover',
  QuantumAlgorithmType.shor: 'shor',
  QuantumAlgorithmType.quantum_fourier: 'quantum_fourier',
  QuantumAlgorithmType.quantum_ml: 'quantum_ml',
  QuantumAlgorithmType.quantum_annealing: 'quantum_annealing',
  QuantumAlgorithmType.vqe: 'vqe',
  QuantumAlgorithmType.qaoa: 'qaoa',
};

const _$QuantumHardwareTypeEnumMap = {
  QuantumHardwareType.superconducting: 'superconducting',
  QuantumHardwareType.trapped_ion: 'trapped_ion',
  QuantumHardwareType.photonic: 'photonic',
  QuantumHardwareType.topological: 'topological',
  QuantumHardwareType.silicon: 'silicon',
  QuantumHardwareType.nitrogen_vacancy: 'nitrogen_vacancy',
};

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
      parameters: json['parameters'] as Map<String, dynamic>,
      initialState: $enumDecode(_$QuantumStateEnumMap, json['initialState']),
      targetState: $enumDecode(_$QuantumStateEnumMap, json['targetState']),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QuantumCircuitToJson(QuantumCircuit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'qubitCount': instance.qubitCount,
      'depth': instance.depth,
      'gates': instance.gates,
      'parameters': instance.parameters,
      'initialState': _$QuantumStateEnumMap[instance.initialState]!,
      'targetState': _$QuantumStateEnumMap[instance.targetState]!,
      'metadata': instance.metadata,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$QuantumStateEnumMap = {
  QuantumState.ground: 'ground',
  QuantumState.excited: 'excited',
  QuantumState.superposition: 'superposition',
  QuantumState.entangled: 'entangled',
  QuantumState.mixed: 'mixed',
};

QuantumGate _$QuantumGateFromJson(Map<String, dynamic> json) => QuantumGate(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  qubits: (json['qubits'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  parameters: json['parameters'] as Map<String, dynamic>,
  duration: (json['duration'] as num).toDouble(),
  fidelity: (json['fidelity'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumGateToJson(QuantumGate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'qubits': instance.qubits,
      'parameters': instance.parameters,
      'duration': instance.duration,
      'fidelity': instance.fidelity,
      'metadata': instance.metadata,
    };

QuantumTrainingSession _$QuantumTrainingSessionFromJson(
  Map<String, dynamic> json,
) => QuantumTrainingSession(
  id: json['id'] as String,
  modelId: json['modelId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  algorithmType: $enumDecode(
    _$QuantumAlgorithmTypeEnumMap,
    json['algorithmType'],
  ),
  hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
  iterationCount: (json['iterationCount'] as num).toInt(),
  learningRate: (json['learningRate'] as num).toDouble(),
  convergenceThreshold: (json['convergenceThreshold'] as num).toDouble(),
  trainingData: json['trainingData'] as Map<String, dynamic>,
  validationData: json['validationData'] as Map<String, dynamic>,
  results: json['results'] as Map<String, dynamic>,
  isCompleted: json['isCompleted'] as bool,
  isSuccessful: json['isSuccessful'] as bool,
  status: json['status'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  duration: (json['duration'] as num).toInt(),
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumTrainingSessionToJson(
  QuantumTrainingSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'modelId': instance.modelId,
  'name': instance.name,
  'description': instance.description,
  'algorithmType': _$QuantumAlgorithmTypeEnumMap[instance.algorithmType]!,
  'hyperparameters': instance.hyperparameters,
  'iterationCount': instance.iterationCount,
  'learningRate': instance.learningRate,
  'convergenceThreshold': instance.convergenceThreshold,
  'trainingData': instance.trainingData,
  'validationData': instance.validationData,
  'results': instance.results,
  'isCompleted': instance.isCompleted,
  'isSuccessful': instance.isSuccessful,
  'status': instance.status,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'duration': instance.duration,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

QuantumOptimizationProblem _$QuantumOptimizationProblemFromJson(
  Map<String, dynamic> json,
) => QuantumOptimizationProblem(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  problemType: json['problemType'] as String,
  variableCount: (json['variableCount'] as num).toInt(),
  constraints: json['constraints'] as Map<String, dynamic>,
  objectiveFunction: json['objectiveFunction'] as Map<String, dynamic>,
  parameters: json['parameters'] as Map<String, dynamic>,
  algorithmType: $enumDecode(
    _$QuantumAlgorithmTypeEnumMap,
    json['algorithmType'],
  ),
  solution: json['solution'] as Map<String, dynamic>,
  optimalValue: (json['optimalValue'] as num).toDouble(),
  isSolved: json['isSolved'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumOptimizationProblemToJson(
  QuantumOptimizationProblem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'problemType': instance.problemType,
  'variableCount': instance.variableCount,
  'constraints': instance.constraints,
  'objectiveFunction': instance.objectiveFunction,
  'parameters': instance.parameters,
  'algorithmType': _$QuantumAlgorithmTypeEnumMap[instance.algorithmType]!,
  'solution': instance.solution,
  'optimalValue': instance.optimalValue,
  'isSolved': instance.isSolved,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

QuantumEncryption _$QuantumEncryptionFromJson(Map<String, dynamic> json) =>
    QuantumEncryption(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      encryptionType: json['encryptionType'] as String,
      keyLength: (json['keyLength'] as num).toInt(),
      keyDistributionMethod: json['keyDistributionMethod'] as String,
      securityLevel: (json['securityLevel'] as num).toDouble(),
      parameters: json['parameters'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QuantumEncryptionToJson(QuantumEncryption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'encryptionType': instance.encryptionType,
      'keyLength': instance.keyLength,
      'keyDistributionMethod': instance.keyDistributionMethod,
      'securityLevel': instance.securityLevel,
      'parameters': instance.parameters,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

QuantumMLModel _$QuantumMLModelFromJson(Map<String, dynamic> json) =>
    QuantumMLModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      modelType: json['modelType'] as String,
      algorithmType: $enumDecode(
        _$QuantumAlgorithmTypeEnumMap,
        json['algorithmType'],
      ),
      featureCount: (json['featureCount'] as num).toInt(),
      outputClasses: (json['outputClasses'] as num).toInt(),
      architecture: json['architecture'] as Map<String, dynamic>,
      hyperparameters: json['hyperparameters'] as Map<String, dynamic>,
      trainingMetrics: json['trainingMetrics'] as Map<String, dynamic>,
      validationMetrics: json['validationMetrics'] as Map<String, dynamic>,
      isTrained: json['isTrained'] as bool,
      isDeployed: json['isDeployed'] as bool,
      lastTrained: DateTime.parse(json['lastTrained'] as String),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QuantumMLModelToJson(QuantumMLModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'modelType': instance.modelType,
      'algorithmType': _$QuantumAlgorithmTypeEnumMap[instance.algorithmType]!,
      'featureCount': instance.featureCount,
      'outputClasses': instance.outputClasses,
      'architecture': instance.architecture,
      'hyperparameters': instance.hyperparameters,
      'trainingMetrics': instance.trainingMetrics,
      'validationMetrics': instance.validationMetrics,
      'isTrained': instance.isTrained,
      'isDeployed': instance.isDeployed,
      'lastTrained': instance.lastTrained.toIso8601String(),
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

QuantumHardwareConfig _$QuantumHardwareConfigFromJson(
  Map<String, dynamic> json,
) => QuantumHardwareConfig(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  hardwareType: $enumDecode(_$QuantumHardwareTypeEnumMap, json['hardwareType']),
  qubitCount: (json['qubitCount'] as num).toInt(),
  coherenceTime: (json['coherenceTime'] as num).toDouble(),
  gateFidelity: (json['gateFidelity'] as num).toDouble(),
  errorRate: (json['errorRate'] as num).toDouble(),
  specifications: json['specifications'] as Map<String, dynamic>,
  calibration: json['calibration'] as Map<String, dynamic>,
  isOnline: json['isOnline'] as bool,
  isCalibrated: json['isCalibrated'] as bool,
  lastCalibration: DateTime.parse(json['lastCalibration'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumHardwareConfigToJson(
  QuantumHardwareConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'hardwareType': _$QuantumHardwareTypeEnumMap[instance.hardwareType]!,
  'qubitCount': instance.qubitCount,
  'coherenceTime': instance.coherenceTime,
  'gateFidelity': instance.gateFidelity,
  'errorRate': instance.errorRate,
  'specifications': instance.specifications,
  'calibration': instance.calibration,
  'isOnline': instance.isOnline,
  'isCalibrated': instance.isCalibrated,
  'lastCalibration': instance.lastCalibration.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

QuantumErrorCorrectionCode _$QuantumErrorCorrectionCodeFromJson(
  Map<String, dynamic> json,
) => QuantumErrorCorrectionCode(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  codeType: $enumDecode(_$QuantumErrorCorrectionEnumMap, json['codeType']),
  logicalQubits: (json['logicalQubits'] as num).toInt(),
  physicalQubits: (json['physicalQubits'] as num).toInt(),
  distance: (json['distance'] as num).toInt(),
  errorThreshold: (json['errorThreshold'] as num).toDouble(),
  parameters: json['parameters'] as Map<String, dynamic>,
  isImplemented: json['isImplemented'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumErrorCorrectionCodeToJson(
  QuantumErrorCorrectionCode instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'codeType': _$QuantumErrorCorrectionEnumMap[instance.codeType]!,
  'logicalQubits': instance.logicalQubits,
  'physicalQubits': instance.physicalQubits,
  'distance': instance.distance,
  'errorThreshold': instance.errorThreshold,
  'parameters': instance.parameters,
  'isImplemented': instance.isImplemented,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

const _$QuantumErrorCorrectionEnumMap = {
  QuantumErrorCorrection.surface_code: 'surface_code',
  QuantumErrorCorrection.stabilizer_code: 'stabilizer_code',
  QuantumErrorCorrection.color_code: 'color_code',
  QuantumErrorCorrection.steane_code: 'steane_code',
  QuantumErrorCorrection.shor_code: 'shor_code',
};

QuantumSimulationResult _$QuantumSimulationResultFromJson(
  Map<String, dynamic> json,
) => QuantumSimulationResult(
  id: json['id'] as String,
  simulationId: json['simulationId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  inputParameters: json['inputParameters'] as Map<String, dynamic>,
  outputResults: json['outputResults'] as Map<String, dynamic>,
  executionTime: (json['executionTime'] as num).toDouble(),
  iterationCount: (json['iterationCount'] as num).toInt(),
  accuracy: (json['accuracy'] as num).toDouble(),
  isSuccessful: json['isSuccessful'] as bool,
  status: json['status'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumSimulationResultToJson(
  QuantumSimulationResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'simulationId': instance.simulationId,
  'name': instance.name,
  'description': instance.description,
  'inputParameters': instance.inputParameters,
  'outputResults': instance.outputResults,
  'executionTime': instance.executionTime,
  'iterationCount': instance.iterationCount,
  'accuracy': instance.accuracy,
  'isSuccessful': instance.isSuccessful,
  'status': instance.status,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

QuantumResearchProject _$QuantumResearchProjectFromJson(
  Map<String, dynamic> json,
) => QuantumResearchProject(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  researchArea: json['researchArea'] as String,
  researchers: (json['researchers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  collaborators: (json['collaborators'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  objectives: json['objectives'] as Map<String, dynamic>,
  methodology: json['methodology'] as Map<String, dynamic>,
  results: json['results'] as Map<String, dynamic>,
  status: json['status'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  budget: (json['budget'] as num).toDouble(),
  fundingSource: json['fundingSource'] as String,
  publications: (json['publications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuantumResearchProjectToJson(
  QuantumResearchProject instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'researchArea': instance.researchArea,
  'researchers': instance.researchers,
  'collaborators': instance.collaborators,
  'objectives': instance.objectives,
  'methodology': instance.methodology,
  'results': instance.results,
  'status': instance.status,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'budget': instance.budget,
  'fundingSource': instance.fundingSource,
  'publications': instance.publications,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};
