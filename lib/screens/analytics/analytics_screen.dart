import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Son 30 Gün';
  
  final List<String> _periods = ['Son 7 Gün', 'Son 30 Gün', 'Son 3 Ay', 'Son 1 Yıl'];
  
  // Demo veriler
  final List<Map<String, dynamic>> _patientStats = [
    {'month': 'Oca', 'patients': 45, 'sessions': 120},
    {'month': 'Şub', 'patients': 52, 'sessions': 135},
    {'month': 'Mar', 'patients': 48, 'sessions': 128},
    {'month': 'Nis', 'patients': 61, 'sessions': 155},
    {'month': 'May', 'patients': 55, 'sessions': 142},
    {'month': 'Haz', 'patients': 58, 'sessions': 148},
  ];
  
  final List<Map<String, dynamic>> _revenueData = [
    {'month': 'Oca', 'revenue': 45000},
    {'month': 'Şub', 'revenue': 52000},
    {'month': 'Mar', 'revenue': 48000},
    {'month': 'Nis', 'revenue': 61000},
    {'month': 'May', 'revenue': 55000},
    {'month': 'Haz', 'revenue': 58000},
  ];
  
  final List<Map<String, dynamic>> _diagnosisStats = [
    {'diagnosis': 'Depresyon', 'count': 35, 'percentage': 35},
    {'diagnosis': 'Anksiyete', 'count': 28, 'percentage': 28},
    {'diagnosis': 'PTSD', 'count': 15, 'percentage': 15},
    {'diagnosis': 'Bipolar', 'count': 12, 'percentage': 12},
    {'diagnosis': 'Diğer', 'count': 10, 'percentage': 10},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitik ve Raporlama'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Text(period),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Genel'),
            Tab(icon: Icon(Icons.people), text: 'Hastalar'),
            Tab(icon: Icon(Icons.attach_money), text: 'Finans'),
            Tab(icon: Icon(Icons.medical_services), text: 'Tanılar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildPatientsTab(),
          _buildFinanceTab(),
          _buildDiagnosisTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Kartları
          _buildKPICards(),
          const SizedBox(height: 24),
          
          // Hasta ve Seans Grafiği
          _buildPatientSessionChart(),
          const SizedBox(height: 24),
          
          // Gelir Grafiği
          _buildRevenueChart(),
          const SizedBox(height: 24),
          
          // Son Aktiviteler
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildKPICard(
          title: 'Toplam Hasta',
          value: '156',
          change: '+12%',
          changeColor: Colors.green,
          icon: Icons.people,
        ),
        _buildKPICard(
          title: 'Aktif Seanslar',
          value: '23',
          change: '+5%',
          changeColor: Colors.green,
          icon: Icons.medical_services,
        ),
        _buildKPICard(
          title: 'Aylık Gelir',
          value: '₺58K',
          change: '+8%',
          changeColor: Colors.green,
          icon: Icons.attach_money,
        ),
        _buildKPICard(
          title: 'Ortalama Seans',
          value: '45 dk',
          change: '-2%',
          changeColor: Colors.red,
          icon: Icons.timer,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String change,
    required Color changeColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSessionChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasta ve Seans Trendi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(_patientStats[value.toInt()]['month']);
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _patientStats.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value['patients'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: _patientStats.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value['sessions'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegendItem('Hastalar', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('Seanslar', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aylık Gelir Trendi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 70000,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('₺${(value / 1000).toInt()}K');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(_revenueData[value.toInt()]['month']);
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _revenueData.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value['revenue'].toDouble(),
                          color: Colors.blue,
                          width: 20,
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
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Son Aktiviteler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text('Yeni hasta kaydı - ${index + 1}'),
                subtitle: Text('${DateTime.now().subtract(Duration(hours: index + 1)).toString().substring(11, 16)}'),
                trailing: Text(
                  '${index + 1}h',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPatientStats(),
          const SizedBox(height: 24),
          _buildPatientAgeDistribution(),
          const SizedBox(height: 24),
          _buildPatientGenderDistribution(),
        ],
      ),
    );
  }

  Widget _buildPatientStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasta İstatistikleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Toplam Hasta', '156', Icons.people),
                ),
                Expanded(
                  child: _buildStatItem('Yeni Hasta', '23', Icons.person_add),
                ),
                Expanded(
                  child: _buildStatItem('Aktif Hasta', '89', Icons.check_circle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPatientAgeDistribution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yaş Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 30,
                      title: '18-25',
                      color: Colors.blue,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 40,
                      title: '26-35',
                      color: Colors.green,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: '36-45',
                      color: Colors.orange,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 10,
                      title: '46+',
                      color: Colors.red,
                      radius: 80,
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

  Widget _buildPatientGenderDistribution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cinsiyet Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderStat('Kadın', '58%', Colors.pink),
                ),
                Expanded(
                  child: _buildGenderStat('Erkek', '42%', Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderStat(String gender, String percentage, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              percentage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(gender),
      ],
    );
  }

  Widget _buildFinanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRevenueStats(),
          const SizedBox(height: 24),
          _buildExpenseChart(),
          const SizedBox(height: 24),
          _buildPaymentMethods(),
        ],
      ),
    );
  }

  Widget _buildRevenueStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gelir İstatistikleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceStat('Aylık Gelir', '₺58K', Icons.attach_money),
                ),
                Expanded(
                  child: _buildFinanceStat('Yıllık Gelir', '₺696K', Icons.trending_up),
                ),
                Expanded(
                  child: _buildFinanceStat('Ortalama', '₺4.8K', Icons.analytics),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExpenseChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gider Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: 'Personel',
                      color: Colors.blue,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 25,
                      title: 'Kira',
                      color: Colors.green,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: 'Ekipman',
                      color: Colors.orange,
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 15,
                      title: 'Diğer',
                      color: Colors.red,
                      radius: 80,
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

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ödeme Yöntemleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['Nakit', 'Kredi Kartı', 'Banka Havalesi', 'Sigorta'].map((method) {
              return ListTile(
                leading: const Icon(Icons.payment),
                title: Text(method),
                trailing: Text('${(20 + (method.hashCode % 30)).toString()}%'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDiagnosisStats(),
          const SizedBox(height: 24),
          _buildDiagnosisChart(),
          const SizedBox(height: 24),
          _buildTreatmentOutcomes(),
        ],
      ),
    );
  }

  Widget _buildDiagnosisStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanı İstatistikleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDiagnosisStat('Toplam Tanı', '100', Icons.medical_services),
                ),
                Expanded(
                  child: _buildDiagnosisStat('En Yaygın', 'Depresyon', Icons.trending_up),
                ),
                Expanded(
                  child: _buildDiagnosisStat('Ortalama', '4.2', Icons.analytics),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.purple),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDiagnosisChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanı Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 40,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(_diagnosisStats[value.toInt()]['diagnosis']);
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _diagnosisStats.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value['count'].toDouble(),
                          color: Colors.purple,
                          width: 20,
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

  Widget _buildTreatmentOutcomes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tedavi Sonuçları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['Başarılı', 'Devam Ediyor', 'İyileşme', 'Takip'].map((outcome) {
              return ListTile(
                leading: const Icon(Icons.check_circle),
                title: Text(outcome),
                trailing: Text('${(15 + (outcome.hashCode % 25)).toString()}%'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor İhracı'),
        content: const Text('Rapor ihracı özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
