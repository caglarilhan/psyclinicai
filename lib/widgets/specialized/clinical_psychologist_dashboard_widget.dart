import 'package:flutter/material.dart';
import '../../models/clinical_psychologist_models.dart';
import '../../services/clinical_psychologist_service.dart';

class ClinicalPsychologistDashboardWidget extends StatefulWidget {
  final String psychologistId;

  const ClinicalPsychologistDashboardWidget({
    super.key,
    required this.psychologistId,
  });

  @override
  State<ClinicalPsychologistDashboardWidget> createState() => _ClinicalPsychologistDashboardWidgetState();
}

class _ClinicalPsychologistDashboardWidgetState extends State<ClinicalPsychologistDashboardWidget> {
  final _psychologistService = ClinicalPsychologistService();
  
  Map<String, dynamic>? _statistics;
  List<TestAdministration> _recentTestAdministrations = [];
  List<PsychologicalReport> _recentReports = [];
  List<SupervisionSession> _upcomingSupervisionSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final statistics = await _psychologistService.getClinicalPsychologistStatistics(widget.psychologistId);
      final testAdministrations = await _psychologistService.getPsychologistTestAdministrations(widget.psychologistId);
      final reports = await _psychologistService.getPsychologistReports(widget.psychologistId);
      final supervisionSessions = await _psychologistService.getSupervisionSessions(widget.psychologistId);
      
