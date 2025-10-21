import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/drug_database_service.dart';
import '../../services/drug_image_recognition_service.dart';
import '../../services/region_service.dart';
import '../../widgets/drug_detail_popup.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DrugImageRecognitionService _recognitionService = DrugImageRecognitionService();
  
  List<DrugInfo> _searchResults = [];
  String _selectedCategory = 'Tümü';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDrugs();
  }

  void _loadDrugs() {
    final drugService = context.read<DrugDatabaseService>();
    _searchResults = drugService.currentCountryDrugs;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      _loadDrugs();
      return;
    }

    final drugService = context.read<DrugDatabaseService>();
    _searchResults = drugService.searchDrugs(query);
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });

    final drugService = context.read<DrugDatabaseService>();
    if (category == 'Tümü') {
      _searchResults = drugService.currentCountryDrugs;
    } else {
      _searchResults = drugService.getDrugsByCategory(category);
    }
  }

  Future<void> _captureDrugImage() async {
    final result = await _recognitionService.captureAndRecognizeDrug();
    if (result != null && mounted) {
      _showRecognitionResult(result);
    }
  }

  Future<void> _selectDrugImage() async {
    final result = await _recognitionService.selectAndRecognizeDrug();
    if (result != null && mounted) {
      _showRecognitionResult(result);
    }
  }

  void _showRecognitionResult(DrugRecognitionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 İlaç Tanıma Sonucu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.drugName != null)
              Text('İlaç Adı: ${result.drugName}'),
            if (result.dosage != null)
              Text('Dozaj: ${result.dosage}'),
            if (result.manufacturer != null)
              Text('Üretici: ${result.manufacturer}'),
            Text('Güven Skoru: ${(result.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Tanınan Metinler:', style: Theme.of(context).textTheme.titleSmall),
            ...result.recognizedTexts.take(5).map((text) => Text('• $text')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (result.matchedDrug != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showDrugDetail(result.matchedDrug!);
              },
              child: const Text('Detayları Gör'),
            ),
        ],
      ),
    );
  }

  void _showDrugDetail(DrugInfo drug) {
    showDialog(
      context: context,
      builder: (context) => DrugDetailPopup(
        drug: drug,
        onAddToPrescription: () {
          Navigator.pop(context);
          _addDrugToPrescription(drug);
        },
      ),
    );
  }

  void _addDrugToPrescription(DrugInfo drug) {
    // Reçeteye ilaç ekleme işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${drug.brandName} reçeteye eklendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final region = context.watch<RegionService>().currentRegionCode;
    final drugService = context.watch<DrugDatabaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçete Yönetimi'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Kamera ile Tanıma',
            icon: const Icon(Icons.camera_alt),
            onPressed: _captureDrugImage,
          ),
          IconButton(
            tooltip: 'Galeri\'den Seç',
            icon: const Icon(Icons.photo_library),
            onPressed: _selectDrugImage,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.public),
            tooltip: 'Ülke Seçimi',
            onSelected: (country) {
              drugService.setCountry(country);
              _loadDrugs();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'TR',
                child: Text('🇹🇷 Türkiye'),
              ),
              const PopupMenuItem(
                value: 'US',
                child: Text('🇺🇸 Amerika'),
              ),
              const PopupMenuItem(
                value: 'EU',
                child: Text('🇪🇺 Avrupa'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Ülke bilgisi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.public, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Aktif Ülke: $region',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${drugService.currentCountryDrugs.length} ilaç',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Arama ve filtre
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Arama çubuğu
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'İlaç adı, etken madde veya kategori ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Kategori filtreleri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Tümü'),
                      const SizedBox(width: 8),
                      ...drugService.categories.map((category) => 
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(category),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // İlaç listesi
          Expanded(
            child: _recognitionService.isProcessing
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('İlaç tanınıyor...'),
                      ],
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'İlaç bulunamadı',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Farklı anahtar kelimeler deneyin',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final drug = _searchResults[index];
                          return DrugCard(
                            drug: drug,
                            onTap: () => _showDrugDetail(drug),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _onCategoryChanged(category);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}