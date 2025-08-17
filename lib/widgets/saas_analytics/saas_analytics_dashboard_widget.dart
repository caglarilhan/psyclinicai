import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/saas_billing_models.dart';
import '../../models/organization_models.dart';
import '../../models/internationalization_models.dart';
import '../../utils/ai_logger.dart';

class SAASAnalyticsDashboardWidget extends StatefulWidget {
  const SAASAnalyticsDashboardWidget({super.key});

  @override
  State<SAASAnalyticsDashboardWidget> createState() => _SAASAnalyticsDashboardWidgetState();
}

class _SAASAnalyticsDashboardWidgetState extends State<SAASAnalyticsDashboardWidget>
    with TickerProviderStateMixin {
  final AILogger _logger = AILogger();
  
  late AnimationController _refreshController;
  late AnimationController _chartController;
  
  // Mock data for demonstration
  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: '1',
      name: 'Starter',
      description: 'Küçük klinikler için',
      monthlyPrice: 99.0,
      yearlyPrice: 990.0,
      currency: 'USD',
      tier: PlanTier.starter,
      features: [],
      maxUsers: 5,
      maxPatients: 100,
      maxStorageGB: 10,
      integrations: ['Basic'],
      isActive: true,
      createdAt: DateTime.now(),
    ),
    SubscriptionPlan(
      id: '2',
      name: 'Professional',
      description: 'Orta ölçekli klinikler için',
      monthlyPrice: 299.0,
      yearlyPrice: 2990.0,
      currency: 'USD',
      tier: PlanTier.professional,
      features: [],
      maxUsers: 20,
      maxPatients: 500,
      maxStorageGB: 50,
      integrations: ['Basic', 'Advanced'],
      isActive: true,
      createdAt: DateTime.now(),
    ),
    SubscriptionPlan(
      id: '3',
      name: 'Enterprise',
      description: 'Büyük kurumlar için',
      monthlyPrice: 999.0,
      yearlyPrice: 9990.0,
      currency: 'USD',
      tier: PlanTier.enterprise,
      features: [],
      maxUsers: 100,
      maxPatients: 2000,
      maxStorageGB: 200,
      integrations: ['Basic', 'Advanced', 'Custom'],
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  final Map<String, int> _regionalData = {
    'USA': 45,
    'Germany': 18,
    'UK': 15,
    'France': 12,
    'Canada': 8,
    'Australia': 6,
    'Other': 16,
  };

  final Map<String, double> _monthlyRevenue = {
    'Jan': 12500,
    'Feb': 15800,
    'Mar': 18900,
    'Apr': 22100,
    'May': 25600,
    'Jun': 28900,
    'Jul': 31200,
    'Aug': 29800,
    'Sep': 32400,
    'Oct': 35600,
    'Nov': 38900,
    'Dec': 42500,
  };

  bool _isLoading = false;
  String _selectedTimeRange = '12m';
  String _selectedMetric = 'revenue';

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
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => _isLoading = false);
      _chartController.forward();
    } catch (e) {
      _logger.error('Failed to load SaaS analytics data', context: 'SAASAnalyticsDashboard', error: e);
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
        title: const Text('SaaS Analytics Dashboard'),
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
              const PopupMenuItem(value: '1m', child: Text('Son 1 Ay')),
              const PopupMenuItem(value: '3m', child: Text('Son 3 Ay')),
              const PopupMenuItem(value: '6m', child: Text('Son 6 Ay')),
              const PopupMenuItem(value: '12m', child: Text('Son 12 Ay')),
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
                    _buildRevenueChart(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildRegionalDistribution()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPlanDistribution()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSubscriptionMetrics(),
                    const SizedBox(height: 24),
                    _buildRegionalCompliance(),
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
          'Toplam Gelir',
          '\$${_calculateTotalRevenue().toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricCard(
          'Aktif Abonelikler',
          '${_calculateActiveSubscriptions()}',
          Icons.subscriptions,
          Colors.blue,
        ),
        _buildMetricCard(
          'Ortalama MRR',
          '\$${_calculateAverageMRR().toStringAsFixed(0)}',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildMetricCard(
          'Churn Rate',
          '${_calculateChurnRate().toStringAsFixed(1)}%',
          Icons.trending_down,
          Colors.red,
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

  Widget _buildRevenueChart() {
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
                  'Aylık Gelir Trendi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<String>(
                  value: _selectedMetric,
                  onChanged: (value) {
                    setState(() => _selectedMetric = value!);
                  },
                  items: [
                    DropdownMenuItem(value: 'revenue', child: const Text('Gelir')),
                    DropdownMenuItem(value: 'growth', child: const Text('Büyüme')),
                    DropdownMenuItem(value: 'forecast', child: const Text('Tahmin')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = _monthlyRevenue.keys.toList();
                          if (value.toInt() < months.length) {
                            return Text(months[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${(value / 1000).toStringAsFixed(0)}K');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildRevenueSpots(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildRevenueSpots() {
    final months = _monthlyRevenue.keys.toList();
    return months.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final revenue = _monthlyRevenue[month]!;
      return FlSpot(index.toDouble(), revenue);
    }).toList();
  }

  Widget _buildRegionalDistribution() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bölgesel Dağılım',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildRegionalSections(),
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

  List<PieChartSectionData> _buildRegionalSections() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    final total = _regionalData.values.reduce((a, b) => a + b);
    final entries = _regionalData.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data / total * 100).toStringAsFixed(1);
      
      return PieChartSectionData(
        value: data.toDouble(),
        title: '$percentage%',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPlanDistribution() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Dağılımı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._plans.map((plan) => _buildPlanItem(plan)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanItem(SubscriptionPlan plan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getPlanColor(plan.tier),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(plan.name),
          ),
          Text(
            '${_getPlanPercentage(plan).toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getPlanColor(PlanTier tier) {
    switch (tier) {
      case PlanTier.starter:
        return Colors.blue;
      case PlanTier.professional:
        return Colors.green;
      case PlanTier.enterprise:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  double _getPlanPercentage(SubscriptionPlan plan) {
    // Mock percentage calculation
    switch (plan.tier) {
      case PlanTier.starter:
        return 45.0;
      case PlanTier.professional:
        return 35.0;
      case PlanTier.enterprise:
        return 20.0;
      default:
        return 0.0;
    }
  }

  Widget _buildSubscriptionMetrics() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abonelik Metrikleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('Yeni Abonelikler', '24', Icons.add_circle, Colors.green),
                ),
                Expanded(
                  child: _buildMetricItem('İptal Edilen', '8', Icons.remove_circle, Colors.red),
                ),
                Expanded(
                  child: _buildMetricItem('Yükseltilen', '12', Icons.trending_up, Colors.blue),
                ),
                Expanded(
                  child: _buildMetricItem('Düşürülen', '3', Icons.trending_down, Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Column(
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
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegionalCompliance() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bölgesel Uyumluluk',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Bölge')),
                DataColumn(label: Text('HIPAA')),
                DataColumn(label: Text('GDPR')),
                DataColumn(label: Text('Diğer')),
                DataColumn(label: Text('Durum')),
              ],
              rows: [
                _buildComplianceRow('USA', '✅', 'N/A', 'SOC 2', 'Uyumlu'),
                _buildComplianceRow('EU', 'N/A', '✅', 'ISO 27001', 'Uyumlu'),
                _buildComplianceRow('UK', 'N/A', '✅', 'NHS', 'Uyumlu'),
                _buildComplianceRow('Canada', 'N/A', 'N/A', 'PIPEDA', 'Uyumlu'),
                _buildComplianceRow('Australia', 'N/A', 'N/A', 'Privacy Act', 'Uyumlu'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildComplianceRow(String region, String hipaa, String gdpr, String other, String status) {
    return DataRow(
      cells: [
        DataCell(Text(region)),
        DataCell(Text(hipaa)),
        DataCell(Text(gdpr)),
        DataCell(Text(other)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Uyumlu' ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for calculations
  double _calculateTotalRevenue() {
    return _monthlyRevenue.values.reduce((a, b) => a + b);
  }

  int _calculateActiveSubscriptions() {
    return 156; // Mock data
  }

  double _calculateAverageMRR() {
    return _monthlyRevenue.values.reduce((a, b) => a + b) / 12;
  }

  double _calculateChurnRate() {
    return 2.3; // Mock data - 2.3% monthly churn
  }
}
