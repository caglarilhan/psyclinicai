import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/diagnosis/diagnosis_search_bar.dart';
import '../../widgets/diagnosis/diagnosis_results.dart';
import '../../widgets/diagnosis/ai_diagnosis_panel.dart';
import '../../models/diagnosis_model.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCountry = AppConstants.targetCountries.first;
  List<DiagnosisModel> _searchResults = [];
  bool _isSearching = false;
  String _aiSuggestion = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Demo veriler
    setState(() {
      _searchResults = _getDemoDiagnoses();
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isSearching = true);

    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simülasyon

      // AI destekli arama
      final results = _searchDiagnoses(query, _selectedCountry);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama hatası: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  List<DiagnosisModel> _searchDiagnoses(String query, String country) {
    final standard = AppConstants.diagnosisStandards[country] ?? 'ICD-10';
    final allDiagnoses = _getAllDiagnoses(standard);

    return allDiagnoses.where((diagnosis) {
      return diagnosis.code.toLowerCase().contains(query.toLowerCase()) ||
          diagnosis.name.toLowerCase().contains(query.toLowerCase()) ||
          diagnosis.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<DiagnosisModel> _getAllDiagnoses(String standard) {
    if (standard.contains('DSM')) {
      return _getDSMDiagnoses();
    } else {
      return _getICDDiagnoses();
    }
  }

  List<DiagnosisModel> _getDSMDiagnoses() {
    return [
      DiagnosisModel(
        code: '296.32',
        name: 'Major Depressive Disorder, Moderate',
        description: 'Depresif duygudurum, ilgi kaybı, kilo değişikliği',
        category: 'Mood Disorders',
        severity: 'Moderate',
        standard: 'DSM-5-TR',
        symptoms: ['Üzgün duygudurum', 'İlgi kaybı', 'Uyku bozukluğu'],
        treatments: ['CBT', 'SSRI', 'Psikoterapi'],
      ),
      DiagnosisModel(
        code: '300.02',
        name: 'Generalized Anxiety Disorder',
        description: 'Sürekli endişe, huzursuzluk, konsantrasyon güçlüğü',
        category: 'Anxiety Disorders',
        severity: 'Mild to Moderate',
        standard: 'DSM-5-TR',
        symptoms: ['Aşırı endişe', 'Huzursuzluk', 'Yorgunluk'],
        treatments: ['CBT', 'Benzodiazepin', 'Relaksasyon'],
      ),
      DiagnosisModel(
        code: '309.81',
        name: 'Posttraumatic Stress Disorder',
        description: 'Travma sonrası stres bozukluğu, flashback\'ler',
        category: 'Trauma and Stressor-Related Disorders',
        severity: 'Severe',
        standard: 'DSM-5-TR',
        symptoms: ['Flashback\'ler', 'Kaçınma', 'Hipervijilans'],
        treatments: ['EMDR', 'Prolonged Exposure', 'SSRI'],
      ),
    ];
  }

  List<DiagnosisModel> _getICDDiagnoses() {
    return [
      DiagnosisModel(
        code: 'F32.1',
        name: 'Moderate depressive episode',
        description: 'Orta şiddette depresif dönem',
        category: 'Mood Disorders',
        severity: 'Moderate',
        standard: 'ICD-11',
        symptoms: [
          'Depresif duygudurum',
          'Enerji kaybı',
          'Konsantrasyon güçlüğü'
        ],
        treatments: ['CBT', 'Antidepresan', 'Psikoterapi'],
      ),
      DiagnosisModel(
        code: 'F41.1',
        name: 'Generalized anxiety disorder',
        description: 'Yaygın anksiyete bozukluğu',
        category: 'Anxiety Disorders',
        severity: 'Mild to Moderate',
        standard: 'ICD-11',
        symptoms: ['Sürekli endişe', 'Huzursuzluk', 'Uyku bozukluğu'],
        treatments: ['CBT', 'Anksiyolitik', 'Relaksasyon'],
      ),
      DiagnosisModel(
        code: 'F43.1',
        name: 'Post-traumatic stress disorder',
        description: 'Travma sonrası stres bozukluğu',
        category: 'Trauma and Stressor-Related Disorders',
        severity: 'Severe',
        standard: 'ICD-11',
        symptoms: [
          'Travma hatıraları',
          'Kaçınma davranışları',
          'Aşırı uyarılma'
        ],
        treatments: ['EMDR', 'Maruz bırakma', 'Antidepresan'],
      ),
    ];
  }

  List<DiagnosisModel> _getDemoDiagnoses() {
    return _getDSMDiagnoses() + _getICDDiagnoses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanı Arama Sistemi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Arama'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Öneri'),
            Tab(icon: Icon(Icons.history), text: 'Geçmiş'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Tanı Arama
          _buildSearchTab(),

          // Tab 2: AI Öneri
          _buildAIRecommendationTab(),

          // Tab 3: Geçmiş
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Üst panel - Ülke seçimi ve arama
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Ülke seçimi
              Row(
                children: [
                  Icon(
                    Icons.public,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tanı Standardı:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      '${_selectedCountry} (${AppConstants.diagnosisStandards[_selectedCountry]})',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showCountrySelectionDialog(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Değiştir'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Arama çubuğu
              DiagnosisSearchBar(
                controller: _searchController,
                onSearch: _performSearch,
                isSearching: _isSearching,
                placeholder: 'ICD/DSM kodu veya tanı adı ile arayın...',
              ),
            ],
          ),
        ),

        // Arama sonuçları
        Expanded(
          child: DiagnosisResults(
            results: _searchResults,
            isSearching: _isSearching,
            onDiagnosisSelected: (diagnosis) {
              _showDiagnosisDetail(context, diagnosis);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIRecommendationTab() {
    return AIDiagnosisPanel(
      onGenerateRecommendation: _generateAIRecommendation,
      suggestion: _aiSuggestion,
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Arama Geçmişi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yakında arama geçmişiniz burada görünecek',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _generateAIRecommendation(String symptoms) async {
    // TODO: AI service entegrasyonu
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _aiSuggestion = '''
Önerilen Tanı: Major Depressive Disorder (F32.1)

Güven Skoru: 85%

Belirtiler Eşleşmesi:
✅ Üzgün duygudurum (100%)
✅ İlgi kaybı (90%)
✅ Uyku bozukluğu (85%)
✅ Enerji kaybı (80%)

Önerilen Müdahale:
1. CBT (Bilişsel Davranışçı Terapi)
2. SSRI (Selektif Serotonin Geri Alım İnhibitörü)
3. Psikoeğitim
4. Sosyal destek grupları

Not: Bu öneri AI tarafından oluşturulmuştur. 
Kesin tanı için klinik değerlendirme gerekir.
        '''
          .trim();
    });
  }

  void _showCountrySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tanı Standardı Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.targetCountries.map((country) {
            final standard = AppConstants.diagnosisStandards[country];
            return RadioListTile<String>(
              title: Text(country),
              subtitle: Text(standard ?? 'Bilinmiyor'),
              value: country,
              groupValue: _selectedCountry,
              onChanged: (value) {
                setState(() => _selectedCountry = value!);
                Navigator.pop(context);
                _performSearch(_searchController.text);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDiagnosisDetail(BuildContext context, DiagnosisModel diagnosis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(diagnosis.name),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                diagnosis.code,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                diagnosis.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildDetailSection('Kategori', diagnosis.category),
              _buildDetailSection('Şiddet', diagnosis.severity),
              _buildDetailSection('Standard', diagnosis.standard),
              const SizedBox(height: 16),
              Text(
                'Belirtiler:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...diagnosis.symptoms.map(
                (symptom) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: AppTheme.accentColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(symptom)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tedaviler:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...diagnosis.treatments.map(
                (treatment) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services,
                          size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(treatment)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Tanıyı seans notuna ekle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${diagnosis.name} seans notuna eklendi'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
            child: const Text('Seans Notuna Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
