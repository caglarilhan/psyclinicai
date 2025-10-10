import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/strategic_planning_models.dart';
import '../../services/strategic_planning_service.dart';
import '../../utils/theme.dart';

class StrategicPlanningDashboardWidget extends StatefulWidget {
  const StrategicPlanningDashboardWidget({super.key});

  @override
  State<StrategicPlanningDashboardWidget> createState() => _StrategicPlanningDashboardWidgetState();
}

class _StrategicPlanningDashboardWidgetState extends State<StrategicPlanningDashboardWidget> {
  final StrategicPlanningService _service = StrategicPlanningService();
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  List<MarketAnalysis> _marketAnalyses = [];
  List<GrowthProjection> _growthProjections = [];
  List<PatientSegmentation> _patientSegmentations = [];
  List<StrategicPlan> _strategicPlans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final organizationId = 'org_001'; // Demo organization ID
      
      final statistics = await _service.getStrategicPlanningStatistics(organizationId);
      final marketAnalyses = await _service.getMarketAnalyses(organizationId);
      final growthProjections = await _service.getGrowthProjections(organizationId);
      final patientSegmentations = await _service.getPatientSegmentations(organizationId);
      final strategicPlans = await _service.getStrategicPlans(organizationId);
      
      setState(() {
        _statistics = statistics;
        _marketAnalyses = marketAnalyses;
        _growthProjections = growthProjections;
        _patientSegmentations = patientSegmentations;
        _strategicPlans = strategicPlans;
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
          _buildMarketAnalysisSection(),
          const SizedBox(height: 24),
          _buildGrowthProjectionsSection(),
          const SizedBox(height: 24),
          _buildPatientSegmentationSection(),
          const SizedBox(height: 24),
          _buildStrategicPlansSection(),
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
          'Stratejik Planlama Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pazar analizi, büyüme projeksiyonları ve stratejik planlama',
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
          'Pazar Analizi',
          '${_statistics['totalMarketAnalyses'] ?? 0}',
          Icons.analytics,
          Colors.blue,
        ),
        _buildStatCard(
          'Büyüme Projeksiyonları',
          '${_statistics['totalGrowthProjections'] ?? 0}',
          Icons.trending_up,
          Colors.green,
        ),
        _buildStatCard(
          'Hasta Segmentasyonu',
          '${_statistics['totalPatientSegmentations'] ?? 0}',
          Icons.people,
          Colors.orange,
        ),
        _buildStatCard(
          'Stratejik Planlar',
          '${_statistics['totalStrategicPlans'] ?? 0}',
          Icons.business,
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

  Widget _buildMarketAnalysisSection() {
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
                  'Pazar Analizi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createMarketAnalysis,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Analiz'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_marketAnalyses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz pazar analizi bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _marketAnalyses.length,
                itemBuilder: (context, index) {
                  final analysis = _marketAnalyses[index];
                  return _buildMarketAnalysisCard(analysis);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketAnalysisCard(MarketAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: const Icon(Icons.analytics, color: Colors.blue),
        ),
        title: Text('Pazar Analizi - ${DateFormat('dd.MM.yyyy').format(analysis.analysisDate)}'),
        subtitle: Text(analysis.summary),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewMarketAnalysis(analysis);
                break;
              case 'edit':
                _editMarketAnalysis(analysis);
                break;
              case 'delete':
                _deleteMarketAnalysis(analysis.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Görüntüle')),
            const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
            const PopupMenuItem(value: 'delete', child: Text('Sil')),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthProjectionsSection() {
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
                  'Büyüme Projeksiyonları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createGrowthProjection,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Projeksiyon'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_growthProjections.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz büyüme projeksiyonu bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _growthProjections.length,
                itemBuilder: (context, index) {
                  final projection = _growthProjections[index];
                  return _buildGrowthProjectionCard(projection);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthProjectionCard(GrowthProjection projection) {
    final currentYear = DateTime.now().year;
    final currentRevenue = projection.revenueProjection[currentYear.toString()] ?? 0.0;
    final nextYearRevenue = projection.revenueProjection[(currentYear + 1).toString()] ?? 0.0;
    final growthRate = currentRevenue > 0 ? ((nextYearRevenue - currentRevenue) / currentRevenue * 100) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          child: const Icon(Icons.trending_up, color: Colors.green),
        ),
        title: Text('Büyüme Projeksiyonu - ${DateFormat('dd.MM.yyyy').format(projection.projectionDate)}'),
        subtitle: Text('${growthRate.toStringAsFixed(1)}% büyüme oranı'),
        trailing: Text(
          '${NumberFormat.currency(symbol: '₺', decimalDigits: 0).format(currentRevenue)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPatientSegmentationSection() {
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
                  'Hasta Segmentasyonu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createPatientSegmentation,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Segmentasyon'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_patientSegmentations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz hasta segmentasyonu bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _patientSegmentations.length,
                itemBuilder: (context, index) {
                  final segmentation = _patientSegmentations[index];
                  return _buildPatientSegmentationCard(segmentation);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSegmentationCard(PatientSegmentation segmentation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          child: const Icon(Icons.people, color: Colors.orange),
        ),
        title: Text('Hasta Segmentasyonu - ${DateFormat('dd.MM.yyyy').format(segmentation.analysisDate)}'),
        subtitle: Text('${segmentation.segments.length} segment tanımlandı'),
        trailing: Text(
          '${segmentation.recommendations.length} öneri',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStrategicPlansSection() {
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
                  'Stratejik Planlar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createStrategicPlan,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Plan'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_strategicPlans.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz stratejik plan bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _strategicPlans.length,
                itemBuilder: (context, index) {
                  final plan = _strategicPlans[index];
                  return _buildStrategicPlanCard(plan);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategicPlanCard(StrategicPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          child: const Icon(Icons.business, color: Colors.purple),
        ),
        title: Text('Stratejik Plan - ${DateFormat('dd.MM.yyyy').format(plan.planDate)}'),
        subtitle: Text(plan.vision),
        trailing: Text(
          plan.status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: plan.status == 'active' ? Colors.green : Colors.orange,
          ),
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
              'AI Destekli Stratejik Analiz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateMarketInsights,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Pazar İçgörüleri'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateGrowthStrategy,
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Büyüme Stratejisi'),
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
  Future<void> _createMarketAnalysis() async {
    // TODO: Implement market analysis creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pazar analizi oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _createGrowthProjection() async {
    // TODO: Implement growth projection creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Büyüme projeksiyonu oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _createPatientSegmentation() async {
    // TODO: Implement patient segmentation creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hasta segmentasyonu oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _createStrategicPlan() async {
    // TODO: Implement strategic plan creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stratejik plan oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _viewMarketAnalysis(MarketAnalysis analysis) async {
    // TODO: Implement market analysis view dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pazar analizi görüntüleme özelliği yakında eklenecek')),
    );
  }

  Future<void> _editMarketAnalysis(MarketAnalysis analysis) async {
    // TODO: Implement market analysis edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pazar analizi düzenleme özelliği yakında eklenecek')),
    );
  }

  Future<void> _deleteMarketAnalysis(String analysisId) async {
    // TODO: Implement market analysis deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pazar analizi silme özelliği yakında eklenecek')),
    );
  }

  Future<void> _generateMarketInsights() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final insights = await _service.generateMarketInsights(
        organizationId: 'org_001',
        currentData: {
          'marketShare': {'individual': 0.15, 'corporate': 0.05},
          'revenue': 1000000.0,
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('Pazar İçgörüleri', insights);
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

  Future<void> _generateGrowthStrategy() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final strategy = await _service.generateGrowthStrategy(
        organizationId: 'org_001',
        currentMetrics: {
          'revenue': 1000000.0,
          'marketShare': 0.05,
        },
        preferredStrategies: [GrowthStrategy.innovation, GrowthStrategy.expansion],
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('Büyüme Stratejisi', strategy);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI strateji hatası: $e')),
        );
      }
    }
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
              if (data['insights'] != null) ...[
                const Text('İçgörüler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['insights'] as List).map((insight) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $insight'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['recommendations'] != null) ...[
                const Text('Öneriler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['recommendations'] as List).map((recommendation) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $recommendation'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['strategies'] != null) ...[
                const Text('Stratejiler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['strategies'] as List).map((strategy) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $strategy'),
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
