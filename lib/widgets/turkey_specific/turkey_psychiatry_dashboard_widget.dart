import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/turkey_health_system_models.dart';
import '../../models/turkey_medication_models.dart';
import '../../models/turkey_diagnosis_models.dart';
import '../../utils/ai_logger.dart';

class TurkeyPsychiatryDashboardWidget extends StatefulWidget {
  const TurkeyPsychiatryDashboardWidget({super.key});

  @override
  State<TurkeyPsychiatryDashboardWidget> createState() =>
      _TurkeyPsychiatryDashboardWidgetState();
}

class _TurkeyPsychiatryDashboardWidgetState
    extends State<TurkeyPsychiatryDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AILogger _logger = AILogger();

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mhrsData = [
    {'date': '2024-01-01', 'appointments': 15, 'completed': 12, 'cancelled': 2, 'noShow': 1},
    {'date': '2024-01-02', 'appointments': 18, 'completed': 16, 'cancelled': 1, 'noShow': 1},
    {'date': '2024-01-03', 'appointments': 20, 'completed': 18, 'cancelled': 1, 'noShow': 1},
    {'date': '2024-01-04', 'appointments': 16, 'completed': 14, 'cancelled': 1, 'noShow': 1},
    {'date': '2024-01-05', 'appointments': 22, 'completed': 20, 'cancelled': 1, 'noShow': 1},
  ];

  final List<Map<String, dynamic>> _sgkData = [
    {'month': 'Ocak', 'reimbursements': 12500, 'pending': 2500, 'rejected': 500},
    {'month': 'Şubat', 'reimbursements': 13200, 'pending': 2800, 'rejected': 400},
    {'month': 'Mart', 'reimbursements': 14100, 'pending': 3100, 'rejected': 600},
    {'month': 'Nisan', 'reimbursements': 13800, 'pending': 2900, 'rejected': 450},
    {'month': 'Mayıs', 'reimbursements': 14500, 'pending': 3200, 'rejected': 550},
  ];

  final List<Map<String, dynamic>> _diagnosisData = [
    {'diagnosis': 'Depresyon', 'count': 45, 'percentage': 25.0},
    {'diagnosis': 'Anksiyete', 'count': 38, 'percentage': 21.1},
    {'diagnosis': 'Bipolar Bozukluk', 'count': 22, 'percentage': 12.2},
    {'diagnosis': 'Şizofreni', 'count': 18, 'percentage': 10.0},
    {'diagnosis': 'OKB', 'count': 15, 'percentage': 8.3},
    {'diagnosis': 'PTSD', 'count': 12, 'percentage': 6.7},
    {'diagnosis': 'Diğer', 'count': 30, 'percentage': 16.7},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _logger.info('Turkey Psychiatry Dashboard initialized', context: 'TurkeyPsychiatryDashboardWidget');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🇹🇷 Türkiye Psikiyatri Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.medical_services), text: 'MHRS'),
            Tab(icon: Icon(Icons.account_balance), text: 'SGK'),
            Tab(icon: Icon(Icons.psychology), text: 'Tanılar'),
            Tab(icon: Icon(Icons.analytics), text: 'Analitik'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMHRSTab(),
          _buildSGKTab(),
          _buildDiagnosisTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildMHRSTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('MHRS Entegrasyon Durumu', Icons.medical_services),
          const SizedBox(height: 16),
          _buildMHRSSummaryCards(),
          const SizedBox(height: 24),
          _buildSectionHeader('Randevu İstatistikleri', Icons.calendar_today),
          const SizedBox(height: 16),
          _buildAppointmentChart(),
          const SizedBox(height: 24),
          _buildSectionHeader('Son Senkronizasyon', Icons.sync),
          const SizedBox(height: 16),
          _buildSyncStatusCard(),
        ],
      ),
    );
  }

  Widget _buildSGKTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('SGK Entegrasyon Durumu', Icons.account_balance),
          const SizedBox(height: 16),
          _buildSGKSummaryCards(),
          const SizedBox(height: 24),
          _buildSectionHeader('Geri Ödeme Analizi', Icons.payments),
          const SizedBox(height: 16),
          _buildReimbursementChart(),
          const SizedBox(height: 24),
          _buildSectionHeader('Sigorta Kapsamı', Icons.security),
          const SizedBox(height: 16),
          _buildInsuranceCoverageCard(),
        ],
      ),
    );
  }

  Widget _buildDiagnosisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Tanı Dağılımı', Icons.psychology),
          const SizedBox(height: 16),
          _buildDiagnosisPieChart(),
          const SizedBox(height: 24),
          _buildSectionHeader('ICD-10 Kodları', Icons.code),
          const SizedBox(height: 16),
          _buildICD10List(),
          const SizedBox(height: 24),
          _buildSectionHeader('Raporlama Gereksinimleri', Icons.assignment),
          const SizedBox(height: 16),
          _buildReportingRequirementsCard(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Performans Metrikleri', Icons.analytics),
          const SizedBox(height: 16),
          _buildPerformanceMetrics(),
          const SizedBox(height: 24),
          _buildSectionHeader('Kültürel Analiz', Icons.language),
          const SizedBox(height: 16),
          _buildCulturalAnalysisCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Uyumluluk Durumu', Icons.check_circle),
          const SizedBox(height: 16),
          _buildComplianceStatusCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red[700], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMHRSSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Toplam Randevu',
          '180',
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Tamamlanan',
          '160',
          Icons.check_circle,
          Colors.green,
        ),
        _buildSummaryCard(
          'İptal Edilen',
          '8',
          Icons.cancel,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Gelmeyen',
          '12',
          Icons.no_accounts,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSGKSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Toplam Geri Ödeme',
          '68.1K ₺',
          Icons.payments,
          Colors.green,
        ),
        _buildSummaryCard(
          'Bekleyen',
          '14.5K ₺',
          Icons.pending,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Reddedilen',
          '2.5K ₺',
          Icons.block,
          Colors.red,
        ),
        _buildSummaryCard(
          'Başarı Oranı',
          '%96.5',
          Icons.trending_up,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Haftalık Randevu Trendi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _mhrsData.length) {
                            return Text(_mhrsData[value.toInt()]['date'].toString().substring(5));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _mhrsData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['appointments'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: _mhrsData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['completed'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
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

  Widget _buildReimbursementChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aylık Geri Ödeme Trendi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 16000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value / 1000).toInt()}K');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _sgkData.length) {
                            return Text(_sgkData[value.toInt()]['month']);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: _sgkData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['reimbursements'].toDouble(),
                          color: Colors.green,
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: entry.value['pending'].toDouble(),
                          color: Colors.orange,
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

  Widget _buildDiagnosisPieChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanı Dağılımı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: _diagnosisData.map((data) {
                    return PieChartSectionData(
                      value: data['percentage'].toDouble(),
                      title: '${data['percentage'].toStringAsFixed(1)}%',
                      radius: 80,
                      color: _getDiagnosisColor(data['diagnosis']),
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDiagnosisLegend(),
          ],
        ),
      ),
    );
  }

  Color _getDiagnosisColor(String diagnosis) {
    final colors = {
      'Depresyon': Colors.blue,
      'Anksiyete': Colors.green,
      'Bipolar Bozukluk': Colors.purple,
      'Şizofreni': Colors.red,
      'OKB': Colors.orange,
      'PTSD': Colors.teal,
      'Diğer': Colors.grey,
    };
    return colors[diagnosis] ?? Colors.grey;
  }

  Widget _buildDiagnosisLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _diagnosisData.map((data) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getDiagnosisColor(data['diagnosis']),
            ),
            const SizedBox(width: 8),
            Text(
              '${data['diagnosis']} (${data['count']})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSyncStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MHRS Senkronizasyon Durumu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Son Senkronizasyon', '2 saat önce', Icons.sync, Colors.green),
            _buildStatusRow('Senkronizasyon Durumu', 'Aktif', Icons.check_circle, Colors.green),
            _buildStatusRow('Hata Sayısı', '0', Icons.error, Colors.green),
            _buildStatusRow('Senkronizasyon Sıklığı', '15 dakika', Icons.timer, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCoverageCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SGK Sigorta Kapsamı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Aktif Sigortalı', '1,250', Icons.people, Colors.green),
            _buildStatusRow('Kapsam Dışı', '45', Icons.person_off, Colors.red),
            _buildStatusRow('Bekleyen Başvuru', '23', Icons.pending, Colors.orange),
            _buildStatusRow('Ortalama Kapsam', '%98.5', Icons.assessment, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildICD10List() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yaygın ICD-10 Kodları',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildICD10Item('F32.1', 'Orta Depresif Epizod', 'Depresyon'),
            _buildICD10Item('F41.1', 'Anksiyete Bozukluğu', 'Anksiyete'),
            _buildICD10Item('F31.1', 'Bipolar Bozukluk', 'Bipolar'),
            _buildICD10Item('F20.0', 'Paranoid Şizofreni', 'Şizofreni'),
            _buildICD10Item('F42.8', 'Obsesif-Kompulsif Bozukluk', 'OKB'),
          ],
        ),
      ),
    );
  }

  Widget _buildICD10Item(String code, String name, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportingRequirementsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Raporlama Gereksinimleri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRequirementItem('Bulaşıcı Hastalıklar', '24 saat içinde', Colors.red),
            _buildRequirementItem('Kronik Hastalıklar', 'Haftalık', Colors.orange),
            _buildRequirementItem('Ölüm Raporları', '48 saat içinde', Colors.red),
            _buildRequirementItem('Doğum Raporları', '72 saat içinde', Colors.blue),
            _buildRequirementItem('Aşı Raporları', 'Haftalık', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, String timeline, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(requirement)),
          Text(
            timeline,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performans Metrikleri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Hasta Memnuniyeti', '4.8/5.0', Colors.green),
            _buildMetricRow('Randevu Tamamlanma', '%89', Colors.blue),
            _buildMetricRow('Ortalama Bekleme Süresi', '15 dakika', Colors.orange),
            _buildMetricRow('Doktor Verimliliği', '%92', Colors.green),
            _buildMetricRow('Hasta Takip Oranı', '%78', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String metric, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(metric)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCulturalAnalysisCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kültürel Analiz',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCulturalItem('Aile Katılımı', 'Yüksek', Colors.green),
            _buildCulturalItem('Sosyal Damga', 'Orta', Colors.orange),
            _buildCulturalItem('Dini Faktörler', 'Düşük', Colors.blue),
            _buildCulturalItem('Geleneksel Tedavi', 'Orta', Colors.orange),
            _buildCulturalItem('Topluluk Desteği', 'Yüksek', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildCulturalItem(String factor, String level, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(factor)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uyumluluk Durumu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComplianceItem('Sağlık Bakanlığı', 'Uyumlu', Colors.green),
            _buildComplianceItem('SGK', 'Uyumlu', Colors.green),
            _buildComplianceItem('Tıbbi Deontoloji', 'Uyumlu', Colors.green),
            _buildComplianceItem('Veri Güvenliği', 'Uyumlu', Colors.green),
            _buildComplianceItem('Hasta Hakları', 'Uyumlu', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceItem(String regulation, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(regulation)),
          Row(
            children: [
              Icon(Icons.check_circle, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
