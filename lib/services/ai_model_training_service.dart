import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:psyclinicai/models/ai_training_models.dart';

/// AI Model Training Service for PsyClinicAI
/// Handles training jobs, custom models, datasets, and templates
class AIModelTrainingService {
  static final AIModelTrainingService _instance = AIModelTrainingService._internal();
  factory AIModelTrainingService() => _instance;
  AIModelTrainingService._internal();

  // Mock data storage
  final List<TrainingJob> _trainingJobs = [];
  final List<CustomModel> _customModels = [];
  final List<Dataset> _datasets = [];
  final List<ModelTemplate> _templates = [];
  
  // Stream controllers for real-time updates
  final StreamController<TrainingJob> _trainingJobController = StreamController<TrainingJob>.broadcast();
  final StreamController<CustomModel> _customModelController = StreamController<CustomModel>.broadcast();
  final StreamController<String> _trainingLogController = StreamController<String>.broadcast();
  
  // Streams
  Stream<TrainingJob> get trainingJobStream => _trainingJobController.stream;
  Stream<CustomModel> get customModelStream => _customModelController.stream;
  Stream<String> get trainingLogStream => _trainingLogController.stream;

  /// Initialize the training service
  Future<void> initialize() async {
    print('🚀 Initializing AI Model Training Service...');
    
    // Initialize mock data
    _initializeMockData();
    
    print('✅ AI Model Training Service initialized successfully');
  }

