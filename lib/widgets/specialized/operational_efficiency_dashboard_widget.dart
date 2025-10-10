import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/operational_efficiency_models.dart';
import '../../services/operational_efficiency_service.dart';
import '../../utils/theme.dart';

class OperationalEfficiencyDashboardWidget extends StatefulWidget {
  const OperationalEfficiencyDashboardWidget({super.key});

  @override
  State<OperationalEfficiencyDashboardWidget> createState() => _OperationalEfficiencyDashboardWidgetState();
}

class _OperationalEfficiencyDashboardWidgetState extends State<OperationalEfficiencyDashboardWidget> {
  final OperationalEfficiencyService _service = OperationalEfficiencyService();
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  List<AppointmentOptimization> _optimizations = [];
  List<ResourcePlanning> _resourcePlannings = [];
  List<QualityControl> _qualityControls = [];
  List<EfficiencyMetrics> _efficiencyMetrics = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final organizationId = 'org_001'; // Demo organization ID
      
      final statistics = await _service.getOperationalStatistics(organizationId);
      final optimizations = await _service.getAppointmentOptimizations(organizationId);
      final resourcePlannings = await _service.getResourcePlannings(organizationId);
      final qualityControls = await _service.getQualityControls(organizationId);
      final efficiencyMetrics = await _service.getEfficiencyMetrics(organizationId);
      
