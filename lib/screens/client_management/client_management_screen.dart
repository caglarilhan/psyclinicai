import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../services/client_service.dart';
import '../../models/client_model.dart';
import 'client_form_screen.dart';
import 'client_detail_screen.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  final ClientService _clientService = ClientService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  String _sortKey = 'createdAt_desc';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () => _addNewClient(),
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      () => _focusSearch(),
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
    );
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    
    try {
      await _clientService.initialize();
      await _clientService.generateDemoData();
      
      final clients = _clientService.getActiveClients();
      setState(() {
        _clients = _applySort(clients);
        _filteredClients = _clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hastalar yüklenirken hata oluştu: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _searchClients(String query) async {
    setState(() {
      if (query.isEmpty) {
        _filteredClients = _clients;
      } else {
        // Search will be handled asynchronously
      }
    });
    
    if (query.isNotEmpty) {
      final results = await _clientService.searchClients(query);
      setState(() {
        _filteredClients = _applySort(results);
      });
    }
  }

  void _addNewClient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClientFormScreen(),
      ),
    ).then((_) => _loadClients());
  }

  void _focusSearch() {
    // Focus search field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Yönetimi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (v){
              setState((){
                _sortKey = v;
                _filteredClients = _applySort(_filteredClients);
                _clients = _applySort(_clients);
              });
            },
            itemBuilder: (context)=> const [
              PopupMenuItem(value: 'createdAt_desc', child: Text('Kayıt tarihi (Yeni → Eski)')),
              PopupMenuItem(value: 'createdAt_asc', child: Text('Kayıt tarihi (Eski → Yeni)')),
              PopupMenuItem(value: 'name_asc', child: Text('İsme göre (A→Z)')),
              PopupMenuItem(value: 'name_desc', child: Text('İsme göre (Z→A)')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClients,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewClient,
            tooltip: 'Yeni Hasta',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Hasta ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchClients('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _searchClients,
            ),
          ),
          
          // Statistics Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Toplam Hasta',
                    '${_clients.length}',
                    Icons.people,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Aktif Hasta',
                    '${_filteredClients.length}',
                    Icons.person,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Clients List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = _filteredClients[index];
                          return _buildClientCard(client);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewClient,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hasta'),
      ),
    );
  }

  List<Client> _applySort(List<Client> list){
    final copy = [...list];
    switch(_sortKey){
      case 'createdAt_asc':
        copy.sort((a,b)=> a.dateOfBirth.compareTo(b.dateOfBirth));
        break;
      case 'name_asc':
        copy.sort((a,b)=> a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case 'name_desc':
        copy.sort((a,b)=> b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
        break;
      case 'createdAt_desc':
      default:
        copy.sort((a,b)=> b.dateOfBirth.compareTo(a.dateOfBirth));
        break;
    }
    return copy;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(Client client) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          client.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${client.age} yaşında • ${client.gender}'),
            Text(client.email),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Görüntüle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppTheme.errorColor),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientDetailScreen(client: client),
                  ),
                );
                break;
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientFormScreen(client: client),
                  ),
                ).then((_) => _loadClients());
                break;
              case 'delete':
                _deleteClient(client);
                break;
            }
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientDetailScreen(client: client),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Henüz hasta kaydı yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk hastanızı eklemek için + butonuna tıklayın',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClient(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hastayı Sil'),
        content: Text('${client.fullName} adlı hastayı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _clientService.deleteClient(client.id);
      if (success) {
        _loadClients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hasta başarıyla silindi'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hasta silinirken hata oluştu'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}