  /// Initialize mock data
  void _initializeMockData() {
    // Mock datasets
    _datasets.addAll([
      Dataset(
        id: 'ds_001',
        name: 'Depression Screening Dataset',
        description: 'Comprehensive dataset for depression screening with patient responses and clinical assessments',
        format: DatasetFormat.csv,
        samples: 5000,
        features: 25,
        size: 15.2,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        quality: 0.92,
        trainSplit: 0.7,
        validationSplit: 0.15,
        testSplit: 0.15,
        schema: {'patient_id': 'string', 'age': 'int', 'gender': 'string'},
        columns: ['patient_id', 'age', 'gender', 'phq9_score', 'gad7_score'],
        statistics: {'mean_age': 35.2, 'gender_distribution': {'M': 0.45, 'F': 0.55}},
        tags: ['depression', 'screening', 'mental_health'],
      ),
      Dataset(
        id: 'ds_002',
        name: 'Anxiety Disorder Classification',
        description: 'Dataset for classifying different types of anxiety disorders',
        format: DatasetFormat.json,
        samples: 3200,
        features: 18,
        size: 8.7,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        quality: 0.89,
        trainSplit: 0.75,
        validationSplit: 0.15,
        testSplit: 0.1,
        schema: {'case_id': 'string', 'diagnosis': 'string', 'symptoms': 'array'},
        columns: ['case_id', 'diagnosis', 'symptoms', 'severity', 'duration'],
        statistics: {'case_count': 3200, 'diagnosis_distribution': {'GAD': 0.4, 'PTSD': 0.3, 'OCD': 0.3}},
        tags: ['anxiety', 'classification', 'disorders'],
      ),
      Dataset(
        id: 'ds_003',
        name: 'Suicide Risk Assessment',
        description: 'Dataset for assessing suicide risk based on various clinical indicators',
        format: DatasetFormat.parquet,
        samples: 1800,
        features: 32,
        size: 12.1,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        quality: 0.95,
        trainSplit: 0.8,
        validationSplit: 0.1,
        testSplit: 0.1,
        schema: {'assessment_id': 'string', 'risk_level': 'string', 'indicators': 'array'},
        columns: ['assessment_id', 'risk_level', 'indicators', 'previous_attempts', 'protective_factors'],
        statistics: {'risk_distribution': {'low': 0.6, 'medium': 0.3, 'high': 0.1}},
        tags: ['suicide', 'risk_assessment', 'crisis'],
      ),
    ]);

    // Mock model templates
    _templates.addAll([
      ModelTemplate(
        id: 'tmpl_001',
        name: 'BERT-Base-Psychology',
        description: 'BERT model fine-tuned for psychological text analysis',
        category: ModelCategory.diagnosis,
        architecture: 'Transformer',
        parameters: 110,
        size: 420.0,
        supportedTasks: ['text_classification', 'sentiment_analysis', 'named_entity_recognition'],
        defaultHyperparameters: {
          'learning_rate': 2e-5,
          'batch_size': 16,
          'epochs': 3,
          'max_length': 512,
        },
        constraints: {'max_sequence_length': 512, 'min_samples': 100},
        requirements: ['torch>=1.9.0', 'transformers>=4.5.0'],
        paperUrl: 'https://arxiv.org/abs/1810.04805',
        repositoryUrl: 'https://github.com/huggingface/transformers',
      ),
      ModelTemplate(
        id: 'tmpl_002',
        name: 'ResNet-50-Mental-Health',
        description: 'ResNet-50 adapted for mental health image analysis',
        category: ModelCategory.screening,
        architecture: 'CNN',
        parameters: 25,
        size: 98.0,
        supportedTasks: ['image_classification', 'object_detection', 'feature_extraction'],
        defaultHyperparameters: {
          'learning_rate': 1e-4,
          'batch_size': 32,
          'epochs': 50,
          'image_size': 224,
        },
        constraints: {'min_image_size': 224, 'max_image_size': 512},
        requirements: ['torch>=1.8.0', 'torchvision>=0.9.0'],
        paperUrl: 'https://arxiv.org/abs/1512.03385',
        repositoryUrl: 'https://github.com/pytorch/vision',
      ),
      ModelTemplate(
        id: 'tmpl_003',
        name: 'LSTM-Emotion-Analysis',
        description: 'LSTM model for sequential emotion analysis from voice data',
        category: ModelCategory.monitoring,
        architecture: 'RNN',
        parameters: 8,
        size: 32.0,
        supportedTasks: ['sequence_classification', 'time_series_analysis', 'emotion_detection'],
        defaultHyperparameters: {
          'learning_rate': 1e-3,
          'batch_size': 64,
          'epochs': 100,
          'sequence_length': 100,
        },
        constraints: {'min_sequence_length': 50, 'max_sequence_length': 500},
        requirements: ['torch>=1.7.0', 'numpy>=1.19.0'],
        paperUrl: 'https://arxiv.org/abs/1503.04069',
        repositoryUrl: 'https://github.com/pytorch/pytorch',
      ),
    ]);

    // Mock training jobs
    _trainingJobs.addAll([
      TrainingJob(
        id: 'job_001',
        modelName: 'Depression Screening v1.0',
        description: 'Custom model for depression screening based on patient responses',
        category: ModelCategory.screening,
        templateId: 'tmpl_001',
        templateName: 'BERT-Base-Psychology',
        datasetId: 'ds_001',
        datasetName: 'Depression Screening Dataset',
        status: TrainingStatus.completed,
        progress: 100,
        currentEpoch: 10,
        totalEpochs: 10,
        currentAccuracy: 0.94,
        currentLoss: 0.12,
        elapsedTime: const Duration(hours: 2, minutes: 30),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        hyperparameters: {'learning_rate': 2e-5, 'batch_size': 16, 'epochs': 10},
        logs: ['Training started', 'Epoch 1/10 completed', 'Training completed successfully'],
        metrics: {'final_accuracy': 0.94, 'final_loss': 0.12},
      ),
      TrainingJob(
        id: 'job_002',
        modelName: 'Anxiety Classifier v2.0',
        description: 'Enhanced anxiety disorder classification model',
        category: ModelCategory.diagnosis,
        templateId: 'tmpl_001',
        templateName: 'BERT-Base-Psychology',
        datasetId: 'ds_002',
        datasetName: 'Anxiety Disorder Classification',
        status: TrainingStatus.running,
        progress: 65,
        currentEpoch: 13,
        totalEpochs: 20,
        currentAccuracy: 0.87,
        currentLoss: 0.23,
        elapsedTime: const Duration(hours: 1, minutes: 45),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        hyperparameters: {'learning_rate': 1e-5, 'batch_size': 32, 'epochs': 20},
        logs: ['Training started', 'Epoch 1/20 completed', 'Epoch 13/20 in progress'],
      ),
    ]);

    // Mock custom models
    _customModels.addAll([
      CustomModel(
        id: 'model_001',
        name: 'Depression Screening v1.0',
        description: 'Custom model for depression screening based on patient responses',
        category: ModelCategory.screening,
        version: '1.0.0',
        size: 420.5,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        performance: ModelPerformance(
          accuracy: 0.94,
          precision: 0.93,
          recall: 0.95,
          f1Score: 0.94,
          auc: 0.96,
          mse: 0.12,
          mae: 0.08,
          classMetrics: {'depression': 0.94, 'no_depression': 0.94},
          customMetrics: {'specificity': 0.93, 'sensitivity': 0.95},
        ),
        metadata: {'template': 'BERT-Base-Psychology', 'dataset': 'ds_001'},
        tags: ['depression', 'screening', 'bert'],
        isDeployed: true,
        deploymentUrl: 'https://api.psyclinicai.com/models/depression-screening',
      ),
    ]);
  }

