import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/diagnosis_service.dart';
import '../../models/diagnosis_models.dart';

class DiagnosisDashboardWidget extends StatefulWidget {
  const DiagnosisDashboardWidget({super.key});

  @override
  State<DiagnosisDashboardWidget> createState() => _DiagnosisDashboardWidgetState();
}

class _DiagnosisDashboardWidgetState extends State<DiagnosisDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _metricController;
  late Animation<double> _metricAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _metricController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _metricAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _metricController, curve: Curves.easeOut),
    );
    _metricController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiagnosisService>(
      builder: (context, diagnosisService, child) {
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
                    const Text(
                      '🧠 Teşhis & Değerlendirme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {});
                        _metricController.reset();
                        _metricController.forward();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Genel Bakış'),
                    Tab(text: 'DSM-5/ICD-11'),
                    Tab(text: 'AI Teşhis'),
                    Tab(text: 'Değerlendirmeler'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(diagnosisService),
                      _buildDiagnosisSystemsTab(diagnosisService),
                      _buildAIDiagnosisTab(diagnosisService),
                      _buildAssessmentsTab(diagnosisService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(DiagnosisService diagnosisService) {
    final totalDisorders = diagnosisService.disorders.length;
    final totalCategories = diagnosisService.categories.length;
    final totalAssessments = diagnosisService.assessments.length;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Toplam Bozukluk',
                  totalDisorders.toString(),
                  Icons.psychology,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Kategoriler',
                  totalCategories.toString(),
                  Icons.category,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Değerlendirmeler',
                  totalAssessments.toString(),
                  Icons.assessment,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'AI Başarı',
                  '%92',
                  Icons.auto_awesome,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSystemsTab(DiagnosisService diagnosisService) {
    final systems = diagnosisService.diagnosisSystems;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teşhis Sistemleri (${systems.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: systems.length,
            itemBuilder: (context, index) {
              final system = systems[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    system.isActive ? Icons.check_circle : Icons.cancel,
                    color: system.isActive ? Colors.green : Colors.red,
                  ),
                  title: Text(system.name),
                  subtitle: Text('${system.version} - ${system.name}'),
                  trailing: Text(system.isActive ? 'Aktif' : 'Pasif'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIDiagnosisTab(DiagnosisService diagnosisService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Teşhis Sistemi',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model Durumu: Aktif'),
                const SizedBox(height: 8),
                Text('Son Güncelleme: ${DateTime.now().toString().split(' ')[0]}'),
                const SizedBox(height: 8),
                Text('Başarı Oranı: %92'),
                const SizedBox(height: 8),
                Text('Ortalama Yanıt Süresi: 2.3s'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // AI teşhis testi başlat
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('AI Teşhis Testi Başlat'),
        ),
      ],
    );
  }

  Widget _buildAssessmentsTab(DiagnosisService diagnosisService) {
    final assessments = diagnosisService.assessments;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Değerlendirmeler (${assessments.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: assessments.isEmpty
              ? const Center(
                  child: Text('Henüz değerlendirme bulunmuyor'),
                )
              : ListView.builder(
                  itemCount: assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = assessments[index];
                    return Card(
                      child: ListTile(
                        title: Text('Hasta: ${assessment.patientId}'),
                        subtitle: Text('Tarih: ${assessment.assessmentDate.toString().split(' ')[0]}'),
                        trailing: Icon(
                          Icons.assessment,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _metricAnimation,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı İşlemler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Yeni değerlendirme
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Değerlendirme'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // AI teşhis
                    },
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI Teşhis'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
