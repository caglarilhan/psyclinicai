import 'package:flutter/material.dart';
import 'package:psyclinicai/models/flag_ai_models.dart';
import 'package:psyclinicai/services/flag_ai_service.dart';
import 'package:psyclinicai/services/ai_logger.dart';

// AI Model Performans Dashboard Widget'ı
class AIModelPerformanceWidget extends StatefulWidget {
  final Function(String) onError;

  const AIModelPerformanceWidget({
    super.key,
    required this.onError,
  });

  @override
  State<AIModelPerformanceWidget> createState() => _AIModelPerformanceWidgetState();
}

class _AIModelPerformanceWidgetState extends State<AIModelPerformanceWidget>
    with TickerProviderStateMixin {
  final FlagAIService _flagService = FlagAIService();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isInitialized = false;
  Map<String, AIModelPerformance> _modelPerformance = {};
  String? _error;
  String _selectedModel = 'all';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeService();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      await _flagService.initialize();
      await _loadModelPerformance();
      
      setState(() {
        _isInitialized = true;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _error = 'Servis başlatılamadı: $e';
      });
      widget.onError('Servis başlatılamadı: $e');
    }
  }

  Future<void> _loadModelPerformance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock model performance data - gerçek uygulamada veritabanından gelecek
      final mockModels = {
        'suicide_risk': AIModelPerformance(
          modelId: 'suicide_risk_v1',
          version: '1.0.0',
          accuracy: 0.94,
          precision: 0.91,
          recall: 0.89,
          f1Score: 0.90,
          falsePositiveRate: 0.06,
          falseNegativeRate: 0.11,
          totalPredictions: 10000,
          correctPredictions: 9400,
          falsePositives: 600,
          falseNegatives: 1100,
          classAccuracy: {
            'low': 0.96,
            'moderate': 0.93,
            'high': 0.91,
            'critical': 0.89,
          },
          lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
          metadata: {
            'training_data': 'Multi-cultural dataset',
            'validation_method': 'Cross-validation',
            'deployment_date': '2024-01-01',
          },
        ),
        'violence_risk': AIModelPerformance(
          modelId: 'violence_risk_v1',
          version: '1.0.0',
          accuracy: 0.92,
          precision: 0.88,
          recall: 0.85,
          f1Score: 0.86,
          falsePositiveRate: 0.08,
          falseNegativeRate: 0.15,
          totalPredictions: 8000,
          correctPredictions: 7360,
          falsePositives: 640,
          falseNegatives: 1200,
          classAccuracy: {
            'low': 0.95,
            'moderate': 0.90,
            'high': 0.87,
            'critical': 0.84,
          },
          lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
          metadata: {
            'training_data': 'International violence dataset',
            'validation_method': 'Multi-site validation',
            'deployment_date': '2024-01-01',
          },
        ),
        'depression_risk': AIModelPerformance(
          modelId: 'depression_risk_v1',
          version: '1.0.0',
          accuracy: 0.89,
          precision: 0.87,
          recall: 0.84,
          f1Score: 0.85,
          falsePositiveRate: 0.11,
          falseNegativeRate: 0.16,
          totalPredictions: 12000,
          correctPredictions: 10680,
          falsePositives: 1320,
          falseNegatives: 1920,
          classAccuracy: {
            'mild': 0.92,
            'moderate': 0.88,
            'severe': 0.85,
          },
          lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
          metadata: {
            'training_data': 'Clinical depression dataset',
            'validation_method': 'Clinical validation',
            'deployment_date': '2024-01-01',
          },
        ),
        'anxiety_risk': AIModelPerformance(
          modelId: 'anxiety_risk_v1',
          version: '1.0.0',
          accuracy: 0.91,
          precision: 0.89,
          recall: 0.86,
          f1Score: 0.87,
          falsePositiveRate: 0.09,
          falseNegativeRate: 0.14,
          totalPredictions: 9500,
          correctPredictions: 8645,
          falsePositives: 855,
          falseNegatives: 1330,
          classAccuracy: {
            'mild': 0.94,
            'moderate': 0.90,
            'severe': 0.87,
          },
          lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
          metadata: {
            'training_data': 'Anxiety disorder dataset',
            'validation_method': 'Multi-center validation',
            'deployment_date': '2024-01-01',
          },
        ),
      };

      setState(() {
        _modelPerformance = mockModels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Model performans verileri yüklenemedi: $e';
        _isLoading = false;
      });
      widget.onError('Model performans verileri yüklenemedi: $e');
    }
  }

  List<AIModelPerformance> get _filteredModels {
    if (_selectedModel == 'all') {
      return _modelPerformance.values.toList();
    }
    return _modelPerformance.values
        .where((model) => model.modelId.contains(_selectedModel))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              if (!_isInitialized) _buildInitializingState(),
              if (_isInitialized && _isLoading) _buildLoadingState(),
              if (_isInitialized && !_isLoading && _error != null) _buildErrorState(),
              if (_isInitialized && !_isLoading && _error == null) ...[
                _buildOverallMetrics(),
                const SizedBox(height: 20),
                _buildModelSelector(),
                const SizedBox(height: 20),
                _buildModelList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.analytics,
            color: Colors.purple,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🤖 AI Model Performans Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Text(
                'AI modellerin performans metrikleri ve analizi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitializingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          const SizedBox(height: 16),
          Text(
            'AI Model Performans Verileri Yükleniyor...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Hata Oluştu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Bilinmeyen hata',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadModelPerformance,
            child: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallMetrics() {
    if (_modelPerformance.isEmpty) return const SizedBox.shrink();

    final totalModels = _modelPerformance.length;
    final avgAccuracy = _modelPerformance.values
        .map((model) => model.accuracy)
        .reduce((a, b) => a + b) / totalModels;
    final avgF1Score = _modelPerformance.values
        .map((model) => model.f1Score)
        .reduce((a, b) => a + b) / totalModels;
    final totalPredictions = _modelPerformance.values
        .map((model) => model.totalPredictions)
        .reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genel Performans Metrikleri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Toplam Model',
                  '$totalModels',
                  Icons.model_training,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Ortalama Doğruluk',
                  '${(avgAccuracy * 100).toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Ortalama F1 Skoru',
                  '${(avgF1Score * 100).toStringAsFixed(1)}%',
                  Icons.analytics,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Toplam Tahmin',
                  '${(totalPredictions / 1000).toStringAsFixed(1)}K',
                  Icons.analytics,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Filtresi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: DropdownButton<String>(
            value: _selectedModel,
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _selectedModel = value!;
              });
            },
            items: [
              DropdownMenuItem(value: 'all', child: Text('Tüm Modeller')),
              DropdownMenuItem(value: 'suicide', child: Text('İntihar Riski')),
              DropdownMenuItem(value: 'violence', child: Text('Şiddet Riski')),
              DropdownMenuItem(value: 'depression', child: Text('Depresyon Riski')),
              DropdownMenuItem(value: 'anxiety', child: Text('Anksiyete Riski')),
            ],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildModelList() {
    if (_filteredModels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Model Bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seçilen filtrelere uygun model bulunamadı',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Performans Detayları (${_filteredModels.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredModels.length,
          itemBuilder: (context, index) {
            final model = _filteredModels[index];
            return _buildModelCard(model);
          },
        ),
      ],
    );
  }

  Widget _buildModelCard(AIModelPerformance model) {
    final accuracyColor = _getAccuracyColor(model.accuracy);
    final f1Color = _getAccuracyColor(model.f1Score);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.psychology,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getModelDisplayName(model.modelId),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'v${model.version}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildMetricChip('Doğruluk', '${(model.accuracy * 100).toStringAsFixed(1)}%', accuracyColor),
              const SizedBox(width: 8),
              _buildMetricChip('F1 Skoru', '${(model.f1Score * 100).toStringAsFixed(1)}%', f1Color),
              const SizedBox(width: 8),
              _buildMetricChip('Tahmin', '${model.totalPredictions}', Colors.blue),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailedMetrics(model),
                const SizedBox(height: 16),
                _buildClassAccuracy(model),
                const SizedBox(height: 16),
                _buildModelMetadata(model),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailedMetrics(AIModelPerformance model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı Metrikler',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailMetric('Precision', '${(model.precision * 100).toStringAsFixed(1)}%', Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDetailMetric('Recall', '${(model.recall * 100).toStringAsFixed(1)}%', Colors.blue),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDetailMetric('False +', '${(model.falsePositiveRate * 100).toStringAsFixed(1)}%', Colors.orange),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDetailMetric('False -', '${(model.falseNegativeRate * 100).toStringAsFixed(1)}%', Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAccuracy(AIModelPerformance model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sınıf Bazında Doğruluk',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: model.classAccuracy.entries.map((entry) {
            final accuracy = entry.value;
            final color = _getAccuracyColor(accuracy);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '${entry.key}: ${(accuracy * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModelMetadata(AIModelPerformance model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Bilgileri',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildMetadataRow('Eğitim Verisi', model.metadata['training_data'] ?? 'N/A'),
              _buildMetadataRow('Doğrulama Yöntemi', model.metadata['validation_method'] ?? 'N/A'),
              _buildMetadataRow('Deployment Tarihi', model.metadata['deployment_date'] ?? 'N/A'),
              _buildMetadataRow('Son Güncelleme', _formatDateTime(model.lastUpdated)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.8) return Colors.orange;
    if (accuracy >= 0.7) return Colors.red;
    return Colors.grey;
  }

  String _getModelDisplayName(String modelId) {
    switch (modelId) {
      case 'suicide_risk_v1':
        return 'İntihar Riski Modeli';
      case 'violence_risk_v1':
        return 'Şiddet Riski Modeli';
      case 'depression_risk_v1':
        return 'Depresyon Riski Modeli';
      case 'anxiety_risk_v1':
        return 'Anksiyete Riski Modeli';
      default:
        return modelId;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
