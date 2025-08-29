import 'package:flutter/material.dart';
import '../../models/crm_models.dart';
import '../../utils/theme.dart';

class AnalyticsDashboardWidget extends StatelessWidget {
  final CRMAnalytics analytics;

  const AnalyticsDashboardWidget({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Ana Metrikler
            _buildMainMetrics(),
            
            const SizedBox(height: 24),
            
            // Grafikler
            _buildCharts(),
            
            const SizedBox(height: 24),
            
            // Detaylı Analizler
            _buildDetailedAnalytics(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: AppTheme.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRM Analitik Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Müşteri ve satış performansınızı analiz edin',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetrics() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard(
          'Toplam Müşteri',
          '${analytics.totalCustomers}',
          Icons.people,
          AppTheme.primaryColor,
          'Aktif: ${analytics.activeCustomers}',
        ),
        _buildMetricCard(
          'Aylık Gelir',
          '₺${analytics.monthlyRevenue.toStringAsFixed(0)}',
          Icons.attach_money,
          AppTheme.successColor,
          'Yıllık: ₺${analytics.yearlyRevenue.toStringAsFixed(0)}',
        ),
        _buildMetricCard(
          'Aktif Fırsatlar',
          '${analytics.activeOpportunities}',
          Icons.trending_up,
          AppTheme.accentColor,
          'Toplam: ${analytics.totalOpportunities}',
        ),
        _buildMetricCard(
          'Ortalama Değer',
          '₺${analytics.averageDealValue.toStringAsFixed(0)}',
          Icons.assessment,
          AppTheme.infoColor,
          'Dönüşüm: %${(analytics.conversionRate * 100).toInt()}',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return Row(
      children: [
        // Gelir Trendi
        Expanded(
          child: _buildChartCard(
            'Gelir Trendi (12 Ay)',
            Icons.trending_up,
            AppTheme.successColor,
            _buildRevenueChart(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Müşteri Dağılımı
        Expanded(
          child: _buildChartCard(
            'Müşteri Tipi Dağılımı',
            Icons.pie_chart,
            AppTheme.infoColor,
            _buildCustomerTypeChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(
    String title,
    IconData icon,
    Color color,
    Widget chart,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final months = analytics.revenueByMonth.keys.toList()..sort();
    final revenues = months.map((month) => analytics.revenueByMonth[month] ?? 0.0).toList();
    
    return Column(
      children: [
        // Basit bar chart
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.asMap().entries.map((entry) {
              final index = entry.key;
              final month = entry.value;
              final revenue = revenues[index];
              final maxRevenue = revenues.reduce((a, b) => a > b ? a : b);
              final height = maxRevenue > 0 ? (revenue / maxRevenue) : 0.0;
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          height: 100 * height,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        month.substring(5), // Sadece ay
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '₺${revenue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerTypeChart() {
    final types = analytics.customersByType.keys.toList();
    final counts = types.map((type) => analytics.customersByType[type] ?? 0).toList();
    final total = counts.fold(0, (sum, count) => sum + count);
    
    return Column(
      children: [
        // Basit pie chart
        Expanded(
          child: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: PieChartPainter(
                  counts: counts,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.accentColor,
                    AppTheme.successColor,
                    AppTheme.infoColor,
                    AppTheme.warningColor,
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Legend
        ...types.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final count = counts[index];
          final percentage = total > 0 ? (count / total * 100) : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: [
                      AppTheme.primaryColor,
                      AppTheme.accentColor,
                      AppTheme.successColor,
                      AppTheme.infoColor,
                      AppTheme.warningColor,
                    ][index % 5],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  '${count} (%${percentage.toStringAsFixed(1)})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDetailedAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı Analizler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Pipeline Analizi
            Expanded(
              child: _buildAnalysisCard(
                'Pipeline Analizi',
                Icons.analytics,
                AppTheme.primaryColor,
                _buildPipelineAnalysis(),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Performans Metrikleri
            Expanded(
              child: _buildAnalysisCard(
                'Performans Metrikleri',
                Icons.speed,
                AppTheme.accentColor,
                _buildPerformanceMetrics(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(
    String title,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildPipelineAnalysis() {
    final stages = analytics.pipelineByStage.keys.toList();
    final values = stages.map((stage) => analytics.pipelineByStage[stage] ?? 0.0).toList();
    final totalValue = values.fold(0.0, (sum, value) => sum + value);
    
    return Column(
      children: [
        ...stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final value = values[index];
          final percentage = totalValue > 0 ? (value / totalValue * 100) : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getStageText(stage),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '₺${value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStageColor(stage),
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: 2),
                Text(
                  '%${percentage.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      children: [
        _buildPerformanceRow(
          'Müşteri Dönüşüm Oranı',
          '${(analytics.conversionRate * 100).toStringAsFixed(1)}%',
          AppTheme.successColor,
        ),
        _buildPerformanceRow(
          'Ortalama Müşteri Değeri',
          '₺${analytics.averageDealValue.toStringAsFixed(0)}',
          AppTheme.infoColor,
        ),
        _buildPerformanceRow(
          'Aktif Müşteri Oranı',
          '${analytics.totalCustomers > 0 ? (analytics.activeCustomers / analytics.totalCustomers * 100).toStringAsFixed(1) : 0}%',
          AppTheme.primaryColor,
        ),
        _buildPerformanceRow(
          'Yeni Müşteri Oranı',
          '${analytics.totalCustomers > 0 ? (analytics.newCustomersThisMonth / analytics.totalCustomers * 100).toStringAsFixed(1) : 0}%',
          AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStageText(String stage) {
    switch (stage) {
      case 'lead':
        return 'Lead';
      case 'qualified':
        return 'Qualified';
      case 'proposal':
        return 'Proposal';
      case 'negotiation':
        return 'Negotiation';
      case 'closed':
        return 'Closed';
      case 'lost':
        return 'Lost';
      default:
        return stage;
    }
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'lead':
        return Colors.grey;
      case 'qualified':
        return Colors.blue;
      case 'proposal':
        return Colors.orange;
      case 'negotiation':
        return Colors.purple;
      case 'closed':
        return Colors.green;
      case 'lost':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }
}

class PieChartPainter extends CustomPainter {
  final List<int> counts;
  final List<Color> colors;

  PieChartPainter({
    required this.counts,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final total = counts.fold(0, (sum, count) => sum + count);
    if (total == 0) return;
    
    double startAngle = 0;
    
    for (int i = 0; i < counts.length; i++) {
      final sweepAngle = (counts[i] / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