  /// Get all training jobs
  List<TrainingJob> getTrainingJobs() {
    return List.unmodifiable(_trainingJobs);
  }

  /// Get training job by ID
  TrainingJob? getTrainingJob(String jobId) {
    try {
      return _trainingJobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Get all custom models
  List<CustomModel> getCustomModels() {
    return List.unmodifiable(_customModels);
  }

  /// Get custom model by ID
  CustomModel? getCustomModel(String modelId) {
    try {
      return _customModels.firstWhere((model) => model.id == modelId);
    } catch (e) {
      return null;
    }
  }

  /// Get all datasets
  List<Dataset> getDatasets() {
    return List.unmodifiable(_datasets);
  }

  /// Get dataset by ID
  Dataset? getDataset(String datasetId) {
    try {
      return _datasets.firstWhere((dataset) => dataset.id == datasetId);
    } catch (e) {
      return null;
    }
  }

  /// Get all model templates
  List<ModelTemplate> getModelTemplates() {
    return List.unmodifiable(_templates);
  }

  /// Get model template by ID
  ModelTemplate? getModelTemplate(String templateId) {
    try {
      return _templates.firstWhere((template) => template.id == templateId);
    } catch (e) {
      return null;
    }
  }

  /// Start a new training job
  Future<TrainingJob> startTraining({
    required String modelName,
    required String description,
    required ModelCategory category,
    required String templateId,
    required String datasetId,
    required double learningRate,
    required int epochs,
    required int batchSize,
    required double validationSplit,
  }) async {
    print('🚀 Starting training job: $modelName');
    
    // Validate inputs
    final template = getModelTemplate(templateId);
    if (template == null) {
      throw Exception('Template not found: $templateId');
    }
    
    final dataset = getDataset(datasetId);
    if (dataset == null) {
      throw Exception('Dataset not found: $datasetId');
    }
    
    if (!dataset.isReadyForTraining) {
      throw Exception('Dataset not ready for training: quality=${dataset.quality}, samples=${dataset.samples}');
    }
    
    // Create training job
    final job = TrainingJob(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      modelName: modelName,
      description: description,
      category: category,
      templateId: templateId,
      templateName: template.name,
      datasetId: datasetId,
      datasetName: dataset.name,
      status: TrainingStatus.pending,
      progress: 0,
      currentEpoch: 0,
      totalEpochs: epochs,
      currentAccuracy: 0.0,
      currentLoss: 1.0,
      elapsedTime: Duration.zero,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hyperparameters: {
        'learning_rate': learningRate,
        'batch_size': batchSize,
        'epochs': epochs,
        'validation_split': validationSplit,
      },
      logs: ['Training job created', 'Initializing...'],
    );
    
    // Add to list
    _trainingJobs.add(job);
    
    // Start training process
    _startTrainingProcess(job);
    
    print('✅ Training job started: ${job.id}');
    return job;
  }

  /// Start the training process for a job
  void _startTrainingProcess(TrainingJob job) async {
    // Update status to running
    _updateJobStatus(job.id, TrainingStatus.running);
    
    // Simulate training process
    for (int epoch = 1; epoch <= job.totalEpochs; epoch++) {
      if (job.status != TrainingStatus.running) {
        break; // Training was paused or stopped
      }
      
      // Simulate epoch training
      await Future.delayed(Duration(seconds: 2)); // Simulate training time
      
      // Update progress
      final progress = ((epoch / job.totalEpochs) * 100).round();
      final accuracy = 0.5 + (epoch / job.totalEpochs) * 0.4 + Random().nextDouble() * 0.1;
      final loss = 1.0 - (epoch / job.totalEpochs) * 0.7 + Random().nextDouble() * 0.1;
      
      _updateJobProgress(job.id, epoch, progress, accuracy, loss);
      
      // Add log entry
      _addTrainingLog(job.id, 'Epoch $epoch/${job.totalEpochs} completed - Accuracy: ${(accuracy * 100).toStringAsFixed(2)}%, Loss: ${loss.toStringAsFixed(4)}');
    }
    
    // Complete training
    if (job.status == TrainingStatus.running) {
      _completeTraining(job.id);
    }
  }

  /// Update job status
  void _updateJobStatus(String jobId, TrainingStatus status) {
    final index = _trainingJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _trainingJobs[index];
      final updatedJob = job.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _trainingJobs[index] = updatedJob;
      _trainingJobController.add(updatedJob);
    }
  }

  /// Update job progress
  void _updateJobProgress(String jobId, int currentEpoch, int progress, double accuracy, double loss) {
    final index = _trainingJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _trainingJobs[index];
      final updatedJob = job.copyWith(
        currentEpoch: currentEpoch,
        progress: progress,
        currentAccuracy: accuracy,
        currentLoss: loss,
        updatedAt: DateTime.now(),
        elapsedTime: DateTime.now().difference(job.createdAt),
      );
      _trainingJobs[index] = updatedJob;
      _trainingJobController.add(updatedJob);
    }
  }

