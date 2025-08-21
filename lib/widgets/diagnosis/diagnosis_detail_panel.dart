import 'package:flutter/material.dart';
import '../../models/diagnosis_models.dart' hide Duration;
import '../../utils/theme.dart';

class DiagnosisDetailPanel extends StatefulWidget {
  final MentalDisorder? disorder;
  final DiagnosisResult? aiSuggestion;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DiagnosisDetailPanel({
    super.key,
    this.disorder,
    this.aiSuggestion,
    this.onClose,
    this.onEdit,
    this.onDelete,
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

    if (widget.disorder != null) {
      title = 'DSM-5: ${widget.disorder!.code}';
      subtitle = widget.disorder!.name;
      icon = Icons.psychology;
      color = AppTheme.secondaryColor;
    } else if (widget.aiSuggestion != null) {
      title = 'AI Önerisi';
      subtitle = widget.aiSuggestion!.disorderName;
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
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
              tooltip: 'Kapat',
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
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
        unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
        indicatorColor: AppTheme.primaryColor,
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
          if (widget.disorder != null) ...[
            _buildInfoSection('Tanı Kodu', widget.disorder!.code),
            _buildInfoSection('Tanı Adı', widget.disorder!.name),
            _buildInfoSection('Kategori', widget.disorder!.categoryId),
            _buildInfoSection('Şiddet', widget.disorder!.severity.name),
            
            const SizedBox(height: 24),
            
            _buildSymptomsList('Belirtiler', widget.disorder!.symptoms.map((s) => s.name).toList()),
          ] else if (widget.aiSuggestion != null) ...[
            _buildInfoSection('AI Önerisi', widget.aiSuggestion!.disorderName),
            _buildInfoSection('Tanı Kodu', widget.aiSuggestion!.disorderCode),
            _buildInfoSection('Güven Skoru', '${(widget.aiSuggestion!.confidence * 100).toStringAsFixed(1)}%'),
            
            const SizedBox(height: 24),
          ],
          
          _buildMetadataSection(),
        ],
      ),
    );
  }

  Widget _buildCriteriaTab() {
    if (widget.disorder == null) {
      return const Center(
        child: Text('Kriter bilgisi mevcut değil'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanı Kriterleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...widget.disorder!.criteria.map((criterion) => 
            _buildCriterionCard(criterion)
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentTab() {
    if (widget.disorder == null) {
      return const Center(
        child: Text('Tedavi bilgisi mevcut değil'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tedavi Seçenekleri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...widget.disorder!.treatmentOptions.map((option) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCriterionCard(DiagnosticCriteria criterion) {
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
                    color: _getCriterionTypeColor('required'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Kriter ${criterion.criterionNumber}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  criterion.id,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              criterion.criterion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (criterion.requiredSymptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Gerekli Belirtiler:',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...criterion.requiredSymptoms.map((symptom) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 2),
                child: Text(
                  '• $symptom',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCriterionTypeColor(String category) {
    switch (category) {
      case 'required':
        return Colors.red;
      case 'optional':
        return Colors.orange;
      case 'exclusion':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMetadataSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metadata',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoSection('Son Güncelleme', DateTime.now().toString().split(' ')[0]),
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
          if (widget.onEdit != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Düzenle'),
              ),
            ),
          if (widget.onEdit != null && widget.onDelete != null)
            const SizedBox(width: 12),
          if (widget.onDelete != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Sil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}