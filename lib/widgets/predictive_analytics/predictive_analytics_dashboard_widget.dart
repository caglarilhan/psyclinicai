import 'package:flutter/material.dart';
import '../../models/predictive_analytics_models.dart';
import '../../services/predictive_analytics_service.dart';
import '../../utils/theme.dart';

class PredictiveAnalyticsDashboardWidget extends StatefulWidget {
  const PredictiveAnalyticsDashboardWidget({super.key});

  @override
  State<PredictiveAnalyticsDashboardWidget> createState() => _PredictiveAnalyticsDashboardWidgetState();
}

class _PredictiveAnalyticsDashboardWidgetState extends State<PredictiveAnalyticsDashboardWidget> {
  final PredictiveAnalyticsService _analyticsService = PredictiveAnalyticsService();
  
  List<PredictiveModel> _models = [];
  List<FeatureImportance> _featureImportance = [];
  ModelPerformanceMetrics? _selectedModelMetrics;
  bool _isLoading = false;
  String? _selectedModelId;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    
    try {
      _models = _analyticsService.getAvailableModels();
      if (_models.isNotEmpty) {
        _selectedModelId = _models.first.id;
        await _loadModelMetrics(_selectedModelId!);
        await _loadFeatureImportance(_selectedModelId!);
      }
    } catch (e) {
      print('Error loading models: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadModelMetrics(String modelId) async {
    try {
      final metrics = await _analyticsService.getModelPerformance(modelId);
      setState(() {
        _selectedModelMetrics = metrics;
      });
    } catch (e) {
      print('Error loading model metrics: $e');
    }
  }

  Future<void> _loadFeatureImportance(String modelId) async {
    try {
      final features = await _analyticsService.getFeatureImportance(modelId);
      setState(() {
        _featureImportance = features;
      });
    } catch (e) {
      print('Error loading feature importance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_models.isEmpty) {
      return _buildNoModelsView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildModelSelector(),
          const SizedBox(height: 24),
          _buildModelOverview(),
          const SizedBox(height: 24),
          _buildPerformanceMetrics(),
          const SizedBox(height: 24),
          _buildFeatureImportance(),
          const SizedBox(height: 24),
          _buildPredictionTools(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple,
            Colors.blue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predictive Analytics Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI-Powered Clinical Predictions & Insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_models.length} Models',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select AI Model',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedModelId,
              decoration: const InputDecoration(
                labelText: 'Choose Model',
                border: OutlineInputBorder(),
              ),
              items: _models.map((model) {
                return DropdownMenuItem(
                  value: model.id,
                  child: Text(model.name),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  setState(() => _selectedModelId = newValue);
                  await _loadModelMetrics(newValue);
                  await _loadFeatureImportance(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelOverview() {
    if (_selectedModelId == null) return const SizedBox.shrink();
    
    final selectedModel = _models.firstWhere((m) => m.id == _selectedModelId);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModelInfoCard(
                    'Accuracy',
                    '${(selectedModel.accuracy * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModelInfoCard(
                    'Type',
                    selectedModel.type.name.toUpperCase(),
                    Icons.category,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModelInfoCard(
                    'Status',
                    selectedModel.status.name.toUpperCase(),
                    Icons.circle,
                    _getStatusColor(selectedModel.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              selectedModel.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildModelParameters(selectedModel.parameters),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    if (_selectedModelMetrics == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Accuracy',
                    '${(_selectedModelMetrics!.accuracy * 100).toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Precision',
                    '${(_selectedModelMetrics!.precision * 100).toStringAsFixed(1)}%',
                    Icons.precision_manufacturing,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Recall',
                    '${(_selectedModelMetrics!.recall * 100).toStringAsFixed(1)}%',
                    Icons.remember_me,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'F1 Score',
                    '${(_selectedModelMetrics!.f1Score * 100).toStringAsFixed(1)}%',
                    Icons.score,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildConfusionMatrix(_selectedModelMetrics!.confusionMatrix),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureImportance() {
    if (_featureImportance.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Importance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _featureImportance.length,
                itemBuilder: (context, index) {
                  final feature = _featureImportance[index];
                  return _buildFeatureImportanceRow(feature, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionTools() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPredictionToolCard(
                    'Treatment Outcome',
                    'Predict treatment success and duration',
                    Icons.medical_services,
                    Colors.green,
                    () => _showTreatmentOutcomeDialog(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPredictionToolCard(
                    'Relapse Risk',
                    'Identify relapse risk factors',
                    Icons.warning,
                    Colors.orange,
                    () => _showRelapseRiskDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPredictionToolCard(
                    'Patient Progress',
                    'Predict recovery timeline',
                    Icons.timeline,
                    Colors.blue,
                    () => _showProgressDialog(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPredictionToolCard(
                    'Crisis Prediction',
                    'Identify crisis situations',
                    Icons.emergency,
                    Colors.red,
                    () => _showCrisisDialog(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoModelsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No AI Models Available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact your administrator to set up predictive models.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelParameters(Map<String, dynamic> parameters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Parameters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: parameters.entries.map((entry) {
            return Chip(
              label: Text('${entry.key}: ${entry.value}'),
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfusionMatrix(Map<String, dynamic> matrix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confusion Matrix',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('TP: ${matrix['true_positive']}'),
                  Text('FP: ${matrix['false_positive']}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('FN: ${matrix['false_negative']}'),
                  Text('TN: ${matrix['true_negative']}'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureImportanceRow(FeatureImportance feature, int index) {
    final color = _getFeatureColor(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.featureName.replaceAll('_', ' ').toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: feature.importance,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(feature.importance * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionToolCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ModelStatus status) {
    switch (status) {
      case ModelStatus.active:
        return Colors.green;
      case ModelStatus.training:
        return Colors.orange;
      case ModelStatus.inactive:
        return Colors.grey;
      case ModelStatus.deprecated:
        return Colors.red;
      case ModelStatus.error:
        return Colors.red;
    }
  }

  Color _getFeatureColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  // Dialog methods for prediction tools
  void _showTreatmentOutcomeDialog() {
    // TODO: Implement treatment outcome prediction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treatment Outcome Prediction - Coming Soon!')),
    );
  }

  void _showRelapseRiskDialog() {
    // TODO: Implement relapse risk prediction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relapse Risk Prediction - Coming Soon!')),
    );
  }

  void _showProgressDialog() {
    // TODO: Implement progress prediction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress Prediction - Coming Soon!')),
    );
  }

  void _showCrisisDialog() {
    // TODO: Implement crisis prediction dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crisis Prediction - Coming Soon!')),
    );
  }
}
