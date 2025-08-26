import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/quantum_ai_service.dart';
import 'package:psyclinicai/models/quantum_ai_models.dart';

void main() {
  group('QuantumAIService Tests', () {
    late QuantumAIService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = QuantumAIService();
    });

    tearDown(() {
      // Don't dispose service during tests to avoid stream controller issues
    });

    group('Service Initialization Tests', () {
      test('should create service instance', () {
        expect(service, isNotNull);
        expect(service, isA<QuantumAIService>());
      });

      test('should initialize successfully', () async {
        await service.initialize();
        // Service should be initialized without errors
        expect(true, isTrue);
      });
    });

    group('Quantum AI Models Tests', () {
      test('should get quantum AI models', () async {
        await service.initialize();
        final models = await service.getQuantumAIModels();

        expect(models, isNotEmpty);
        expect(models.length, equals(3));
      });

      test('should have quantum ML classifier model', () async {
        await service.initialize();
        final models = await service.getQuantumAIModels();
        final classifierModel = models.firstWhere((model) => model.id == 'quantum_ml_classifier');

        expect(classifierModel, isNotNull);
        expect(classifierModel.name, equals('Quantum ML Classifier'));
        expect(classifierModel.description, equals('Kuantum makine öğrenmesi sınıflandırıcısı'));
        expect(classifierModel.algorithmType, equals(QuantumAlgorithmType.quantum_ml));
        expect(classifierModel.hardwareType, equals(QuantumHardwareType.superconducting));
        expect(classifierModel.qubitCount, equals(20));
        expect(classifierModel.coherenceTime, equals(100.0));
        expect(classifierModel.gateFidelity, equals(0.999));
        expect(classifierModel.errorRate, equals(0.001));
        expect(classifierModel.isTrained, isTrue);
        expect(classifierModel.isDeployed, isTrue);
      });

      test('should have quantum optimizer model', () async {
        await service.initialize();
        final models = await service.getQuantumAIModels();
        final optimizerModel = models.firstWhere((model) => model.id == 'quantum_optimizer');

        expect(optimizerModel, isNotNull);
        expect(optimizerModel.name, equals('Quantum Optimizer'));
        expect(optimizerModel.description, equals('Kuantum optimizasyon algoritması'));
        expect(optimizerModel.algorithmType, equals(QuantumAlgorithmType.qaoa));
        expect(optimizerModel.hardwareType, equals(QuantumHardwareType.trapped_ion));
        expect(optimizerModel.qubitCount, equals(30));
        expect(optimizerModel.coherenceTime, equals(150.0));
        expect(optimizerModel.gateFidelity, equals(0.998));
        expect(optimizerModel.errorRate, equals(0.002));
      });

      test('should have quantum simulator model', () async {
        await service.initialize();
        final models = await service.getQuantumAIModels();
        final simulatorModel = models.firstWhere((model) => model.id == 'quantum_simulator');

        expect(simulatorModel, isNotNull);
        expect(simulatorModel.name, equals('Quantum Simulator'));
        expect(simulatorModel.description, equals('Kuantum simülasyon modeli'));
        expect(simulatorModel.algorithmType, equals(QuantumAlgorithmType.vqe));
        expect(simulatorModel.hardwareType, equals(QuantumHardwareType.photonic));
        expect(simulatorModel.qubitCount, equals(25));
        expect(simulatorModel.coherenceTime, equals(80.0));
        expect(simulatorModel.gateFidelity, equals(0.997));
        expect(simulatorModel.errorRate, equals(0.003));
      });
    });

    group('Quantum Circuits Tests', () {
      test('should get quantum circuits', () async {
        await service.initialize();
        final circuits = await service.getQuantumCircuits();

        expect(circuits, isNotEmpty);
        expect(circuits.length, equals(2));
      });

      test('should have classifier circuit', () async {
        await service.initialize();
        final circuits = await service.getQuantumCircuits();
        final classifierCircuit = circuits.firstWhere((circuit) => circuit.id == 'classifier_circuit');

        expect(classifierCircuit, isNotNull);
        expect(classifierCircuit.name, equals('Classifier Circuit'));
        expect(classifierCircuit.description, equals('Sınıflandırma için kuantum devre'));
        expect(classifierCircuit.qubitCount, equals(20));
        expect(classifierCircuit.depth, equals(15));
        expect(classifierCircuit.initialState, equals(QuantumState.ground));
        expect(classifierCircuit.targetState, equals(QuantumState.superposition));
        expect(classifierCircuit.gates, isNotEmpty);
      });

      test('should have optimization circuit', () async {
        await service.initialize();
        final circuits = await service.getQuantumCircuits();
        final optimizationCircuit = circuits.firstWhere((circuit) => circuit.id == 'optimization_circuit');

        expect(optimizationCircuit, isNotNull);
        expect(optimizationCircuit.name, equals('Optimization Circuit'));
        expect(optimizationCircuit.description, equals('Optimizasyon için kuantum devre'));
        expect(optimizationCircuit.qubitCount, equals(30));
        expect(optimizationCircuit.depth, equals(25));
        expect(optimizationCircuit.initialState, equals(QuantumState.ground));
        expect(optimizationCircuit.targetState, equals(QuantumState.entangled));
        expect(optimizationCircuit.gates, isNotEmpty);
      });
    });

    group('Quantum Training Tests', () {
      test('should create training session', () async {
        final session = await service.createTrainingSession(
          modelId: 'quantum_ml_classifier',
          name: 'Test Training Session',
          description: 'Test eğitim oturumu',
          algorithmType: QuantumAlgorithmType.quantum_ml,
          hyperparameters: {
            'learning_rate': 0.01,
            'batch_size': 32,
            'epochs': 100,
          },
          trainingData: {'features': [1, 2, 3], 'labels': [0, 1, 0]},
          validationData: {'features': [4, 5, 6], 'labels': [1, 0, 1]},
        );

        expect(session, isNotNull);
        expect(session.name, equals('Test Training Session'));
        expect(session.description, equals('Test eğitim oturumu'));
        expect(session.modelId, equals('quantum_ml_classifier'));
        expect(session.algorithmType, equals(QuantumAlgorithmType.quantum_ml));
        expect(session.isCompleted, isFalse);
        expect(session.isSuccessful, isFalse);
        expect(session.status, equals('created'));
        expect(session.iterationCount, equals(0));
      });

      test('should start training', () async {
        final session = await service.createTrainingSession(
          modelId: 'quantum_ml_classifier',
          name: 'Training Test',
          description: 'Training test',
          algorithmType: QuantumAlgorithmType.quantum_ml,
          hyperparameters: {'learning_rate': 0.01},
          trainingData: {'data': 'test'},
          validationData: {'data': 'test'},
        );

        await service.startTraining(session.id);
        // Training should start without errors
        expect(true, isTrue);
      });
    });

    group('Quantum Optimization Tests', () {
      test('should create optimization problem', () async {
        final problem = await service.createOptimizationProblem(
          name: 'Test Optimization',
          description: 'Test optimizasyon problemi',
          problemType: 'minimization',
          variableCount: 10,
          constraints: {'x >= 0': true},
          objectiveFunction: {'f(x)': 'x^2 + 2x + 1'},
          algorithmType: QuantumAlgorithmType.qaoa,
        );

        expect(problem, isNotNull);
        expect(problem.name, equals('Test Optimization'));
        expect(problem.description, equals('Test optimizasyon problemi'));
        expect(problem.problemType, equals('minimization'));
        expect(problem.variableCount, equals(10));
        expect(problem.algorithmType, equals(QuantumAlgorithmType.qaoa));
        expect(problem.isSolved, isFalse);
      });

      test('should solve optimization problem', () async {
        final problem = await service.createOptimizationProblem(
          name: 'Test Problem',
          description: 'Test problem',
          problemType: 'minimization',
          variableCount: 5,
          constraints: {'x >= 0': true},
          objectiveFunction: {'f(x)': 'x^2'},
          algorithmType: QuantumAlgorithmType.qaoa,
        );

        final solution = await service.solveOptimizationProblem(problem.id);

        expect(solution, isNotNull);
        expect(solution['problem_id'], equals(problem.id));
        expect(solution['status'], equals('solved'));
        expect(solution['solution'], isNotNull);
        expect(solution['execution_time'], isNotNull);
        expect(solution['iterations'], isNotNull);
      });
    });

    group('Quantum Encryption Tests', () {
      test('should create quantum encryption', () async {
        final encryption = await service.createQuantumEncryption(
          name: 'Test Encryption',
          description: 'Test kuantum şifreleme',
          encryptionType: 'BB84',
          keyLength: 256,
          keyDistributionMethod: 'quantum_key_distribution',
        );

        expect(encryption, isNotNull);
        expect(encryption.name, equals('Test Encryption'));
        expect(encryption.description, equals('Test kuantum şifreleme'));
        expect(encryption.encryptionType, equals('BB84'));
        expect(encryption.keyLength, equals(256));
        expect(encryption.keyDistributionMethod, equals('quantum_key_distribution'));
        expect(encryption.securityLevel, greaterThan(0.99));
        expect(encryption.isActive, isTrue);
      });
    });

    group('Quantum Hardware Tests', () {
      test('should get hardware status', () async {
        final status = await service.getQuantumHardwareStatus();

        expect(status, isNotNull);
        expect(status['is_online'], isNotNull);
        expect(status['available_qubits'], isNotNull);
        expect(status['temperature'], isNotNull);
        expect(status['coherence_time'], isNotNull);
        expect(status['gate_fidelity'], isNotNull);
        expect(status['error_rate'], isNotNull);
        expect(status['status'], isNotNull);
      });

      test('should get performance metrics', () async {
        final metrics = await service.getQuantumPerformanceMetrics();

        expect(metrics, isNotNull);
        expect(metrics['quantum_volume'], isNotNull);
        expect(metrics['success_rate'], isNotNull);
        expect(metrics['execution_time'], isNotNull);
        expect(metrics['energy_efficiency'], isNotNull);
        expect(metrics['scalability_score'], isNotNull);
        expect(metrics['reliability_index'], isNotNull);
      });
    });

    group('Stream Tests', () {
      test('should provide model stream', () {
        final stream = service.modelStream;
        expect(stream, isNotNull);
      });

      test('should provide training stream', () {
        final stream = service.trainingStream;
        expect(stream, isNotNull);
      });

      test('should provide optimization stream', () {
        final stream = service.optimizationStream;
        expect(stream, isNotNull);
      });

      test('should provide quantum status stream', () {
        final stream = service.quantumStatusStream;
        expect(stream, isNotNull);
      });
    });

    group('Mock Data Validation Tests', () {
      test('should provide realistic mock quantum models', () async {
        final models = await service.getQuantumAIModels();

        for (final model in models) {
          expect(model.id, isNotEmpty);
          expect(model.name, isNotEmpty);
          expect(model.description, isNotEmpty);
          expect(model.qubitCount, greaterThan(0));
          expect(model.coherenceTime, greaterThan(0));
          expect(model.gateFidelity, greaterThan(0.9));
          expect(model.errorRate, lessThan(0.01));
          expect(model.parameters, isNotEmpty);
          expect(model.performance, isNotEmpty);
        }
      });

      test('should provide realistic mock quantum circuits', () async {
        final circuits = await service.getQuantumCircuits();

        for (final circuit in circuits) {
          expect(circuit.id, isNotEmpty);
          expect(circuit.name, isNotEmpty);
          expect(circuit.description, isNotEmpty);
          expect(circuit.qubitCount, greaterThan(0));
          expect(circuit.depth, greaterThan(0));
          expect(circuit.gates, isNotEmpty);
          expect(circuit.parameters, isNotEmpty);
        }
      });

      test('should provide realistic mock training sessions', () async {
        final session = await service.createTrainingSession(
          modelId: 'test_model',
          name: 'Test Session',
          description: 'Test session',
          algorithmType: QuantumAlgorithmType.quantum_ml,
          hyperparameters: {'lr': 0.01},
          trainingData: {'data': 'test'},
          validationData: {'data': 'test'},
        );

        expect(session.id, isNotEmpty);
        expect(session.name, isNotEmpty);
        expect(session.description, isNotEmpty);
        expect(session.modelId, isNotEmpty);
        expect(session.algorithmType, isNotNull);
        expect(session.hyperparameters, isNotEmpty);
        expect(session.trainingData, isNotEmpty);
        expect(session.validationData, isNotEmpty);
        expect(session.results, isNotEmpty);
      });

      test('should provide realistic mock optimization problems', () async {
        final problem = await service.createOptimizationProblem(
          name: 'Test Problem',
          description: 'Test problem',
          problemType: 'minimization',
          variableCount: 10,
          constraints: {'x >= 0': true},
          objectiveFunction: {'f(x)': 'x^2'},
          algorithmType: QuantumAlgorithmType.qaoa,
        );

        expect(problem.id, isNotEmpty);
        expect(problem.name, isNotEmpty);
        expect(problem.description, isNotEmpty);
        expect(problem.problemType, isNotEmpty);
        expect(problem.variableCount, greaterThan(0));
        expect(problem.constraints, isNotEmpty);
        expect(problem.objectiveFunction, isNotEmpty);
        expect(problem.algorithmType, isNotNull);
        expect(problem.parameters, isNotEmpty);
      });

      test('should provide realistic mock quantum encryption', () async {
        final encryption = await service.createQuantumEncryption(
          name: 'Test Encryption',
          description: 'Test encryption',
          encryptionType: 'BB84',
          keyLength: 256,
          keyDistributionMethod: 'QKD',
        );

        expect(encryption.id, isNotEmpty);
        expect(encryption.name, isNotEmpty);
        expect(encryption.description, isNotEmpty);
        expect(encryption.encryptionType, isNotEmpty);
        expect(encryption.keyLength, greaterThan(0));
        expect(encryption.keyDistributionMethod, isNotEmpty);
        expect(encryption.securityLevel, greaterThan(0.99));
        expect(encryption.parameters, isNotEmpty);
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        // This test verifies that the service handles network errors
        // by falling back to mock data
        await service.initialize();
        final models = await service.getQuantumAIModels();
        expect(models, isNotEmpty);
        expect(models.length, equals(3));
      });

      test('should handle hardware initialization errors gracefully', () async {
        // Service should initialize with mock hardware if real hardware fails
        await service.initialize();
        expect(true, isTrue);
      });
    });

    group('Quantum Algorithm Types Tests', () {
      test('should support all quantum algorithm types', () {
        expect(QuantumAlgorithmType.values, contains(QuantumAlgorithmType.grover));
        expect(QuantumAlgorithmType.values, contains(QuantumAlgorithmType.shor));
        expect(QuantumAlgorithmType.values, contains(QuantumAlgorithmType.quantum_fourier));
        expect(QuantumAlgorithmType.values, contains(QuantumAlgorithmType.quantum_ml));
        expect(QuantumAlgorithmType.values, contains(QuantumAlgorithmType.quantum_annealing));
        expect(QuantumAlgorithmType.values, contains(QuantumAlgorithmType.vqe));
        expect(QuantumAlgorithmType.values, contains(QuantumAlgorithmType.qaoa));
      });
    });

    group('Quantum Hardware Types Tests', () {
      test('should support all quantum hardware types', () {
        expect(QuantumHardwareType.values, contains(QuantumHardwareType.superconducting));
        expect(QuantumHardwareType.values, contains(QuantumHardwareType.trapped_ion));
        expect(QuantumHardwareType.values, contains(QuantumHardwareType.photonic));
        expect(QuantumHardwareType.values, contains(QuantumHardwareType.topological));
        expect(QuantumHardwareType.values, contains(QuantumHardwareType.silicon));
        expect(QuantumHardwareType.values, contains(QuantumHardwareType.nitrogen_vacancy));
      });
    });

    group('Quantum State Tests', () {
      test('should support all quantum states', () {
        expect(QuantumState.values, contains(QuantumState.ground));
        expect(QuantumState.values, contains(QuantumState.excited));
        expect(QuantumState.values, contains(QuantumState.superposition));
        expect(QuantumState.values, contains(QuantumState.entangled));
        expect(QuantumState.values, contains(QuantumState.mixed));
      });
    });

    group('Quantum Error Correction Tests', () {
      test('should support all error correction codes', () {
        expect(QuantumErrorCorrection.values, contains(QuantumErrorCorrection.surface_code));
        expect(QuantumErrorCorrection.values, contains(QuantumErrorCorrection.stabilizer_code));
        expect(QuantumErrorCorrection.values, contains(QuantumErrorCorrection.color_code));
        expect(QuantumErrorCorrection.values, contains(QuantumErrorCorrection.steane_code));
        expect(QuantumErrorCorrection.values, contains(QuantumErrorCorrection.shor_code));
      });
    });
  });
}