      setState(() {
        _statistics = statistics;
        _optimizations = optimizations;
        _resourcePlannings = resourcePlannings;
        _qualityControls = qualityControls;
        _efficiencyMetrics = efficiencyMetrics;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatisticsCards(),
          const SizedBox(height: 24),
          _buildOptimizationSection(),
          const SizedBox(height: 24),
          _buildResourcePlanningSection(),
          const SizedBox(height: 24),
          _buildQualityControlSection(),
          const SizedBox(height: 24),
          _buildEfficiencyMetricsSection(),
          const SizedBox(height: 24),
          _buildAIFeaturesSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operasyonel Verimlilik Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Randevu optimizasyonu, kaynak planlama ve kalite kontrol',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Optimizasyonlar',
          '${_statistics['totalOptimizations'] ?? 0}',
          Icons.tune,
          Colors.blue,
        ),
        _buildStatCard(
          'Kaynak Planlamaları',
          '${_statistics['totalResourcePlannings'] ?? 0}',
          Icons.account_tree,
          Colors.green,
        ),
        _buildStatCard(
          'Kalite Kontrolleri',
          '${_statistics['totalQualityControls'] ?? 0}',
          Icons.verified,
          Colors.orange,
        ),
        _buildStatCard(
          'Verimlilik Metrikleri',
          '${_statistics['totalEfficiencyMetrics'] ?? 0}',
          Icons.analytics,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Randevu Optimizasyonları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createOptimization,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Optimizasyon'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_optimizations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz optimizasyon bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _optimizations.length,
                itemBuilder: (context, index) {
                  final optimization = _optimizations[index];
                  return _buildOptimizationCard(optimization);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationCard(AppointmentOptimization optimization) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: const Icon(Icons.tune, color: Colors.blue),
        ),
        title: Text('Optimizasyon - ${DateFormat('dd.MM.yyyy').format(optimization.optimizationDate)}'),
        subtitle: Text('${optimization.improvementPercentage.toStringAsFixed(1)}% iyileştirme'),
        trailing: Text(
          optimization.status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: optimization.status == 'active' ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildResourcePlanningSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kaynak Planlamaları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createResourcePlanning,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Planlama'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_resourcePlannings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz kaynak planlaması bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _resourcePlannings.length,
                itemBuilder: (context, index) {
                  final planning = _resourcePlannings[index];
                  return _buildResourcePlanningCard(planning);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcePlanningCard(ResourcePlanning planning) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          child: const Icon(Icons.account_tree, color: Colors.green),
        ),
        title: Text('Kaynak Planlaması - ${DateFormat('dd.MM.yyyy').format(planning.planningDate)}'),
        subtitle: Text('${planning.resourceAllocations.length} kaynak tahsisi'),
        trailing: Text(
          planning.status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: planning.status == 'active' ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildQualityControlSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kalite Kontrolleri',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createQualityControl,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Kontrol'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_qualityControls.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz kalite kontrolü bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _qualityControls.length,
                itemBuilder: (context, index) {
                  final control = _qualityControls[index];
                  return _buildQualityControlCard(control);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityControlCard(QualityControl control) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          child: const Icon(Icons.verified, color: Colors.orange),
        ),
        title: Text('${control.controlType} - ${DateFormat('dd.MM.yyyy').format(control.controlDate)}'),
        subtitle: Text('${control.issues.length} sorun, ${control.improvements.length} iyileştirme'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${control.overallScore.toStringAsFixed(1)}/5.0',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              control.status,
              style: TextStyle(
                fontSize: 12,
                color: control.status == 'completed' ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetricsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verimlilik Metrikleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEfficiencyMetric(
                    'Kullanım Oranı',
                    '85%',
                    Icons.pie_chart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEfficiencyMetric(
                    'Kalite Skoru',
                    '4.2/5.0',
                    Icons.star,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEfficiencyMetric(
                    'Maliyet Verimliliği',
                    '92%',
                    Icons.attach_money,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEfficiencyMetric(
                    'Hasta Memnuniyeti',
                    '4.5/5.0',
                    Icons.sentiment_satisfied,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetric(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildAIFeaturesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Destekli Operasyonel Analiz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateOptimizationRecommendations,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Optimizasyon Önerileri'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateResourceOptimization,
                    icon: const Icon(Icons.account_tree),
                    label: const Text('Kaynak Optimizasyonu'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateQualityInsights,
                    icon: const Icon(Icons.verified),
                    label: const Text('Kalite İçgörüleri'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateEfficiencyReport,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Verimlilik Raporu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  Future<void> _createOptimization() async {
    // TODO: Implement optimization creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Optimizasyon oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _createResourcePlanning() async {
    // TODO: Implement resource planning creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kaynak planlaması oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _createQualityControl() async {
    // TODO: Implement quality control creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kalite kontrolü oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _generateOptimizationRecommendations() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final recommendations = await _service.generateOptimizationRecommendations(
        organizationId: 'org_001',
        currentMetrics: {
          'utilization_rate': 0.75,
          'wait_time': 15.0,
          'no_show_rate': 0.12,
          'patient_satisfaction': 4.2,
        },
        optimizationType: OptimizationType.appointment,
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('Optimizasyon Önerileri', recommendations);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI analiz hatası: $e')),
        );
      }
    }
  }

  Future<void> _generateResourceOptimization() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final optimization = await _service.generateResourceOptimization(
        organizationId: 'org_001',
        resourceData: {
          'utilization': 0.70,
          'workload': 0.85,
          'room_utilization': 0.75,
          'maintenance_cost': 1200.0,
        },
        resourceType: ResourceType.staff,
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('Kaynak Optimizasyonu', optimization);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI analiz hatası: $e')),
        );
      }
    }
  }

  Future<void> _generateQualityInsights() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final insights = await _service.generateQualityInsights(
        organizationId: 'org_001',
        qualityData: {
          'overall_score': 4.1,
          'patient_satisfaction': 4.3,
          'compliance_rate': 0.92,
          'documentation_completeness': 0.85,
        },
        qualityType: 'Monthly Review',
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('Kalite İçgörüleri', insights);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI analiz hatası: $e')),
        );
      }
    }
  }

  Future<void> _generateEfficiencyReport() async {
    // TODO: Implement efficiency report generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verimlilik raporu özelliği yakında eklenecek')),
    );
  }

  void _showInsightsDialog(String title, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data['recommendations'] != null) ...[
                const Text('Öneriler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['recommendations'] as List).map((recommendation) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $recommendation'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['actionItems'] != null) ...[
                const Text('Aksiyon Maddeleri:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['actionItems'] as List).map((item) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $item'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['expectedImprovements'] != null) ...[
                const Text('Beklenen İyileştirmeler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['expectedImprovements'] as List).map((improvement) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $improvement'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['insights'] != null) ...[
                const Text('İçgörüler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['insights'] as List).map((insight) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $insight'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['confidence'] != null) ...[
                Text('Güven Skoru: ${(data['confidence'] * 100).toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
