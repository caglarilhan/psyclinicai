import 'package:flutter/material.dart';
import 'package:psyclinicai/services/predictive_analytics_service.dart';
import 'package:psyclinicai/services/crisis_detection_service.dart';
import 'package:psyclinicai/services/personalized_treatment_service.dart';
import 'package:psyclinicai/models/predictive_analytics_models.dart';

/// Predictive Analytics Dashboard Widget for PsyClinicAI
class PredictiveAnalyticsDashboardWidget extends StatefulWidget {
  const PredictiveAnalyticsDashboardWidget({Key? key}) : super(key: key);

  @override
  State<PredictiveAnalyticsDashboardWidget> createState() => _PredictiveAnalyticsDashboardWidgetState();
}

class _PredictiveAnalyticsDashboardWidgetState extends State<PredictiveAnalyticsDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Services
  final PredictiveAnalyticsService _predictiveService = PredictiveAnalyticsService();
  final CrisisDetectionService _crisisService = CrisisDetectionService();
  final PersonalizedTreatmentService _treatmentService = PersonalizedTreatmentService();
  
  // State variables
  bool _isLoading = false;
  List<PredictiveModel> _models = [];
  ModelPerformanceMetrics? _performanceMetrics;
  List<ModelTrainingJob> _trainingJobs = [];
  Map<String, dynamic> _currentPredictions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPredictiveData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load predictive analytics data
  Future<void> _loadPredictiveData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load models
      _models = await _predictiveService.getAvailableModels();
      
      // Load performance metrics for first model
      if (_models.isNotEmpty) {
        _performanceMetrics = await _predictiveService.getModelPerformanceMetrics(_models.first.id);
      }
      
      // Load training jobs
      _trainingJobs = await _predictiveService.getTrainingJobs();
      
      print('✅ Predictive analytics data loaded successfully');
    } catch (e) {
      print('❌ Failed to load predictive analytics data: $e');
      _showErrorSnackBar('Failed to load predictive analytics data: $e');
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
        title: const Text('🔮 Predictive Analytics Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.psychology), text: 'Models'),
            Tab(icon: Icon(Icons.analytics), text: 'Performance'),
            Tab(icon: Icon(Icons.train), text: 'Training'),
            Tab(icon: Icon(Icons.psychology), text: 'Predictions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildModelsTab(),
                _buildPerformanceTab(),
                _buildTrainingTab(),
                _buildPredictionsTab(),
              ],
            ),
    );
  }

  /// Overview Tab
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentPredictions(),
        ],
      ),
    );
  }

  /// Overview Cards
  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildOverviewCard(
          title: 'Active Models',
          value: _models.length.toString(),
          icon: Icons.psychology,
          color: Colors.blue,
          subtitle: 'Predictive models',
        ),
        _buildOverviewCard(
          title: 'Avg Accuracy',
          value: _calculateAverageAccuracy(),
          icon: Icons.trending_up,
          color: Colors.green,
          subtitle: 'Model performance',
        ),
        _buildOverviewCard(
          title: 'Training Jobs',
          value: _trainingJobs.length.toString(),
          icon: Icons.train,
          color: Colors.orange,
          subtitle: 'Active training',
        ),
        _buildOverviewCard(
          title: 'Predictions Today',
          value: _currentPredictions.length.toString(),
          icon: Icons.psychology,
          color: Colors.purple,
          subtitle: 'Daily predictions',
        ),
      ],
    );
  }

  /// Overview Card
  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Actions
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runQuickPrediction,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Quick Prediction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startModelTraining,
                    icon: const Icon(Icons.train),
                    label: const Text('Train Model'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _analyzeModelPerformance,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analyze Performance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportPredictions,
                    icon: const Icon(Icons.download),
                    label: const Text('Export Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  /// Recent Predictions
  Widget _buildRecentPredictions() {
    if (_currentPredictions.isEmpty) {
      return Card(
        child: const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.psychology, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No recent predictions',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Recent Predictions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentPredictions.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final prediction = _currentPredictions.entries.elementAt(index);
                return ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.blue),
                  title: Text(prediction.key),
                  subtitle: Text(prediction.value.toString()),
                  trailing: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Models Tab
  Widget _buildModelsTab() {
    if (_models.isEmpty) {
      return _buildNoModelsView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _models.length,
      itemBuilder: (context, index) {
        final model = _models[index];
        return _buildModelCard(model);
      },
    );
  }

  /// Model Card
  Widget _buildModelCard(PredictiveModel model) {
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
                  _getModelIcon(model.type),
                  color: _getModelColor(model.type),
                  size: 32,
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
                        model.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildModelStatusChip(model.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModelMetric('Accuracy', '${(model.accuracy * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildModelMetric('Version', model.version),
                ),
                Expanded(
                  child: _buildModelMetric('Last Updated', _formatDate(model.lastUpdated)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _runModelPrediction(model),
                    child: const Text('Run Prediction'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewModelDetails(model),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _retrainModel(model),
                    child: const Text('Retrain'),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Model Status Chip
  Widget _buildModelStatusChip(ModelStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case ModelStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case ModelStatus.training:
        color = Colors.orange;
        text = 'Training';
        break;
      case ModelStatus.inactive:
        color = Colors.grey;
        text = 'Inactive';
        break;
      case ModelStatus.deprecated:
        color = Colors.amber;
        text = 'Deprecated';
        break;
      case ModelStatus.error:
        color = Colors.red;
        text = 'Error';
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

  /// Performance Tab
  Widget _buildPerformanceTab() {
    if (_performanceMetrics.isEmpty) {
      return _buildNoPerformanceDataView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceOverview(),
          const SizedBox(height: 24),
          _buildPerformanceCharts(),
          const SizedBox(height: 24),
          _buildPerformanceTable(),
        ],
      ),
    );
  }

  /// Performance Overview
  Widget _buildPerformanceOverview() {
    final avgAccuracy = _performanceMetrics
        .map((m) => m.accuracy)
        .reduce((a, b) => a + b) / _performanceMetrics.length;

    final avgPrecision = _performanceMetrics
        .map((m) => m.precision)
        .reduce((a, b) => a + b) / _performanceMetrics.length;

    final avgRecall = _performanceMetrics
        .map((m) => m.recall)
        .reduce((a, b) => a + b) / _performanceMetrics.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Performance Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric('Average Accuracy', '${(avgAccuracy * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildPerformanceMetric('Average Precision', '${(avgPrecision * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildPerformanceMetric('Average Recall', '${(avgRecall * 100).toStringAsFixed(1)}%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Performance Metric
  Widget _buildPerformanceMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Performance Charts
  Widget _buildPerformanceCharts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Performance Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text(
                  'Performance charts would be displayed here\n(Integration with charting library required)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Performance Table
  Widget _buildPerformanceTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Detailed Performance Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Model')),
                  DataColumn(label: Text('Accuracy')),
                  DataColumn(label: Text('Precision')),
                  DataColumn(label: Text('Recall')),
                  DataColumn(label: Text('F1 Score')),
                  DataColumn(label: Text('Last Updated')),
                ],
                rows: _performanceMetrics.map((metric) {
                  return DataRow(
                    cells: [
                      DataCell(Text(metric.modelId)),
                      DataCell(Text('${(metric.accuracy * 100).toStringAsFixed(1)}%')),
                      DataCell(Text('${(metric.precision * 100).toStringAsFixed(1)}%')),
                      DataCell(Text('${(metric.recall * 100).toStringAsFixed(1)}%')),
                      DataCell(Text('${(metric.f1Score * 100).toStringAsFixed(1)}%')),
                      DataCell(Text(_formatDate(metric.lastUpdated))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Training Tab
  Widget _buildTrainingTab() {
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
  Widget _buildTrainingJobCard(ModelTrainingJob job) {
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
                  _getTrainingStatusIcon(job.status),
                  color: _getTrainingStatusColor(job.status),
                  size: 32,
                ),
                const SizedBox(width: 16),
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
                        'Training Job: ${job.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrainingStatusChip(job.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTrainingMetric('Progress', '${(job.progress * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildTrainingMetric('Duration', _formatDuration(job.duration)),
                ),
                Expanded(
                  child: _buildTrainingMetric('Started', _formatDate(job.startedAt)),
                ),
              ],
            ),
            if (job.status == TrainingJobStatus.running) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: job.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewTrainingDetails(job),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                if (job.status == TrainingJobStatus.running)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _stopTraining(job),
                      child: const Text('Stop Training'),
                    ),
                  ),
                if (job.status == TrainingJobStatus.completed)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deployModel(job),
                      child: const Text('Deploy Model'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Training Metric
  Widget _buildTrainingMetric(String label, String value) {
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Training Status Chip
  Widget _buildTrainingStatusChip(TrainingJobStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case TrainingJobStatus.pending:
        color = Colors.grey;
        text = 'Pending';
        break;
      case TrainingJobStatus.running:
        color = Colors.blue;
        text = 'Running';
        break;
      case TrainingJobStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case TrainingJobStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
      case TrainingJobStatus.cancelled:
        color = Colors.orange;
        text = 'Cancelled';
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

  /// Predictions Tab
  Widget _buildPredictionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionControls(),
          const SizedBox(height: 24),
          _buildPredictionResults(),
        ],
      ),
    );
  }

  /// Prediction Controls
  Widget _buildPredictionControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Run Predictions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runTreatmentOutcomePrediction,
                    icon: const Icon(Icons.healing),
                    label: const Text('Treatment Outcome'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runRelapseRiskPrediction,
                    icon: const Icon(Icons.warning),
                    label: const Text('Relapse Risk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runCrisisPrediction,
                    icon: const Icon(Icons.emergency),
                    label: const Text('Crisis Prediction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runPatientProgressPrediction,
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Patient Progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  /// Prediction Results
  Widget _buildPredictionResults() {
    if (_currentPredictions.isEmpty) {
      return Card(
        child: const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.psychology, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No predictions run yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Use the controls above to run predictions',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Prediction Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._currentPredictions.entries.map((entry) => _buildPredictionResult(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  /// Prediction Result
  Widget _buildPredictionResult(String type, dynamic result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPredictionIcon(type),
                color: _getPredictionColor(type),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _exportPredictionResult(type, result),
                icon: const Icon(Icons.download),
                tooltip: 'Export result',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// No Models View
  Widget _buildNoModelsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No predictive models available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Models will appear here once they are created and trained',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// No Performance Data View
  Widget _buildNoPerformanceDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No performance data available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Performance metrics will appear here once models are evaluated',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// No Training Jobs View
  Widget _buildNoTrainingJobsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.train, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No training jobs available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Training jobs will appear here once they are created',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Helper Methods
  String _calculateAverageAccuracy() {
    if (_performanceMetrics.isEmpty) return '0.0%';
    
    final avgAccuracy = _performanceMetrics
        .map((m) => m.accuracy)
        .reduce((a, b) => a + b) / _performanceMetrics.length;
    
    return '${(avgAccuracy * 100).toStringAsFixed(1)}%';
  }

  IconData _getModelIcon(ModelType type) {
    switch (type) {
      case ModelType.treatmentOutcome:
        return Icons.healing;
      case ModelType.relapseRisk:
        return Icons.warning;
      case ModelType.crisisPrediction:
        return Icons.emergency;
      case ModelType.patientProgress:
        return Icons.trending_up;
      default:
        return Icons.psychology;
    }
  }

  Color _getModelColor(ModelType type) {
    switch (type) {
      case ModelType.treatmentOutcome:
        return Colors.green;
      case ModelType.relapseRisk:
        return Colors.orange;
      case ModelType.crisisPrediction:
        return Colors.red;
      case ModelType.patientProgress:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrainingStatusIcon(TrainingJobStatus status) {
    switch (status) {
      case TrainingJobStatus.pending:
        return Icons.schedule;
      case TrainingJobStatus.running:
        return Icons.train;
      case TrainingJobStatus.completed:
        return Icons.check_circle;
      case TrainingJobStatus.failed:
        return Icons.error;
      case TrainingJobStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getTrainingStatusColor(TrainingJobStatus status) {
    switch (status) {
      case TrainingJobStatus.pending:
        return Colors.grey;
      case TrainingJobStatus.running:
        return Colors.blue;
      case TrainingJobStatus.completed:
        return Colors.green;
      case TrainingJobStatus.failed:
        return Colors.red;
      case TrainingJobStatus.cancelled:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPredictionIcon(String type) {
    if (type.contains('Treatment')) return Icons.healing;
    if (type.contains('Relapse')) return Icons.warning;
    if (type.contains('Crisis')) return Icons.emergency;
    if (type.contains('Progress')) return Icons.trending_up;
    return Icons.psychology;
  }

  Color _getPredictionColor(String type) {
    if (type.contains('Treatment')) return Colors.green;
    if (type.contains('Relapse')) return Colors.orange;
    if (type.contains('Crisis')) return Colors.red;
    if (type.contains('Progress')) return Colors.blue;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  /// Action Methods
  void _runQuickPrediction() {
    // Implementation for quick prediction
    _showInfoSnackBar('Quick prediction feature coming soon!');
  }

  void _startModelTraining() {
    // Implementation for starting model training
    _showInfoSnackBar('Model training feature coming soon!');
  }

  void _analyzeModelPerformance() {
    // Implementation for analyzing model performance
    _showInfoSnackBar('Performance analysis feature coming soon!');
  }

  void _exportPredictions() {
    // Implementation for exporting predictions
    _showInfoSnackBar('Export feature coming soon!');
  }

  void _runModelPrediction(PredictiveModel model) {
    // Implementation for running model prediction
    _showInfoSnackBar('Running prediction for ${model.name}...');
  }

  void _viewModelDetails(PredictiveModel model) {
    // Implementation for viewing model details
    _showInfoSnackBar('Viewing details for ${model.name}');
  }

  void _retrainModel(PredictiveModel model) {
    // Implementation for retraining model
    _showInfoSnackBar('Retraining ${model.name}...');
  }

  void _viewTrainingDetails(ModelTrainingJob job) {
    // Implementation for viewing training details
    _showInfoSnackBar('Viewing training details for ${job.modelName}');
  }

  void _stopTraining(ModelTrainingJob job) {
    // Implementation for stopping training
    _showInfoSnackBar('Stopping training for ${job.modelName}');
  }

  void _deployModel(ModelTrainingJob job) {
    // Implementation for deploying model
    _showInfoSnackBar('Deploying ${job.modelName}...');
  }

  void _runTreatmentOutcomePrediction() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prediction = await _predictiveService.predictTreatmentOutcome(
        patientId: 'demo_patient_001',
        diagnosis: 'Major Depressive Disorder',
        proposedTreatment: 'CBT + Sertraline',
        patientFactors: {'age': 30, 'severity': 'moderate'},
      );

      setState(() {
        _currentPredictions['Treatment Outcome Prediction'] = prediction;
      });

      _showSuccessSnackBar('Treatment outcome prediction completed!');
    } catch (e) {
      _showErrorSnackBar('Treatment outcome prediction failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _runRelapseRiskPrediction() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prediction = await _predictiveService.predictRelapseRisk(
        patientId: 'demo_patient_001',
        diagnosis: 'Major Depressive Disorder',
        treatmentHistory: ['CBT', 'Sertraline'],
        currentSymptoms: ['mild_sadness'],
      );

      setState(() {
        _currentPredictions['Relapse Risk Prediction'] = prediction;
      });

      _showSuccessSnackBar('Relapse risk prediction completed!');
    } catch (e) {
      _showErrorSnackBar('Relapse risk prediction failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _runCrisisPrediction() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prediction = await _predictiveService.predictCrisis(
        patientId: 'demo_patient_001',
        currentSymptoms: ['hopelessness', 'isolation'],
        riskFactors: ['previous_attempts', 'substance_use'],
        recentBehavior: 'withdrawn',
      );

      setState(() {
        _currentPredictions['Crisis Prediction'] = prediction;
      });

      _showSuccessSnackBar('Crisis prediction completed!');
    } catch (e) {
      _showErrorSnackBar('Crisis prediction failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _runPatientProgressPrediction() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prediction = await _predictiveService.predictPatientProgress(
        patientId: 'demo_patient_001',
        diagnosis: 'Major Depressive Disorder',
        treatmentPlan: 'CBT + Sertraline',
        currentProgress: 0.4,
        adherence: 0.8,
      );

      setState(() {
        _currentPredictions['Patient Progress Prediction'] = prediction;
      });

      _showSuccessSnackBar('Patient progress prediction completed!');
    } catch (e) {
      _showErrorSnackBar('Patient progress prediction failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _exportPredictionResult(String type, dynamic result) {
    // Implementation for exporting prediction result
    _showInfoSnackBar('Exporting $type result...');
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

