import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/prescription_model.dart';
import '../../widgets/prescription/prescription_form.dart';
import '../../widgets/prescription/ai_recommendation_panel.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<PrescriptionModel> _prescriptionHistory = [];
  String _aiRecommendation = '';
  bool _isGeneratingAI = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    // Demo reçete geçmişi
    setState(() {
      _prescriptionHistory = [
        PrescriptionModel(
          id: '1',
          patientName: 'Ahmet Yılmaz',
          diagnosis: 'Major Depressive Disorder (F32.1)',
          medications: [
            MedicationModel(
              name: 'Escitalopram',
              dosage: '10mg',
              frequency: '1x daily',
              duration: '30 days',
              instructions: 'Sabah yemekle birlikte alın',
            ),
          ],
          interactions: [
            'Serotonin sendromu riski - MAOI ile birlikte kullanmayın'
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          status: 'Active',
        ),
        PrescriptionModel(
          id: '2',
          patientName: 'Fatma Demir',
          diagnosis: 'Generalized Anxiety Disorder (F41.1)',
          medications: [
            MedicationModel(
              name: 'Alprazolam',
              dosage: '0.5mg',
              frequency: '2x daily',
              duration: '14 days',
              instructions: 'Gerektiğinde, maksimum 3x günde',
            ),
          ],
          interactions: [
            'Alkol ile birlikte kullanmayın',
            'Uyku hali yapabilir'
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
          status: 'Completed',
        ),
      ];
    });
  }

  Future<void> _generateAIRecommendation(
      String diagnosis, List<String> currentMeds) async {
    setState(() => _isGeneratingAI = true);

    try {
      // TODO: AI service entegrasyonu
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _aiRecommendation = '''
AI İlaç Önerisi - ${diagnosis}

Önerilen İlaçlar:
1. Escitalopram 10mg (1x daily)
   - Etki: SSRI, depresyon ve anksiyete
   - Başlangıç: 5mg ile başla, 1 hafta sonra 10mg'a çıkar
   - Yan etkiler: Mide bulantısı, uyku bozukluğu

2. Bupropion 150mg (1x daily)
   - Etki: NDRI, enerji ve motivasyon
   - Başlangıç: 150mg sabah
   - Yan etkiler: İştah azalması, uykusuzluk

Etkileşim Kontrolü:
✅ Escitalopram + Bupropion: Güvenli kombinasyon
⚠️ Escitalopram + MAOI: Serotonin sendromu riski
❌ Alprazolam + Alkol: Merkezi sinir sistemi baskılanması

Doz Ayarlama:
- İlk 2 hafta düşük dozla başla
- Yan etkileri takip et
- 4-6 hafta sonra etkinlik değerlendir

Not: Bu öneri AI tarafından oluşturulmuştur. 
Kesin reçete için doktor onayı gerekir.
        '''
            .trim();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI önerisi hatası: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isGeneratingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçete & İlaç Sistemi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: 'Yeni Reçete'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Öneri'),
            Tab(icon: Icon(Icons.history), text: 'Geçmiş'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Yeni Reçete
          PrescriptionForm(
            onPrescriptionCreated: (prescription) {
              setState(() {
                _prescriptionHistory.insert(0, prescription);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Reçete oluşturuldu: ${prescription.patientName}'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
          ),

          // Tab 2: AI Öneri
          AIRecommendationPanel(
            onGenerateRecommendation: _generateAIRecommendation,
            recommendation: _aiRecommendation,
            isGenerating: _isGeneratingAI,
          ),

          // Tab 3: Geçmiş
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _prescriptionHistory.length,
      itemBuilder: (context, index) {
        final prescription = _prescriptionHistory[index];
        return _buildPrescriptionCard(context, prescription);
      },
    );
  }

  Widget _buildPrescriptionCard(
      BuildContext context, PrescriptionModel prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: prescription.status == 'Active'
              ? AppTheme.accentColor
              : Colors.grey,
          child: Icon(
            prescription.status == 'Active'
                ? Icons.medication
                : Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          prescription.patientName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          prescription.diagnosis,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: prescription.status == 'Active'
                ? AppTheme.accentColor.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            prescription.status,
            style: TextStyle(
              color: prescription.status == 'Active'
                  ? AppTheme.accentColor
                  : Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İlaçlar
                Text(
                  'İlaçlar:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ...prescription.medications.map(
                  (med) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medication,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${med.name} ${med.dosage}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${med.frequency} - ${med.duration}'),
                        if (med.instructions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            med.instructions,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Etkileşimler
                if (prescription.interactions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Etkileşimler:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...prescription.interactions.map(
                    (interaction) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: AppTheme.warningColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              interaction,
                              style: TextStyle(
                                color: AppTheme.warningColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Tarih
                const SizedBox(height: 16),
                Text(
                  'Oluşturulma: ${_formatDate(prescription.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),

                // Aksiyonlar
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Reçeteyi düzenle
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Düzenle'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: PDF export
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
