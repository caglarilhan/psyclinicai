import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../../models/client_model.dart';
import '../../widgets/client_management/client_list_widget.dart';
import '../../widgets/client_management/client_search_widget.dart';
import '../../widgets/client_management/client_filters_widget.dart';
import '../../widgets/client_management/client_stats_widget.dart';
import '../../utils/theme.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ClientModel> _clients = [];
  List<ClientModel> _filteredClients = [];
  List<Map<String, dynamic>> _recentClients = [];
  List<Map<String, dynamic>> _favoriteClients = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  String _selectedStatus = 'all';
  String _selectedRiskLevel = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDemoClients();
    _loadInitialData();
    _setupKeyboardShortcuts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _removeKeyboardShortcuts();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDemoClients() {
    setState(() {
      _isLoading = true;
    });

    // Demo client data
    _clients = [
      ClientModel(
        id: '1',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        dateOfBirth: DateTime(1990, 5, 15),
        phoneNumber: '+90 555 123 4567',
        email: 'ahmet.yilmaz@email.com',
        primaryDiagnosis: 'Depresyon',
        status: ClientStatus.active,
        riskLevel: ClientRiskLevel.medium,
        firstSessionDate: DateTime.now().subtract(const Duration(days: 30)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 7)),
        totalSessions: 8,
        assignedTherapistId: 'therapist1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      ClientModel(
        id: '2',
        firstName: 'Ayşe',
        lastName: 'Demir',
        dateOfBirth: DateTime(1985, 8, 22),
        phoneNumber: '+90 555 987 6543',
        email: 'ayse.demir@email.com',
        primaryDiagnosis: 'Anksiyete Bozukluğu',
        status: ClientStatus.active,
        riskLevel: ClientRiskLevel.low,
        firstSessionDate: DateTime.now().subtract(const Duration(days: 45)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 3)),
        totalSessions: 12,
        assignedTherapistId: 'therapist2',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ClientModel(
        id: '3',
        firstName: 'Mehmet',
        lastName: 'Kaya',
        dateOfBirth: DateTime(1978, 3, 10),
        phoneNumber: '+90 555 456 7890',
        email: 'mehmet.kaya@email.com',
        primaryDiagnosis: 'PTSD',
        status: ClientStatus.active,
        riskLevel: ClientRiskLevel.high,
        firstSessionDate: DateTime.now().subtract(const Duration(days: 60)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 1)),
        totalSessions: 20,
        assignedTherapistId: 'therapist1',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ClientModel(
        id: '4',
        firstName: 'Fatma',
        lastName: 'Özkan',
        dateOfBirth: DateTime(1992, 11, 5),
        phoneNumber: '+90 555 321 0987',
        email: 'fatma.ozkan@email.com',
        primaryDiagnosis: 'Bipolar Bozukluk',
        status: ClientStatus.onHold,
        riskLevel: ClientRiskLevel.critical,
        firstSessionDate: DateTime.now().subtract(const Duration(days: 90)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 15)),
        totalSessions: 15,
        assignedTherapistId: 'therapist3',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ClientModel(
        id: '5',
        firstName: 'Ali',
        lastName: 'Çelik',
        dateOfBirth: DateTime(1988, 7, 18),
        phoneNumber: '+90 555 654 3210',
        email: 'ali.celik@email.com',
        primaryDiagnosis: 'OKB',
        status: ClientStatus.discharged,
        riskLevel: ClientRiskLevel.low,
        firstSessionDate: DateTime.now().subtract(const Duration(days: 120)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 30)),
        totalSessions: 25,
        assignedTherapistId: 'therapist2',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    _filteredClients = List.from(_clients);
    _isLoading = false;
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredClients = _clients.where((client) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            client.firstName.toLowerCase().contains(searchQuery) ||
            client.lastName.toLowerCase().contains(searchQuery) ||
            client.email?.toLowerCase().contains(searchQuery) == true ||
            client.primaryDiagnosis?.toLowerCase().contains(searchQuery) == true;

        // Status filter
        final matchesStatus = _selectedStatus == 'all' ||
            client.status.name == _selectedStatus;

        // Risk level filter
        final matchesRiskLevel = _selectedRiskLevel == 'all' ||
            client.riskLevel.name == _selectedRiskLevel;

        return matchesSearch && matchesStatus && matchesRiskLevel;
      }).toList();
    });
  }

  void _onFilterChanged(String filter, String value) {
    setState(() {
      if (filter == 'status') {
        _selectedStatus = value;
      } else if (filter == 'riskLevel') {
        _selectedRiskLevel = value;
      }
    });
    _applyFilters();
  }

  void _addNewClient() {
    HapticFeedback.lightImpact();
    // TODO: Implement new client form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeni danışan ekleme özelliği yakında!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return DesktopLayout(
      title: 'Danışan Portalı',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Danışan',
          onPressed: _addNewClient,
          icon: Icons.person_add,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'AI Analiz',
          onPressed: _generateAIAnalysis,
          icon: Icons.auto_awesome,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'İstatistikler',
          onPressed: _showClientStatistics,
          icon: Icons.analytics,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportClientReport,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showClientSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Tüm Danışanlar',
          icon: Icons.people,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Son Danışanlar',
          icon: Icons.history,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Favori Danışanlar',
          icon: Icons.favorite,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Raporlar',
          icon: Icons.analytics,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDesktopAllClientsTab(),
        _buildDesktopRecentTab(),
        _buildDesktopFavoritesTab(),
        _buildDesktopReportsTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Vaka Yönetimi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addNewClient,
            icon: const Icon(Icons.person_add),
            tooltip: 'Yeni Danışan Ekle',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement settings
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm Danışanlar', icon: Icon(Icons.people)),
            Tab(text: 'Aktif', icon: Icon(Icons.check_circle)),
            Tab(text: 'Yüksek Risk', icon: Icon(Icons.warning)),
            Tab(text: 'İstatistikler', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ClientSearchWidget(
                  controller: _searchController,
                  onSearchChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                ClientFiltersWidget(
                  selectedStatus: _selectedStatus,
                  selectedRiskLevel: _selectedRiskLevel,
                  onFilterChanged: _onFilterChanged,
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Clients Tab
                _buildClientsTab(_filteredClients),
                
                // Active Clients Tab
                _buildClientsTab(_filteredClients.where((c) => c.isActive).toList()),
                
                // High Risk Clients Tab
                _buildClientsTab(_filteredClients.where((c) => c.isHighRisk).toList()),
                
                // Statistics Tab
                ClientStatsWidget(clients: _clients),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewClient,
        icon: const Icon(Icons.person_add),
        label: const Text('Yeni Danışan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildClientsTab(List<ClientModel> clients) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Danışan bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arama kriterlerinizi değiştirmeyi deneyin',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ClientListWidget(
      clients: clients,
      onClientTap: (client) {
        HapticFeedback.lightImpact();
        // TODO: Navigate to client detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${client.displayName} profilini görüntüle'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      _addNewClient,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
      _generateAIAnalysis,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _showClientStatistics,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _exportClientReport,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü tab metodları
  Widget _buildDesktopAllClientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tüm Danışanlar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search and Filters
                  ClientSearchWidget(
                    controller: _searchController,
                    onSearchChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 16),
                  ClientFiltersWidget(
                    selectedStatus: _selectedStatus,
                    selectedRiskLevel: _selectedRiskLevel,
                    onFilterChanged: _onFilterChanged,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Danışan Listesi',
                    style: DesktopTheme.desktopSectionTitleStyle,
                  ),
                  const SizedBox(height: 16),
                  _buildClientsTab(_filteredClients),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRecentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Danışanlar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_recentClients.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son ${_recentClients.length} Danışan',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._recentClients.map((client) => _buildClientListItem(client)),
                  ],
                ),
              ),
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz danışan eklenmemiş',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopFavoritesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favori Danışanlar',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_favoriteClients.isNotEmpty)
            DesktopTheme.desktopCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_favoriteClients.length} Favori Danışan',
                      style: DesktopTheme.desktopSectionTitleStyle,
                    ),
                    const SizedBox(height: 16),
                    ..._favoriteClients.map((client) => _buildClientListItem(client)),
                  ],
                ),
              ),
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz favori danışan eklenmedi',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danışan Raporları',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopTheme.desktopCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İstatistikler',
                    style: DesktopTheme.desktopSectionTitleStyle,
                  ),
                  const SizedBox(height: 16),
                  ClientStatsWidget(clients: _clients),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientListItem(Map<String, dynamic> client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            client['name'][0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(client['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${client['diagnosis']} - ${client['status']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRiskColor(client['riskLevel']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                client['riskLevel'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showClientDetails(client),
            ),
          ],
        ),
        onTap: () => _showClientDetails(client),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'high':
        return AppTheme.errorColor;
      case 'critical':
        return Colors.red[900]!;
      default:
        return AppTheme.primaryColor;
    }
  }

  // Yeni özellikler için metodlar
  void _loadInitialData() {
    setState(() {
      _recentClients = _getDemoRecentClients();
      _favoriteClients = _getDemoFavoriteClients();
    });
  }

  List<Map<String, dynamic>> _getDemoRecentClients() {
    return [
      {
        'id': '1',
        'name': 'Ahmet Yılmaz',
        'diagnosis': 'Depresyon',
        'status': 'Aktif',
        'riskLevel': 'Medium',
        'lastSession': '2024-01-15',
      },
      {
        'id': '2',
        'name': 'Ayşe Demir',
        'diagnosis': 'Anksiyete',
        'status': 'Aktif',
        'riskLevel': 'Low',
        'lastSession': '2024-01-10',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoFavoriteClients() {
    return [
      {
        'id': '1',
        'name': 'Ahmet Yılmaz',
        'diagnosis': 'Depresyon',
        'status': 'Aktif',
        'riskLevel': 'Medium',
        'totalSessions': 8,
      },
      {
        'id': '3',
        'name': 'Mehmet Kaya',
        'diagnosis': 'PTSD',
        'status': 'Aktif',
        'riskLevel': 'High',
        'totalSessions': 20,
      },
    ];
  }

  void _addToFavorites(Map<String, dynamic> client) {
    setState(() {
      if (!_favoriteClients.contains(client)) {
        _favoriteClients.add(client);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${client['name']} favorilere eklendi'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _removeFromFavorites(Map<String, dynamic> client) {
    setState(() {
      _favoriteClients.remove(client);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${client['name']} favorilerden çıkarıldı'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addToRecent(Map<String, dynamic> client) {
    setState(() {
      _recentClients.remove(client); // Eğer varsa kaldır
      _recentClients.insert(0, client); // Başa ekle
      if (_recentClients.length > 10) {
        _recentClients.removeLast(); // Son 10 danışanı tut
      }
    });
  }

  void _generateAIAnalysis() {
    // TODO: AI analiz oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI analiz oluşturuluyor...')),
    );
  }

  void _showClientStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Danışan İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticItem('Toplam Danışan', '${_clients.length}'),
            _buildStatisticItem('Aktif Danışanlar', '${_clients.where((c) => c.isActive).length}'),
            _buildStatisticItem('Yüksek Risk', '${_clients.where((c) => c.isHighRisk).length}'),
            _buildStatisticItem('Favori Danışanlar', '${_favoriteClients.length}'),
          ],
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

  Widget _buildStatisticItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _exportClientReport() {
    // TODO: Danışan raporu export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Danışan raporu PDF olarak export ediliyor...')),
    );
  }

  void _showClientSettings() {
    // TODO: Danışan ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Danışan ayarları yakında gelecek')),
    );
  }

  void _showClientDetails(Map<String, dynamic> client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tanı', client['diagnosis']),
            _buildDetailRow('Durum', client['status']),
            _buildDetailRow('Risk Seviyesi', client['riskLevel']),
            if (client['lastSession'] != null)
              _buildDetailRow('Son Seans', client['lastSession']),
            if (client['totalSessions'] != null)
              _buildDetailRow('Toplam Seans', client['totalSessions'].toString()),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
