import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/ai_performance_metrics.dart';
import '../../services/ai_orchestration_service.dart';
import '../../utils/ai_logger.dart';

class AIAnalyticsDashboardWidget extends StatefulWidget {
  const AIAnalyticsDashboardWidget({super.key});

  @override
  State<AIAnalyticsDashboardWidget> createState() => _AIAnalyticsDashboardWidgetState();
}

class _AIAnalyticsDashboardWidgetState extends State<AIAnalyticsDashboardWidget>
    with TickerProviderStateMixin {
  final AIOrchestrationService _aiService = AIOrchestrationService();
  final AILogger _logger = AILogger();
  
  late AnimationController _refreshController;
  late AnimationController _chartController;
  
  Map<String, AIModelPerformance> _modelPerformance = {};
  Map<String, dynamic> _serviceStats = {};
  List<AITaskResult> _recentTasks = [];
  
  bool _isLoading = true;
  String _selectedTimeRange = '24h';
  String _selectedMetric = 'accuracy';

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
    
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(minutes: 5), () {
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
        _recentTasks = allTasks.take(20).toList();
        _isLoading = false;
      });
      
      _chartController.forward();
    } catch (e) {
      _logger.error('Failed to load AI analytics data', context: 'AIAnalyticsDashboard', error: e);
      setState(() => _isLoading = false);
    }
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
              setState(() => _selectedTimeRange = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '1h', child: Text('Son 1 Saat')),
              const PopupMenuItem(value: '24h', child: Text('Son 24 Saat')),
              const PopupMenuItem(value: '7d', child: Text('Son 7 Gün')),
              const PopupMenuItem(value: '30d', child: Text('Son 30 Gün')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedTimeRange),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 24),
                    _buildPerformanceChart(),
                    const SizedBox(height: 24),
                    _buildModelComparisonTable(),
                    const SizedBox(height: 24),
                    _buildRecentTasksList(),
                  ],
                ),
              ),
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
          '${_serviceStats['totalRequests'] ?? 0}',
          Icons.api,
          Colors.blue,
        ),
        _buildMetricCard(
          'Başarı Oranı',
          '${((_serviceStats['overallSuccessRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.green,
        ),
        _buildMetricCard(
          'Aktif Modeller',
          '${_serviceStats['activeModels'] ?? 0}',
          Icons.psychology,
          Colors.purple,
        ),
        _buildMetricCard(
          'Cache Hit Rate',
          '${_calculateCacheHitRate()}%',
          Icons.storage,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
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
    );
  }

  Widget _buildPerformanceChart() {
    if (_modelPerformance.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('Henüz performans verisi yok'),
          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Model Performans Karşılaştırması',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<String>(
                  value: _selectedMetric,
                  onChanged: (value) {
                    setState(() => _selectedMetric = value!);
                  },
                  items: [
                    DropdownMenuItem(value: 'accuracy', child: const Text('Doğruluk')),
                    DropdownMenuItem(value: 'responseTime', child: const Text('Yanıt Süresi')),
                    DropdownMenuItem(value: 'confidence', child: const Text('Güven')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final models = _modelPerformance.keys.toList();
                          if (value.toInt() < models.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                models[value.toInt()].toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
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
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue() {
    if (_modelPerformance.isEmpty) return 1.0;
    
    switch (_selectedMetric) {
      case 'accuracy':
        return 1.0;
      case 'responseTime':
        return _modelPerformance.values
            .map((m) => m.responseTime)
            .reduce((a, b) => a > b ? a : b) * 1.2;
      case 'confidence':
        return 1.0;
      default:
        return 1.0;
    }
  }

  List<BarChartGroupData> _buildBarGroups() {
    final models = _modelPerformance.keys.toList();
    return List.generate(models.length, (index) {
      final modelId = models[index];
      final performance = _modelPerformance[modelId]!;
      
      double value;
      switch (_selectedMetric) {
        case 'accuracy':
          value = performance.accuracy;
          break;
        case 'responseTime':
          value = performance.responseTime;
          break;
        case 'confidence':
          value = performance.confidenceScore;
          break;
        default:
          value = performance.accuracy;
      }
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: _getModelColor(modelId),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  Color _getModelColor(String modelId) {
    switch (modelId) {
      case 'openai':
        return Colors.blue;
      case 'claude':
        return Colors.green;
      case 'llama':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildModelComparisonTable() {
    if (_modelPerformance.isEmpty) {
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
              'Detaylı Model Karşılaştırması',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Model')),
                  DataColumn(label: Text('Doğruluk')),
                  DataColumn(label: Text('Yanıt Süresi')),
                  DataColumn(label: Text('Güven')),
                  DataColumn(label: Text('Toplam İstek')),
                  DataColumn(label: Text('Başarı Oranı')),
                  DataColumn(label: Text('Son Kullanım')),
                ],
                rows: _modelPerformance.values.map((performance) {
                  return DataRow(
                    cells: [
                      DataCell(Text(performance.modelName)),
                      DataCell(Text('${(performance.accuracy * 100).toStringAsFixed(1)}%')),
                      DataCell(Text('${performance.responseTime.toStringAsFixed(2)}s')),
                      DataCell(Text('${(performance.confidenceScore * 100).toStringAsFixed(1)}%')),
                      DataCell(Text('${performance.totalRequests}')),
                      DataCell(Text('${(performance.successRate * 100).toStringAsFixed(1)}%')),
                      DataCell(Text(_formatDateTime(performance.lastUsed))),
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

  String _calculateCacheHitRate() {
    final cacheStats = _serviceStats['cacheStats'] as Map<String, dynamic>?;
    if (cacheStats == null) return '0';
    
    final memoryHits = cacheStats['memoryCacheSize'] ?? 0;
    final diskHits = cacheStats['diskCacheSize'] ?? 0;
    final totalHits = memoryHits + diskHits;
    final totalRequests = _serviceStats['totalRequests'] ?? 1;
    
    return ((totalHits / totalRequests) * 100).toStringAsFixed(1);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}
