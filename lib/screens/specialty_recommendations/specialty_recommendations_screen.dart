import 'package:flutter/material.dart';
import '../../models/specialty_models.dart';
import '../../services/specialty_recommendation_service.dart';
import '../../services/role_service.dart';

class SpecialtyRecommendationsScreen extends StatefulWidget {
  const SpecialtyRecommendationsScreen({super.key});

  @override
  State<SpecialtyRecommendationsScreen> createState() => _SpecialtyRecommendationsScreenState();
}

class _SpecialtyRecommendationsScreenState extends State<SpecialtyRecommendationsScreen> with TickerProviderStateMixin {
  final SpecialtyRecommendationService _specialtyService = SpecialtyRecommendationService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<SpecialtyRecommendation> _recommendations = [];
  Map<String, dynamic> _statistics = {};
  
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _selectedPriority = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      _specialtyService.initializeSpecialtyData();
      
      final currentUser = _roleService.getCurrentUser();
      final userRole = currentUser['role'] as String;
      
      final specialty = _getSpecialtyFromRole(userRole);
      _recommendations = _specialtyService.getRecommendationsForSpecialty(specialty);
      _statistics = _specialtyService.getSpecialtyStatistics(specialty);
    } catch (e) {
      print('Error loading specialty recommendations: $e');
    }
    
    setState(() => _isLoading = false);
  }

  SpecialtyType _getSpecialtyFromRole(String role) {
    switch (role) {
      case 'Psikiyatrist':
        return SpecialtyType.psychiatrist;
      case 'Psikolog':
        return SpecialtyType.psychologist;
      case 'Hemşire':
        return SpecialtyType.nurse;
      case 'Sekreter':
        return SpecialtyType.secretary;
      case 'Yönetici':
        return SpecialtyType.administrator;
      case 'Hasta':
        return SpecialtyType.patient;
      default:
        return SpecialtyType.psychiatrist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        backgroundColor: Colors.purple[900],
        title: const Text(
          'Uzmanlık Önerileri',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Psikiyatrist'),
            Tab(text: 'Psikolog'),
            Tab(text: 'Hemşire'),
            Tab(text: 'Sekreter'),
            Tab(text: 'Yönetici'),
            Tab(text: 'Hasta'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSpecialtyTab(SpecialtyType.psychiatrist),
                _buildSpecialtyTab(SpecialtyType.psychologist),
                _buildSpecialtyTab(SpecialtyType.nurse),
                _buildSpecialtyTab(SpecialtyType.secretary),
                _buildSpecialtyTab(SpecialtyType.administrator),
                _buildSpecialtyTab(SpecialtyType.patient),
              ],
            ),
    );
  }

  Widget _buildSpecialtyTab(SpecialtyType specialty) {
    final recommendations = _specialtyService.getRecommendationsForSpecialty(specialty);
    final categories = _specialtyService.getCategoriesForSpecialty(specialty);
    final statistics = _specialtyService.getSpecialtyStatistics(specialty);
    
    return Column(
      children: [
        _buildSpecialtyHeader(specialty, statistics),
        _buildFilters(categories),
        Expanded(
          child: _buildRecommendationsList(recommendations, specialty),
        ),
      ],
    );
  }

  Widget _buildSpecialtyHeader(SpecialtyType specialty, Map<String, dynamic> statistics) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.purple[800],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _specialtyService.getSpecialtyName(specialty),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _specialtyService.getSpecialtyDescription(specialty),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard('Toplam Öneri', statistics['totalRecommendations'].toString(), Colors.blue),
                  const SizedBox(width: 16),
                  _buildStatCard('Kategori', statistics['categories'].toString(), Colors.green),
                  const SizedBox(width: 16),
                  _buildStatCard('Yüksek Öncelik', statistics['highPriority'].toString(), Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<String> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.purple[800],
              style: const TextStyle(color: Colors.white),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('Tümü')),
                ...categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Öncelik',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.purple[800],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tümü')),
                DropdownMenuItem(value: 'high', child: Text('Yüksek')),
                DropdownMenuItem(value: 'medium', child: Text('Orta')),
                DropdownMenuItem(value: 'low', child: Text('Düşük')),
              ],
              onChanged: (value) {
                setState(() => _selectedPriority = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<SpecialtyRecommendation> recommendations, SpecialtyType specialty) {
    final filteredRecommendations = _getFilteredRecommendations(recommendations);
    
    return filteredRecommendations.isEmpty
        ? const Center(
            child: Text(
              'Bu uzmanlık için öneri bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRecommendations.length,
            itemBuilder: (context, index) {
              final recommendation = filteredRecommendations[index];
              return _buildRecommendationCard(recommendation);
            },
          );
  }

  List<SpecialtyRecommendation> _getFilteredRecommendations(List<SpecialtyRecommendation> recommendations) {
    var filtered = recommendations;
    
    if (_selectedCategory != 'all') {
      filtered = filtered.where((rec) => rec.category == _selectedCategory).toList();
    }
    
    if (_selectedPriority != 'all') {
      filtered = filtered.where((rec) => rec.priority == _selectedPriority).toList();
    }
    
    return filtered;
  }

  Widget _buildRecommendationCard(SpecialtyRecommendation recommendation) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    final categoryColor = _getCategoryColor(recommendation.category);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recommendation.priority.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: categoryColor.withOpacity(0.5)),
              ),
              child: Text(
                recommendation.category,
                style: TextStyle(
                  color: categoryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            const Text(
              'Özellikler:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendation.features.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feature,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecommendationDetails(recommendation),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _implementRecommendation(recommendation),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Uygula'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'İlaç Yönetimi':
        return Colors.blue;
      case 'Tanı ve Değerlendirme':
        return Colors.purple;
      case 'Terapi Yönetimi':
        return Colors.pink;
      case 'Hasta Bakımı':
        return Colors.green;
      case 'Randevu Yönetimi':
        return Colors.orange;
      case 'Analitik ve Raporlama':
        return Colors.indigo;
      case 'Finansal Yönetim':
        return Colors.teal;
      case 'Kişisel Takip':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  void _showRecommendationDetails(SpecialtyRecommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          recommendation.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Açıklama: ${recommendation.description}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Kategori: ${recommendation.category}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Öncelik: ${recommendation.priority}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                'Özellikler:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...recommendation.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text(
                    '• $feature',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _implementRecommendation(recommendation);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _implementRecommendation(SpecialtyRecommendation recommendation) {
    // TODO: Implement recommendation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recommendation.title} önerisi uygulanıyor...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
