import 'package:flutter/material.dart';
import '../../services/predictive_analytics_service.dart';
import '../../services/ai_analytics_service.dart';
import '../../models/predictive_analytics_models.dart';

class AdvancedAnalyticsDashboardWidget extends StatefulWidget {
  const AdvancedAnalyticsDashboardWidget({super.key});

  @override
  State<AdvancedAnalyticsDashboardWidget> createState() => _AdvancedAnalyticsDashboardWidgetState();
}

class _AdvancedAnalyticsDashboardWidgetState extends State<AdvancedAnalyticsDashboardWidget> {
  final PredictiveAnalyticsService _predictiveService = PredictiveAnalyticsService();
  final AIAnalyticsService _aiService = AIAnalyticsService();
  
  List<PredictiveModel> _models = [];
  List<ModelPerformanceMetrics> _performanceMetrics = [];
  List<FeatureImportance> _featureImportance = [];
  List<ModelTrainingJob> _trainingJobs = [];
  
  bool _isLoading = false;
  String _selectedModelType = 'all';
  String _selectedTimeRange = '30d';

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    try {
      // Load predictive models
      final models = await _predictiveService.getAvailableModels();
      
      // Load performance metrics
      final metrics = await _predictiveService.getModelPerformanceMetrics();
      
      // Load feature importance
      final features = await _predictiveService.getFeatureImportance();
      
      // Load training jobs
      final jobs = await _predictiveService.getModelTrainingJobs();
      
      setState(() {
        _models = models;
        _performanceMetrics = metrics;
        _featureImportance = features;
        _trainingJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading analytics data: $e');
    }
  }

  Future<void> _retrainModel(String modelId) async {
    setState(() => _isLoading = true);
    try {
      await _predictiveService.retrainModel(modelId);
      _showSnackBar('✅ Model retraining started successfully!');
      await _loadAnalyticsData();
    } catch (e) {
      _showSnackBar('❌ Model retraining failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deployModel(String modelId) async {
    setState(() => _isLoading = true);
    try {
      await _predictiveService.deployModel(modelId);
      _showSnackBar('✅ Model deployed successfully!');
      await _loadAnalyticsData();
    } catch (e) {
      _showSnackBar('❌ Model deployment failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Advanced Analytics Dashboard'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewCards(),
            const SizedBox(height: 24),
            
            // Model Performance
            _buildModelPerformanceSection(),
            const SizedBox(height: 24),
            
            // Feature Importance
            _buildFeatureImportanceSection(),
            const SizedBox(height: 24),
            
            // Training Jobs
            _buildTrainingJobsSection(),
            const SizedBox(height: 24),
            
            // Model Management
            _buildModelManagementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Models',
            '${_models.length}',
            Colors.blue,
            Icons.psychology,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Active Models',
            '${_models.where((m) => m.status == ModelStatus.active).length}',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Training Jobs',
            '${_trainingJobs.length}',
            Colors.orange,
            Icons.sync,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Avg Accuracy',
            '${_performanceMetrics.isNotEmpty ? (_performanceMetrics.map((m) => m.accuracy).reduce((a, b) => a + b) / _performanceMetrics.length * 100).toStringAsFixed(1) : '0.0'}%',
            Colors.purple,
            Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelPerformanceSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Model Performance Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_performanceMetrics.isEmpty)
              const Center(
                child: Text(
                  'No performance metrics available',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _performanceMetrics.length,
                itemBuilder: (context, index) {
                  final metric = _performanceMetrics[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getModelTypeIcon(metric.modelType),
                                color: _getModelTypeColor(metric.modelType),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${metric.modelType.name.toUpperCase()} Model',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  '${(metric.accuracy * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: _getAccuracyColor(metric.accuracy),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricItem(
                                  'Precision',
                                  '${(metric.precision * 100).toStringAsFixed(1)}%',
                                  Colors.blue,
                                ),
                              ),
                              Expanded(
                                child: _buildMetricItem(
                                  'Recall',
                                  '${(metric.recall * 100).toStringAsFixed(1)}%',
                                  Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _buildMetricItem(
                                  'F1 Score',
                                  '${(metric.f1Score * 100).toStringAsFixed(1)}%',
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Last Updated: ${_formatDate(metric.lastUpdated)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureImportanceSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Feature Importance Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_featureImportance.isEmpty)
              const Center(
                child: Text(
                  'No feature importance data available',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            else
              Column(
                children: _featureImportance.take(10).map((feature) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getFeatureImportanceColor(feature.importance),
                        child: Text(
                          '${(feature.importance * 100).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        feature.featureName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Model: ${feature.modelType.name} | Type: ${feature.featureType}',
                      ),
                      trailing: Icon(
                        _getFeatureTypeIcon(feature.featureType),
                        color: _getFeatureImportanceColor(feature.importance),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingJobsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Model Training Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_trainingJobs.isEmpty)
              const Center(
                child: Text(
                  'No training jobs available',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trainingJobs.length,
                itemBuilder: (context, index) {
                  final job = _trainingJobs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getTrainingStatusColor(job.status),
                        child: Icon(
                          _getTrainingStatusIcon(job.status),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Training Job ${job.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Model: ${job.modelType.name} | Status: ${job.status.name}\n'
                        'Started: ${_formatDate(job.startedAt)}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'retrain':
                              _retrainModel(job.modelId);
                              break;
                            case 'deploy':
                              _deployModel(job.modelId);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'retrain',
                            child: Text('Retrain Model'),
                          ),
                          const PopupMenuItem(
                            value: 'deploy',
                            child: Text('Deploy Model'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelManagementSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Model Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadAnalyticsData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () {
                      // Simulate new model training
                      _showSnackBar('🚀 Starting new model training job...');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Train New Model'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Advanced analytics provides insights into model performance, feature importance, '
              'and training job status. Use this dashboard to monitor and optimize your AI models.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModelTypeIcon(ModelType type) {
    switch (type) {
      case ModelType.treatmentOutcome:
        return Icons.healing;
      case ModelType.relapseRisk:
        return Icons.warning;
      case ModelType.patientProgress:
        return Icons.trending_up;
      case ModelType.crisisPrediction:
        return Icons.emergency;
      default:
        return Icons.psychology;
    }
  }

  Color _getModelTypeColor(ModelType type) {
    switch (type) {
      case ModelType.treatmentOutcome:
        return Colors.green;
      case ModelType.relapseRisk:
        return Colors.orange;
      case ModelType.patientProgress:
        return Colors.blue;
      case ModelType.crisisPrediction:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.8) return Colors.blue;
    if (accuracy >= 0.7) return Colors.orange;
    return Colors.red;
  }

  Color _getFeatureImportanceColor(double importance) {
    if (importance >= 0.8) return Colors.red;
    if (importance >= 0.6) return Colors.orange;
    if (importance >= 0.4) return Colors.blue;
    return Colors.grey;
  }

  IconData _getFeatureTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'demographic':
        return Icons.people;
      case 'clinical':
        return Icons.medical_services;
      case 'behavioral':
        return Icons.psychology;
      case 'temporal':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  Color _getTrainingStatusColor(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.running:
        return Colors.blue;
      case TrainingStatus.completed:
        return Colors.green;
      case TrainingStatus.failed:
        return Colors.red;
      case TrainingStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrainingStatusIcon(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.running:
        return Icons.sync;
      case TrainingStatus.completed:
        return Icons.check_circle;
      case TrainingStatus.failed:
        return Icons.error;
      case TrainingStatus.pending:
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
