import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/ai_performance_metrics.dart';
import '../../services/ai_orchestration_service.dart';
import '../../services/ai_cache_service.dart';
import '../../utils/ai_logger.dart';

class AIAnalyticsDashboardWidget extends StatefulWidget {
  const AIAnalyticsDashboardWidget({super.key});

  @override
  State<AIAnalyticsDashboardWidget> createState() => _AIAnalyticsDashboardWidgetState();
}

class _AIAnalyticsDashboardWidgetState extends State<AIAnalyticsDashboardWidget>
    with TickerProviderStateMixin {
  final AIOrchestrationService _aiService = AIOrchestrationService();
  final AICacheService _cacheService = AICacheService();
  final AILogger _logger = AILogger();
  
  late AnimationController _refreshController;
  late AnimationController _chartController;
  late AnimationController _metricController;
  
  Map<String, AIModelPerformance> _modelPerformance = {};
  Map<String, dynamic> _serviceStats = {};
  Map<String, dynamic> _cacheStats = {};
  List<AITaskResult> _recentTasks = [];
  
  bool _isLoading = true;
  String _selectedTimeRange = '24h';
  String _selectedMetric = 'accuracy';
  String _selectedView = 'overview';
  
  // Real-time metrics
  int _totalRequests = 0;
  int _successfulRequests = 0;
  double _successRate = 0.0;
  double _averageResponseTime = 0.0;
  double _cacheHitRate = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _metricController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _chartController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(minutes: 2), () {
      if (mounted) {
        _loadData();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final performance = _aiService.getModelPerformance();
      final stats = _aiService.getServiceStats();
      final cacheStats = await _cacheService.getCacheStats();
      
      // Get recent tasks from all models
      final allTasks = <AITaskResult>[];
      for (final modelId in performance.keys) {
        final tasks = _aiService.getTaskHistory(modelId);
        allTasks.addAll(tasks);
      }
      
      // Sort by timestamp and take recent ones
      allTasks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      setState(() {
        _modelPerformance = performance;
        _serviceStats = stats;
        _cacheStats = cacheStats;
        _recentTasks = allTasks.take(20).toList();
        _isLoading = false;
      });
      
      // Update real-time metrics
      _updateRealTimeMetrics();
      
      _chartController.forward();
      _metricController.forward();
      
    } catch (e) {
      _logger.error('Failed to load AI analytics data', context: 'AIAnalyticsDashboard', error: e);
      setState(() => _isLoading = false);
    }
  }

  void _updateRealTimeMetrics() {
    _totalRequests = _serviceStats['totalRequests'] ?? 0;
    _successfulRequests = _serviceStats['totalSuccessful'] ?? 0;
    _successRate = _serviceStats['overallSuccessRate'] ?? 0.0;
    _averageResponseTime = _calculateAverageResponseTime();
    _cacheHitRate = _calculateCacheHitRate();
  }

  double _calculateAverageResponseTime() {
    if (_modelPerformance.isEmpty) return 0.0;
    
    final totalTime = _modelPerformance.values.fold<double>(
      0.0, (sum, model) => sum + model.responseTime);
    
    return totalTime / _modelPerformance.length;
  }

  double _calculateCacheHitRate() {
    final totalHits = (_cacheStats['memoryHits'] ?? 0) + (_cacheStats['diskHits'] ?? 0);
    final totalRequests = _totalRequests;
    
    if (totalRequests == 0) return 0.0;
    return totalHits / totalRequests;
  }

  Future<void> _refreshData() async {
    _refreshController.forward();
    await _loadData();
    _refreshController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedView = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'overview', child: Text('Genel Bakış')),
              const PopupMenuItem(value: 'performance', child: Text('Performans')),
              const PopupMenuItem(value: 'cache', child: Text('Cache Analizi')),
              const PopupMenuItem(value: 'models', child: Text('Model Detayları')),
              const PopupMenuItem(value: 'tasks', child: Text('Görev Geçmişi')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getViewTitle(_selectedView)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSelectedView(),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'overview':
        return _buildOverviewView();
      case 'performance':
        return _buildPerformanceView();
      case 'cache':
        return _buildCacheView();
      case 'models':
        return _buildModelsView();
      case 'tasks':
        return _buildTasksView();
      default:
        return _buildOverviewView();
    }
  }

  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildPerformanceChart(),
          const SizedBox(height: 24),
          _buildCacheEfficiencyChart(),
          const SizedBox(height: 24),
          _buildRecentTasksList(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Toplam İstek',
          '$_totalRequests',
          Icons.api,
          Colors.blue,
          _metricController,
        ),
        _buildMetricCard(
          'Başarı Oranı',
          '${(_successRate * 100).toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.green,
          _metricController,
        ),
        _buildMetricCard(
          'Ortalama Yanıt',
          '${_averageResponseTime.toStringAsFixed(2)}s',
          Icons.speed,
          Colors.orange,
          _metricController,
        ),
        _buildMetricCard(
          'Cache Hit Rate',
          '${(_cacheHitRate * 100).toStringAsFixed(1)}%',
          Icons.storage,
          Colors.purple,
          _metricController,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * controller.value),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: color),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart() {
    if (_modelPerformance.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('Henüz performans verisi yok')),
        ),
      );
    }

    final performanceData = _modelPerformance.values.toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model Performans Karşılaştırması',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < performanceData.length) {
                            return Text(
                              performanceData[value.toInt()].modelName,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value * 100).toInt()}%');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: performanceData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final model = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: model.accuracy,
                          color: _getPerformanceColor(model.accuracy),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheEfficiencyChart() {
    final memoryHits = _cacheStats['memoryHits'] ?? 0;
    final diskHits = _cacheStats['diskHits'] ?? 0;
    final misses = _cacheStats['misses'] ?? 0;
    
    if (memoryHits + diskHits + misses == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('Henüz cache verisi yok')),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Verimliliği',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: memoryHits.toDouble(),
                      title: 'Memory\n${memoryHits}',
                      color: Colors.blue,
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: diskHits.toDouble(),
                      title: 'Disk\n${diskHits}',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: misses.toDouble(),
                      title: 'Miss\n${misses}',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceMetrics(),
          const SizedBox(height: 24),
          _buildResponseTimeChart(),
          const SizedBox(height: 24),
          _buildSuccessRateChart(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performans Metrikleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._modelPerformance.values.map((model) => _buildModelPerformanceTile(model)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelPerformanceTile(AIModelPerformance model) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getPerformanceColor(model.accuracy),
        child: Text(
          model.modelName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(model.modelName),
      subtitle: Text('${model.totalRequests} istek, ${(model.successRate * 100).toStringAsFixed(1)}% başarı'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${model.responseTime.toStringAsFixed(2)}s',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${(model.accuracy * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getPerformanceColor(model.accuracy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCacheOverview(),
          const SizedBox(height: 24),
          _buildCacheTrends(),
          const SizedBox(height: 24),
          _buildCacheOptimization(),
        ],
      ),
    );
  }

  Widget _buildCacheOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Genel Bakış',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
              children: [
                _buildCacheMetricTile('Memory Cache', '${_cacheStats['memoryCacheSize'] ?? 0}', Colors.blue),
                _buildCacheMetricTile('Disk Cache', '${_cacheStats['diskCacheSize'] ?? 0}', Colors.green),
                _buildCacheMetricTile('Cache Hits', '${_cacheStats['memoryHits'] ?? 0 + _cacheStats['diskHits'] ?? 0}', Colors.orange),
                _buildCacheMetricTile('Cache Misses', '${_cacheStats['misses'] ?? 0}', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheMetricTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModelsList(),
          const SizedBox(height: 24),
          _buildModelComparison(),
        ],
      ),
    );
  }

  Widget _buildModelsList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Modelleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._modelPerformance.values.map((model) => _buildDetailedModelTile(model)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedModelTile(AIModelPerformance model) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: _getPerformanceColor(model.accuracy),
        child: Text(
          model.modelName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(model.modelName),
      subtitle: Text('Son kullanım: ${_formatDateTime(model.lastUsed)}'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMetricRow('Toplam İstek', '${model.totalRequests}'),
              _buildMetricRow('Başarılı İstek', '${model.successfulRequests}'),
              _buildMetricRow('Başarısız İstek', '${model.failedRequests}'),
              _buildMetricRow('Başarı Oranı', '${(model.successRate * 100).toStringAsFixed(1)}%'),
              _buildMetricRow('Ortalama Yanıt Süresi', '${model.responseTime.toStringAsFixed(2)}s'),
              _buildMetricRow('Güven Skoru', '${(model.confidenceScore * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTasksView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTasksOverview(),
          const SizedBox(height: 24),
          _buildRecentTasksList(),
        ],
      ),
    );
  }

  Widget _buildTasksOverview() {
    final totalTasks = _recentTasks.length;
    final successfulTasks = _recentTasks.where((t) => t.success).length;
    final failedTasks = totalTasks - successfulTasks;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Görev Genel Bakış',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTaskMetricCard('Toplam', totalTasks, Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTaskMetricCard('Başarılı', successfulTasks, Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTaskMetricCard('Başarısız', failedTasks, Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskMetricCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasksList() {
    if (_recentTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son AI Görevleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTasks.length,
              itemBuilder: (context, index) {
                final task = _recentTasks[index];
                return ListTile(
                  leading: Icon(
                    task.success ? Icons.check_circle : Icons.error,
                    color: task.success ? Colors.green : Colors.red,
                  ),
                  title: Text('${task.modelId.toUpperCase()} - ${task.taskType}'),
                  subtitle: Text(
                    'Güven: ${(task.confidence * 100).toStringAsFixed(1)}% | '
                    'Süre: ${task.responseTime.inMilliseconds}ms',
                  ),
                  trailing: Text(
                    _formatDateTime(task.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getPerformanceColor(double value) {
    if (value >= 0.8) return Colors.green;
    if (value >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getViewTitle(String view) {
    switch (view) {
      case 'overview': return 'Genel Bakış';
      case 'performance': return 'Performans';
      case 'cache': return 'Cache Analizi';
      case 'models': return 'Model Detayları';
      case 'tasks': return 'Görev Geçmişi';
      default: return 'Genel Bakış';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  // Placeholder methods for charts that will be implemented
  Widget _buildResponseTimeChart() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Yanıt Süresi Grafiği - Geliştirilecek')),
      ),
    );
  }

  Widget _buildSuccessRateChart() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Başarı Oranı Grafiği - Geliştirilecek')),
      ),
    );
  }

  Widget _buildCacheTrends() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Cache Trendleri - Geliştirilecek')),
      ),
    );
  }

  Widget _buildCacheOptimization() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Cache Optimizasyonu - Geliştirilecek')),
      ),
    );
  }

  Widget _buildModelComparison() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('Model Karşılaştırması - Geliştirilecek')),
      ),
    );
  }
}
