import 'package:flutter/material.dart';

class GlobalSearchService {
  static final GlobalSearchService _instance = GlobalSearchService._internal();
  factory GlobalSearchService() => _instance;
  GlobalSearchService._internal();

  // Arama geçmişi
  List<String> _searchHistory = [];
  List<String> _favoriteSearches = [];

  // Arama geçmişi getter
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  List<String> get favoriteSearches => List.unmodifiable(_favoriteSearches);

  // Arama sonuçları
  List<SearchResult> _searchResults = [];

  // Arama yap
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Arama geçmişine ekle
    _addToHistory(query);

    // Demo arama sonuçları
    _searchResults = _getDemoSearchResults(query);
    
    return _searchResults;
  }

  // Arama geçmişine ekle
  void _addToHistory(String query) {
    _searchHistory.remove(query); // Eğer varsa kaldır
    _searchHistory.insert(0, query); // Başa ekle
    
    // Son 10 aramayı tut
    if (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
  }

  // Favorilere ekle
  void addToFavorites(String query) {
    if (!_favoriteSearches.contains(query)) {
      _favoriteSearches.add(query);
    }
  }

  // Favorilerden çıkar
  void removeFromFavorites(String query) {
    _favoriteSearches.remove(query);
  }

  // Arama geçmişini temizle
  void clearHistory() {
    _searchHistory.clear();
  }

  // Favorileri temizle
  void clearFavorites() {
    _favoriteSearches.clear();
  }

  // Demo arama sonuçları
  List<SearchResult> _getDemoSearchResults(String query) {
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    // Danışan araması
    if (lowerQuery.contains('danışan') || lowerQuery.contains('client') || lowerQuery.contains('ahmet') || lowerQuery.contains('ayşe')) {
      results.addAll([
        SearchResult(
          id: '1',
          title: 'Ahmet Yılmaz',
          subtitle: 'Danışan - Depresyon',
          type: SearchResultType.client,
          icon: Icons.person,
          color: Colors.blue,
        ),
        SearchResult(
          id: '2',
          title: 'Ayşe Demir',
          subtitle: 'Danışan - Anksiyete',
          type: SearchResultType.client,
          icon: Icons.person,
          color: Colors.blue,
        ),
      ]);
    }

    // Seans araması
    if (lowerQuery.contains('seans') || lowerQuery.contains('session')) {
      results.addAll([
        SearchResult(
          id: '3',
          title: 'Seans #001',
          subtitle: 'Ahmet Yılmaz - 15 Ocak 2024',
          type: SearchResultType.session,
          icon: Icons.event,
          color: Colors.green,
        ),
        SearchResult(
          id: '4',
          title: 'Seans #002',
          subtitle: 'Ayşe Demir - 10 Ocak 2024',
          type: SearchResultType.session,
          icon: Icons.event,
          color: Colors.green,
        ),
      ]);
    }

    // Tanı araması
    if (lowerQuery.contains('tanı') || lowerQuery.contains('diagnosis') || lowerQuery.contains('depresyon') || lowerQuery.contains('anksiyete')) {
      results.addAll([
        SearchResult(
          id: '5',
          title: 'Depresyon',
          subtitle: 'Tanı - ICD-10 F32.1',
          type: SearchResultType.diagnosis,
          icon: Icons.medical_services,
          color: Colors.red,
        ),
        SearchResult(
          id: '6',
          title: 'Anksiyete Bozukluğu',
          subtitle: 'Tanı - ICD-10 F41.1',
          type: SearchResultType.diagnosis,
          icon: Icons.medical_services,
          color: Colors.red,
        ),
      ]);
    }

    // İlaç araması
    if (lowerQuery.contains('ilaç') || lowerQuery.contains('medication') || lowerQuery.contains('prozac') || lowerQuery.contains('xanax')) {
      results.addAll([
        SearchResult(
          id: '7',
          title: 'Prozac',
          subtitle: 'İlaç - Fluoxetine',
          type: SearchResultType.medication,
          icon: Icons.medication,
          color: Colors.purple,
        ),
        SearchResult(
          id: '8',
          title: 'Xanax',
          subtitle: 'İlaç - Alprazolam',
          type: SearchResultType.medication,
          icon: Icons.medication,
          color: Colors.purple,
        ),
      ]);
    }

    // Not araması
    if (lowerQuery.contains('not') || lowerQuery.contains('note')) {
      results.addAll([
        SearchResult(
          id: '9',
          title: 'DAP Notu',
          subtitle: 'Ahmet Yılmaz - 15 Ocak 2024',
          type: SearchResultType.note,
          icon: Icons.note,
          color: Colors.orange,
        ),
        SearchResult(
          id: '10',
          title: 'SOAP Notu',
          subtitle: 'Ayşe Demir - 10 Ocak 2024',
          type: SearchResultType.note,
          icon: Icons.note,
          color: Colors.orange,
        ),
      ]);
    }

    // Randevu araması
    if (lowerQuery.contains('randevu') || lowerQuery.contains('appointment')) {
      results.addAll([
        SearchResult(
          id: '11',
          title: 'Randevu #001',
          subtitle: 'Ahmet Yılmaz - 20 Ocak 2024 14:00',
          type: SearchResultType.appointment,
          icon: Icons.calendar_today,
          color: Colors.teal,
        ),
        SearchResult(
          id: '12',
          title: 'Randevu #002',
          subtitle: 'Ayşe Demir - 22 Ocak 2024 16:00',
          type: SearchResultType.appointment,
          icon: Icons.calendar_today,
          color: Colors.teal,
        ),
      ]);
    }

    return results;
  }

  // AI destekli öneriler
  List<String> getAIRecommendations(String query) {
    final lowerQuery = query.toLowerCase();
    final recommendations = <String>[];

    if (lowerQuery.contains('danışan')) {
      recommendations.addAll([
        'Ahmet Yılmaz',
        'Ayşe Demir',
        'Mehmet Kaya',
        'Fatma Özkan',
      ]);
    }

    if (lowerQuery.contains('tanı')) {
      recommendations.addAll([
        'Depresyon',
        'Anksiyete Bozukluğu',
        'PTSD',
        'Bipolar Bozukluk',
        'OKB',
      ]);
    }

    if (lowerQuery.contains('ilaç')) {
      recommendations.addAll([
        'Prozac',
        'Xanax',
        'Zoloft',
        'Lexapro',
        'Wellbutrin',
      ]);
    }

    return recommendations;
  }

  // Arama istatistikleri
  Map<String, dynamic> getSearchStatistics() {
    return {
      'totalSearches': _searchHistory.length,
      'favoriteSearches': _favoriteSearches.length,
      'recentSearches': _searchHistory.take(5).toList(),
      'topSearches': _getTopSearches(),
    };
  }

  // En popüler aramalar
  List<String> _getTopSearches() {
    final searchCount = <String, int>{};
    
    for (final search in _searchHistory) {
      searchCount[search] = (searchCount[search] ?? 0) + 1;
    }

    final sortedSearches = searchCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSearches.take(5).map((e) => e.key).toList();
  }
}

