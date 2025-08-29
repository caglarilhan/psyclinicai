import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/analytics_models.dart';
import '../../services/analytics_service.dart';
import '../../widgets/analytics/chart_widgets.dart';
import '../../widgets/analytics/metric_cards.dart';
import '../../widgets/analytics/trend_analysis_widget.dart';
import '../../services/finance_service.dart';

class AdvancedAnalyticsDashboardScreen extends StatefulWidget {
  const AdvancedAnalyticsDashboardScreen({super.key});

  @override
  State<AdvancedAnalyticsDashboardScreen> createState() => _AdvancedAnalyticsDashboardScreenState();
}

class _AdvancedAnalyticsDashboardScreenState extends State<AdvancedAnalyticsDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  AnalyticsData? _analyticsData;
  String _selectedTimeRange = '30d';
  String _selectedMetric = 'all';
  FinancialMetrics? _financeMetrics;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _analyticsService.getAnalyticsData(_selectedTimeRange);
      // Finance metriklerini de dahil et
      final finance = FinanceService();
      finance.initialize();
      final fm = finance.getMetrics();
      setState(() {
        _analyticsData = data;
        _financeMetrics = fm;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Analitik Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Rapor İndir',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analyticsData == null
              ? const Center(child: Text('Veri bulunamadı'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filtreler ve Kontroller
                      _buildFiltersSection(),
                      
                      const SizedBox(height: 24),
                      
                      // KPI Kartları
                      _buildKPISection(),
                      
                      const SizedBox(height: 24),
                      
                      // Ana Grafikler
                      _buildMainChartsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // AI Trend Analizi
                      _buildTrendAnalysisSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Performans Metrikleri
                      _buildPerformanceMetricsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Detaylı Analizler
                      _buildDetailedAnalyticsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFiltersSection() {
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
          Text(
            'Filtreler ve Kontroller',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeRange,
                  decoration: const InputDecoration(
                    labelText: 'Zaman Aralığı',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '7d', child: Text('Son 7 Gün')),
                    DropdownMenuItem(value: '30d', child: Text('Son 30 Gün')),
                    DropdownMenuItem(value: '90d', child: Text('Son 90 Gün')),
                    DropdownMenuItem(value: '1y', child: Text('Son 1 Yıl')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTimeRange = value);
                      _loadAnalyticsData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMetric,
                  decoration: const InputDecoration(
                    labelText: 'Metrik Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tüm Metrikler')),
                    DropdownMenuItem(value: 'clinical', child: Text('Klinik')),
                    DropdownMenuItem(value: 'financial', child: Text('Finansal')),
                    DropdownMenuItem(value: 'operational', child: Text('Operasyonel')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMetric = value);
                      _loadAnalyticsData();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPISection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ana Performans Göstergeleri (KPI)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            MetricCard(
              title: 'Toplam Seans',
              value: _analyticsData!.totalSessions.toString(),
              change: _analyticsData!.sessionGrowth,
              icon: Icons.psychology,
              color: AppTheme.primaryColor,
            ),
            MetricCard(
              title: 'Aktif Danışan',
              value: _analyticsData!.activeClients.toString(),
              change: _analyticsData!.clientGrowth,
              icon: Icons.people,
              color: AppTheme.successColor,
            ),
            MetricCard(
              title: 'Aylık Gelir',
              value: (_financeMetrics != null)
                  ? '₺${_financeMetrics!.totalIncome.toStringAsFixed(0)}'
                  : '₺${_analyticsData!.monthlyRevenue.toStringAsFixed(0)}K',
              change: _analyticsData!.revenueGrowth,
              icon: Icons.account_balance_wallet,
              color: AppTheme.accentColor,
            ),
            MetricCard(
              title: 'Memnuniyet',
              value: '${_analyticsData!.satisfactionScore.toStringAsFixed(1)}%',
              change: _analyticsData!.satisfactionGrowth,
              icon: Icons.sentiment_satisfied,
              color: AppTheme.infoColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainChartsSection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ana Grafikler ve Trendler',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ChartCard(
                title: 'Seans Trendi',
                subtitle: 'Günlük seans sayıları',
                child: LineChartWidget(
                  data: _analyticsData!.sessionTrends,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartCard(
                title: 'Gelir Dağılımı',
                subtitle: 'Aylık gelir analizi',
                child: BarChartWidget(
                  data: _analyticsData!.revenueData,
                  color: AppTheme.successColor,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ChartCard(
                title: 'Danışan Dağılımı',
                subtitle: 'Yaş ve cinsiyet analizi',
                child: PieChartWidget(
                  data: _analyticsData!.clientDistribution,
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor, AppTheme.accentColor],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartCard(
                title: 'Performans Karşılaştırması',
                subtitle: 'Terapist bazlı analiz',
                child: RadarChartWidget(
                  data: _analyticsData!.performanceComparison,
                  labels: ['Empati', 'Teknik', 'İletişim', 'Sonuç', 'Memnuniyet'],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendAnalysisSection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
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
                Icons.auto_awesome,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Destekli Trend Analizi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TrendAnalysisWidget(
            trends: _analyticsData!.aiTrends,
            insights: _analyticsData!.aiInsights,
            recommendations: _analyticsData!.aiRecommendations,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsSection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performans Metrikleri',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: PerformanceMetricsCard(
                title: 'Klinik Performans',
                metrics: _analyticsData!.clinicalMetrics,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PerformanceMetricsCard(
                title: 'Finansal Performans',
                metrics: _analyticsData!.financialMetrics,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: PerformanceMetricsCard(
                title: 'Operasyonel Performans',
                metrics: _analyticsData!.operationalMetrics,
                color: AppTheme.infoColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PerformanceMetricsCard(
                title: 'Kalite Metrikleri',
                metrics: _analyticsData!.qualityMetrics,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedAnalyticsSection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı Analizler',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: DetailedAnalyticsCard(
                title: 'Danışan Segmentasyonu',
                data: _analyticsData!.clientSegmentation,
                chartType: 'pie',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DetailedAnalyticsCard(
                title: 'Zaman Analizi',
                data: _analyticsData!.timeAnalysis,
                chartType: 'heatmap',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: DetailedAnalyticsCard(
                title: 'Risk Analizi',
                data: _analyticsData!.riskAnalysis,
                chartType: 'gauge',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DetailedAnalyticsCard(
                title: 'Tahmin Modelleri',
                data: _analyticsData!.predictionModels,
                chartType: 'forecast',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _exportReport() {
    // TODO: PDF/Excel rapor export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor export özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
