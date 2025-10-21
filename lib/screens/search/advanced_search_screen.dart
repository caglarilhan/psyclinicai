import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tümü';
  String _selectedDateRange = 'Son 30 Gün';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  
  final List<String> _categories = [
    'Tümü',
    'Hastalar',
    'Randevular',
    'Reçeteler',
    'Faturalar',
    'Mesajlar',
    'Sesli Notlar',
    'Dosyalar',
    'Sigorta Talepleri',
  ];

  final List<String> _dateRanges = [
    'Son 7 Gün',
    'Son 30 Gün',
    'Son 3 Ay',
    'Son 6 Ay',
    'Son 1 Yıl',
    'Tüm Zamanlar',
  ];

  final List<Map<String, dynamic>> _mockData = [
    {
      'id': '1',
      'type': 'Hasta',
      'title': 'Ahmet Yılmaz',
      'subtitle': 'Depresyon - Son randevu: 15.02.2024',
      'content': 'Majör depresif bozukluk tanısı. Fluoksetin tedavisi devam ediyor.',
      'date': DateTime(2024, 2, 15),
      'tags': ['Depresyon', 'Fluoksetin', 'Aktif'],
      'priority': 'Yüksek',
      'category': 'Hastalar',
    },
    {
      'id': '2',
      'type': 'Randevu',
      'title': 'Ayşe Demir - Kontrol',
      'subtitle': '16.02.2024 14:30 - Dr. Mehmet Kaya',
      'content': 'Anksiyete bozukluğu takibi. CBT seansları devam ediyor.',
      'date': DateTime(2024, 2, 16),
      'tags': ['Anksiyete', 'CBT', 'Kontrol'],
      'priority': 'Orta',
      'category': 'Randevular',
    },
    {
      'id': '3',
      'type': 'Reçete',
      'title': 'RX-2024-001',
      'subtitle': 'Ahmet Yılmaz - Fluoksetin 20mg',
      'content': 'Günde 1 kez sabah yemekle birlikte. 30 günlük tedavi.',
      'date': DateTime(2024, 2, 15),
      'tags': ['Fluoksetin', 'Antidepresan', 'Aktif'],
      'priority': 'Yüksek',
      'category': 'Reçeteler',
    },
    {
      'id': '4',
      'type': 'Fatura',
      'title': 'INV-2024-001',
      'subtitle': 'Ahmet Yılmaz - ₺450.00',
      'content': 'Psikiyatri konsültasyonu ve ilaç tedavisi. Sigorta kapsaması: %70.',
      'date': DateTime(2024, 2, 15),
      'tags': ['Ödendi', 'Sigorta', 'Konsültasyon'],
      'priority': 'Düşük',
      'category': 'Faturalar',
    },
    {
      'id': '5',
      'type': 'Mesaj',
      'title': 'Dr. Ayşe Demir',
      'subtitle': 'Ahmet Yılmaz için mesaj',
      'content': 'İlaçlarınızı düzenli alıyor musunuz? Randevu öncesi kontrol.',
      'date': DateTime(2024, 2, 14),
      'tags': ['İlaç', 'Kontrol', 'Randevu'],
      'priority': 'Orta',
      'category': 'Mesajlar',
    },
    {
      'id': '6',
      'type': 'Sesli Not',
      'title': 'Hasta Ahmet Yılmaz - Depresyon',
      'subtitle': '3:45 - 15.02.2024',
      'content': 'Hasta depresyon belirtileri gösteriyor. Uyku sorunları ve iştah kaybı var.',
      'date': DateTime(2024, 2, 15),
      'tags': ['Depresyon', 'Uyku', 'İştah'],
      'priority': 'Yüksek',
      'category': 'Sesli Notlar',
    },
    {
      'id': '7',
      'type': 'Dosya',
      'title': 'Tedavi Planı - Ahmet Yılmaz',
      'subtitle': 'PDF - 2.3 MB',
      'content': 'Majör depresif bozukluk için detaylı tedavi planı ve takip protokolleri.',
      'date': DateTime(2024, 2, 10),
      'tags': ['Tedavi Planı', 'PDF', 'Depresyon'],
      'priority': 'Orta',
      'category': 'Dosyalar',
    },
    {
      'id': '8',
      'type': 'Sigorta Talebi',
      'title': 'CLM-001',
      'subtitle': 'Ahmet Yılmaz - SGK',
      'content': 'Psikiyatri konsültasyonu ve ilaç tedavisi. Talep tutarı: ₺450.',
      'date': DateTime(2024, 2, 15),
      'tags': ['SGK', 'Onaylandı', 'Konsültasyon'],
      'priority': 'Orta',
      'category': 'Sigorta Talepleri',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final results = _mockData.where((item) {
        final matchesCategory = _selectedCategory == 'Tümü' || item['category'] == _selectedCategory;
        final matchesQuery = item['title'].toLowerCase().contains(query.toLowerCase()) ||
                           item['subtitle'].toLowerCase().contains(query.toLowerCase()) ||
                           item['content'].toLowerCase().contains(query.toLowerCase()) ||
                           item['tags'].any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        
        return matchesCategory && matchesQuery;
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Arama'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showSearchHistory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Arama'),
            Tab(icon: Icon(Icons.bookmark), text: 'Kayıtlı Aramalar'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trendler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildSavedSearchesTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Arama çubuğu ve filtreler
        Container(
          padding: const EdgeInsets.all(16),
          color: colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Hasta, randevu, reçete, fatura ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _performSearch,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Tarih Aralığı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _selectedDateRange,
                      items: _dateRanges.map((range) {
                        return DropdownMenuItem(
                          value: range,
                          child: Text(range),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDateRange = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Arama sonuçları
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return _buildSearchResultCard(_searchResults[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty ? 'Arama yapmak için yukarıdaki alana yazın' : 'Sonuç bulunamadı',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty 
                ? 'Hasta, randevu, reçete veya fatura arayabilirsiniz'
                : 'Farklı anahtar kelimeler deneyin veya filtreleri değiştirin',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color priorityColor;
    switch (result['priority']) {
      case 'Yüksek':
        priorityColor = Colors.red;
        break;
      case 'Orta':
        priorityColor = Colors.orange;
        break;
      case 'Düşük':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    IconData typeIcon;
    switch (result['type']) {
      case 'Hasta':
        typeIcon = Icons.person;
        break;
      case 'Randevu':
        typeIcon = Icons.calendar_today;
        break;
      case 'Reçete':
        typeIcon = Icons.medication;
        break;
      case 'Fatura':
        typeIcon = Icons.receipt;
        break;
      case 'Mesaj':
        typeIcon = Icons.message;
        break;
      case 'Sesli Not':
        typeIcon = Icons.mic;
        break;
      case 'Dosya':
        typeIcon = Icons.folder;
        break;
      case 'Sigorta Talebi':
        typeIcon = Icons.local_hospital;
        break;
      default:
        typeIcon = Icons.description;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openResult(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(typeIcon, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['title'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          result['subtitle'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result['priority'],
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result['content'],
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd.MM.yyyy').format(result['date']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 4,
                    children: result['tags'].take(3).map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedSearchesTab() {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSavedSearchItem('Depresyon hastaları', 'Son 30 gün', Icons.person),
        _buildSavedSearchItem('Bekleyen randevular', 'Bugün', Icons.calendar_today),
        _buildSavedSearchItem('Fluoksetin reçeteleri', 'Son 7 gün', Icons.medication),
        _buildSavedSearchItem('Ödenmemiş faturalar', 'Son 3 ay', Icons.receipt),
        _buildSavedSearchItem('SGK sigorta talepleri', 'Son 30 gün', Icons.local_hospital),
      ],
    );
  }

  Widget _buildSavedSearchItem(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _runSavedSearch(title),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSavedSearch(title),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTrendItem('Depresyon', 'Bu hafta %15 artış', Icons.trending_up, Colors.red),
        _buildTrendItem('Anksiyete', 'Bu hafta %8 artış', Icons.trending_up, Colors.orange),
        _buildTrendItem('Fluoksetin', 'En çok reçetelenen ilaç', Icons.medication, Colors.blue),
        _buildTrendItem('Randevu iptalleri', 'Bu hafta %5 azalış', Icons.trending_down, Colors.green),
        _buildTrendItem('Sigorta talepleri', 'Bu ay %12 artış', Icons.local_hospital, Colors.purple),
      ],
    );
  }

  Widget _buildTrendItem(String title, String subtitle, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(color == Colors.green ? Icons.trending_down : Icons.trending_up, color: color),
      ),
    );
  }

  void _showFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gelişmiş Filtreler'),
        content: const Text('Detaylı filtreleme seçenekleri burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arama Geçmişi'),
        content: const Text('Son aramalar burada görüntülenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _openResult(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${result['type']} detayları açılıyor...')),
    );
  }

  void _runSavedSearch(String title) {
    _searchController.text = title;
    _performSearch(title);
  }

  void _deleteSavedSearch(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$title" kayıtlı arama silindi')),
    );
  }
}
