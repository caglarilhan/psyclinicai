import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/analytics_models.dart';
import '../../services/analytics_service.dart';
import '../../widgets/analytics/chart_widgets.dart';
import '../../widgets/analytics/metric_cards.dart';
import '../../widgets/analytics/trend_analysis_widget.dart';
import '../../services/finance_service.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class AdvancedAnalyticsDashboardScreen extends StatefulWidget {
  const AdvancedAnalyticsDashboardScreen({super.key});

  @override
  State<AdvancedAnalyticsDashboardScreen> createState() => _AdvancedAnalyticsDashboardScreenState();
}

class _AdvancedAnalyticsDashboardScreenState extends State<AdvancedAnalyticsDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  bool _isLoading = true;
  AnalyticsData? _analyticsData;
  String _selectedTimeRange = '30d';
  String _selectedMetric = 'all';
  FinancialMetrics? _financeMetrics;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
    _setupKeyboardShortcuts();
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
  void dispose() {
    _removeKeyboardShortcuts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return DesktopLayout(
      title: 'Gelişmiş Analitik Dashboard',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yenile',
          onPressed: _loadAnalyticsData,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Rapor İndir',
          onPressed: _exportReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'AI Analiz',
          onPressed: _runAIAnalysis,
          icon: Icons.psychology,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showAnalyticsSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Genel Bakış',
          icon: Icons.dashboard,
          onTap: () => _scrollToSection('overview'),
        ),
        DesktopSidebarItem(
          title: 'KPI Metrikleri',
          icon: Icons.analytics,
          onTap: () => _scrollToSection('kpi'),
        ),
        DesktopSidebarItem(
          title: 'Grafikler',
          icon: Icons.show_chart,
          onTap: () => _scrollToSection('charts'),
        ),
        DesktopSidebarItem(
          title: 'AI Trend Analizi',
          icon: Icons.trending_up,
          onTap: () => _scrollToSection('trends'),
        ),
        DesktopSidebarItem(
          title: 'Finansal Analiz',
          icon: Icons.account_balance_wallet,
          onTap: () => _scrollToSection('finance'),
        ),
        DesktopSidebarItem(
          title: 'Raporlar',
          icon: Icons.assessment,
          onTap: () => _scrollToSection('reports'),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_analyticsData == null) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtreler ve Kontroller
          _buildDesktopFiltersSection(),
          
          const SizedBox(height: 32),
          
          // KPI Kartları
          _buildDesktopKPISection(),
          
          const SizedBox(height: 32),
          
          // Ana Grafikler
          _buildDesktopMainChartsSection(),
          
          const SizedBox(height: 32),
          
          // AI Trend Analizi
          _buildDesktopTrendAnalysisSection(),
          
          const SizedBox(height: 32),
          
          // Finansal Analiz
          _buildDesktopFinancialAnalysisSection(),
          
          const SizedBox(height: 32),
          
          // Detaylı Raporlar
          _buildDesktopReportsSection(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
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

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _loadAnalyticsData,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _exportReport,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _runAIAnalysis,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showAnalyticsSettings,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü bölüm metodları
  Widget _buildDesktopFiltersSection() {
    return DesktopTheme.desktopCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtreler ve Kontroller',
              style: DesktopTheme.desktopSectionTitleStyle,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DesktopTheme.desktopInput(
                    label: 'Zaman Aralığı',
                    controller: TextEditingController(text: _selectedTimeRange),
                    hintText: '30d, 7d, 1m, 3m',
                    onChanged: (value) {
                      setState(() {
                        _selectedTimeRange = value;
                      });
                      _loadAnalyticsData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DesktopTheme.desktopInput(
                    label: 'Metrik',
                    controller: TextEditingController(text: _selectedMetric),
                    hintText: 'all, clinical, financial',
                    onChanged: (value) {
                      setState(() {
                        _selectedMetric = value;
                      });
                      _loadAnalyticsData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DesktopTheme.desktopButton(
                  text: 'Uygula',
                  onPressed: _loadAnalyticsData,
                  icon: Icons.filter_list,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopKPISection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KPI Metrikleri',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopGrid(
          children: [
            _buildDesktopKPICard(
              'Toplam Danışan',
              _analyticsData!.totalClients.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildDesktopKPICard(
              'Aktif Seanslar',
              _analyticsData!.activeSessions.toString(),
              Icons.medical_services,
              Colors.green,
            ),
            _buildDesktopKPICard(
              'Gelir',
              '${_analyticsData!.totalRevenue.toStringAsFixed(2)} ₺',
              Icons.account_balance_wallet,
              Colors.orange,
            ),
            _buildDesktopKPICard(
              'Memnuniyet',
              '${_analyticsData!.satisfactionScore.toStringAsFixed(1)}%',
              Icons.star,
              Colors.purple,
            ),
          ],
          context: context,
        ),
      ],
    );
  }

  Widget _buildDesktopMainChartsSection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ana Grafikler',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DesktopTheme.desktopCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danışan Trendi',
                        style: DesktopTheme.desktopTitleStyle,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: ClientTrendChart(data: _analyticsData!.clientTrends),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: DesktopTheme.desktopCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gelir Analizi',
                        style: DesktopTheme.desktopTitleStyle,
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: RevenueChart(data: _analyticsData!.revenueData),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopTrendAnalysisSection() {
    if (_analyticsData == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Destekli Trend Analizi',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopTheme.desktopCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: TrendAnalysisWidget(
              trends: _analyticsData!.aiTrends,
              insights: _analyticsData!.aiInsights,
              recommendations: _analyticsData!.aiRecommendations,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFinancialAnalysisSection() {
    if (_financeMetrics == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Finansal Analiz',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopGrid(
          children: [
            _buildDesktopKPICard(
              'Toplam Gelir',
              '${_financeMetrics!.totalIncome.toStringAsFixed(2)} ₺',
              Icons.trending_up,
              Colors.green,
            ),
            _buildDesktopKPICard(
              'Toplam Gider',
              '${_financeMetrics!.totalExpenses.toStringAsFixed(2)} ₺',
              Icons.trending_down,
              Colors.red,
            ),
            _buildDesktopKPICard(
              'Net Kar',
              '${_financeMetrics!.netProfit.toStringAsFixed(2)} ₺',
              Icons.account_balance,
              Colors.blue,
            ),
            _buildDesktopKPICard(
              'Kar Marjı',
              '${_financeMetrics!.profitMargin.toStringAsFixed(1)}%',
              Icons.analytics,
              Colors.orange,
            ),
          ],
          context: context,
        ),
      ],
    );
  }

  Widget _buildDesktopReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı Raporlar',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopDataTable(
          headers: const ['Rapor Adı', 'Tarih', 'Durum', 'Aksiyon'],
          rows: [
            ['Aylık Performans Raporu', '2024-01-15', 'Hazır', 'İndir'],
            ['Finansal Analiz Raporu', '2024-01-10', 'Hazır', 'İndir'],
            ['Danışan Memnuniyet Raporu', '2024-01-05', 'Hazır', 'İndir'],
            ['AI Trend Analiz Raporu', '2024-01-01', 'Hazır', 'İndir'],
          ],
          onRowTap: (index) {
            // TODO: Rapor indirme
          },
        ),
      ],
    );
  }

  Widget _buildDesktopKPICard(String title, String value, IconData icon, Color color) {
    return DesktopGridCard(
      title: title,
      subtitle: value,
      icon: icon,
      color: color,
      onTap: () {
        // TODO: Detay görüntüleme
      },
    );
  }

  void _scrollToSection(String section) {
    // TODO: Bölüme kaydırma
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$section bölümüne kaydırılıyor...')),
    );
  }

  void _runAIAnalysis() {
    // TODO: AI analiz çalıştırma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI analiz çalıştırılıyor...')),
    );
  }

  void _showAnalyticsSettings() {
    // TODO: Analitik ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analitik ayarları açılıyor...')),
    );
  }
}
