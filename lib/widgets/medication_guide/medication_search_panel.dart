import 'package:flutter/material.dart';
import '../../models/medication_guide_model.dart';
import '../../utils/theme.dart';

class MedicationSearchPanel extends StatefulWidget {
  final List<MedicationModel> allMedications;
  final List<MedicationModel> searchResults;
  final bool isSearching;
  final Function(MedicationModel) onMedicationSelected;
  final Function(String, List<MedicationModel>) onSearchPerformed;

  const MedicationSearchPanel({
    super.key,
    required this.allMedications,
    required this.searchResults,
    required this.isSearching,
    required this.onMedicationSelected,
    required this.onSearchPerformed,
  });

  @override
  State<MedicationSearchPanel> createState() => _MedicationSearchPanelState();
}

class _MedicationSearchPanelState extends State<MedicationSearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  MedicationCategory? _selectedCategory;
  String _selectedSubcategory = '';
  List<MedicationModel> _filteredMedications = [];
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    _filteredMedications = widget.allMedications;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    final results = widget.allMedications.where((med) {
      // Metin araması
      final matchesText = med.name.toLowerCase().contains(query) ||
          med.genericName.toLowerCase().contains(query) ||
          med.brandNames.any((brand) => brand.toLowerCase().contains(query)) ||
          med.indications
              .any((indication) => indication.toLowerCase().contains(query));

      // Kategori filtresi
      final matchesCategory =
          _selectedCategory == null || med.category == _selectedCategory;

      // Alt kategori filtresi
      final matchesSubcategory = _selectedSubcategory.isEmpty ||
          med.subcategory
              .toLowerCase()
              .contains(_selectedSubcategory.toLowerCase());

      return matchesText && matchesCategory && matchesSubcategory;
    }).toList();

    setState(() {
      _filteredMedications = results;
    });

    widget.onSearchPerformed(query, results);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedSubcategory = '';
      _searchController.clear();
    });
    _performSearch();
  }

  List<String> _getSubcategories(MedicationCategory? category) {
    if (category == null) return [];

    final subcategories = widget.allMedications
        .where((med) => med.category == category)
        .map((med) => med.subcategory)
        .toSet()
        .toList();

    subcategories.sort();
    return subcategories;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arama çubuğu
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Ana arama çubuğu
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'İlaç adı, etken madde veya endikasyon ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchFocusNode.requestFocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.accentColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gelişmiş filtreler toggle
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAdvancedFilters = !_showAdvancedFilters;
                      });
                    },
                    icon: Icon(_showAdvancedFilters
                        ? Icons.expand_less
                        : Icons.expand_more),
                    label: Text(_showAdvancedFilters
                        ? 'Filtreleri Gizle'
                        : 'Gelişmiş Filtreler'),
                  ),
                  const Spacer(),
                  if (_selectedCategory != null ||
                      _selectedSubcategory.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Filtreleri Temizle'),
                    ),
                ],
              ),

              // Gelişmiş filtreler
              if (_showAdvancedFilters) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Kategori filtresi
                    Expanded(
                      child: DropdownButtonFormField<MedicationCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'İlaç Kategorisi',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tüm Kategoriler'),
                          ),
                          ...MedicationCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(category),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_getCategoryName(category)),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _selectedSubcategory = '';
                          });
                          _performSearch();
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Alt kategori filtresi
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubcategory.isEmpty
                            ? null
                            : _selectedSubcategory,
                        decoration: const InputDecoration(
                          labelText: 'Alt Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tüm Alt Kategoriler'),
                          ),
                          ..._getSubcategories(_selectedCategory)
                              .map((subcategory) {
                            return DropdownMenuItem(
                              value: subcategory,
                              child: Text(subcategory),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSubcategory = value ?? '';
                          });
                          _performSearch();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Arama sonuçları
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (widget.isSearching && _searchController.text.isEmpty) {
      return const Center(
        child: Text('Arama yapmak için bir terim girin'),
      );
    }

    if (_filteredMedications.isEmpty) {
      return Center(
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
              'Arama kriterlerinize uygun ilaç bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Farklı anahtar kelimeler deneyin veya filtreleri değiştirin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredMedications.length,
      itemBuilder: (context, index) {
        final medication = _filteredMedications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(MedicationModel medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => widget.onMedicationSelected(medication),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İlaç adı ve kategori
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication.genericName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: medication.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: medication.categoryColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      medication.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: medication.categoryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Alt kategori
              if (medication.subcategory.isNotEmpty) ...[
                Text(
                  'Alt Kategori: ${medication.subcategory}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Endikasyonlar
              if (medication.indications.isNotEmpty) ...[
                Text(
                  'Endikasyonlar:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: medication.indications.take(3).map((indication) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        indication,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (medication.indications.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${medication.indications.length - 3} daha...',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],

              // Dozaj ve uyarılar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dozaj: ${medication.dosage}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uygulama: ${medication.administration}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Gebelik ve emzirme kategorileri
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: medication.pregnancyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: medication.pregnancyColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Gebelik: ${medication.pregnancyCategory}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: medication.pregnancyColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: medication.lactationColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: medication.lactationColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Emzirme: ${medication.lactationCategory}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: medication.lactationColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Onay durumları
              Row(
                children: [
                  Text(
                    'Onay Durumu:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...medication.approvalStatus.entries.take(3).map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: medication
                            .getApprovalStatusColor(entry.key)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: medication.getApprovalStatusColor(entry.key),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: medication.getApprovalStatusColor(entry.key),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.antidepressant:
        return Colors.blue;
      case MedicationCategory.anxiolytic:
        return Colors.green;
      case MedicationCategory.antipsychotic:
        return Colors.red;
      case MedicationCategory.moodStabilizer:
        return Colors.orange;
      case MedicationCategory.stimulant:
        return Colors.purple;
      case MedicationCategory.hypnotic:
        return Colors.indigo;
      case MedicationCategory.anticonvulsant:
        return Colors.teal;
      case MedicationCategory.antianxiety:
        return Colors.lightGreen;
      case MedicationCategory.antimanic:
        return Colors.deepOrange;
      case MedicationCategory.anticholinergic:
        return Colors.brown;
      case MedicationCategory.antihistamine:
        return Colors.cyan;
      case MedicationCategory.betaBlocker:
        return Colors.amber;
      case MedicationCategory.calciumChannelBlocker:
        return Colors.lime;
      case MedicationCategory.aceInhibitor:
        return Colors.pink;
      case MedicationCategory.angiotensinReceptorBlocker:
        return Colors.deepPurple;
      case MedicationCategory.diuretic:
        return Colors.lightBlue;
      case MedicationCategory.statin:
        return Colors.redAccent;
      case MedicationCategory.antiplatelet:
        return Colors.orangeAccent;
      case MedicationCategory.anticoagulant:
        return Colors.red.shade300;
      case MedicationCategory.nsaid:
        return Colors.blueGrey;
      case MedicationCategory.opioid:
        return Colors.deepPurpleAccent;
      case MedicationCategory.muscleRelaxant:
        return Colors.lightGreenAccent;
      case MedicationCategory.antiepileptic:
        return Colors.tealAccent;
      case MedicationCategory.antiparkinsonian:
        return Colors.yellow;
      case MedicationCategory.antialzheimer:
        return Colors.blueAccent;
      case MedicationCategory.antimigraine:
        return Colors.purpleAccent;
      case MedicationCategory.antinausea:
        return Colors.greenAccent;
      case MedicationCategory.antidiabetic:
        return Colors.orange.shade300;
      case MedicationCategory.thyroid:
        return Colors.yellowAccent;
      case MedicationCategory.corticosteroid:
        return Colors.red.shade200;
      case MedicationCategory.immunosuppressant:
        return Colors.indigo;
      case MedicationCategory.antiviral:
        return Colors.purple.shade300;
      case MedicationCategory.antibacterial:
        return Colors.blue.shade300;
      case MedicationCategory.antifungal:
        return Colors.green.shade300;
      case MedicationCategory.other:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.antidepressant:
        return 'Antidepresan';
      case MedicationCategory.anxiolytic:
        return 'Anksiyolitik';
      case MedicationCategory.antipsychotic:
        return 'Antipsikotik';
      case MedicationCategory.moodStabilizer:
        return 'Duygu Durum Dengeleyici';
      case MedicationCategory.stimulant:
        return 'Uyarıcı';
      case MedicationCategory.hypnotic:
        return 'Hipnotik';
      case MedicationCategory.anticonvulsant:
        return 'Antikonvülsan';
      case MedicationCategory.antianxiety:
        return 'Antianksiyete';
      case MedicationCategory.antimanic:
        return 'Antimanik';
      case MedicationCategory.anticholinergic:
        return 'Antikolinerjik';
      case MedicationCategory.antihistamine:
        return 'Antihistaminik';
      case MedicationCategory.betaBlocker:
        return 'Beta Bloker';
      case MedicationCategory.calciumChannelBlocker:
        return 'Kalsiyum Kanal Blokeri';
      case MedicationCategory.aceInhibitor:
        return 'ACE İnhibitörü';
      case MedicationCategory.angiotensinReceptorBlocker:
        return 'Anjiyotensin Reseptör Blokeri';
      case MedicationCategory.diuretic:
        return 'Diüretik';
      case MedicationCategory.statin:
        return 'Statin';
      case MedicationCategory.antiplatelet:
        return 'Antitrombosit';
      case MedicationCategory.anticoagulant:
        return 'Antikoagülan';
      case MedicationCategory.nsaid:
        return 'NSAID';
      case MedicationCategory.opioid:
        return 'Opioid';
      case MedicationCategory.muscleRelaxant:
        return 'Kas Gevşetici';
      case MedicationCategory.antiepileptic:
        return 'Antiepileptik';
      case MedicationCategory.antiparkinsonian:
        return 'Antiparkinsonian';
      case MedicationCategory.antialzheimer:
        return 'Antialzheimer';
      case MedicationCategory.antimigraine:
        return 'Antimigren';
      case MedicationCategory.antinausea:
        return 'Antinausea';
      case MedicationCategory.antidiabetic:
        return 'Antidiabetik';
      case MedicationCategory.thyroid:
        return 'Tiroid';
      case MedicationCategory.corticosteroid:
        return 'Kortikosteroid';
      case MedicationCategory.immunosuppressant:
        return 'İmmünosupressan';
      case MedicationCategory.antiviral:
        return 'Antiviral';
      case MedicationCategory.antibacterial:
        return 'Antibakteriyel';
      case MedicationCategory.antifungal:
        return 'Antifungal';
      case MedicationCategory.other:
        return 'Diğer';
      default:
        return 'Diğer';
    }
  }
}
