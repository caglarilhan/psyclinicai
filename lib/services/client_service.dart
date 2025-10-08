import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client_model.dart';
import 'database_service.dart';

class ClientService {
  static final ClientService _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

  static const String _clientsKey = 'clients';
  List<Client> _clients = [];
  final DatabaseService _databaseService = DatabaseService();

  // Initialize service
  Future<void> initialize() async {
    await _databaseService.initializeWithDemoData();
    await _loadClients();
  }

  // Load clients from storage
  Future<void> _loadClients() async {
    try {
      _clients = await _databaseService.getActiveClients();
    } catch (e) {
      print('Error loading clients: $e');
      _clients = [];
    }
  }

  // Save clients to storage
  Future<void> _saveClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientsJson = _clients
          .map((client) => jsonEncode(client.toJson()))
          .toList();
      
      await prefs.setStringList(_clientsKey, clientsJson);
    } catch (e) {
      print('Error saving clients: $e');
    }
  }

  // Get all clients
  List<Client> getAllClients() {
    return List.unmodifiable(_clients);
  }

  // Get active clients
  List<Client> getActiveClients() {
    return _clients.where((client) => client.isActive).toList();
  }

  // Get client by ID
  Client? getClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search clients
  Future<List<Client>> searchClients(String query) async {
    if (query.isEmpty) return getActiveClients();
    
    try {
      return await _databaseService.searchClients(query);
    } catch (e) {
      print('Error searching clients: $e');
      return [];
    }
  }

  // Add new client
  Future<bool> addClient(Client client) async {
    try {
      // Check if client with same email already exists
      if (_clients.any((c) => c.email == client.email)) {
        throw Exception('Bu e-posta adresi zaten kullanılıyor');
      }

      await _databaseService.insertClient(client);
      await _loadClients();
      return true;
    } catch (e) {
      print('Error adding client: $e');
      return false;
    }
  }

  // Update client
  Future<bool> updateClient(Client updatedClient) async {
    try {
      // Check if email is already used by another client
      if (_clients.any((c) => c.email == updatedClient.email && c.id != updatedClient.id)) {
        throw Exception('Bu e-posta adresi başka bir hasta tarafından kullanılıyor');
      }

      await _databaseService.updateClient(updatedClient);
      await _loadClients();
      return true;
    } catch (e) {
      print('Error updating client: $e');
      return false;
    }
  }

  // Delete client (soft delete)
  Future<bool> deleteClient(String id) async {
    try {
      await _databaseService.deleteClient(id);
      await _loadClients();
      return true;
    } catch (e) {
      print('Error deleting client: $e');
      return false;
    }
  }

  // Get client statistics
  Map<String, int> getClientStatistics() {
    final activeClients = getActiveClients();
    final totalClients = _clients.length;
    final maleClients = activeClients.where((c) => c.gender == 'Erkek').length;
    final femaleClients = activeClients.where((c) => c.gender == 'Kadın').length;
    
    return {
      'total': totalClients,
      'active': activeClients.length,
      'male': maleClients,
      'female': femaleClients,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_clients.isNotEmpty) return; // Don't generate if data already exists

    final demoClients = [
      Client(
        id: '1',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        email: 'ahmet.yilmaz@email.com',
        phone: '+90 555 123 4567',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Erkek',
        address: 'İstanbul, Türkiye',
        emergencyContact: 'Ayşe Yılmaz',
        emergencyPhone: '+90 555 987 6543',
        notes: 'Anksiyete bozukluğu tedavisi görüyor.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Client(
        id: '2',
        firstName: 'Fatma',
        lastName: 'Kaya',
        email: 'fatma.kaya@email.com',
        phone: '+90 555 234 5678',
        dateOfBirth: DateTime(1985, 8, 22),
        gender: 'Kadın',
        address: 'Ankara, Türkiye',
        emergencyContact: 'Mehmet Kaya',
        emergencyPhone: '+90 555 876 5432',
        notes: 'Depresyon tedavisi devam ediyor.',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Client(
        id: '3',
        firstName: 'Mehmet',
        lastName: 'Demir',
        email: 'mehmet.demir@email.com',
        phone: '+90 555 345 6789',
        dateOfBirth: DateTime(1992, 12, 3),
        gender: 'Erkek',
        address: 'İzmir, Türkiye',
        emergencyContact: 'Zeynep Demir',
        emergencyPhone: '+90 555 765 4321',
        notes: 'PTSD tedavisi başlatıldı.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    _clients.addAll(demoClients);
    await _saveClients();
  }
}
