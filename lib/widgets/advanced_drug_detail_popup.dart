import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/advanced_drug_info.dart';
import '../services/ai_drug_interaction_service.dart';
import '../services/region_service.dart';

class AdvancedDrugDetailPopup extends StatefulWidget {
  final AdvancedDrugInfo drug;
  final List<String> currentDrugs;
  final VoidCallback? onAddToPrescription;

  const AdvancedDrugDetailPopup({
    super.key,
    required this.drug,
    this.currentDrugs = const [],
    this.onAddToPrescription,
  });

  @override
  State<AdvancedDrugDetailPopup> createState() => _AdvancedDrugDetailPopupState();
}

class _AdvancedDrugDetailPopupState extends State<AdvancedDrugDetailPopup>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DrugInteractionAnalysis? _interactionAnalysis;
  List<DrugRecommendation> _recommendations = [];
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _analyzeInteractions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzeInteractions() async {
    if (widget.currentDrugs.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    final interactionService = context.read<AIDrugInteractionService>();
    final analysis = await interactionService.analyzeDrugInteractions(
      [widget.drug.id, ...widget.currentDrugs],
      '35', // Demo yaş
      'Erkek', // Demo cinsiyet
      ['Hipertansiyon'], // Demo durumlar
    );

    setState(() {
      _interactionAnalysis = analysis;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final region = context.watch<RegionService>().currentRegionCode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme, colorScheme),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Genel', icon: Icon(Icons.info)),
                Tab(text: 'İçerik', icon: Icon(Icons.science)),
                Tab(text: 'Dozaj', icon: Icon(Icons.medication)),
                Tab(text: 'Etkileşim', icon: Icon(Icons.warning)),
                Tab(text: 'Öneriler', icon: Icon(Icons.lightbulb)),
                Tab(text: 'Uyarılar', icon: Icon(Icons.error)),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralTab(context, region),
                  _buildContentTab(context),
                  _buildDosageTab(context),
                  _buildInteractionTab(context),
                  _buildRecommendationsTab(context),
                  _buildWarningsTab(context),
                ],
              ),
            ),
            
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // İlaç ikonu
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(widget.drug.category),
              size: 30,
              color: colorScheme.primary,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // İlaç bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.drug.brandName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.drug.genericName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  widget.drug.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          
          // Risk göstergesi
          if (_interactionAnalysis != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRiskColor(_interactionAnalysis!.overallRisk),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRiskText(_interactionAnalysis!.overallRisk),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(BuildContext context, String region) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Temel Bilgiler', [
            _buildInfoRow('ATC Kodu', widget.drug.atcCode),
            _buildInfoRow('Geri Ödeme Kodu', widget.drug.reimbursementCode),
            _buildInfoRow('Hamilelik Kategorisi', widget.drug.pregnancyCategory),
            _buildInfoRow('Emzirme Kategorisi', widget.drug.lactationCategory),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Endikasyon', [
            Text(widget.drug.indication),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Kontrendikasyonlar', [
            ...widget.drug.contraindications.map((contra) => 
              Text('• $contra')).toList(),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Yan Etkiler', [
            ...widget.drug.sideEffects.map((effect) => 
              Text('• $effect')).toList(),
          ]),
        ],
      ),
    );
  }

  Widget _buildContentTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Aktif İçerikler', [
            ...widget.drug.contents.where((c) => c.type == 'active').map((content) =>
              _buildContentRow(content)).toList(),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('İnaktif İçerikler', [
            ...widget.drug.contents.where((c) => c.type == 'inactive').map((content) =>
              _buildContentRow(content)).toList(),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Farmakokinetik', [
            _buildInfoRow('Yarılanma Ömrü', widget.drug.pharmacokinetics['halfLife'] ?? 'Bilinmiyor'),
            _buildInfoRow('Biyoyararlanım', widget.drug.pharmacokinetics['bioavailability'] ?? 'Bilinmiyor'),
            _buildInfoRow('Protein Bağlanması', widget.drug.pharmacokinetics['proteinBinding'] ?? 'Bilinmiyor'),
          ]),
        ],
      ),
    );
  }

  Widget _buildDosageTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.drug.dosages.map((dosage) =>
            _buildDosageCard(dosage)).toList(),
        ],
      ),
    );
  }

  Widget _buildInteractionTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAnalyzing)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Etkileşimler analiz ediliyor...'),
                ],
              ),
            )
          else if (_interactionAnalysis != null) ...[
            _buildInfoSection('Genel Risk', [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getRiskColor(_interactionAnalysis!.overallRisk).withOpacity(0.1),
                  border: Border.all(color: _getRiskColor(_interactionAnalysis!.overallRisk)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Seviyesi: ${_getRiskText(_interactionAnalysis!.overallRisk)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_interactionAnalysis!.recommendation),
                  ],
                ),
              ),
            ]),
            
            const SizedBox(height: 16),
            
            _buildInfoSection('Uyarılar', [
              ..._interactionAnalysis!.warnings.map((warning) =>
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(warning),
                )).toList(),
            ]),
            
            const SizedBox(height: 16),
            
            _buildInfoSection('Detaylı Etkileşimler', [
              ..._interactionAnalysis!.interactions.map((interaction) =>
                _buildInteractionCard(interaction)).toList(),
            ]),
          ] else ...[
            const Center(
              child: Text('Etkileşim analizi için mevcut ilaçlar gerekli'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: _getRecommendations,
            icon: const Icon(Icons.lightbulb),
            label: const Text('AI Önerileri Al'),
          ),
          
          const SizedBox(height: 16),
          
          if (_recommendations.isNotEmpty)
            ..._recommendations.map((rec) => _buildRecommendationCard(rec)).toList()
          else
            const Center(
              child: Text('Öneriler için yukarıdaki butona basın'),
            ),
        ],
      ),
    );
  }

  Widget _buildWarningsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Genel Uyarılar', [
            ...widget.drug.warnings.map((warning) =>
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(warning),
              )).toList(),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Ülke-Özel Uyarılar', [
            if (widget.drug.warningsByCountry[context.watch<RegionService>().currentRegionCode] != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.drug.warningsByCountry[context.watch<RegionService>().currentRegionCode]!),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showFullDetails(context),
              icon: const Icon(Icons.info),
              label: const Text('Detaylar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onAddToPrescription,
              icon: const Icon(Icons.add),
              label: const Text('Reçeteye Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildContentRow(DrugContent content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(content.ingredient),
          ),
          Text('${content.amount} ${content.unit}'),
        ],
      ),
    );
  }

  Widget _buildDosageCard(DrugDosage dosage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dosage.form,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Güçler: ${dosage.strengths.join(', ')}'),
            Text('Sıklık: ${dosage.frequency}'),
            Text('Süre: ${dosage.duration}'),
            Text('Uygulama: ${dosage.administration}'),
            Text('Maksimum günlük doz: ${dosage.maxDailyDose}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionCard(DrugInteraction interaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(interaction.severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interaction.interactionType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Şiddet: ${interaction.severity.toUpperCase()}',
                  style: TextStyle(
                    color: _getSeverityColor(interaction.severity),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(interaction.description),
            const SizedBox(height: 4),
            Text(
              'Mekanizma: ${interaction.mechanism}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            Text(
              'Öneri: ${interaction.recommendation}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(DrugRecommendation rec) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rec.drugId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Güven: ${(rec.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: rec.confidence > 0.8 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(rec.reason),
            const SizedBox(height: 4),
            Text('Alternatif: ${rec.alternative}'),
            Text('Dozaj: ${rec.dosage}'),
            Text('Takip: ${rec.monitoring}'),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'analjezik':
        return Icons.healing;
      case 'antidepresan':
        return Icons.psychology;
      case 'antibiyotik':
        return Icons.biotech;
      case 'antidiyabetik':
        return Icons.bloodtype;
      case 'proton pompa inhibitörü':
        return Icons.medical_services;
      default:
        return Icons.medication;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRiskText(String risk) {
    switch (risk) {
      case 'high':
        return 'YÜKSEK RİSK';
      case 'medium':
        return 'ORTA RİSK';
      case 'low':
        return 'DÜŞÜK RİSK';
      default:
        return 'BİLİNMİYOR';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _getRecommendations() async {
    final interactionService = context.read<AIDrugInteractionService>();
    final recommendations = await interactionService.getDrugRecommendations(
      'Depresyon', // Demo durum
      widget.currentDrugs,
      '35', // Demo yaş
      'Erkek', // Demo cinsiyet
      [], // Demo alerjiler
    );

    setState(() {
      _recommendations = recommendations;
    });
  }

  void _showFullDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.drug.brandName} - Detaylar'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ATC Kodu: ${widget.drug.atcCode}'),
              Text('Geri Ödeme Kodu: ${widget.drug.reimbursementCode}'),
              Text('Hamilelik Kategorisi: ${widget.drug.pregnancyCategory}'),
              Text('Emzirme Kategorisi: ${widget.drug.lactationCategory}'),
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
}
