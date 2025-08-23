import 'package:flutter/material.dart';
import 'package:psyclinicai/services/ai_model_training_service.dart';
import 'package:psyclinicai/models/ai_training_models.dart';

/// AI Model Training Dashboard Widget for PsyClinicAI
class AIModelTrainingDashboardWidget extends StatefulWidget {
  const AIModelTrainingDashboardWidget({Key? key}) : super(key: key);

  @override
  State<AIModelTrainingDashboardWidget> createState() => _AIModelTrainingDashboardWidgetState();
}

class _AIModelTrainingDashboardWidgetState extends State<AIModelTrainingDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Service
  final AIModelTrainingService _trainingService = AIModelTrainingService();
  
  // State variables
  bool _isLoading = false;
  List<TrainingJob> _trainingJobs = [];
  List<CustomModel> _customModels = [];
  List<Dataset> _datasets = [];
  List<ModelTemplate> _templates = [];
  
  // Training form
  final _formKey = GlobalKey<FormState>();
  final _modelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ModelCategory _selectedCategory = ModelCategory.diagnosis;
  ModelTemplate? _selectedTemplate;
  Dataset? _selectedDataset;
  double _learningRate = 0.001;
  int _epochs = 100;
  int _batchSize = 32;
  double _validationSplit = 0.2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeTrainingDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _modelNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Initialize training dashboard
  Future<void> _initializeTrainingDashboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _trainingService.initialize();
      
      _trainingJobs = _trainingService.getTrainingJobs();
      _customModels = _trainingService.getCustomModels();
      _datasets = _trainingService.getDatasets();
      _templates = _trainingService.getModelTemplates();
      
      print('✅ AI Training Dashboard initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize AI Training Dashboard: $e');
      _showErrorSnackBar('Failed to initialize training dashboard: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Model Training'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.train), text: 'Training Jobs'),
            Tab(icon: Icon(Icons.model_training), text: 'Custom Models'),
            Tab(icon: Icon(Icons.storage), text: 'Datasets'),
            Tab(icon: Icon(Icons.add), text: 'New Training'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTrainingJobsTab(),
                _buildCustomModelsTab(),
                _buildDatasetsTab(),
                _buildNewTrainingTab(),
              ],
            ),
    );
  }

  /// Overview Tab
  Widget _buildOverviewTab() {
    final activeJobs = _trainingJobs.where((job) => job.status == TrainingStatus.running).length;
    final completedJobs = _trainingJobs.where((job) => job.status == TrainingStatus.completed).length;
    final failedJobs = _trainingJobs.where((job) => job.status == TrainingStatus.failed).length;
    final totalModels = _customModels.length;
    final totalDatasets = _datasets.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Training Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Stats cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Active Jobs', activeJobs.toString(), Icons.play_circle, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Completed', completedJobs.toString(), Icons.check_circle, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Failed', failedJobs.toString(), Icons.error, Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Custom Models', totalModels.toString(), Icons.model_training, Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Datasets', totalDatasets.toString(), Icons.storage, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Templates', _templates.length.toString(), Icons.template, Colors.teal)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent activity
          const Text(
            '🕒 Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (_trainingJobs.isEmpty)
            _buildNoActivityView()
          else
            _buildRecentActivityList(),
            
          const SizedBox(height: 32),
          
          // Quick actions
          const Text(
            '⚡ Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(4), // Switch to New Training tab
                  icon: const Icon(Icons.add),
                  label: const Text('Start Training'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(2), // Switch to Custom Models tab
                  icon: const Icon(Icons.model_training),
                  label: const Text('View Models'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Stat Card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Activity List
  Widget _buildRecentActivityList() {
    final recentJobs = _trainingJobs.take(5).toList();
    
    return Column(
      children: recentJobs.map((job) => _buildActivityItem(job)).toList(),
    );
  }

  /// Activity Item
  Widget _buildActivityItem(TrainingJob job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(job.status),
          child: Icon(
            _getStatusIcon(job.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(job.modelName),
        subtitle: Text('${job.status.name} • ${_formatDate(job.updatedAt)}'),
        trailing: _buildProgressIndicator(job),
        onTap: () => _viewJobDetails(job),
      ),
    );
  }

  /// Progress Indicator
  Widget _buildProgressIndicator(TrainingJob job) {
    if (job.status == TrainingStatus.running) {
      return SizedBox(
        width: 60,
        child: LinearProgressIndicator(
          value: job.progress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(job.status)),
        ),
      );
    }
    
    return Text(
      '${job.progress}%',
      style: TextStyle(
        color: _getStatusColor(job.status),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Training Jobs Tab
  Widget _buildTrainingJobsTab() {
    if (_trainingJobs.isEmpty) {
      return _buildNoTrainingJobsView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _trainingJobs.length,
      itemBuilder: (context, index) {
        final job = _trainingJobs[index];
        return _buildTrainingJobCard(job);
      },
    );
  }

  /// Training Job Card
  Widget _buildTrainingJobCard(TrainingJob job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.modelName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Template: ${job.templateName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(job.status),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress: ${job.progress}%'),
                    Text('Epoch ${job.currentEpoch}/${job.totalEpochs}'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: job.progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(job.status)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Metrics
            Row(
              children: [
                Expanded(
                  child: _buildJobMetric('Accuracy', '${(job.currentAccuracy * 100).toStringAsFixed(2)}%'),
                ),
                Expanded(
                  child: _buildJobMetric('Loss', job.currentLoss.toStringAsFixed(4)),
                ),
                Expanded(
                  child: _buildJobMetric('Time', _formatDuration(job.elapsedTime)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                if (job.status == TrainingStatus.running) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pauseJob(job.id),
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _stopJob(job.id),
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else if (job.status == TrainingStatus.paused) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _resumeJob(job.id),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Resume'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewJobDetails(job),
                    icon: const Icon(Icons.info),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadModel(job.id),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Job Metric
  Widget _buildJobMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Custom Models Tab
  Widget _buildCustomModelsTab() {
    if (_customModels.isEmpty) {
      return _buildNoCustomModelsView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _customModels.length,
      itemBuilder: (context, index) {
        final model = _customModels[index];
        return _buildCustomModelCard(model);
      },
    );
  }

  /// Custom Model Card
  Widget _buildCustomModelCard(CustomModel model) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(model.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(model.category),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${model.version} • ${model.category.name.replaceAll('_', ' ').toUpperCase()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(model.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${model.size} MB',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              model.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Performance metrics
            Row(
              children: [
                Expanded(
                  child: _buildModelMetric('Accuracy', '${(model.performance.accuracy * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildModelMetric('Precision', '${(model.performance.precision * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildModelMetric('Recall', '${(model.performance.recall * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildModelMetric('F1-Score', '${(model.performance.f1Score * 100).toStringAsFixed(1)}%'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deployModel(model.id),
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Deploy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _testModel(model.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportModel(model.id),
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteModel(model.id),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Model Metric
  Widget _buildModelMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Datasets Tab
  Widget _buildDatasetsTab() {
    if (_datasets.isEmpty) {
      return _buildNoDatasetsView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _datasets.length,
      itemBuilder: (context, index) {
        final dataset = _datasets[index];
        return _buildDatasetCard(dataset);
      },
    );
  }

  /// Dataset Card
  Widget _buildDatasetCard(Dataset dataset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 32,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dataset.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dataset.samples} samples • ${dataset.features} features',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dataset.format.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${dataset.size} MB',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              dataset.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Dataset info
            Row(
              children: [
                Expanded(
                  child: _buildDatasetInfo('Split', '${(dataset.trainSplit * 100).toStringAsFixed(0)}/${(dataset.validationSplit * 100).toStringAsFixed(0)}/${(dataset.testSplit * 100).toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: _buildDatasetInfo('Quality', '${(dataset.quality * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildDatasetInfo('Updated', _formatDate(dataset.updatedAt)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _previewDataset(dataset.id),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editDataset(dataset.id),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportDataset(dataset.id),
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteDataset(dataset.id),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dataset Info
  Widget _buildDatasetInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// New Training Tab
  Widget _buildNewTrainingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚀 Start New Training',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Basic info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _modelNameController,
                      decoration: const InputDecoration(
                        labelText: 'Model Name',
                        hintText: 'Enter a unique name for your model',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a model name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe what this model will do',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<ModelCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ModelCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name.replaceAll('_', ' ').toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Model configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Model Configuration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<ModelTemplate>(
                      value: _selectedTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Base Template',
                        border: OutlineInputBorder(),
                        helperText: 'Select a pre-trained model to fine-tune',
                      ),
                      items: _templates.map((template) {
                        return DropdownMenuItem(
                          value: template,
                          child: Text(template.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTemplate = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a template';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<Dataset>(
                      value: _selectedDataset,
                      decoration: const InputDecoration(
                        labelText: 'Training Dataset',
                        border: OutlineInputBorder(),
                        helperText: 'Select the dataset to train on',
                      ),
                      items: _datasets.map((dataset) {
                        return DropdownMenuItem(
                          value: dataset,
                          child: Text('${dataset.name} (${dataset.samples} samples)'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDataset = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a dataset';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Training parameters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training Parameters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Learning Rate: ${_learningRate.toStringAsFixed(4)}'),
                              Slider(
                                value: _learningRate,
                                min: 0.0001,
                                max: 0.01,
                                divisions: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _learningRate = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Epochs: $_epochs'),
                              Slider(
                                value: _epochs.toDouble(),
                                min: 10,
                                max: 1000,
                                divisions: 99,
                                onChanged: (value) {
                                  setState(() {
                                    _epochs = value.toInt();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Batch Size: $_batchSize'),
                              Slider(
                                value: _batchSize.toDouble(),
                                min: 8,
                                max: 128,
                                divisions: 15,
                                onChanged: (value) {
                                  setState(() {
                                    _batchSize = value.toInt();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Validation Split: ${(_validationSplit * 100).toStringAsFixed(0)}%'),
                              Slider(
                                value: _validationSplit,
                                min: 0.1,
                                max: 0.5,
                                divisions: 4,
                                onChanged: (value) {
                                  setState(() {
                                    _validationSplit = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Start training button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _startTraining,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Training'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper Methods
  Color _getStatusColor(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.pending:
        return Colors.grey;
      case TrainingStatus.running:
        return Colors.blue;
      case TrainingStatus.paused:
        return Colors.orange;
      case TrainingStatus.completed:
        return Colors.green;
      case TrainingStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.pending:
        return Icons.schedule;
      case TrainingStatus.running:
        return Icons.play_arrow;
      case TrainingStatus.paused:
        return Icons.pause;
      case TrainingStatus.completed:
        return Icons.check_circle;
      case TrainingStatus.failed:
        return Icons.error;
    }
  }

  Color _getCategoryColor(ModelCategory category) {
    switch (category) {
      case ModelCategory.diagnosis:
        return Colors.blue;
      case ModelCategory.treatment:
        return Colors.green;
      case ModelCategory.riskAssessment:
        return Colors.orange;
      case ModelCategory.prognosis:
        return Colors.purple;
      case ModelCategory.screening:
        return Colors.teal;
      case ModelCategory.monitoring:
        return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(ModelCategory category) {
    switch (category) {
      case ModelCategory.diagnosis:
        return Icons.medical_services;
      case ModelCategory.treatment:
        return Icons.healing;
      case ModelCategory.riskAssessment:
        return Icons.warning;
      case ModelCategory.prognosis:
        return Icons.timeline;
      case ModelCategory.screening:
        return Icons.filter_list;
      case ModelCategory.monitoring:
        return Icons.monitor_heart;
    }
  }

  Widget _buildStatusChip(TrainingStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case TrainingStatus.pending:
        color = Colors.grey;
        text = 'Pending';
        break;
      case TrainingStatus.running:
        color = Colors.blue;
        text = 'Running';
        break;
      case TrainingStatus.paused:
        color = Colors.orange;
        text = 'Paused';
        break;
      case TrainingStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case TrainingStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Action Methods
  Future<void> _startTraining() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTemplate == null || _selectedDataset == null) {
      _showErrorSnackBar('Please select a template and dataset');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final job = await _trainingService.startTraining(
        modelName: _modelNameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        templateId: _selectedTemplate!.id,
        datasetId: _selectedDataset!.id,
        learningRate: _learningRate,
        epochs: _epochs,
        batchSize: _batchSize,
        validationSplit: _validationSplit,
      );

      // Refresh training jobs
      _trainingJobs = _trainingService.getTrainingJobs();
      
      // Reset form
      _formKey.currentState!.reset();
      _modelNameController.clear();
      _descriptionController.clear();
      _selectedCategory = ModelCategory.diagnosis;
      _selectedTemplate = null;
      _selectedDataset = null;
      _learningRate = 0.001;
      _epochs = 100;
      _batchSize = 32;
      _validationSplit = 0.2;

      // Switch to training jobs tab
      _tabController.animateTo(1);
      
      _showSuccessSnackBar('Training job started successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to start training: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pauseJob(String jobId) async {
    try {
      await _trainingService.pauseJob(jobId);
      _trainingJobs = _trainingService.getTrainingJobs();
      _showSuccessSnackBar('Training job paused');
    } catch (e) {
      _showErrorSnackBar('Failed to pause job: $e');
    }
  }

  Future<void> _resumeJob(String jobId) async {
    try {
      await _trainingService.resumeJob(jobId);
      _trainingJobs = _trainingService.getTrainingJobs();
      _showSuccessSnackBar('Training job resumed');
    } catch (e) {
      _showErrorSnackBar('Failed to resume job: $e');
    }
  }

  Future<void> _stopJob(String jobId) async {
    try {
      await _trainingService.stopJob(jobId);
      _trainingJobs = _trainingService.getTrainingJobs();
      _showSuccessSnackBar('Training job stopped');
    } catch (e) {
      _showErrorSnackBar('Failed to stop job: $e');
    }
  }

  void _viewJobDetails(TrainingJob job) {
    _showInfoSnackBar('Job details feature coming soon!');
  }

  Future<void> _downloadModel(String jobId) async {
    try {
      await _trainingService.downloadModel(jobId);
      _showSuccessSnackBar('Model downloaded successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to download model: $e');
    }
  }

  Future<void> _deployModel(String modelId) async {
    try {
      await _trainingService.deployModel(modelId);
      _showSuccessSnackBar('Model deployed successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to deploy model: $e');
    }
  }

  Future<void> _testModel(String modelId) async {
    try {
      await _trainingService.testModel(modelId);
      _showSuccessSnackBar('Model test completed!');
    } catch (e) {
      _showErrorSnackBar('Model test failed: $e');
    }
  }

  Future<void> _exportModel(String modelId) async {
    try {
      await _trainingService.exportModel(modelId);
      _showSuccessSnackBar('Model exported successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to export model: $e');
    }
  }

  Future<void> _deleteModel(String modelId) async {
    try {
      await _trainingService.deleteModel(modelId);
      _customModels = _trainingService.getCustomModels();
      _showSuccessSnackBar('Model deleted successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to delete model: $e');
    }
  }

  void _previewDataset(String datasetId) {
    _showInfoSnackBar('Dataset preview feature coming soon!');
  }

  void _editDataset(String datasetId) {
    _showInfoSnackBar('Dataset editing feature coming soon!');
  }

  Future<void> _exportDataset(String datasetId) async {
    try {
      await _trainingService.exportDataset(datasetId);
      _showSuccessSnackBar('Dataset exported successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to export dataset: $e');
    }
  }

  Future<void> _deleteDataset(String datasetId) async {
    try {
      await _trainingService.deleteDataset(datasetId);
      _datasets = _trainingService.getDatasets();
      _showSuccessSnackBar('Dataset deleted successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to delete dataset: $e');
    }
  }

  /// No Data Views
  Widget _buildNoActivityView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No recent activity',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start training your first model to see activity here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoTrainingJobsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.train, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No training jobs',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your first training job to see it here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(4),
            icon: const Icon(Icons.add),
            label: const Text('Start Training'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCustomModelsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.model_training, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No custom models',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Train your first custom model to see it here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(4),
            icon: const Icon(Icons.add),
            label: const Text('Start Training'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDatasetsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storage, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No datasets',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your first dataset to start training',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showInfoSnackBar('Dataset upload feature coming soon!'),
            icon: const Icon(Icons.upload),
            label: const Text('Upload Dataset'),
          ),
        ],
      ),
    );
  }

  /// Snackbar Methods
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
