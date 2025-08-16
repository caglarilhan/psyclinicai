import 'package:flutter/material.dart';
import '../../models/diagnosis_models.dart';
import '../../services/diagnosis_service.dart';
import '../../utils/theme.dart';

class DiagnosisSearchWidget extends StatefulWidget {
  final Function(ICD11Diagnosis)? onICD11Selected;
  final Function(DSM5Diagnosis)? onDSM5Selected;
  final Function(AIDiagnosisSuggestion)? onAISelected;
  final String? initialQuery;
  final String language;

  const DiagnosisSearchWidget({
    super.key,
    this.onICD11Selected,
    this.onDSM5Selected,
    this.onAISelected,
    this.initialQuery,
    this.language = 'en',
  });

  @override
  State<DiagnosisSearchWidget> createState() => _DiagnosisSearchWidgetState();
}

class _DiagnosisSearchWidgetState extends State<DiagnosisSearchWidget>
    with TickerProviderStateMixin {
  final DiagnosisService _diagnosisService = DiagnosisService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  DiagnosisSearchResult? _searchResults;
  bool _isSearching = false;
  String? _error;
  String _selectedSystem = 'all'; // all, icd11, dsm5, ai
  
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 20),
            
            // Search Bar
            _buildSearchBar(),
            
            const SizedBox(height: 20),
            
            // System Tabs
            _buildSystemTabs(),
            
            const SizedBox(height: 20),
            
            // Search Results
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.medical_services,
          color: AppTheme.primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanı Arama Sistemi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                'ICD-11, DSM-5 ve AI destekli tanı önerileri',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // Language Selector
        _buildLanguageSelector(),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            color: AppTheme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            widget.language.toUpperCase(),
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Belirti, tanı veya kod ara...',
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.primaryColor,
          ),
          suffixIcon: _isSearching
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = null;
                      _error = null;
                    });
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (_) => _performSearch(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSystemTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Tümü'),
          Tab(text: 'ICD-11'),
          Tab(text: 'DSM-5'),
          Tab(text: 'AI Öneri'),
        ],
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _selectedSystem = 'all';
                break;
              case 1:
                _selectedSystem = 'icd11';
                break;
              case 2:
                _selectedSystem = 'dsm5';
                break;
              case 3:
                _selectedSystem = 'ai';
                break;
            }
          });
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_error != null) {
      return _buildErrorState();
    }
    
    if (_searchResults == null) {
      return _buildEmptyState();
    }
    
    if (_isSearching) {
      return _buildLoadingState();
    }
    
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResults(),
        _buildICD11Results(),
        _buildDSM5Results(),
        _buildAIResults(),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            'Tanı aramaya başlayın',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belirti, tanı adı veya kod yazarak arama yapın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Aranıyor...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Arama hatası',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Bilinmeyen bir hata oluştu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllResults() {
    final totalResults = _searchResults!.totalResults;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$totalResults sonuç bulundu (${_searchResults!.icd11Results.length} ICD-11, ${_searchResults!.dsm5Results.length} DSM-5, ${_searchResults!.aiSuggestions.length} AI)',
                  style: TextStyle(
                    color: AppTheme.infoColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Results List
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: [
              // ICD-11 Results
              if (_searchResults!.icd11Results.isNotEmpty) ...[
                _buildSectionHeader('ICD-11 Sonuçları', Icons.medical_services, AppTheme.primaryColor),
                ..._searchResults!.icd11Results.map((diagnosis) => _buildICD11Result(diagnosis)),
                const SizedBox(height: 16),
              ],
              
              // DSM-5 Results
              if (_searchResults!.dsm5Results.isNotEmpty) ...[
                _buildSectionHeader('DSM-5 Sonuçları', Icons.psychology, AppTheme.secondaryColor),
                ..._searchResults!.dsm5Results.map((diagnosis) => _buildDSM5Result(diagnosis)),
                const SizedBox(height: 16),
              ],
              
              // AI Suggestions
              if (_searchResults!.aiSuggestions.isNotEmpty) ...[
                _buildSectionHeader('AI Önerileri', Icons.auto_awesome, AppTheme.accentColor),
                ..._searchResults!.aiSuggestions.map((suggestion) => _buildAIResult(suggestion)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildICD11Results() {
    if (_searchResults!.icd11Results.isEmpty) {
      return _buildNoResultsState('ICD-11');
    }
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchResults!.icd11Results.length,
      itemBuilder: (context, index) {
        return _buildICD11Result(_searchResults!.icd11Results[index]);
      },
    );
  }

  Widget _buildDSM5Results() {
    if (_searchResults!.dsm5Results.isEmpty) {
      return _buildNoResultsState('DSM-5');
    }
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchResults!.dsm5Results.length,
      itemBuilder: (context, index) {
        return _buildDSM5Result(_searchResults!.dsm5Results[index]);
      },
    );
  }

  Widget _buildAIResults() {
    if (_searchResults!.aiSuggestions.isEmpty) {
      return _buildNoResultsState('AI Önerileri');
    }
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: _searchResults!.aiSuggestions.length,
      itemBuilder: (context, index) {
        return _buildAIResult(_searchResults!.aiSuggestions[index]);
      },
    );
  }

  Widget _buildNoResultsState(String system) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '$system sonucu bulunamadı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildICD11Result(ICD11Diagnosis diagnosis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onICD11Selected?.call(diagnosis),
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
                      diagnosis.code,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diagnosis.title,
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
                diagnosis.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (diagnosis.symptoms.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: diagnosis.symptoms.take(3).map((symptom) => Chip(
                    label: Text(
                      symptom,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppTheme.secondaryColor),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDSM5Result(DSM5Diagnosis diagnosis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onDSM5Selected?.call(diagnosis),
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
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      diagnosis.code,
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diagnosis.title,
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
                diagnosis.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (diagnosis.criteria.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Kriterler: ${diagnosis.criteria.length} adet',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIResult(AIDiagnosisSuggestion suggestion) {
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
                      suggestion.suggestedDiagnosis,
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
                suggestion.reasoning,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (suggestion.supportingSymptoms.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: suggestion.supportingSymptoms.take(3).map((symptom) => Chip(
                    label: Text(
                      symptom,
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
      final results = await _diagnosisService.searchDiagnoses(
        query: query,
        language: widget.language,
      );

      setState(() {
        _searchResults = results;
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
