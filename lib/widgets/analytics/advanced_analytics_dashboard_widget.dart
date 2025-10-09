import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/analytics_models.dart';
import '../../services/analytics_service.dart';
import '../../utils/theme.dart';

class AdvancedAnalyticsDashboardWidget extends StatefulWidget {
  final String userId;

  const AdvancedAnalyticsDashboardWidget({
    super.key,
    required this.userId,
  });

  @override
  State<AdvancedAnalyticsDashboardWidget> createState() => _AdvancedAnalyticsDashboardDashboardWidgetState();
}

class _AdvancedAnalyticsDashboardDashboardWidgetState extends State<AdvancedAnalyticsDashboardWidget> {
  final _analyticsService = AnalyticsService();
  AnalyticsDashboard? _dashboard;
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.monthly;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final dashboard = await _analyticsService.generateAnalyticsDashboard(
        userId: widget.userId,
        period: _selectedPeriod,
      );
      
      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Analitik veriler yüklenemedi: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboard == null) {
      return const Center(child: Text('Analitik veriler bulunamadı'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Period Selector
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // KPI Cards
          _buildKPICards(),
          
          const SizedBox(height: 24),
          
          // Charts Row
          Row(
            children: [
              Expanded(child: _buildRevenueChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildTrendChart()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Patient Outcomes
          _buildPatientOutcomes(),
          
          const SizedBox(height: 24),
          
          // Retention Metrics
          _buildRetentionMetrics(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.analytics, color: AppTheme.primaryColor, size: 32),
        const SizedBox(width: 12),
        Text(
          'Gelişmiş Analitik',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        DropdownButton<AnalyticsPeriod>(
          value: _selectedPeriod,
          items: AnalyticsPeriod.values.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(_getPeriodDisplayName(period)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
                _isLoading = true;
              });
              _loadDashboard();
            }
          },
        ),
      ],
    );
  }

  Widget _buildKPICards() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _dashboard!.kpis.length,
      itemBuilder: (context, index) {
        final kpi = _dashboard!.kpis[index];
        return _buildKPICard(kpi);
      },
    );
  }

  Widget _buildKPICard(ClinicalKPI kpi) {
    final isPositive = kpi.isPositiveChange;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kpi.metricName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _formatKPIValue(kpi.value, kpi.metricName),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  changeIcon,
                  color: changeColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${kpi.changePercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: changeColor,
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

  Widget _buildRevenueChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gelir Analizi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _dashboard!.revenue.recurringRevenue,
                      title: 'Tekrarlayan',
                      color: AppTheme.primaryColor,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: _dashboard!.revenue.oneTimeRevenue,
                      title: 'Tek Seferlik',
                      color: Colors.orange,
                      radius: 60,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Tekrarlayan', AppTheme.primaryColor),
                _buildLegendItem('Tek Seferlik', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final trend = _dashboard!.trends.isNotEmpty ? _dashboard!.trends.first : null;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analizi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: trend != null
                  ? LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: trend.dataPoints.map((dp) {
                              return FlSpot(
                                dp.date.millisecondsSinceEpoch.toDouble(),
                                dp.value,
                              );
                            }).toList(),
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('Trend verisi bulunamadı')),
            ),
            if (trend != null) ...[
              const SizedBox(height: 16),
              Text(
                trend.interpretation,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatientOutcomes() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasta Sonuçları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._dashboard!.patientOutcomes.map((outcome) => _buildOutcomeItem(outcome)),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeItem(PatientOutcomeMetrics outcome) {
    final categoryColor = _getOutcomeCategoryColor(outcome.outcomeCategory);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: categoryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasta ${outcome.patientId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${outcome.assessmentType} - ${outcome.sessionsCompleted} seans',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${outcome.improvementPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              Text(
                outcome.outcomeCategory,
                style: TextStyle(
                  fontSize: 12,
                  color: categoryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionMetrics() {
    final retention = _dashboard!.retention;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasta Sadakat Metrikleri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRetentionMetric(
                    'Yeni Hasta',
                    retention.newPatients.toString(),
                    Icons.person_add,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildRetentionMetric(
                    'Sadık Hasta',
                    retention.retainedPatients.toString(),
                    Icons.person,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildRetentionMetric(
                    'Kayıp Hasta',
                    retention.lostPatients.toString(),
                    Icons.person_off,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRetentionMetric(
                    'Sadakat Oranı',
                    '${retention.retentionRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildRetentionMetric(
                    'Kayıp Oranı',
                    '${retention.churnRate.toStringAsFixed(1)}%',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildRetentionMetric(
                    'Ortalama Değer',
                    '\$${retention.averageLifetimeValue.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _formatKPIValue(double value, String metricName) {
    if (metricName.contains('Oranı') || metricName.contains('Memnuniyet')) {
      return value.toStringAsFixed(1);
    } else if (metricName.contains('Seans')) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  Color _getOutcomeCategoryColor(String category) {
    switch (category) {
      case 'Mükemmel':
        return Colors.green;
      case 'İyi':
        return Colors.lightGreen;
      case 'Orta':
        return Colors.orange;
      case 'Zayıf':
        return Colors.red;
      case 'Kötü':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }

  String _getPeriodDisplayName(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return 'Günlük';
      case AnalyticsPeriod.weekly:
        return 'Haftalık';
      case AnalyticsPeriod.monthly:
        return 'Aylık';
      case AnalyticsPeriod.yearly:
        return 'Yıllık';
    }
  }
}