  /// Add training log
  void _addTrainingLog(String jobId, String message) {
    _trainingLogController.add('[$jobId] $message');
  }

  /// Complete training
  void _completeTraining(String jobId) {
    final index = _trainingJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _trainingJobs[index];
      final updatedJob = job.copyWith(
        status: TrainingStatus.completed,
        progress: 100,
        currentEpoch: job.totalEpochs,
        updatedAt: DateTime.now(),
        elapsedTime: DateTime.now().difference(job.createdAt),
      );
      _trainingJobs[index] = updatedJob;
      
      // Create custom model
      _createCustomModel(updatedJob);
      
      _trainingJobController.add(updatedJob);
      _addTrainingLog(jobId, 'Training completed successfully!');
    }
  }

  /// Create custom model from completed training job
  void _createCustomModel(TrainingJob job) {
    final model = CustomModel(
      id: 'model_${DateTime.now().millisecondsSinceEpoch}',
      name: job.modelName,
      description: job.description,
      category: job.category,
      version: '1.0.0',
      size: 420.0, // Mock size
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      performance: ModelPerformance(
        accuracy: job.currentAccuracy,
        precision: job.currentAccuracy * 0.98,
        recall: job.currentAccuracy * 1.02,
        f1Score: job.currentAccuracy,
        auc: job.currentAccuracy + 0.02,
        mse: job.currentLoss,
        mae: job.currentLoss * 0.8,
        classMetrics: {'class_1': job.currentAccuracy, 'class_2': job.currentAccuracy},
        customMetrics: {'specificity': job.currentAccuracy * 0.98, 'sensitivity': job.currentAccuracy * 1.02},
      ),
      metadata: {
        'template_id': job.templateId,
        'dataset_id': job.datasetId,
        'training_job_id': job.id,
        'hyperparameters': job.hyperparameters,
      },
      tags: [job.category.name, 'custom', 'trained'],
      isDeployed: false,
    );
    
    _customModels.add(model);
    _customModelController.add(model);
  }

  /// Pause training job
  Future<void> pauseJob(String jobId) async {
    print('⏸️ Pausing training job: $jobId');
    
    final job = getTrainingJob(jobId);
    if (job == null) {
      throw Exception('Training job not found: $jobId');
    }
    
    if (job.status != TrainingStatus.running) {
      throw Exception('Cannot pause job with status: ${job.status}');
    }
    
    _updateJobStatus(jobId, TrainingStatus.paused);
    _addTrainingLog(jobId, 'Training paused by user');
    
    print('✅ Training job paused: $jobId');
  }

  /// Resume training job
  Future<void> resumeJob(String jobId) async {
    print('▶️ Resuming training job: $jobId');
    
    final job = getTrainingJob(jobId);
    if (job == null) {
      throw Exception('Training job not found: $jobId');
    }
    
    if (job.status != TrainingStatus.paused) {
      throw Exception('Cannot resume job with status: ${job.status}');
    }
    
    _updateJobStatus(jobId, TrainingStatus.running);
    _addTrainingLog(jobId, 'Training resumed by user');
    
    // Continue training from where it left off
    _continueTraining(job);
    
    print('✅ Training job resumed: $jobId');
  }

  /// Continue training from paused state
  void _continueTraining(TrainingJob job) async {
    for (int epoch = job.currentEpoch + 1; epoch <= job.totalEpochs; epoch++) {
      if (job.status != TrainingStatus.running) {
        break;
      }
      
      await Future.delayed(Duration(seconds: 2));
      
      final progress = ((epoch / job.totalEpochs) * 100).round();
      final accuracy = 0.5 + (epoch / job.totalEpochs) * 0.4 + Random().nextDouble() * 0.1;
      final loss = 1.0 - (epoch / job.totalEpochs) * 0.7 + Random().nextDouble() * 0.1;
      
      _updateJobProgress(job.id, epoch, progress, accuracy, loss);
      _addTrainingLog(job.id, 'Epoch $epoch/${job.totalEpochs} completed - Accuracy: ${(accuracy * 100).toStringAsFixed(2)}%, Loss: ${loss.toStringAsFixed(4)}');
    }
    
    if (job.status == TrainingStatus.running) {
      _completeTraining(job.id);
    }
  }

  /// Stop training job
  Future<void> stopJob(String jobId) async {
    print('⏹️ Stopping training job: $jobId');
    
    final job = getTrainingJob(jobId);
    if (job == null) {
      throw Exception('Training job not found: $jobId');
    }
    
    if (job.status != TrainingStatus.running) {
      throw Exception('Cannot stop job with status: ${job.status}');
    }
    
    _updateJobStatus(jobId, TrainingStatus.failed);
    _addTrainingLog(jobId, 'Training stopped by user');
    
    print('✅ Training job stopped: $jobId');
  }

  /// Download trained model
  Future<void> downloadModel(String jobId) async {
    print('📥 Downloading model for job: $jobId');
    
    final job = getTrainingJob(jobId);
    if (job == null) {
      throw Exception('Training job not found: $jobId');
    }
    
    if (job.status != TrainingStatus.completed) {
      throw Exception('Cannot download model: training not completed');
    }
    
    // Simulate download
    await Future.delayed(Duration(seconds: 3));
    
    print('✅ Model downloaded successfully for job: $jobId');
  }

  /// Deploy custom model
  Future<void> deployModel(String modelId) async {
    print('🚀 Deploying model: $modelId');
    
    final model = getCustomModel(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    if (model.isDeployed) {
      throw Exception('Model already deployed');
    }
    
    // Simulate deployment
    await Future.delayed(Duration(seconds: 5));
    
    // Update model deployment status
    final index = _customModels.indexWhere((m) => m.id == modelId);
    if (index != -1) {
      final updatedModel = model.copyWith(
        isDeployed: true,
        deploymentUrl: 'https://api.psyclinicai.com/models/${model.id}',
        updatedAt: DateTime.now(),
      );
      _customModels[index] = updatedModel;
      _customModelController.add(updatedModel);
    }
    
    print('✅ Model deployed successfully: $modelId');
  }

  /// Test custom model
  Future<void> testModel(String modelId) async {
    print('🧪 Testing model: $modelId');
    
    final model = getCustomModel(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    // Simulate testing
    await Future.delayed(Duration(seconds: 2));
    
    print('✅ Model test completed: $modelId');
  }

  /// Export custom model
  Future<void> exportModel(String modelId) async {
    print('📤 Exporting model: $modelId');
    
    final model = getCustomModel(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    // Simulate export
    await Future.delayed(Duration(seconds: 4));
    
    print('✅ Model exported successfully: $modelId');
  }

  /// Delete custom model
  Future<void> deleteModel(String modelId) async {
    print('🗑️ Deleting model: $modelId');
    
    final model = getCustomModel(modelId);
    if (model == null) {
      throw Exception('Model not found: $modelId');
    }
    
    if (model.isDeployed) {
      throw Exception('Cannot delete deployed model. Undeploy first.');
    }
    
    // Remove from list
    _customModels.removeWhere((m) => m.id == modelId);
    
    print('✅ Model deleted successfully: $modelId');
  }

  /// Preview dataset
  Future<Map<String, dynamic>> previewDataset(String datasetId) async {
    print('👁️ Previewing dataset: $datasetId');
    
    final dataset = getDataset(datasetId);
    if (dataset == null) {
      throw Exception('Dataset not found: $datasetId');
    }
    
    // Simulate preview generation
    await Future.delayed(Duration(seconds: 1));
    
    return {
      'id': dataset.id,
      'name': dataset.name,
      'sample_data': [
        {'column1': 'value1', 'column2': 'value2'},
        {'column1': 'value3', 'column2': 'value4'},
      ],
      'statistics': dataset.statistics,
      'schema': dataset.schema,
    };
  }

  /// Edit dataset
  Future<void> editDataset(String datasetId) async {
    print('✏️ Editing dataset: $datasetId');
    
    final dataset = getDataset(datasetId);
    if (dataset == null) {
      throw Exception('Dataset not found: $datasetId');
    }
    
    // Simulate editing
    await Future.delayed(Duration(seconds: 2));
    
    print('✅ Dataset edit completed: $datasetId');
  }

  /// Export dataset
  Future<void> exportDataset(String datasetId) async {
    print('📤 Exporting dataset: $datasetId');
    
    final dataset = getDataset(datasetId);
    if (dataset == null) {
      throw Exception('Dataset not found: $datasetId');
    }
    
    // Simulate export
    await Future.delayed(Duration(seconds: 3));
    
    print('✅ Dataset exported successfully: $datasetId');
  }

  /// Delete dataset
  Future<void> deleteDataset(String datasetId) async {
    print('🗑️ Deleting dataset: $datasetId');
    
    final dataset = getDataset(datasetId);
    if (dataset == null) {
      throw Exception('Dataset not found: $datasetId');
    }
    
    // Check if dataset is being used in training
    final isInUse = _trainingJobs.any((job) => job.datasetId == datasetId);
    if (isInUse) {
      throw Exception('Cannot delete dataset: it is being used in training jobs');
    }
    
    // Remove from list
    _datasets.removeWhere((d) => d.id == datasetId);
    
    print('✅ Dataset deleted successfully: $datasetId');
  }

  /// Search training jobs
  List<TrainingJob> searchTrainingJobs({
    String? query,
    ModelCategory? category,
    TrainingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _trainingJobs.where((job) {
      if (query != null && query.isNotEmpty) {
        if (!job.modelName.toLowerCase().contains(query.toLowerCase()) &&
            !job.description.toLowerCase().contains(query.toLowerCase())) {
          return false;
        }
      }
      
      if (category != null && job.category != category) {
        return false;
      }
      
      if (status != null && job.status != status) {
        return false;
      }
      
      if (startDate != null && job.createdAt.isBefore(startDate)) {
        return false;
      }
      
      if (endDate != null && job.createdAt.isAfter(endDate)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Search custom models
  List<CustomModel> searchCustomModels({
    String? query,
    ModelCategory? category,
    bool? isDeployed,
  }) {
    return _customModels.where((model) {
      if (query != null && query.isNotEmpty) {
        if (!model.name.toLowerCase().contains(query.toLowerCase()) &&
            !model.description.toLowerCase().contains(query.toLowerCase())) {
          return false;
        }
      }
      
      if (category != null && model.category != category) {
        return false;
      }
      
      if (isDeployed != null && model.isDeployed != isDeployed) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Search datasets
  List<Dataset> searchDatasets({
    String? query,
    DatasetFormat? format,
    double? minQuality,
    int? minSamples,
  }) {
    return _datasets.where((dataset) {
      if (query != null && query.isNotEmpty) {
        if (!dataset.name.toLowerCase().contains(query.toLowerCase()) &&
            !dataset.description.toLowerCase().contains(query.toLowerCase())) {
          return false;
        }
      }
      
      if (format != null && dataset.format != format) {
        return false;
      }
      
      if (minQuality != null && dataset.quality < minQuality) {
        return false;
      }
      
      if (minSamples != null && dataset.samples < minSamples) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Get training statistics
  Map<String, dynamic> getTrainingStatistics() {
    final totalJobs = _trainingJobs.length;
    final completedJobs = _trainingJobs.where((job) => job.status == TrainingStatus.completed).length;
    final runningJobs = _trainingJobs.where((job) => job.status == TrainingStatus.running).length;
    final failedJobs = _trainingJobs.where((job) => job.status == TrainingStatus.failed).length;
    
    final totalModels = _customModels.length;
    final deployedModels = _customModels.where((model) => model.isDeployed).length;
    
    final totalDatasets = _datasets.length;
    final readyDatasets = _datasets.where((dataset) => dataset.isReadyForTraining).length;
    
    return {
      'total_jobs': totalJobs,
      'completed_jobs': completedJobs,
      'running_jobs': runningJobs,
      'failed_jobs': failedJobs,
      'success_rate': totalJobs > 0 ? (completedJobs / totalJobs) : 0.0,
      'total_models': totalModels,
      'deployed_models': deployedModels,
      'deployment_rate': totalModels > 0 ? (deployedModels / totalModels) : 0.0,
      'total_datasets': totalDatasets,
      'ready_datasets': readyDatasets,
      'dataset_quality': totalDatasets > 0 ? (_datasets.map((d) => d.quality).reduce((a, b) => a + b) / totalDatasets) : 0.0,
    };
  }

  /// Clean up resources
  void dispose() {
    _trainingJobController.close();
    _customModelController.close();
    _trainingLogController.close();
  }
}
