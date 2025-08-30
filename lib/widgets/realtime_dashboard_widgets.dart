import 'package:flutter/material.dart';
import '../services/realtime_dashboard_service.dart';
import '../utils/theme.dart';

// Real-time Dashboard Widget
class RealtimeDashboardWidget extends StatefulWidget {
  const RealtimeDashboardWidget({super.key});

  @override
  State<RealtimeDashboardWidget> createState() => _RealtimeDashboardWidgetState();
}

class _RealtimeDashboardWidgetState extends State<RealtimeDashboardWidget> {
  final RealtimeDashboardService _dashboardService = RealtimeDashboardService();
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _liveUpdates = [];
  Map<String, dynamic> _performanceMetrics = {};

  @override
  void initState() {
    super.initState();
    _dashboardService.initialize();
    
    // Listen to data stream
    _dashboardService.dataStream.listen((data) {
      setState(() {
        _dashboardData = data;
      });
    });
    
    // Listen to updates stream
    _dashboardService.updateStream.listen((update) {
      setState(() {
        _liveUpdates.insert(0, update);
      });
    });
    
    // Listen to performance stream
    _dashboardService.performanceStream.listen((metrics) {
      setState(() {
        _performanceMetrics = metrics;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Live updates indicator
        if (_liveUpdates.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.live_tv, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_liveUpdates.length} canlı güncelleme',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
                const Spacer(),
                const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                const SizedBox(width: 4),
                const Text(
                  'CANLI',
                  style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        
        // Dashboard content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Key metrics
                _buildKeyMetricsRow(),
                const SizedBox(height: 16),
                
                // Charts row
                _buildChartsRow(),
                const SizedBox(height: 16),
                
                // Performance metrics
                _buildPerformanceMetrics(),
                const SizedBox(height: 16),
                
                // Live updates
                _buildLiveUpdates(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Aktif Seanslar',
            '${_dashboardData['activeSessions']?.toStringAsFixed(0) ?? '0'}',
            Icons.psychology,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Bekleyen Randevular',
            '${_dashboardData['pendingAppointments']?.toStringAsFixed(0) ?? '0'}',
            Icons.calendar_today,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Toplam Danışan',
            '${_dashboardData['totalClients']?.toStringAsFixed(0) ?? '0'}',
            Icons.people,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildChartsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildChartCard(
            'Saatlik Seanslar',
            _dashboardData['hourlySessions'] ?? [],
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildChartCard(
            'Haftalık Gelir',
            _dashboardData['weeklyRevenue'] ?? [],
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, List<dynamic> data, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: _buildSimpleChart(data, color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(List<dynamic> data, Color color) {
    if (data.isEmpty) {
      return const Center(child: Text('Veri yok'));
    }
    
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: ChartPainter(data, color),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Performans Metrikleri',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Yanıt Süresi',
                    '${_performanceMetrics['responseTime']?.toStringAsFixed(0) ?? '0'}ms',
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'Bellek Kullanımı',
                    '${_performanceMetrics['memoryUsage']?.toStringAsFixed(1) ?? '0'}%',
                    Icons.memory,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'CPU Kullanımı',
                    '${_performanceMetrics['cpuUsage']?.toStringAsFixed(1) ?? '0'}%',
                    Icons.computer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLiveUpdates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.live_tv, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Canlı Güncellemeler',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _clearAllUpdates,
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Tümünü Temizle',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: _liveUpdates.isEmpty
                  ? const Center(
                      child: Text('Henüz güncelleme yok'),
                    )
                  : ListView.builder(
                      itemCount: _liveUpdates.length,
                      itemBuilder: (context, index) {
                        final update = _liveUpdates[index];
                        return _buildUpdateItem(update);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem(Map<String, dynamic> update) {
    final message = update['message'] as String? ?? '';
    final type = update['type'] as String? ?? 'info';
    final timestamp = update['timestamp'] as String? ?? '';
    final priority = update['priority'] as String? ?? 'low';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUpdateTypeColor(type),
          child: Icon(
            _getUpdateTypeIcon(type),
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          _formatTimestamp(timestamp),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: _getPriorityIcon(priority),
      ),
    );
  }

  Color _getUpdateTypeColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getUpdateTypeIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Widget _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return const Icon(Icons.priority_high, color: Colors.red);
      case 'medium':
        return const Icon(Icons.remove, color: Colors.orange);
      default:
        return const Icon(Icons.arrow_downward, color: Colors.green);
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return 'Az önce';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} dakika önce';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} saat önce';
      } else {
        return '${difference.inDays} gün önce';
      }
    } catch (e) {
      return 'Bilinmeyen zaman';
    }
  }

  Future<void> _clearAllUpdates() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Güncellemeleri Temizle'),
        content: const Text('Tüm canlı güncellemeleri silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Temizle'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dashboardService.clearAllLiveUpdates();
      setState(() {
        _liveUpdates.clear();
      });
    }
  }
}

// Simple Chart Painter
class ChartPainter extends CustomPainter {
  final List<dynamic> data;
  final Color color;

  ChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxValue = data.fold<double>(0, (max, item) {
      final value = (item['sessions'] ?? item['revenue'] ?? 0).toDouble();
      return value > max ? value : max;
    });

    if (maxValue == 0) return;

    final stepX = size.width / (data.length - 1);
    final stepY = size.height / maxValue;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final value = (item['sessions'] ?? item['revenue'] ?? 0).toDouble();
      final x = i * stepX;
      final y = size.height - (value * stepY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Widget Builder
class CustomWidgetBuilder extends StatefulWidget {
  final String widgetType;
  final Map<String, dynamic> config;

  const CustomWidgetBuilder({
    super.key,
    required this.widgetType,
    required this.config,
  });

  @override
  State<CustomWidgetBuilder> createState() => _CustomWidgetBuilderState();
}

class _CustomWidgetBuilderState extends State<CustomWidgetBuilder> {
  final RealtimeDashboardService _dashboardService = RealtimeDashboardService();
  Map<String, dynamic> _widgetData = {};

  @override
  void initState() {
    super.initState();
    _updateWidgetData();
  }

  void _updateWidgetData() {
    setState(() {
      _widgetData = _dashboardService.createCustomWidget(widget.widgetType, widget.config);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.widgetType) {
      case 'chart':
        return _buildChartWidget();
      case 'metric':
        return _buildMetricWidget();
      case 'list':
        return _buildListWidget();
      case 'gauge':
        return _buildGaugeWidget();
      default:
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Bilinmeyen widget türü'),
          ),
        );
    }
  }

  Widget _buildChartWidget() {
    final data = _widgetData['data'] as List<dynamic>? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Özel Grafik',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: ChartPainter(data, AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricWidget() {
    final name = _widgetData['name'] as String? ?? 'Metrik';
    final value = _widgetData['value'] as double? ?? 0;
    final change = _widgetData['change'] as double? ?? 0;
    final trend = _widgetData['trend'] as String? ?? 'up';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(0),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  trend == 'up' ? Icons.trending_up : Icons.trending_down,
                  color: trend == 'up' ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: trend == 'up' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListWidget() {
    final items = _widgetData['items'] as List<dynamic>? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Özel Liste',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...items.map((item) => ListTile(
              title: Text(item['title'] ?? ''),
              subtitle: Text(item['subtitle'] ?? ''),
              trailing: Text(
                item['value']?.toString() ?? '0',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeWidget() {
    final value = _widgetData['value'] as double? ?? 0;
    final min = _widgetData['min'] as double? ?? 0;
    final max = _widgetData['max'] as double? ?? 100;
    final percentage = _widgetData['percentage'] as double? ?? 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Özel Gösterge',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('$value / $max'),
          ],
        ),
      ),
    );
  }
}
