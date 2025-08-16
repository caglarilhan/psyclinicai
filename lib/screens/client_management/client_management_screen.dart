import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/client_model.dart';
import '../../widgets/client_management/client_list_widget.dart';
import '../../widgets/client_management/client_search_widget.dart';
import '../../widgets/client_management/client_filters_widget.dart';
import '../../widgets/client_management/client_stats_widget.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ClientModel> _clients = [];
  List<ClientModel> _filteredClients = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  String _selectedStatus = 'all';
  String _selectedRiskLevel = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDemoClients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
}
