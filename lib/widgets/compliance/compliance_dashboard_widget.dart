import 'package:flutter/material.dart';
import '../../models/compliance_models.dart';
import '../../services/compliance_service.dart';
import '../../utils/theme.dart';

class ComplianceDashboardWidget extends StatefulWidget {
  final String userId;

  const ComplianceDashboardWidget({
    super.key,
    required this.userId,
  });

  @override
  State<ComplianceDashboardWidget> createState() => _ComplianceDashboardWidgetState();
}

class _ComplianceDashboardWidgetState extends State<ComplianceDashboardWidget> {
  final _complianceService = ComplianceService();
  ComplianceDashboard? _dashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final dashboard = await _complianceService.generateComplianceDashboard(
        userId: widget.userId,
      );
      
      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Uyumluluk verileri yüklenemedi: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboard == null) {
      return const Center(child: Text('Uyumluluk verileri bulunamadı'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // Summary Cards
          _buildSummaryCards(),
          
          const SizedBox(height: 24),
          
          // Regional Compliance Status
          _buildRegionalCompliance(),
          
          const SizedBox(height: 24),
          
          // Active Violations
          _buildActiveViolations(),
          
          const SizedBox(height: 24),
          
          // Pending Recommendations
          _buildPendingRecommendations(),
          
          const SizedBox(height: 24),
          
          // Recent Reports
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.security, color: AppTheme.primaryColor, size: 32),
        const SizedBox(width: 12),
        Text(
          'Uyumluluk Dashboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _generateNewReport,
          icon: const Icon(Icons.add),
          label: const Text('Yeni Rapor'),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final summary = _dashboard!.summary;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Toplam Rapor',
          '${summary['totalReports'] ?? 0}',
          Icons.description,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Aktif İhlal',
          '${summary['activeViolations'] ?? 0}',
          Icons.warning,
          Colors.red,
        ),
        _buildSummaryCard(
          'Bekleyen Öneri',
          '${summary['pendingRecommendations'] ?? 0}',
          Icons.lightbulb,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Uyumlu Bölge',
          '${summary['compliantRegions'] ?? 0}',
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
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

  Widget _buildRegionalCompliance() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bölgesel Uyumluluk Durumu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._dashboard!.regionalStatus.entries.map((entry) {
              return _buildRegionalStatusItem(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionalStatusItem(ComplianceRegion region, ComplianceStatus status) {
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRegionDisplayName(region),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getStatusDisplayName(status),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _viewRegionDetails(region),
            child: const Text('Detaylar'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveViolations() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Aktif İhlaller',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _viewAllViolations,
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dashboard!.activeViolations.isEmpty)
              const Center(
                child: Text('Aktif ihlal bulunmuyor'),
              )
            else
              ..._dashboard!.activeViolations.take(3).map((violation) {
                return _buildViolationItem(violation);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationItem(ComplianceViolation violation) {
    final severityColor = _getSeverityColor(violation.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: severityColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  violation.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  _getSeverityDisplayName(violation.severity),
                  style: TextStyle(
                    fontSize: 10,
                    color: severityColor,
                  ),
                ),
                backgroundColor: severityColor.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            violation.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Tespit: ${_formatDate(violation.detectedAt)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _resolveViolation(violation),
                child: const Text('Çöz'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRecommendations() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Bekleyen Öneriler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _viewAllRecommendations,
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dashboard!.pendingRecommendations.isEmpty)
              const Center(
                child: Text('Bekleyen öneri bulunmuyor'),
              )
            else
              ..._dashboard!.pendingRecommendations.take(3).map((recommendation) {
                return _buildRecommendationItem(recommendation);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(ComplianceRecommendation recommendation) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priorityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: priorityColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  _getPriorityDisplayName(recommendation.priority),
                  style: TextStyle(
                    fontSize: 10,
                    color: priorityColor,
                  ),
                ),
                backgroundColor: priorityColor.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Oluşturulma: ${_formatDate(recommendation.createdAt)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _implementRecommendation(recommendation),
                child: const Text('Uygula'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Son Raporlar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _viewAllReports,
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dashboard!.reports.isEmpty)
              const Center(
                child: Text('Henüz rapor oluşturulmamış'),
              )
            else
              ..._dashboard!.reports.take(3).map((report) {
                return _buildReportItem(report);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(ComplianceReport report) {
    final statusColor = _getStatusColor(report.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_getRegionDisplayName(report.region)} - ${_getTypeDisplayName(report.type)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  _getStatusDisplayName(report.status),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                  ),
                ),
                backgroundColor: statusColor.withOpacity(0.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Geçerlilik: ${_formatDate(report.validUntil)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Oluşturulma: ${_formatDate(report.generatedAt)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _viewReportDetails(report),
                child: const Text('Detaylar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Colors.green;
      case ComplianceStatus.nonCompliant:
        return Colors.red;
      case ComplianceStatus.partial:
        return Colors.orange;
      case ComplianceStatus.pending:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.nonCompliant:
        return Icons.error;
      case ComplianceStatus.partial:
        return Icons.warning;
      case ComplianceStatus.pending:
        return Icons.schedule;
    }
  }

  Color _getSeverityColor(ComplianceSeverity severity) {
    switch (severity) {
      case ComplianceSeverity.low:
        return Colors.green;
      case ComplianceSeverity.medium:
        return Colors.orange;
      case ComplianceSeverity.high:
        return Colors.red;
      case ComplianceSeverity.critical:
        return Colors.red[800]!;
    }
  }

  Color _getPriorityColor(CompliancePriority priority) {
    switch (priority) {
      case CompliancePriority.low:
        return Colors.green;
      case CompliancePriority.medium:
        return Colors.orange;
      case CompliancePriority.high:
        return Colors.red;
      case CompliancePriority.urgent:
        return Colors.red[800]!;
    }
  }

  String _getRegionDisplayName(ComplianceRegion region) {
    switch (region) {
      case ComplianceRegion.US:
        return 'ABD';
      case ComplianceRegion.EU:
        return 'AB';
      case ComplianceRegion.TR:
        return 'Türkiye';
      case ComplianceRegion.CA:
        return 'Kanada';
      case ComplianceRegion.AU:
        return 'Avustralya';
    }
  }

  String _getTypeDisplayName(ComplianceType type) {
    switch (type) {
      case ComplianceType.HIPAA:
        return 'HIPAA';
      case ComplianceType.GDPR:
        return 'GDPR';
      case ComplianceType.KVKK:
        return 'KVKK';
      case ComplianceType.PIPEDA:
        return 'PIPEDA';
      case ComplianceType.PrivacyAct:
        return 'Privacy Act';
    }
  }

  String _getStatusDisplayName(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return 'Uyumlu';
      case ComplianceStatus.nonCompliant:
        return 'Uyumsuz';
      case ComplianceStatus.partial:
        return 'Kısmi';
      case ComplianceStatus.pending:
        return 'Beklemede';
    }
  }

  String _getSeverityDisplayName(ComplianceSeverity severity) {
    switch (severity) {
      case ComplianceSeverity.low:
        return 'Düşük';
      case ComplianceSeverity.medium:
        return 'Orta';
      case ComplianceSeverity.high:
        return 'Yüksek';
      case ComplianceSeverity.critical:
        return 'Kritik';
    }
  }

  String _getPriorityDisplayName(CompliancePriority priority) {
    switch (priority) {
      case CompliancePriority.low:
        return 'Düşük';
      case CompliancePriority.medium:
        return 'Orta';
      case CompliancePriority.high:
        return 'Yüksek';
      case CompliancePriority.urgent:
        return 'Acil';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  void _generateNewReport() {
    showDialog(
      context: context,
      builder: (context) => _NewReportDialog(
        onReportGenerated: () {
          Navigator.pop(context);
          _loadDashboard();
        },
      ),
    );
  }

  void _viewRegionDetails(ComplianceRegion region) {
    // TODO: Navigate to region details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bölge detayları yakında eklenecek')),
    );
  }

  void _viewAllViolations() {
    // TODO: Navigate to all violations
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm ihlaller yakında eklenecek')),
    );
  }

  void _resolveViolation(ComplianceViolation violation) {
    showDialog(
      context: context,
      builder: (context) => _ResolveViolationDialog(
        violation: violation,
        onResolved: () {
          Navigator.pop(context);
          _loadDashboard();
        },
      ),
    );
  }

  void _viewAllRecommendations() {
    // TODO: Navigate to all recommendations
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm öneriler yakında eklenecek')),
    );
  }

  void _implementRecommendation(ComplianceRecommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => _ImplementRecommendationDialog(
        recommendation: recommendation,
        onImplemented: () {
          Navigator.pop(context);
          _loadDashboard();
        },
      ),
    );
  }

  void _viewAllReports() {
    // TODO: Navigate to all reports
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm raporlar yakında eklenecek')),
    );
  }

  void _viewReportDetails(ComplianceReport report) {
    // TODO: Navigate to report details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapor detayları yakında eklenecek')),
    );
  }
}

class _NewReportDialog extends StatefulWidget {
  final VoidCallback onReportGenerated;

  const _NewReportDialog({required this.onReportGenerated});

  @override
  State<_NewReportDialog> createState() => _NewReportDialogState();
}

class _NewReportDialogState extends State<_NewReportDialog> {
  ComplianceRegion _selectedRegion = ComplianceRegion.US;
  ComplianceType _selectedType = ComplianceType.HIPAA;
  final _complianceService = ComplianceService();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Uyumluluk Raporu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<ComplianceRegion>(
            value: _selectedRegion,
            decoration: const InputDecoration(
              labelText: 'Bölge',
              border: OutlineInputBorder(),
            ),
            items: ComplianceRegion.values.map((region) {
              return DropdownMenuItem(
                value: region,
                child: Text(_getRegionDisplayName(region)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRegion = value;
                  _selectedType = _getDefaultTypeForRegion(value);
                });
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ComplianceType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Uyumluluk Türü',
              border: OutlineInputBorder(),
            ),
            items: _getAvailableTypesForRegion(_selectedRegion).map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getTypeDisplayName(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isGenerating ? null : _generateReport,
          child: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Oluştur'),
        ),
      ],
    );
  }

  ComplianceType _getDefaultTypeForRegion(ComplianceRegion region) {
    switch (region) {
      case ComplianceRegion.US:
        return ComplianceType.HIPAA;
      case ComplianceRegion.EU:
        return ComplianceType.GDPR;
      case ComplianceRegion.TR:
        return ComplianceType.KVKK;
      case ComplianceRegion.CA:
        return ComplianceType.PIPEDA;
      case ComplianceRegion.AU:
        return ComplianceType.PrivacyAct;
    }
  }

  List<ComplianceType> _getAvailableTypesForRegion(ComplianceRegion region) {
    switch (region) {
      case ComplianceRegion.US:
        return [ComplianceType.HIPAA];
      case ComplianceRegion.EU:
        return [ComplianceType.GDPR];
      case ComplianceRegion.TR:
        return [ComplianceType.KVKK];
      case ComplianceRegion.CA:
        return [ComplianceType.PIPEDA];
      case ComplianceRegion.AU:
        return [ComplianceType.PrivacyAct];
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    
    try {
      await _complianceService.createComplianceReport(
        region: _selectedRegion,
        type: _selectedType,
        generatedBy: 'current_user', // TODO: Get actual user ID
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uyumluluk raporu başarıyla oluşturuldu'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onReportGenerated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  String _getRegionDisplayName(ComplianceRegion region) {
    switch (region) {
      case ComplianceRegion.US:
        return 'ABD';
      case ComplianceRegion.EU:
        return 'AB';
      case ComplianceRegion.TR:
        return 'Türkiye';
      case ComplianceRegion.CA:
        return 'Kanada';
      case ComplianceRegion.AU:
        return 'Avustralya';
    }
  }

  String _getTypeDisplayName(ComplianceType type) {
    switch (type) {
      case ComplianceType.HIPAA:
        return 'HIPAA';
      case ComplianceType.GDPR:
        return 'GDPR';
      case ComplianceType.KVKK:
        return 'KVKK';
      case ComplianceType.PIPEDA:
        return 'PIPEDA';
      case ComplianceType.PrivacyAct:
        return 'Privacy Act';
    }
  }
}

class _ResolveViolationDialog extends StatefulWidget {
  final ComplianceViolation violation;
  final VoidCallback onResolved;

  const _ResolveViolationDialog({
    required this.violation,
    required this.onResolved,
  });

  @override
  State<_ResolveViolationDialog> createState() => _ResolveViolationDialogState();
}

class _ResolveViolationDialogState extends State<_ResolveViolationDialog> {
  final _resolutionController = TextEditingController();
  final _complianceService = ComplianceService();
  bool _isResolving = false;

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('İhlali Çöz: ${widget.violation.title}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: Column(
          children: [
            Text(
              widget.violation.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _resolutionController,
              decoration: const InputDecoration(
                labelText: 'Çözüm Açıklaması',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textAlignVertical: TextAlignVertical.top,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isResolving ? null : _resolveViolation,
          child: _isResolving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Çöz'),
        ),
      ],
    );
  }

  Future<void> _resolveViolation() async {
    if (_resolutionController.text.trim().isEmpty) return;
    
    setState(() => _isResolving = true);
    
    try {
      await _complianceService.resolveComplianceViolation(
        violationId: widget.violation.id,
        resolution: _resolutionController.text.trim(),
        resolvedBy: 'current_user', // TODO: Get actual user ID
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İhlal başarıyla çözüldü'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onResolved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isResolving = false);
    }
  }
}

class _ImplementRecommendationDialog extends StatefulWidget {
  final ComplianceRecommendation recommendation;
  final VoidCallback onImplemented;

  const _ImplementRecommendationDialog({
    required this.recommendation,
    required this.onImplemented,
  });

  @override
  State<_ImplementRecommendationDialog> createState() => _ImplementRecommendationDialogState();
}

class _ImplementRecommendationDialogState extends State<_ImplementRecommendationDialog> {
  final _implementationController = TextEditingController();
  final _complianceService = ComplianceService();
  bool _isImplementing = false;

  @override
  void dispose() {
    _implementationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Öneriyi Uygula: ${widget.recommendation.title}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: Column(
          children: [
            Text(
              widget.recommendation.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _implementationController,
              decoration: const InputDecoration(
                labelText: 'Uygulama Detayları',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textAlignVertical: TextAlignVertical.top,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isImplementing ? null : _implementRecommendation,
          child: _isImplementing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Uygula'),
        ),
      ],
    );
  }

  Future<void> _implementRecommendation() async {
    if (_implementationController.text.trim().isEmpty) return;
    
    setState(() => _isImplementing = true);
    
    try {
      await _complianceService.implementComplianceRecommendation(
        recommendationId: widget.recommendation.id,
        implementation: _implementationController.text.trim(),
        implementedBy: 'current_user', // TODO: Get actual user ID
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öneri başarıyla uygulandı'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onImplemented();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isImplementing = false);
    }
  }
}
