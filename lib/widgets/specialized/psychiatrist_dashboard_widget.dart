import 'package:flutter/material.dart';
import '../../models/psychiatrist_specialized_models.dart';
import '../../services/psychiatrist_specialized_service.dart';

class PsychiatristDashboardWidget extends StatefulWidget {
  final String psychiatristId;

  const PsychiatristDashboardWidget({
    super.key,
    required this.psychiatristId,
  });

  @override
  State<PsychiatristDashboardWidget> createState() => _PsychiatristDashboardWidgetState();
}

class _PsychiatristDashboardWidgetState extends State<PsychiatristDashboardWidget> {
  final _psychiatristService = PsychiatristSpecializedService();
  
  Map<String, dynamic>? _statistics;
  List<Prescription> _recentPrescriptions = [];
  List<SideEffectReport> _activeSideEffects = [];
  List<LabTest> _pendingLabTests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final statistics = await _psychiatristService.getPsychiatristStatistics(widget.psychiatristId);
      final prescriptions = await _psychiatristService.getPsychiatristPrescriptions(widget.psychiatristId);
      final sideEffects = await _psychiatristService.getActiveSideEffectReports();
      final labTests = await _psychiatristService.getPendingLabTests(widget.psychiatristId);
      
      setState(() {
        _statistics = statistics;
        _recentPrescriptions = prescriptions.take(5).toList();
        _activeSideEffects = sideEffects;
        _pendingLabTests = labTests;
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
          _buildStatisticsGrid(),
          const SizedBox(height: 24),
          _buildActiveAlerts(),
          const SizedBox(height: 24),
          _buildRecentPrescriptions(),
          const SizedBox(height: 24),
          _buildPendingLabTests(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.psychology, size: 48, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Psikiyatrist Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İlaç yönetimi, yan etki takibi ve laboratuvar sonuçları',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Yenile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    if (_statistics == null) return const SizedBox();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Reçete',
          '${_statistics!['totalPrescriptions']}',
          Icons.medication,
          Colors.blue,
        ),
        _buildStatCard(
          'Yan Etki Raporu',
          '${_statistics!['totalSideEffectReports']}',
          Icons.warning,
          Colors.orange,
        ),
        _buildStatCard(
          'Laboratuvar Testi',
          '${_statistics!['totalLabTests']}',
          Icons.science,
          Colors.green,
        ),
        _buildStatCard(
          'Değerlendirme',
          '${_statistics!['totalAssessments']}',
          Icons.assessment,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
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
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlerts() {
    if (_activeSideEffects.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Aktif Yan Etki Raporları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._activeSideEffects.take(3).map((report) => _buildSideEffectCard(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildSideEffectCard(SideEffectReport report) {
    Color severityColor;
    switch (report.severity) {
      case SideEffectSeverity.mild:
        severityColor = Colors.yellow;
        break;
      case SideEffectSeverity.moderate:
        severityColor = Colors.orange;
        break;
      case SideEffectSeverity.severe:
        severityColor = Colors.red;
        break;
      case SideEffectSeverity.lifeThreatening:
        severityColor = Colors.red[900]!;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: severityColor.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.medication, color: severityColor),
        title: Text(report.medicationName),
        subtitle: Text(report.sideEffect),
        trailing: Chip(
          label: Text(
            report.severity.name.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: severityColor,
          labelStyle: const TextStyle(color: Colors.white),
        ),
        onTap: () => _showSideEffectDetails(report),
      ),
    );
  }

  Widget _buildRecentPrescriptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Son Reçeteler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllPrescriptions(),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentPrescriptions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz reçete bulunmuyor'),
                ),
              )
            else
              ..._recentPrescriptions.map((prescription) => _buildPrescriptionCard(prescription)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.blue),
        title: Text(prescription.diagnosis),
        subtitle: Text(
          '${prescription.medications.length} ilaç • ${_formatDate(prescription.prescribedAt)}',
        ),
        trailing: prescription.isRefillable
            ? const Icon(Icons.refresh, color: Colors.green)
            : const Icon(Icons.check, color: Colors.grey),
        onTap: () => _showPrescriptionDetails(prescription),
      ),
    );
  }

  Widget _buildPendingLabTests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Bekleyen Laboratuvar Testleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_pendingLabTests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Bekleyen test bulunmuyor'),
                ),
              )
            else
              ..._pendingLabTests.map((test) => _buildLabTestCard(test)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabTestCard(LabTest test) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.science, color: Colors.green),
        title: Text(test.testName),
        subtitle: Text(
          '${test.type.name.toUpperCase()} • ${_formatDate(test.orderedAt)}',
        ),
        trailing: const Icon(Icons.schedule, color: Colors.orange),
        onTap: () => _showLabTestDetails(test),
      ),
    );
  }

  void _showSideEffectDetails(SideEffectReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yan Etki Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İlaç: ${report.medicationName}'),
            Text('Yan Etki: ${report.sideEffect}'),
            Text('Şiddet: ${report.severity.name}'),
            Text('Açıklama: ${report.description}'),
            Text('Raporlayan: ${report.reportedBy}'),
            Text('Tarih: ${_formatDate(report.reportedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionDetails(Prescription prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reçete Detayları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanı: ${prescription.diagnosis}'),
              Text('Tarih: ${_formatDate(prescription.prescribedAt)}'),
              Text('Geçerlilik: ${prescription.validUntil != null ? _formatDate(prescription.validUntil!) : 'Belirtilmemiş'}'),
              Text('İlaçlar:'),
              ...prescription.medications.map((med) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('• ${med.medicationName} ${med.dosage}${med.dosageUnit}'),
                ),
              ),
              Text('Talimatlar: ${prescription.instructions}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLabTestDetails(LabTest test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laboratuvar Test Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test: ${test.testName}'),
            Text('Tip: ${test.type.name}'),
            Text('Sipariş Tarihi: ${_formatDate(test.orderedAt)}'),
            if (test.completedAt != null)
              Text('Tamamlanma: ${_formatDate(test.completedAt!)}'),
            if (test.results != null)
              Text('Sonuçlar: ${test.results}'),
            if (test.interpretation != null)
              Text('Yorum: ${test.interpretation}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showAllPrescriptions() {
    // Navigate to prescriptions screen
    Navigator.pushNamed(context, '/prescriptions');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