// Arama sonucu modeli
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final IconData icon;
  final Color color;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.color,
  });
}

// Arama sonucu türleri
enum SearchResultType {
  client,
  session,
  diagnosis,
  medication,
  note,
  appointment,
  general,
}

// Global arama widget'ı
class GlobalSearchWidget extends StatefulWidget {
  final Function(SearchResult)? onResultSelected;

  const GlobalSearchWidget({
    super.key,
    this.onResultSelected,
  });

  @override
  State<GlobalSearchWidget> createState() => _GlobalSearchWidgetState();
}

class _GlobalSearchWidgetState extends State<GlobalSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalSearchService _searchService = GlobalSearchService();
  List<SearchResult> _searchResults = [];
  List<String> _aiRecommendations = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _aiRecommendations = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Arama yap
    final results = await _searchService.search(query);
    final recommendations = _searchService.getAIRecommendations(query);

    setState(() {
      _searchResults = results;
      _aiRecommendations = recommendations;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arama çubuğu
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Global arama yapın...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Arama sonuçları
        if (_searchResults.isNotEmpty) ...[
          Text(
            'Arama Sonuçları',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._searchResults.map((result) => _buildSearchResult(result)),
        ],
        
        // AI önerileri
        if (_aiRecommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'AI Önerileri',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _aiRecommendations.map((recommendation) => 
              Chip(
                label: Text(recommendation),
                onDeleted: () {
                  _searchController.text = recommendation;
                },
              ),
            ).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResult(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: result.color,
          child: Icon(result.icon, color: Colors.white),
        ),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        onTap: () {
          widget.onResultSelected?.call(result);
        },
      ),
    );
  }
}
