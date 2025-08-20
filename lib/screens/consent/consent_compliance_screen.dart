import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/consent_service.dart';
import '../../services/regional_config_service.dart';
import '../../models/consent_models.dart';
import '../../utils/ai_logger.dart';

class ConsentComplianceScreen extends StatefulWidget {
  const ConsentComplianceScreen({super.key});

  @override
  State<ConsentComplianceScreen> createState() => _ConsentComplianceScreenState();
}

class _ConsentComplianceScreenState extends State<ConsentComplianceScreen>
    with TickerProviderStateMixin {
  final AILogger _logger = AILogger();
  
  late TabController _tabController;
  late AnimationController _animationController;
  
  List<ConsentRecord> _consentRecords = [];
  List<ConsentTemplate> _consentTemplates = [];
  ConsentComplianceReport? _complianceReport;
  
  bool _isLoading = false;
  String _selectedRegion = 'TR';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final consentService = Provider.of<ConsentService>(context, listen: false);
      final regionalService = Provider.of<RegionalConfigService>(context, listen: false);
      
      // Load consent data
      _consentRecords = consentService.getConsentsByRegion(_selectedRegion);
      _consentTemplates = consentService.consentTemplates.values
          .where((t) => t.region == _selectedRegion)
          .toList();
      
      // Generate compliance report
      _complianceReport = await consentService.generateComplianceReport(
        region: _selectedRegion,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() => _isLoading = false);
      _animationController.forward();
      
    } catch (e) {
      _logger.error('Failed to load consent data', context: 'ConsentComplianceScreen', error: e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onam & Uyumluluk'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          _buildRegionSelector(),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildComplianceOverview(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildConsentManagementTab(),
                      _buildComplianceTab(),
                      _buildTemplatesTab(),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.manage_accounts), text: 'Onam Yönetimi'),
          Tab(icon: Icon(Icons.verified), text: 'Uyumluluk'),
          Tab(icon: Icon(Icons.description), text: 'Şablonlar'),
        ],
      ),
    );
  }

  Widget _buildRegionSelector() {
    return Consumer<RegionalConfigService>(
      builder: (context, regionalService, child) {
        return PopupMenuButton<String>(
          onSelected: (region) {
            setState(() => _selectedRegion = region);
            _loadData();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'TR', child: Text('Türkiye')),
            const PopupMenuItem(value: 'US', child: Text('Amerika')),
            const PopupMenuItem(value: 'EU', child: Text('Avrupa')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.public, size: 16),
                const SizedBox(width: 4),
                Text(_selectedRegion),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceOverview() {
    if (_complianceReport == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uyumluluk Genel Bakış - ${_getRegionName(_selectedRegion)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComplianceMetricCard(
                  'Toplam Onam',
                  '${_complianceReport!.totalConsents}',
                  Icons.description,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplianceMetricCard(
                  'Aktif Onam',
                  '${_complianceReport!.activeConsents}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplianceMetricCard(
                  'Uyumluluk Oranı',
                  '${(_complianceReport!.complianceRate * 100).toStringAsFixed(1)}%',
                  Icons.verified,
                  _getComplianceColor(_complianceReport!.complianceRate),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComplianceMetricCard(
                  'Durum',
                  _complianceReport!.complianceStatus,
                  Icons.info,
                  _getComplianceColor(_complianceReport!.complianceRate),
                ),
              ),
            ],
          ),
          if (_complianceReport!.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Öneriler:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._complianceReport!.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rec)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildComplianceMetricCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _animationController.value),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _buildConsentManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Onam Kayıtları',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateConsentDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Yeni Onam'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_consentRecords.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Henüz onam kaydı yok')),
              ),
            )
          else
            ..._consentRecords.map((consent) => _buildConsentCard(consent)),
        ],
      ),
    );
  }

  Widget _buildConsentCard(ConsentRecord consent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: consent.isValid ? Colors.green : Colors.red,
          child: Icon(
            consent.isValid ? Icons.check : Icons.warning,
            color: Colors.white,
          ),
        ),
        title: Text('${consent.consentType} - ${consent.patientId}'),
        subtitle: Text('Tarih: ${_formatDate(consent.consentDate)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConsentDetailRow('Durum', consent.isValid ? 'Aktif' : 'Pasif'),
                _buildConsentDetailRow('Bölge', consent.region),
                _buildConsentDetailRow('Yöntem', consent.method.name),
                _buildConsentDetailRow('Kaydeden', consent.recordedBy),
                if (consent.expiryDate != null)
                  _buildConsentDetailRow('Geçerlilik', _formatDate(consent.expiryDate!)),
                if (consent.revokedAt != null) ...[
                  _buildConsentDetailRow('İptal Tarihi', _formatDate(consent.revokedAt!)),
                  _buildConsentDetailRow('İptal Nedeni', consent.revocationReason ?? 'Belirtilmemiş'),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditConsentDialog(consent),
                        icon: const Icon(Icons.edit),
                        label: const Text('Düzenle'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: consent.isValid ? () => _showRevokeConsentDialog(consent) : null,
                        icon: const Icon(Icons.cancel),
                        label: const Text('İptal Et'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uyumluluk Detayları',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDateRangeSelector(),
          const SizedBox(height: 24),
          if (_complianceReport != null) ...[
            _buildComplianceDetails(),
            const SizedBox(height: 24),
            _buildComplianceChart(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarih Aralığı',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Başlangıç',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                        _loadData();
                      }
                    },
                    controller: TextEditingController(
                      text: _startDate != null ? _formatDate(_startDate!) : '',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Bitiş',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                        _loadData();
                      }
                    },
                    controller: TextEditingController(
                      text: _endDate != null ? _formatDate(_endDate!) : '',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detaylı Analiz',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildComplianceDetailRow('Toplam Onam', '${_complianceReport!.totalConsents}'),
            _buildComplianceDetailRow('Aktif Onam', '${_complianceReport!.activeConsents}'),
            _buildComplianceDetailRow('Süresi Dolmuş', '${_complianceReport!.expiredConsents}'),
            _buildComplianceDetailRow('İptal Edilen', '${_complianceReport!.revokedConsents}'),
            _buildComplianceDetailRow('Uyumluluk Oranı', '${(_complianceReport!.complianceRate * 100).toStringAsFixed(1)}%'),
            _buildComplianceDetailRow('Rapor Tarihi', _formatDateTime(_complianceReport!.generatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildComplianceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uyumluluk Dağılımı',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: _buildChartSegment(
                      'Aktif',
                      _complianceReport!.activeConsents,
                      _complianceReport!.totalConsents,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildChartSegment(
                      'Süresi Dolmuş',
                      _complianceReport!.expiredConsents,
                      _complianceReport!.totalConsents,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildChartSegment(
                      'İptal',
                      _complianceReport!.revokedConsents,
                      _complianceReport!.totalConsents,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSegment(String label, int value, int total, Color color) {
    final percentage = total > 0 ? value / total : 0.0;
    
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$label\n$value',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Onam Şablonları',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateTemplateDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Yeni Şablon'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_consentTemplates.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Henüz şablon yok')),
              ),
            )
          else
            ..._consentTemplates.map((template) => _buildTemplateCard(template)),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(ConsentTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: template.isValid ? Colors.green : Colors.grey,
          child: Text(
            template.version.substring(0, 1),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(template.name),
        subtitle: Text('Versiyon: ${template.version}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemplateDetailRow('Bölge', template.region),
                _buildTemplateDetailRow('Hukuki Dayanak', template.legalBasis),
                _buildTemplateDetailRow('Saklama Süresi', template.retentionPeriod),
                _buildTemplateDetailRow('Durum', template.isValid ? 'Aktif' : 'Pasif'),
                const SizedBox(height: 16),
                Text(
                  'İçerik:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(template.content),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditTemplateDialog(template),
                        icon: const Icon(Icons.edit),
                        label: const Text('Düzenle'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showTemplatePreview(template),
                        icon: const Icon(Icons.preview),
                        label: const Text('Önizle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Dialog methods
  void _showCreateConsentDialog() {
    // TODO: Implement consent creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onam oluşturma özelliği geliştirilecek')),
    );
  }

  void _showEditConsentDialog(ConsentRecord consent) {
    // TODO: Implement consent editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onam düzenleme özelliği geliştirilecek')),
    );
  }

  void _showRevokeConsentDialog(ConsentRecord consent) {
    // TODO: Implement consent revocation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onam iptal özelliği geliştirilecek')),
    );
  }

  void _showCreateTemplateDialog() {
    // TODO: Implement template creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şablon oluşturma özelliği geliştirilecek')),
    );
  }

  void _showEditTemplateDialog(ConsentTemplate template) {
    // TODO: Implement template editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şablon düzenleme özelliği geliştirilecek')),
    );
  }

  void _showTemplatePreview(ConsentTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Versiyon: ${template.version}'),
              Text('Bölge: ${template.region}'),
              Text('Hukuki Dayanak: ${template.legalBasis}'),
              Text('Saklama Süresi: ${template.retentionPeriod}'),
              const SizedBox(height: 16),
              const Text('İçerik:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(template.content),
              ),
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

  // Helper methods
  String _getRegionName(String region) {
    switch (region) {
      case 'TR': return 'Türkiye';
      case 'US': return 'Amerika';
      case 'EU': return 'Avrupa';
      default: return region;
    }
  }

  Color _getComplianceColor(double rate) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.8) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
