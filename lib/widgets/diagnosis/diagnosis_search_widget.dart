import 'package:flutter/material.dart';
import '../../models/diagnosis_models.dart';
import '../../services/diagnosis_service.dart';
import '../../utils/theme.dart';

class DiagnosisSearchWidget extends StatefulWidget {
  final String language;
  final Function(MentalDisorder)? onDiagnosisSelected;
  final Function(DiagnosisSuggestion)? onAISelected;

  const DiagnosisSearchWidget({
    super.key,
    this.language = 'tr',
    this.onDiagnosisSelected,
    this.onAISelected,
  });

  @override
  State<DiagnosisSearchWidget> createState() => _DiagnosisSearchWidgetState();
}

class _DiagnosisSearchWidgetState extends State<DiagnosisSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final DiagnosisService _diagnosisService = DiagnosisService();
  
  List<MentalDisorder> _searchResults = [];
  List<DiagnosisSuggestion> _aiSuggestions = [];
  bool _isSearching = false;
  String? _error;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _diagnosisService.getCategories();
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories.first.id;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tanı ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSearching ? null : _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Ara'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Category Filter
        Container(
          height: 50,
          child: FutureBuilder<List<DiagnosticCategory>>(
            future: _diagnosisService.getCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoryChip('Tümü', 'all', _selectedCategory == 'all');
                  }
                  final category = categories[index - 1];
                  return _buildCategoryChip(
                    category.name,
                    category.id,
                    _selectedCategory == category.id,
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Error Display
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),

        // Search Results
        if (_searchResults.isNotEmpty || _aiSuggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                // AI Suggestions
                if (_aiSuggestions.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'AI Önerileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._aiSuggestions.map((suggestion) => _buildAIResult(suggestion)),
                  const SizedBox(height: 16),
                ],

                // Manual Search Results
                if (_searchResults.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Arama Sonuçları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._searchResults.map((disorder) => _buildDiagnosisResult(disorder)),
                ],
              ],
            ),
          ),
        ],

        // Empty State
        if (_searchResults.isEmpty && _aiSuggestions.isEmpty && !_isSearching && _error == null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tanı aramaya başlayın',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belirtileri yazın veya tanı adını arayın',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String value, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = value;
          });
          if (selected) {
            _performSearch();
          }
        },
        selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.accentColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.accentColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDiagnosisResult(MentalDisorder disorder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onDiagnosisSelected?.call(disorder),
        borderRadius: BorderRadius.circular(8),
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
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      disorder.code,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      disorder.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
              if (disorder.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  disorder.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIResult(DiagnosisSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onAISelected?.call(suggestion),
        borderRadius: BorderRadius.circular(8),
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
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppTheme.accentColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(suggestion.confidence * 100).round()}%',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.diagnosis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'AI analizi - ${suggestion.evidence.length} kanıt bulundu',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (suggestion.evidence.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: suggestion.evidence.take(3).map((evidence) => Chip(
                    label: Text(
                      evidence,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: AppTheme.accentColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppTheme.accentColor),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      // Search for disorders
      final disorders = await _diagnosisService.searchDisorders(query: query);
      
      // Generate AI diagnosis if we have symptoms
      List<DiagnosisSuggestion> aiResults = [];
      if (query.length > 10) { // Only generate AI suggestions for longer queries
        try {
          // Create mock symptom assessments for AI diagnosis
          final mockSymptoms = [
            SymptomAssessment(
              id: 'mock_symptom_1',
              patientId: 'mock_patient_001',
              clinicianId: 'mock_clinician_001',
              symptomId: 'symptom_1',
              symptomName: 'Depressed mood',
              severity: SymptomSeverity.moderate,
              duration: TreatmentDuration.chronic,
              frequency: Frequency.continuous,
              triggers: ['stress'],
              alleviators: ['exercise'],
              impact: 'Moderate impact on daily functioning',
            ),
          ];

          final aiDiagnosis = await _diagnosisService.generateAIDiagnosis(
            patientId: 'mock_patient_001',
            clinicianId: 'mock_clinician_001',
            symptoms: mockSymptoms,
            clinicalNotes: query,
          );
          
          if (aiDiagnosis.diagnoses.isNotEmpty) {
            // Convert DiagnosisResult to DiagnosisSuggestion
            for (final diagnosis in aiDiagnosis.diagnoses) {
              if (diagnosis.diagnosisSuggestions.isNotEmpty) {
                aiResults.addAll(diagnosis.diagnosisSuggestions);
              }
            }
          }
        } catch (e) {
          print('AI diagnosis failed: $e');
        }
      }

      setState(() {
        _searchResults = disorders;
        _aiSuggestions = aiResults;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSearching = false;
      });
    }
  }
}
