import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai_training_service.dart';
import 'package:psyclinicai/models/ai_training_models.dart';

void main() {
  group('AITrainingService Tests', () {
    late AITrainingService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = AITrainingService();
    });

    tearDown(() {
      // Don't dispose service during tests to avoid stream controller issues
    });

    group('Dataset Management Tests', () {
      test('should return training datasets', () async {
        final datasets = await service.getTrainingDatasets();
        
        expect(datasets, isNotEmpty);
        expect(datasets.length, equals(2));
        
        final firstDataset = datasets.first;
        expect(firstDataset.name, equals('Mental Health Assessment Data'));
        expect(firstDataset.dataType, equals(TrainingDataType.tabular));
        expect(firstDataset.totalSamples, equals(10000));
        expect(firstDataset.quality, equals(DataQuality.excellent));
      });

      test('should cache datasets after first fetch', () async {
        // First fetch
        final datasets1 = await service.getTrainingDatasets();
        expect(datasets1.length, equals(2));
        
        // Second fetch should use cache
        final datasets2 = await service.getTrainingDatasets();
        expect(datasets2.length, equals(2));
        expect(datasets1.length, equals(datasets2.length));
      });
    });

    group('Model Definition Tests', () {
      test('should return AI model definitions', () async {
        final models = await service.getAIModelDefinitions();
        
        expect(models, isNotEmpty);
        expect(models.length, equals(2));
        
        final firstModel = models.first;
        expect(firstModel.name, equals('Mental Health Classifier'));
        expect(firstModel.architecture, equals(ModelArchitecture.transformer));
        expect(firstModel.framework, equals(TrainingFramework.pytorch));
        expect(firstModel.parameterCount, equals(125000000));
      });

      test('should cache models after first fetch', () async {
        // First fetch
        final models1 = await service.getAIModelDefinitions();
        expect(models1.length, equals(2));
        
        // Second fetch should use cache
        final models2 = await service.getAIModelDefinitions();
        expect(models2.length, equals(2));
        expect(models1.length, equals(models2.length));
      });
    });

    group('Training Session Tests', () {
      test('should create training session', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training Session',
          description: 'A test training session for mental health classification',
          hyperparameters: {
            'learning_rate': 0.001,
            'batch_size': 32,
            'epochs': 100,
          },
          trainingConfig: {
            'optimizer': 'adam',
            'loss_function': 'cross_entropy',
            'validation_split': 0.2,
          },
          totalEpochs: 100,
          createdBy: 'test_user',
        );

        expect(session, isNotNull);
        expect(session.id, isNotEmpty);
        expect(session.name, equals('Test Training Session'));
        expect(session.status, equals(TrainingStatus.pending));
        expect(session.modelId, equals('model_001'));
        expect(session.datasetId, equals('dataset_001'));
        expect(session.totalEpochs, equals(100));
        expect(session.createdBy, equals('test_user'));
      });

      test('should get training session by ID', () {
        // Create a session first
        service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Session',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 50,
        ).then((session) {
          final retrievedSession = service.getTrainingSession(session.id);
          expect(retrievedSession, isNotNull);
          expect(retrievedSession!.id, equals(session.id));
          expect(retrievedSession.name, equals('Test Session'));
        });
      });

      test('should get all training sessions', () async {
        // Create multiple sessions
        await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Session 1',
          description: 'First session',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 50,
        );

        await service.createTrainingSession(
          modelId: 'model_002',
          datasetId: 'dataset_002',
          name: 'Session 2',
          description: 'Second session',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 75,
        );

        final sessions = service.getAllTrainingSessions();
        expect(sessions.length, greaterThanOrEqualTo(1));
      });
    });

    group('Training Control Tests', () {
      test('should start training session', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 10,
        );

        final success = await service.startTraining(session.id);
        expect(success, isTrue);

        final updatedSession = service.getTrainingSession(session.id);
        expect(updatedSession!.status, equals(TrainingStatus.inProgress));
      });

      test('should pause training session', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 10,
        );

        await service.startTraining(session.id);
        final success = await service.pauseTraining(session.id);
        expect(success, isTrue);

        final updatedSession = service.getTrainingSession(session.id);
        expect(updatedSession!.status, equals(TrainingStatus.paused));
      });

      test('should resume training session', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 10,
        );

        await service.startTraining(session.id);
        await service.pauseTraining(session.id);
        final success = await service.resumeTraining(session.id);
        expect(success, isTrue);

        final updatedSession = service.getTrainingSession(session.id);
        expect(updatedSession!.status, equals(TrainingStatus.inProgress));
      });

      test('should stop training session', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 10,
        );

        await service.startTraining(session.id);
        final success = await service.stopTraining(session.id);
        expect(success, isTrue);

        final updatedSession = service.getTrainingSession(session.id);
        expect(updatedSession!.status, equals(TrainingStatus.cancelled));
      });

      test('should not start non-existent session', () async {
        final success = await service.startTraining('non_existent_session');
        expect(success, isFalse);
      });

      test('should not pause non-running session', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 10,
        );

        final success = await service.pauseTraining(session.id);
        expect(success, isFalse);
      });
    });

    group('Training Progress Tests', () {
      test('should update training progress', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 10,
        );

        final progress = TrainingProgress(
          id: 'progress_001',
          sessionId: session.id,
          currentEpoch: 5,
          totalEpochs: 10,
          progress: 0.5,
          currentLoss: 0.3,
          currentAccuracy: 0.85,
          learningRate: 0.001,
          metrics: {'loss': 0.3, 'accuracy': 0.85},
          status: 'training',
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        service.updateTrainingProgress(progress);

        final updatedSession = service.getTrainingSession(session.id);
        expect(updatedSession!.currentEpoch, equals(5));
        expect(updatedSession.currentLoss, equals(0.3));
        expect(updatedSession.currentAccuracy, equals(0.85));
      });

      test('should complete training when epochs reach total', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 2,
        );

        // Simulate progress to completion
        final progress1 = TrainingProgress(
          id: 'progress_001',
          sessionId: session.id,
          currentEpoch: 1,
          totalEpochs: 2,
          progress: 0.5,
          currentLoss: 0.5,
          currentAccuracy: 0.7,
          learningRate: 0.001,
          metrics: {'loss': 0.5, 'accuracy': 0.7},
          status: 'training',
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final progress2 = TrainingProgress(
          id: 'progress_002',
          sessionId: session.id,
          currentEpoch: 2,
          totalEpochs: 2,
          progress: 1.0,
          currentLoss: 0.2,
          currentAccuracy: 0.9,
          learningRate: 0.001,
          metrics: {'loss': 0.2, 'accuracy': 0.9},
          status: 'training',
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        service.updateTrainingProgress(progress1);
        service.updateTrainingProgress(progress2);

        final completedSession = service.getTrainingSession(session.id);
        expect(completedSession!.status, equals(TrainingStatus.completed));
        expect(completedSession.currentEpoch, equals(2));
      });
    });

    group('Trained Models Tests', () {
      test('should create trained model after completion', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 2,
        );

        // Complete training
        final progress = TrainingProgress(
          id: 'progress_001',
          sessionId: session.id,
          currentEpoch: 2,
          totalEpochs: 2,
          progress: 1.0,
          currentLoss: 0.2,
          currentAccuracy: 0.9,
          learningRate: 0.001,
          metrics: {'loss': 0.2, 'accuracy': 0.9},
          status: 'training',
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        service.updateTrainingProgress(progress);

        final trainedModels = service.getTrainedModels();
        expect(trainedModels, isNotEmpty);
        
        final trainedModel = trainedModels.first;
        expect(trainedModel.sessionId, equals(session.id));
        expect(trainedModel.name, contains('Test Training'));
        expect(trainedModel.status, equals('ready'));
        expect(trainedModel.isDeployed, isFalse);
      });

      test('should deploy trained model', () async {
        // Create and complete a training session first
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 2,
        );

        final progress = TrainingProgress(
          id: 'progress_001',
          sessionId: session.id,
          currentEpoch: 2,
          totalEpochs: 2,
          progress: 1.0,
          currentLoss: 0.2,
          currentAccuracy: 0.9,
          learningRate: 0.001,
          metrics: {'loss': 0.2, 'accuracy': 0.9},
          status: 'training',
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        service.updateTrainingProgress(progress);

        final trainedModels = service.getTrainedModels();
        expect(trainedModels, isNotEmpty);

        final success = await service.deployModel(trainedModels.first.id, 'production');
        expect(success, isTrue);

        final deployedModel = service.getTrainedModels().first;
        expect(deployedModel.status, equals('deployed'));
        expect(deployedModel.isDeployed, isTrue);
      });

      test('should not deploy non-existent model', () async {
        final success = await service.deployModel('non_existent_model', 'production');
        expect(success, isFalse);
      });
    });

    group('Model Evaluation Tests', () {
      test('should evaluate trained model', () async {
        // Create and complete a training session first
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 2,
        );

        final progress = TrainingProgress(
          id: 'progress_001',
          sessionId: session.id,
          currentEpoch: 2,
          totalEpochs: 2,
          progress: 1.0,
          currentLoss: 0.2,
          currentAccuracy: 0.9,
          learningRate: 0.001,
          metrics: {'loss': 0.2, 'accuracy': 0.9},
          status: 'training',
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        service.updateTrainingProgress(progress);

        final trainedModels = service.getTrainedModels();
        expect(trainedModels, isNotEmpty);

        final evaluation = await service.evaluateModel(trainedModels.first.id, 'dataset_001');
        expect(evaluation, isNotNull);
        expect(evaluation.modelId, equals(trainedModels.first.id));
        expect(evaluation.datasetId, equals('dataset_001'));
        expect(evaluation.metrics['accuracy'], equals(0.92));
        expect(evaluation.metrics['precision'], equals(0.89));
        expect(evaluation.metrics['recall'], equals(0.94));
      });

      test('should throw exception for non-existent model evaluation', () async {
        expect(
          () => service.evaluateModel('non_existent_model', 'dataset_001'),
          throwsException,
        );
      });
    });

    group('Training Configuration Tests', () {
      test('should create training configuration', () async {
        final config = await service.createTrainingConfiguration(
          name: 'Test Config',
          description: 'Test training configuration',
          hyperparameters: {
            'learning_rate': 0.001,
            'batch_size': 32,
            'epochs': 100,
          },
          dataConfig: {
            'validation_split': 0.2,
            'augmentation': true,
          },
          modelConfig: {
            'architecture': 'transformer',
            'layers': 6,
          },
          optimizerConfig: {
            'type': 'adam',
            'weight_decay': 0.01,
          },
          createdBy: 'test_user',
        );

        expect(config, isNotNull);
        expect(config.name, equals('Test Config'));
        expect(config.description, equals('Test training configuration'));
        expect(config.hyperparameters['learning_rate'], equals(0.001));
        expect(config.dataConfig['validation_split'], equals(0.2));
        expect(config.modelConfig['architecture'], equals('transformer'));
        expect(config.optimizerConfig['type'], equals('adam'));
        expect(config.createdBy, equals('test_user'));
        expect(config.isActive, isTrue);
      });

      test('should create preprocessing pipeline', () async {
        final pipeline = await service.createPreprocessingPipeline(
          name: 'Test Pipeline',
          description: 'Test preprocessing pipeline',
          steps: ['normalization', 'encoding', 'scaling'],
          configuration: {
            'normalization': 'standard',
            'encoding': 'one_hot',
            'scaling': 'min_max',
          },
          createdBy: 'test_user',
        );

        expect(pipeline, isNotNull);
        expect(pipeline.name, equals('Test Pipeline'));
        expect(pipeline.description, equals('Test preprocessing pipeline'));
        expect(pipeline.steps, equals(['normalization', 'encoding', 'scaling']));
        expect(pipeline.configuration['normalization'], equals('standard'));
        expect(pipeline.createdBy, equals('test_user'));
        expect(pipeline.isActive, isTrue);
      });
    });

    group('Training Statistics Tests', () {
      test('should return training statistics', () async {
        // Create some training sessions
        await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Session 1',
          description: 'First session',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 50,
        );

        await service.createTrainingSession(
          modelId: 'model_002',
          datasetId: 'dataset_002',
          name: 'Session 2',
          description: 'Second session',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 75,
        );

        final stats = service.getTrainingStatistics();
        expect(stats, isNotNull);
        expect(stats['total_sessions'], greaterThanOrEqualTo(1));
        expect(stats['completed_sessions'], isA<int>());
        expect(stats['failed_sessions'], isA<int>());
        expect(stats['active_sessions'], isA<int>());
        expect(stats['success_rate'], isA<double>());
        expect(stats['average_training_time'], isA<double>());
      });
    });

    group('Stream Tests', () {
      test('should emit training progress updates', () async {
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 5,
        );

        final progressUpdates = <TrainingProgress>[];
        final subscription = service.trainingProgressStream.listen(progressUpdates.add);

        // Start training to trigger progress updates
        await service.startTraining(session.id);

        // Wait for some progress updates
        await Future.delayed(const Duration(seconds: 3));

        expect(progressUpdates, isNotEmpty);
        expect(progressUpdates.first.sessionId, equals(session.id));

        subscription.cancel();
      });

      test('should emit training session updates', () async {
        final sessionUpdates = <TrainingSession>[];
        final subscription = service.trainingSessionStream.listen(sessionUpdates.add);

        // Create a session to trigger updates
        await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 10,
        );

        expect(sessionUpdates, isNotEmpty);
        expect(sessionUpdates.first.name, equals('Test Training'));

        subscription.cancel();
      });

      test('should emit trained model updates', () async {
        final modelUpdates = <TrainedModel>[];
        final subscription = service.trainedModelStream.listen(modelUpdates.add);

        // Create and complete a training session to trigger model creation
        final session = await service.createTrainingSession(
          modelId: 'model_001',
          datasetId: 'dataset_001',
          name: 'Test Training',
          description: 'Test description',
          hyperparameters: {},
          trainingConfig: {},
          totalEpochs: 2,
        );

        final progress = TrainingProgress(
          id: 'progress_001',
          sessionId: session.id,
          currentEpoch: 2,
          totalEpochs: 2,
          progress: 1.0,
          currentLoss: 0.2,
          currentAccuracy: 0.9,
          learningRate: 0.001,
          metrics: {'loss': 0.2, 'accuracy': 0.9},
          status: 'training',
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        service.updateTrainingProgress(progress);

        // Wait for model creation
        await Future.delayed(const Duration(milliseconds: 100));

        expect(modelUpdates, isNotEmpty);
        expect(modelUpdates.first.sessionId, equals(session.id));

        subscription.cancel();
      });
    });

    group('Error Handling Tests', () {
      test('should handle invalid session operations gracefully', () async {
        // Try to start non-existent session
        final startResult = await service.startTraining('invalid_id');
        expect(startResult, isFalse);

        // Try to pause non-existent session
        final pauseResult = await service.pauseTraining('invalid_id');
        expect(pauseResult, isFalse);

        // Try to stop non-existent session
        final stopResult = await service.stopTraining('invalid_id');
        expect(stopResult, isFalse);
      });

      test('should handle invalid model operations gracefully', () async {
        // Try to deploy non-existent model
        final deployResult = await service.deployModel('invalid_id', 'production');
        expect(deployResult, isFalse);

        // Try to evaluate non-existent model
        expect(
          () => service.evaluateModel('invalid_id', 'dataset_001'),
          throwsException,
        );
      });
    });
  });
}
