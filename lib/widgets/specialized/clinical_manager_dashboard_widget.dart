import 'package:flutter/material.dart';
import '../../models/clinical_manager_models.dart';
import '../../services/clinical_manager_service.dart';

class ClinicalManagerDashboardWidget extends StatefulWidget {
  final String managerId;

  const ClinicalManagerDashboardWidget({
    super.key,
    required this.managerId,
  });

  @override
  State<ClinicalManagerDashboardWidget> createState() => _ClinicalManagerDashboardWidgetState();
}

class _ClinicalManagerDashboardWidgetState extends State<ClinicalManagerDashboardWidget> {
  final _managerService = ClinicalManagerService();
  
  Map<String, dynamic>? _statistics;
  List<ClinicalDepartment> _departments = [];
  List<ComplianceAudit> _upcomingAudits = [];
  List<FinancialAlert> _activeAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final statistics = await _managerService.getClinicalManagerStatistics(widget.managerId);
      final departments = await _managerService.getDepartments();
      final upcomingAudits = await _managerService.getUpcomingAudits('org_001');
      final activeAlerts = await _managerService.getActiveFinancialAlerts('org_001');
      
      setState(() {
        _statistics = statistics;
        _departments = departments;
        _upcomingAudits = upcomingAudits;
        _activeAlerts = activeAlerts;
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
          _buildActiveAlerts(),
          const SizedBox(height: 24),
          _buildDepartmentOverview(),
          const SizedBox(height: 24),
          _buildUpcomingAudits(),
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
            const Icon(Icons.business, size: 48, color: Colors.indigo),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Klinik Yöneticisi Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kurum yönetimi, performans takibi ve uyumluluk',
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
          'Yönetilen Bölüm',
          '${_statistics!['managedDepartments']}',
          Icons.business,
          Colors.indigo,
        ),
        _buildStatCard(
          'Personel Değerlendirme',
          '${_statistics!['staffEvaluations']}',
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          'Uyumluluk Denetimi',
          '${_statistics!['complianceAudits']}',
          Icons.security,
          Colors.orange,
        ),
        _buildStatCard(
          'Mali Rapor',
          '${_statistics!['financialReports']}',
          Icons.account_balance,
          Colors.blue,
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
                  'Personel Değerlendir',
                  Icons.people,
                  Colors.green,
                  () => _evaluateStaff(),
                ),
                _buildQuickActionCard(
                  'Uyumluluk Denetimi',
                  Icons.security,
                  Colors.orange,
                  () => _conductComplianceAudit(),
                ),
                _buildQuickActionCard(
                  'Mali Rapor',
                  Icons.account_balance,
                  Colors.blue,
                  () => _generateFinancialReport(),
                ),
                _buildQuickActionCard(
                  'Kaynak Dağılımı',
                  Icons.assignment,
                  Colors.purple,
                  () => _allocateResources(),
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

  Widget _buildActiveAlerts() {
    if (_activeAlerts.isEmpty) return const SizedBox();

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
                  'Aktif Mali Uyarılar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._activeAlerts.take(3).map((alert) => _buildAlertCard(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(FinancialAlert alert) {
    Color severityColor;
    switch (alert.severity) {
      case 'low':
        severityColor = Colors.yellow;
        break;
      case 'medium':
        severityColor = Colors.orange;
        break;
      case 'high':
        severityColor = Colors.red;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: severityColor.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.warning, color: severityColor),
        title: Text(alert.message),
        subtitle: Text('${alert.type} • ${_formatDate(alert.alertDate)}'),
        trailing: Chip(
          label: Text(
            alert.severity.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: severityColor,
          labelStyle: const TextStyle(color: Colors.white),
        ),
        onTap: () => _showAlertDetails(alert),
      ),
    );
  }

  Widget _buildDepartmentOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Bölüm Genel Bakış',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllDepartments(),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_departments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz bölüm bulunmuyor'),
                ),
              )
            else
              ..._departments.map((department) => _buildDepartmentCard(department)),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(ClinicalDepartment department) {
    final capacityUtilization = (department.currentPatientCount / department.targetPatientCapacity * 100).round();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getDepartmentIcon(department.type),
          color: _getDepartmentColor(department.type),
        ),
        title: Text(department.name),
        subtitle: Text(
          '${department.currentPatientCount}/${department.targetPatientCapacity} hasta • %$capacityUtilization kapasite',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₺${(department.budget / 1000).toStringAsFixed(0)}K',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Bütçe',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () => _showDepartmentDetails(department),
      ),
    );
  }

  Widget _buildUpcomingAudits() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Yaklaşan Uyumluluk Denetimleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_upcomingAudits.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Yaklaşan denetim bulunmuyor'),
                ),
              )
            else
              ..._upcomingAudits.map((audit) => _buildAuditCard(audit)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditCard(ComplianceAudit audit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.security, color: Colors.orange),
        title: Text(audit.complianceType.name.toUpperCase()),
        subtitle: Text(
          '${_formatDate(audit.nextAuditDate)} • Skor: ${audit.complianceScore.toStringAsFixed(1)}%',
        ),
        trailing: const Icon(Icons.schedule, color: Colors.blue),
        onTap: () => _showAuditDetails(audit),
      ),
    );
  }

  IconData _getDepartmentIcon(DepartmentType type) {
    switch (type) {
      case DepartmentType.psychiatry:
        return Icons.psychology;
      case DepartmentType.psychology:
        return Icons.psychology;
      case DepartmentType.therapy:
        return Icons.healing;
      case DepartmentType.counseling:
        return Icons.support;
      case DepartmentType.socialWork:
        return Icons.people;
      case DepartmentType.administration:
        return Icons.business;
    }
  }

  Color _getDepartmentColor(DepartmentType type) {
    switch (type) {
      case DepartmentType.psychiatry:
        return Colors.blue;
      case DepartmentType.psychology:
        return Colors.purple;
      case DepartmentType.therapy:
        return Colors.green;
      case DepartmentType.counseling:
        return Colors.orange;
      case DepartmentType.socialWork:
        return Colors.teal;
      case DepartmentType.administration:
        return Colors.indigo;
    }
  }

  void _evaluateStaff() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personel Değerlendirme'),
        content: const Text('Personel değerlendirme ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to staff evaluation screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _conductComplianceAudit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uyumluluk Denetimi'),
        content: const Text('Uyumluluk denetimi ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to compliance audit screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _generateFinancialReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mali Rapor'),
        content: const Text('Mali rapor oluşturma ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to financial report screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _allocateResources() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaynak Dağılımı'),
        content: const Text('Kaynak dağılımı ekranına yönlendiriliyorsunuz...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to resource allocation screen
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(FinancialAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uyarı Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip: ${alert.type}'),
            Text('Şiddet: ${alert.severity}'),
            Text('Mesaj: ${alert.message}'),
            Text('Tutar: ₺${alert.amount.toStringAsFixed(2)}'),
            Text('Tarih: ${_formatDate(alert.alertDate)}'),
            Text('Durum: ${alert.isResolved ? 'Çözüldü' : 'Aktif'}'),
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

  void _showDepartmentDetails(ClinicalDepartment department) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bölüm Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ad: ${department.name}'),
            Text('Tip: ${department.type.name}'),
            Text('Yönetici: ${department.managerId}'),
            Text('Personel Sayısı: ${department.staffIds.length}'),
            Text('Bütçe: ₺${department.budget.toStringAsFixed(2)}'),
            Text('Hasta Kapasitesi: ${department.currentPatientCount}/${department.targetPatientCapacity}'),
            Text('Oluşturulma: ${_formatDate(department.createdAt)}'),
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

  void _showAuditDetails(ComplianceAudit audit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Denetim Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip: ${audit.complianceType.name}'),
            Text('Denetim Tarihi: ${_formatDate(audit.auditDate)}'),
            Text('Denetçi: ${audit.auditorId}'),
            Text('Uyumluluk Skoru: ${audit.complianceScore.toStringAsFixed(1)}%'),
            Text('İhlal Sayısı: ${audit.violations.length}'),
            Text('Sonraki Denetim: ${_formatDate(audit.nextAuditDate)}'),
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

  void _showAllDepartments() {
    // Navigate to departments screen
    Navigator.pushNamed(context, '/departments');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
