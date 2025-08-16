import 'package:flutter/material.dart';
import '../../models/diagnosis_models.dart';
import '../../utils/theme.dart';

class DiagnosisDetailPanel extends StatefulWidget {
  final ICD11Diagnosis? icd11Diagnosis;
  final DSM5Diagnosis? dsm5Diagnosis;
  final AIDiagnosisSuggestion? aiSuggestion;
  final VoidCallback? onClose;
  final Function(ICD11Diagnosis)? onSaveICD11;
  final Function(DSM5Diagnosis)? onSaveDSM5;
  final Function(AIDiagnosisSuggestion)? onSaveAI;

  const DiagnosisDetailPanel({
    super.key,
    this.icd11Diagnosis,
    this.dsm5Diagnosis,
    this.aiSuggestion,
    this.onClose,
    this.onSaveICD11,
    this.onSaveDSM5,
    this.onSaveAI,
  });

  @override
  State<DiagnosisDetailPanel> createState() => _DiagnosisDetailPanelState();
}

class _DiagnosisDetailPanelState extends State<DiagnosisDetailPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Tab Content
            Expanded(child: _buildTabContent()),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Tanı Detayları';
    String subtitle = 'Detaylı bilgi ve öneriler';
    IconData icon = Icons.medical_services;
    Color color = AppTheme.primaryColor;

    if (widget.icd11Diagnosis != null) {
      title = 'ICD-11: ${widget.icd11Diagnosis!.code}';
      subtitle = widget.icd11Diagnosis!.title;
      icon = Icons.medical_services;
      color = AppTheme.primaryColor;
    } else if (widget.dsm5Diagnosis != null) {
      title = 'DSM-5: ${widget.dsm5Diagnosis!.code}';
      subtitle = widget.dsm5Diagnosis!.title;
      icon = Icons.psychology;
      color = AppTheme.secondaryColor;
    } else if (widget.aiSuggestion != null) {
      title = 'AI Önerisi';
      subtitle = widget.aiSuggestion!.suggestedDiagnosis;
      icon = Icons.auto_awesome;
      color = AppTheme.accentColor;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: Colors.grey[600],
            ),
            tooltip: 'Kapat',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Genel'),
          Tab(text: 'Kriterler'),
          Tab(text: 'Tedavi'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGeneralTab(),
        _buildCriteriaTab(),
        _buildTreatmentTab(),
      ],
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.icd11Diagnosis != null) ...[
            _buildInfoSection('Kod', widget.icd11Diagnosis!.code, Icons.tag),
            _buildInfoSection('Başlık', widget.icd11Diagnosis!.title, Icons.title),
            _buildInfoSection('Açıklama', widget.icd11Diagnosis!.description, Icons.description),
            _buildInfoSection('Kategori', widget.icd11Diagnosis!.category, Icons.category),
            _buildInfoSection('Alt Kategori', widget.icd11Diagnosis!.subcategory, Icons.subdirectory_arrow_right),
            _buildInfoSection('Şiddet', widget.icd11Diagnosis!.severity, Icons.trending_up),
            _buildInfoSection('Kronisite', widget.icd11Diagnosis!.chronicity, Icons.schedule),
            if (widget.icd11Diagnosis!.symptoms.isNotEmpty)
              _buildListSection('Belirtiler', widget.icd11Diagnosis!.symptoms, Icons.medical_services),
            if (widget.icd11Diagnosis!.riskFactors.isNotEmpty)
              _buildListSection('Risk Faktörleri', widget.icd11Diagnosis!.riskFactors, Icons.warning),
            if (widget.icd11Diagnosis!.complications.isNotEmpty)
              _buildListSection('Komplikasyonlar', widget.icd11Diagnosis!.complications, Icons.error),
          ] else if (widget.dsm5Diagnosis != null) ...[
            _buildInfoSection('Kod', widget.dsm5Diagnosis!.code, Icons.tag),
            _buildInfoSection('Başlık', widget.dsm5Diagnosis!.title, Icons.title),
            _buildInfoSection('Açıklama', widget.dsm5Diagnosis!.description, Icons.description),
                          _buildInfoSection('Kategori', widget.dsm5Diagnosis!.title, Icons.category),
              _buildInfoSection('Alt Kategori', widget.dsm5Diagnosis!.code, Icons.subdirectory_arrow_right),
            _buildInfoSection('Şiddet', widget.dsm5Diagnosis!.severity, Icons.trending_up),
            _buildInfoSection('Kronisite', widget.dsm5Diagnosis!.chronicity, Icons.schedule),
            if (widget.dsm5Diagnosis!.symptoms.isNotEmpty)
              _buildListSection('Belirtiler', widget.dsm5Diagnosis!.symptoms, Icons.medical_services),
            if (widget.dsm5Diagnosis!.riskFactors.isNotEmpty)
              _buildListSection('Risk Faktörleri', widget.dsm5Diagnosis!.riskFactors, Icons.warning),
            if (widget.dsm5Diagnosis!.comorbidities.isNotEmpty)
              _buildListSection('Komorbiditeler', widget.dsm5Diagnosis!.comorbidities, Icons.merge_type),
          ] else if (widget.aiSuggestion != null) ...[
            _buildInfoSection('Önerilen Tanı', widget.aiSuggestion!.suggestedDiagnosis, Icons.auto_awesome),
            _buildInfoSection('Kod', widget.aiSuggestion!.diagnosisCode, Icons.tag),
            _buildInfoSection('Sistem', widget.aiSuggestion!.classificationSystem, Icons.system_update),
            _buildInfoSection('Güven', '${(widget.aiSuggestion!.confidence * 100).round()}%', Icons.verified),
            _buildInfoSection('Gerekçe', widget.aiSuggestion!.reasoning, Icons.psychology),
            if (widget.aiSuggestion!.supportingSymptoms.isNotEmpty)
              _buildListSection('Destekleyen Belirtiler', widget.aiSuggestion!.supportingSymptoms, Icons.check_circle),
            if (widget.aiSuggestion!.differentialDiagnoses.isNotEmpty)
              _buildListSection('Ayırıcı Tanılar', widget.aiSuggestion!.differentialDiagnoses, Icons.compare_arrows),
            if (widget.aiSuggestion!.recommendedAssessments.isNotEmpty)
              _buildListSection('Önerilen Değerlendirmeler', widget.aiSuggestion!.recommendedAssessments, Icons.assessment),
          ],
          
          const SizedBox(height: 20),
          
          // Metadata
          _buildMetadataSection(),
        ],
      ),
    );
  }

  Widget _buildCriteriaTab() {
    if (widget.dsm5Diagnosis != null && widget.dsm5Diagnosis!.criteria.isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DSM-5 Tanı Kriterleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.dsm5Diagnosis!.criteria.map((criterion) => _buildCriterionCard(criterion)),
          ],
        ),
      );
    } else if (widget.icd11Diagnosis != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ICD-11 Kriterleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.icd11Diagnosis!.inclusionCriteria.isNotEmpty) ...[
              _buildListSection('Dahil Etme Kriterleri', widget.icd11Diagnosis!.inclusionCriteria, Icons.check_circle),
              const SizedBox(height: 16),
            ],
            if (widget.icd11Diagnosis!.exclusionCriteria.isNotEmpty) ...[
              _buildListSection('Hariç Tutma Kriterleri', widget.icd11Diagnosis!.exclusionCriteria, Icons.cancel),
              const SizedBox(height: 16),
            ],
            if (widget.icd11Diagnosis!.relatedConditions.isNotEmpty) ...[
              _buildListSection('İlgili Durumlar', widget.icd11Diagnosis!.relatedConditions, Icons.link),
            ],
          ],
        ),
      );
    } else {
      return const Center(
        child: Text('Bu tanı için kriter bilgisi bulunmuyor'),
      );
    }
  }

  Widget _buildTreatmentTab() {
    List<String> treatments = [];
    List<String> medications = [];
    List<String> therapies = [];

    if (widget.icd11Diagnosis != null) {
      treatments = widget.icd11Diagnosis!.treatmentOptions;
      medications = widget.icd11Diagnosis!.medications;
      therapies = widget.icd11Diagnosis!.therapies;
    } else if (widget.dsm5Diagnosis != null) {
      treatments = widget.dsm5Diagnosis!.treatmentOptions;
      medications = widget.dsm5Diagnosis!.medications;
      therapies = widget.dsm5Diagnosis!.therapies;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (treatments.isNotEmpty) ...[
            _buildListSection('Tedavi Seçenekleri', treatments, Icons.healing),
            const SizedBox(height: 16),
          ],
          if (medications.isNotEmpty) ...[
            _buildListSection('İlaçlar', medications, Icons.medication),
            const SizedBox(height: 16),
          ],
          if (therapies.isNotEmpty) ...[
            _buildListSection('Terapiler', therapies, Icons.psychology),
            const SizedBox(height: 16),
          ],
          if (treatments.isEmpty && medications.isEmpty && therapies.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tedavi bilgisi bulunmuyor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu tanı için henüz tedavi önerileri eklenmemiş',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String label, List<String> items, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionCard(DSM5Criterion criterion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    criterion.code,
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCriterionTypeColor(criterion.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    criterion.type,
                    style: TextStyle(
                      color: _getCriterionTypeColor(criterion.type),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              criterion.description,
              style: const TextStyle(fontSize: 14),
            ),
            if (criterion.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Örnekler:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ...criterion.examples.map((example) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '• $example',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCriterionTypeColor(String type) {
    switch (type) {
      case 'required':
        return AppTheme.primaryColor;
      case 'optional':
        return AppTheme.secondaryColor;
      case 'exclusion':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMetadataSection() {
    DateTime? lastUpdated;
    String? source = 'Unknown';

    if (widget.icd11Diagnosis != null) {
      lastUpdated = widget.icd11Diagnosis!.lastUpdated;
      source = 'ICD-11';
    } else if (widget.dsm5Diagnosis != null) {
      lastUpdated = widget.dsm5Diagnosis!.lastUpdated;
      source = 'DSM-5';
    } else if (widget.aiSuggestion != null) {
      lastUpdated = widget.aiSuggestion!.generatedAt;
      source = 'AI Generated';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meta Bilgiler',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.source, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Kaynak: $source',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.update, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Güncellenme: ${_formatDate(lastUpdated)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onClose,
              child: const Text('Kapat'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (widget.icd11Diagnosis != null && widget.onSaveICD11 != null) {
      widget.onSaveICD11!(widget.icd11Diagnosis!);
    } else if (widget.dsm5Diagnosis != null && widget.onSaveDSM5 != null) {
      widget.onSaveDSM5!(widget.dsm5Diagnosis!);
    } else if (widget.aiSuggestion != null && widget.onSaveAI != null) {
      widget.onSaveAI!(widget.aiSuggestion!);
    }
    
    widget.onClose?.call();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
