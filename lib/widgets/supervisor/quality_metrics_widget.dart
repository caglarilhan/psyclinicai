import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/supervision_models.dart';

class QualityMetricsWidget extends StatefulWidget {
  final List<QualityMetric> metrics;
  final Function(QualityMetric) onMetricTap;

  const QualityMetricsWidget({
    super.key,
    required this.metrics,
    required this.onMetricTap,
  });

  @override
  State<QualityMetricsWidget> createState() => _QualityMetricsWidgetState();
}

class _QualityMetricsWidgetState extends State<QualityMetricsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _selectedTimeframe = 'Son 30 Gün';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<QualityMetric> get _filteredMetrics {
    return widget.metrics.where((metric) {
      final matchesSearch = metric.metricName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          metric.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'Tümü' || metric.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Metrik ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Tümü', 'Hasta Memnuniyeti', 'Tedavi Başarısı', 'Güvenlik', 'Kalite']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimeframe,
                      decoration: InputDecoration(
                        labelText: 'Zaman Aralığı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Son 7 Gün', 'Son 30 Gün', 'Son 3 Ay', 'Son 1 Yıl']
                          .map((timeframe) => DropdownMenuItem(
                                value: timeframe,
                                child: Text(timeframe),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedTimeframe = value!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            tabs: const [
              Tab(text: 'Genel Bakış'),
              Tab(text: 'Trendler'),
              Tab(text: 'Detaylar'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Metrics Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTrendsTab(),
              _buildDetailsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    if (_filteredMetrics.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Ortalama Puan',
                  value: _calculateAverageScore().toStringAsFixed(1),
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Toplam Metrik',
                  value: _filteredMetrics.length.toString(),
                  icon: Icons.analytics,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Metrics Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _filteredMetrics.length,
            itemBuilder: (context, index) {
              final metric = _filteredMetrics[index];
              return _buildMetricCard(metric);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (_filteredMetrics.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Trend Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trend Grafiği',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Metrik trendleri burada görüntülenecek',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Trend List
          ..._filteredMetrics.map((metric) => _buildTrendItem(metric)),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (_filteredMetrics.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredMetrics.length,
      itemBuilder: (context, index) {
        final metric = _filteredMetrics[index];
        return _buildDetailedMetricCard(metric);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Kalite metrik verisi bulunamadı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kalite metrikleri henüz eklenmemiş',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(QualityMetric metric) {
    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onMetricTap(metric);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getMetricIcon(metric.category),
                color: _getMetricColor(metric.score),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                metric.metricName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${(metric.score * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getMetricColor(metric.score),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendItem(QualityMetric metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getMetricIcon(metric.category),
          color: _getMetricColor(metric.score),
        ),
        title: Text(metric.metricName),
        subtitle: Text(metric.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(metric.score * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getMetricColor(metric.score),
              ),
            ),
            Text(
              metric.trend,
              style: TextStyle(
                fontSize: 12,
                color: _getTrendColor(metric.trend),
              ),
            ),
          ],
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onMetricTap(metric);
        },
      ),
    );
  }

  Widget _buildDetailedMetricCard(QualityMetric metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getMetricIcon(metric.category),
          color: _getMetricColor(metric.score),
        ),
        title: Text(
          metric.metricName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(metric.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score and Trend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puan: ${(metric.score * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getMetricColor(metric.score),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTrendColor(metric.trend).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        metric.trend,
                        style: TextStyle(
                          color: _getTrendColor(metric.trend),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress Bar
                LinearProgressIndicator(
                  value: metric.score,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getMetricColor(metric.score),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                
                const SizedBox(height: 16),
                
                // Additional Details
                if (metric.targetValue != null) ...[
                  Text(
                    'Hedef: ${(metric.targetValue! * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                if (metric.weight != null) ...[
                  Text(
                    'Ağırlık: ${(metric.weight! * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Notes
                if (metric.notes != null && metric.notes!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      metric.notes!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMetricIcon(String category) {
    switch (category) {
      case 'Hasta Memnuniyeti':
        return Icons.sentiment_satisfied;
      case 'Tedavi Başarısı':
        return Icons.healing;
      case 'Güvenlik':
        return Icons.security;
      case 'Kalite':
        return Icons.verified;
      default:
        return Icons.analytics;
    }
  }

  Color _getMetricColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getTrendColor(String trend) {
    if (trend.contains('↑') || trend.contains('artış')) return Colors.green;
    if (trend.contains('↓') || trend.contains('azalış')) return Colors.red;
    return Colors.grey;
  }

  double _calculateAverageScore() {
    if (_filteredMetrics.isEmpty) return 0.0;
    final totalScore = _filteredMetrics.fold<double>(
      0.0,
      (sum, metric) => sum + metric.score,
    );
    return totalScore / _filteredMetrics.length;
  }
}