      setState(() {
        _statistics = statistics;
        _recentTestAdministrations = testAdministrations.take(5).toList();
        _recentReports = reports.take(5).toList();
        _upcomingSupervisionSessions = supervisionSessions.take(3).toList();
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
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentTestAdministrations(),
          const SizedBox(height: 24),
          _buildRecentReports(),
          const SizedBox(height: 24),
          _buildUpcomingSupervisionSessions(),
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
            const Icon(Icons.psychology, size: 48, color: Colors.purple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Klinik Psikolog Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Test değerlendirme, raporlama ve süpervizyon',
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
          'Test Uygulaması',
          '${_statistics!['totalTestAdministrations']}',
          Icons.quiz,
          Colors.purple,
        ),
        _buildStatCard(
          'Psikolojik Rapor',
          '${_statistics!['totalReports']}',
          Icons.description,
          Colors.blue,
        ),
        _buildStatCard(
          'Süpervizyon',
          '${_statistics!['totalSupervisionSessions']}',
          Icons.supervisor_account,
          Colors.green,
        ),
        _buildStatCard(
          'Yeterlilik Değerlendirme',
          '${_statistics!['totalCompetencyAssessments']}',
          Icons.assessment,
          Colors.orange,
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

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı İşlemler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
              children: [
                _buildQuickActionCard(
                  'Yeni Test',
                  Icons.add_circle,
                  Colors.purple,
                  () => _startNewTest(),
                ),
                _buildQuickActionCard(
                  'Rapor Oluştur',
                  Icons.description,
                  Colors.blue,
                  () => _createNewReport(),
                ),
                _buildQuickActionCard(
                  'Süpervizyon',
                  Icons.supervisor_account,
                  Colors.green,
                  () => _scheduleSupervision(),
                ),
                _buildQuickActionCard(
                  'Test Bataryası',
                  Icons.library_books,
                  Colors.orange,
                  () => _selectTestBattery(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTestAdministrations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Son Test Uygulamaları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllTestAdministrations(),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentTestAdministrations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz test uygulaması bulunmuyor'),
                ),
              )
            else
              ..._recentTestAdministrations.map((administration) => _buildTestAdministrationCard(administration)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestAdministrationCard(TestAdministration administration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          administration.isCompleted ? Icons.check_circle : Icons.schedule,
          color: administration.isCompleted ? Colors.green : Colors.orange,
        ),
        title: Text('Test ID: ${administration.testId}'),
        subtitle: Text(
          '${_formatDate(administration.administrationDate)} • ${administration.environment}',
        ),
        trailing: administration.isCompleted
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.schedule, color: Colors.orange),
        onTap: () => _showTestAdministrationDetails(administration),
      ),
    );
  }

  Widget _buildRecentReports() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Son Psikolojik Raporlar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllReports(),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentReports.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz rapor bulunmuyor'),
                ),
              )
            else
              ..._recentReports.map((report) => _buildReportCard(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(PsychologicalReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          report.isFinalized ? Icons.description : Icons.edit,
          color: report.isFinalized ? Colors.green : Colors.orange,
        ),
        title: Text(report.reportType),
        subtitle: Text(
          '${_formatDate(report.reportDate)} • ${report.diagnosticImpressions}',
        ),
        trailing: report.isFinalized
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.edit, color: Colors.orange),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  Widget _buildUpcomingSupervisionSessions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.supervisor_account, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Yaklaşan Süpervizyon Seansları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_upcomingSupervisionSessions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Yaklaşan süpervizyon seansı bulunmuyor'),
                ),
              )
            else
              ..._upcomingSupervisionSessions.map((session) => _buildSupervisionSessionCard(session)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisionSessionCard(SupervisionSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.supervisor_account, color: Colors.green),
        title: Text(session.sessionType),
        subtitle: Text(
          '${_formatDate(session.sessionDate)} • ${session.duration} dakika',
        ),
        trailing: const Icon(Icons.schedule, color: Colors.blue),
        onTap: () => _showSupervisionSessionDetails(session),
      ),
    );
  }

  void _startNewTest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Test Başlat'),
        content: const Text('Test seçimi ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to test selection screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _createNewReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Rapor Oluştur'),
        content: const Text('Rapor oluşturma ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to report creation screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _scheduleSupervision() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Süpervizyon Planla'),
        content: const Text('Süpervizyon planlama ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to supervision scheduling screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _selectTestBattery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Bataryası Seç'),
        content: const Text('Test bataryası seçim ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to test battery selection screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _showTestAdministrationDetails(TestAdministration administration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Uygulama Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test ID: ${administration.testId}'),
            Text('Hasta ID: ${administration.patientId}'),
            Text('Tarih: ${_formatDate(administration.administrationDate)}'),
            Text('Ortam: ${administration.environment}'),
            Text('Tip: ${administration.administrationType.name}'),
            Text('Durum: ${administration.isCompleted ? 'Tamamlandı' : 'Devam ediyor'}'),
            if (administration.isCompleted && administration.completionDate != null)
              Text('Tamamlanma: ${_formatDate(administration.completionDate!)}'),
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

  void _showReportDetails(PsychologicalReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor Detayları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tip: ${report.reportType}'),
              Text('Tarih: ${_formatDate(report.reportDate)}'),
              Text('Referans Sorusu: ${report.referralQuestion}'),
              Text('Tanısal İzlenimler: ${report.diagnosticImpressions}'),
              Text('Durum: ${report.isFinalized ? 'Finalize edildi' : 'Taslak'}'),
              Text('İmza: ${report.signature}'),
              Text('Lisans No: ${report.licenseNumber}'),
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

  void _showSupervisionSessionDetails(SupervisionSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Süpervizyon Seans Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip: ${session.sessionType}'),
            Text('Tarih: ${_formatDate(session.sessionDate)}'),
            Text('Süre: ${session.duration} dakika'),
            Text('Süpervizör: ${session.supervisorId}'),
            Text('Tartışılan Vakalar: ${session.casesDiscussed.length}'),
            Text('Sonraki Seans: ${_formatDate(session.nextSessionDate)}'),
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

  void _showAllTestAdministrations() {
    // Navigate to test administrations screen
    Navigator.pushNamed(context, '/test-administrations');
  }

  void _showAllReports() {
    // Navigate to reports screen
    Navigator.pushNamed(context, '/psychological-reports');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
