import 'package:flutter/material.dart';
import '../services/advanced_analytics_service.dart';
import '../utils/theme.dart';

// Advanced Analytics Dashboard Widget
class AdvancedAnalyticsDashboardWidget extends StatefulWidget {
  const AdvancedAnalyticsDashboardWidget({super.key});

  @override
  State<AdvancedAnalyticsDashboardWidget> createState() => _AdvancedAnalyticsDashboardWidgetState();
}

class _AdvancedAnalyticsDashboardWidgetState extends State<AdvancedAnalyticsDashboardWidget> {
  final AdvancedAnalyticsService _analyticsService = AdvancedAnalyticsService();
  Map<String, dynamic> _analyticsData = {};
  List<Map<String, dynamic>> _trends = [];
  List<Map<String, dynamic>> _predictions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Listen to data updates
    _analyticsService.dataStream.listen((data) {
      setState(() {
        _analyticsData = data;
      });
    });
    
    _analyticsService.trendStream.listen((trend) {
      setState(() {
        _trends.add(trend);
      });
    });
    
    _analyticsService.predictionStream.listen((prediction) {
      setState(() {
        _predictions.add(prediction);
      });
    });
  }

  void _loadData() {
    setState(() {
      _analyticsData = _analyticsService.analyticsData;
      _trends = _analyticsService.trends;
      _predictions = _analyticsService.predictions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('Gelişmiş Analitik'),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Genel Bakış'),
              Tab(text: 'Trendler'),
              Tab(text: 'Tahminler'),
              Tab(text: 'Raporlar'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildTrendsTab(),
            _buildPredictionsTab(),
            _buildReportsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Metrics
          _buildKeyMetricsRow(),
          const SizedBox(height: 16),
          
          // Performance Metrics
          _buildPerformanceMetrics(),
          const SizedBox(height: 16),
          
          // Growth Charts
          _buildGrowthCharts(),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Seanslar',
            '${_analyticsData['sessions']?['total'] ?? 0}',
            '${_analyticsData['sessions']?['growth'] ?? 0}%',
            Icons.psychology,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Müşteriler',
            '${_analyticsData['clients']?['total'] ?? 0}',
            '${_analyticsData['clients']?['retentionRate'] ?? 0}%',
            Icons.people,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Gelir',
            '₺${_formatNumber(_analyticsData['revenue']?['total'] ?? 0)}',
            '${_analyticsData['revenue']?['growth'] ?? 0}%',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String change, IconData icon, Color color) {
    final isPositive = change.startsWith('-') == false;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final performance = _analyticsData['performance'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performans Metrikleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _buildPerformanceItem(
              'Yanıt Süresi',
              '${performance['responseTime'] ?? 0} s',
              Icons.speed,
              Colors.blue,
            ),
            
            _buildPerformanceItem(
              'Çalışma Süresi',
              '${performance['uptime'] ?? 0}%',
              Icons.check_circle,
              Colors.green,
            ),
            
            _buildPerformanceItem(
              'Kullanıcı Memnuniyeti',
              '${performance['userSatisfaction'] ?? 0}/5',
              Icons.star,
              Colors.orange,
            ),
            
            _buildPerformanceItem(
              'Hata Oranı',
              '${performance['errorRate'] ?? 0}%',
              Icons.error,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCharts() {
    final trends = _analyticsData['trends'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Büyüme Trendleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            if (trends['sessionsGrowth'] != null)
              _buildTrendChart('Seans Büyümesi', trends['sessionsGrowth'], Colors.blue),
            
            const SizedBox(height: 16),
            
            if (trends['revenueGrowth'] != null)
              _buildTrendChart('Gelir Büyümesi', trends['revenueGrowth'], Colors.green),
            
            const SizedBox(height: 16),
            
            if (trends['clientGrowth'] != null)
              _buildTrendChart('Müşteri Büyümesi', trends['clientGrowth'], Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(String title, List<dynamic> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: Row(
            children: data.map((value) {
              final height = (value.toDouble() / 10) * 60; // Normalize to 60px height
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: height.clamp(4, 60),
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsTab() {
    return _trends.isEmpty
        ? _buildEmptyState('Trend Analizi', 'Henüz trend analizi yapılmamış')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _trends.length,
            itemBuilder: (context, index) {
              final trend = _trends[index];
              return _buildTrendCard(trend);
            },
          );
  }

  Widget _buildTrendCard(Map<String, dynamic> trend) {
    final metric = trend['metric'] ?? '';
    final direction = trend['trend']?['direction'] ?? 'stable';
    final confidence = trend['confidence'] ?? 0.0;
    final insights = List<String>.from(trend['insights'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTrendIcon(direction),
                  color: _getTrendColor(direction),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMetricName(metric),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildConfidenceBadge(confidence),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Trend: ${_getTrendDescription(direction)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            const SizedBox(height: 8),
            
            if (insights.isNotEmpty) ...[
              Text(
                'İçgörüler:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...insights.map((insight) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(insight)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsTab() {
    return _predictions.isEmpty
        ? _buildEmptyState('Tahminler', 'Henüz tahmin oluşturulmamış')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _predictions.length,
            itemBuilder: (context, index) {
              final prediction = _predictions[index];
              return _buildPredictionCard(prediction);
            },
          );
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
    final metric = prediction['metric'] ?? '';
    final confidence = prediction['confidence'] ?? 0.0;
    final forecast = List<double>.from(prediction['forecast'] ?? []);
    final recommendations = List<String>.from(prediction['recommendations'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMetricName(metric),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildConfidenceBadge(confidence),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Tahmin (${forecast.length} dönem):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              height: 40,
              child: Row(
                children: forecast.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Öneriler:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...recommendations.map((recommendation) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(recommendation)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    final reports = _analyticsService.customReports;
    
    return reports.isEmpty
        ? _buildEmptyState('Özel Raporlar', 'Henüz özel rapor oluşturulmamış')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportCard(report);
            },
          );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final name = report['name'] ?? '';
    final description = report['description'] ?? '';
    final isActive = report['isActive'] == true;
    final lastGenerated = report['lastGenerated'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.grey,
          child: Icon(
            Icons.assessment,
            color: Colors.white,
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            if (lastGenerated != null)
              Text(
                'Son çalıştırma: ${_formatDate(lastGenerated)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'run':
                _runReport(report['id']);
                break;
              case 'edit':
                _editReport(report);
                break;
              case 'delete':
                _deleteReport(report['id']);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'run',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Çalıştır'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Sil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni $title oluşturmak için + butonuna tıklayın',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    final percentage = (confidence * 100).toInt();
    Color color;
    
    if (percentage >= 80) {
      color = Colors.green;
    } else if (percentage >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getTrendIcon(String direction) {
    switch (direction) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String direction) {
    switch (direction) {
      case 'increasing':
        return Colors.green;
      case 'decreasing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTrendDescription(String direction) {
    switch (direction) {
      case 'increasing':
        return 'Artış trendinde';
      case 'decreasing':
        return 'Düşüş trendinde';
      default:
        return 'Stabil';
    }
  }

  String _getMetricName(String metric) {
    switch (metric) {
      case 'sessionsGrowth':
        return 'Seans Büyümesi';
      case 'revenueGrowth':
        return 'Gelir Büyümesi';
      case 'clientGrowth':
        return 'Müşteri Büyümesi';
      default:
        return metric;
    }
  }

  String _formatNumber(dynamic number) {
    if (number is int || number is double) {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      }
      return number.toString();
    }
    return '0';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _refreshData() {
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veriler yenilendi')),
    );
  }

  void _runReport(String reportId) async {
    try {
      final results = await _analyticsService.runReport(reportId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapor çalıştırıldı: ${results.length} metrik')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapor çalıştırma hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editReport(Map<String, dynamic> report) {
    // TODO: Report edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapor düzenleme özelliği yakında')),
    );
  }

  void _deleteReport(String reportId) {
    // TODO: Report deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapor silme özelliği yakında')),
    );
  }
}
