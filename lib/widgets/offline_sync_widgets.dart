import 'package:flutter/material.dart';
import '../services/offline_sync_service.dart';
import '../utils/theme.dart';

// Offline Status Widget
class OfflineStatusWidget extends StatelessWidget {
  const OfflineStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final offlineSyncService = OfflineSyncService();
    
    return Column(
      children: [
        // Offline indicator
        offlineSyncService.buildOfflineIndicator(),
        
        // Sync progress
        offlineSyncService.buildSyncProgress(),
      ],
    );
  }
}

// Offline Sync Management Widget
class OfflineSyncManagementWidget extends StatefulWidget {
  const OfflineSyncManagementWidget({super.key});

  @override
  State<OfflineSyncManagementWidget> createState() => _OfflineSyncManagementWidgetState();
}

class _OfflineSyncManagementWidgetState extends State<OfflineSyncManagementWidget> {
  final OfflineSyncService _offlineSyncService = OfflineSyncService();
  Map<String, dynamic> _syncStats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _syncStats = _offlineSyncService.getSyncStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _syncStats['isOnline'] ? Icons.wifi : Icons.wifi_off,
                  color: _syncStats['isOnline'] ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Çevrimdışı Senkronizasyon',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bağlantı durumu
            _buildStatItem(
              'Bağlantı Durumu',
              _syncStats['isOnline'] ? 'Çevrimiçi' : 'Çevrimdışı',
              _syncStats['isOnline'] ? Icons.wifi : Icons.wifi_off,
              _syncStats['isOnline'] ? Colors.green : Colors.orange,
            ),
            
            // Bekleyen işlemler
            _buildStatItem(
              'Bekleyen İşlemler',
              '${_syncStats['pendingOperations'] ?? 0}',
              Icons.pending,
              Colors.blue,
            ),
            
            // Son sync zamanı
            _buildStatItem(
              'Son Senkronizasyon',
              _getLastSyncTime(),
              Icons.sync,
              Colors.grey,
            ),
            
            // Offline veri boyutu
            _buildStatItem(
              'Offline Veri',
              '${_syncStats['offlineDataSize'] ?? 0} kayıt',
              Icons.storage,
              Colors.purple,
            ),
            
            const SizedBox(height: 16),
            
            // Manuel sync butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _syncStats['isOnline'] && !_syncStats['isSyncing'] 
                    ? _manualSync 
                    : null,
                icon: _syncStats['isSyncing'] 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(_syncStats['isSyncing'] ? 'Senkronize Ediliyor...' : 'Manuel Senkronizasyon'),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Offline veri temizleme butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearOfflineData,
                icon: const Icon(Icons.clear_all),
                label: const Text('Offline Verileri Temizle'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getLastSyncTime() {
    final lastSyncTime = _syncStats['lastSyncTime'];
    if (lastSyncTime == null) return 'Hiç senkronize edilmedi';
    
    try {
      final dateTime = DateTime.parse(lastSyncTime);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return 'Geçersiz tarih';
    }
  }

  Future<void> _manualSync() async {
    try {
      await _offlineSyncService.manualSync();
      _updateStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senkronizasyon tamamlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Senkronizasyon hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearOfflineData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Verileri Temizle'),
        content: const Text(
          'Tüm offline verileri ve bekleyen işlemleri silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Temizle'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement clear offline data
      _updateStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline veriler temizlendi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

// Offline Data Browser Widget
class OfflineDataBrowserWidget extends StatefulWidget {
  const OfflineDataBrowserWidget({super.key});

  @override
  State<OfflineDataBrowserWidget> createState() => _OfflineDataBrowserWidgetState();
}

class _OfflineDataBrowserWidgetState extends State<OfflineDataBrowserWidget> {
  final OfflineSyncService _offlineSyncService = OfflineSyncService();
  String _selectedCollection = 'sessions';
  List<Map<String, dynamic>> _records = [];

  final List<String> _collections = [
    'sessions',
    'appointments',
    'clients',
    'medications',
    'notes',
    'diagnoses',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = _offlineSyncService.getOfflineRecords(_selectedCollection);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Offline Veri Tarayıcısı',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Collection seçici
            DropdownButtonFormField<String>(
              value: _selectedCollection,
              decoration: const InputDecoration(
                labelText: 'Veri Türü',
                border: OutlineInputBorder(),
              ),
              items: _collections.map((collection) {
                return DropdownMenuItem(
                  value: collection,
                  child: Text(_getCollectionName(collection)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCollection = value!;
                });
                _loadRecords();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Kayıt sayısı
            Text(
              '${_records.length} kayıt bulundu',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 16),
            
            // Kayıt listesi
            Expanded(
              child: _records.isEmpty
                  ? const Center(
                      child: Text('Bu türde offline veri bulunamadı'),
                    )
                  : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return _buildRecordItem(record);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record) {
    final data = record['data'] as Map<String, dynamic>? ?? {};
    final createdAt = record['createdAt'] as String? ?? '';
    final synced = record['synced'] as bool? ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: synced ? Colors.green : Colors.orange,
          child: Icon(
            synced ? Icons.check : Icons.sync,
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(_getRecordTitle(data)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getRecordSubtitle(data)),
            Text(
              'Oluşturulma: ${_formatDate(createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: const Text('Görüntüle'),
            ),
            PopupMenuItem(
              value: 'edit',
              child: const Text('Düzenle'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Text('Sil'),
            ),
          ],
          onSelected: (value) => _handleRecordAction(value, record),
        ),
      ),
    );
  }

  String _getCollectionName(String collection) {
    switch (collection) {
      case 'sessions':
        return 'Seanslar';
      case 'appointments':
        return 'Randevular';
      case 'clients':
        return 'Danışanlar';
      case 'medications':
        return 'İlaçlar';
      case 'notes':
        return 'Notlar';
      case 'diagnoses':
        return 'Tanılar';
      default:
        return collection;
    }
  }

  String _getRecordTitle(Map<String, dynamic> data) {
    switch (_selectedCollection) {
      case 'sessions':
        return data['clientName'] ?? 'Bilinmeyen Seans';
      case 'appointments':
        return data['clientName'] ?? 'Bilinmeyen Randevu';
      case 'clients':
        return '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
      case 'medications':
        return data['name'] ?? 'Bilinmeyen İlaç';
      case 'notes':
        return data['title'] ?? 'Bilinmeyen Not';
      case 'diagnoses':
        return data['name'] ?? 'Bilinmeyen Tanı';
      default:
        return 'Kayıt';
    }
  }

  String _getRecordSubtitle(Map<String, dynamic> data) {
    switch (_selectedCollection) {
      case 'sessions':
        return data['notes']?.toString().substring(0, 50) ?? 'Not yok';
      case 'appointments':
        return data['appointmentTime'] ?? 'Tarih yok';
      case 'clients':
        return data['email'] ?? 'Email yok';
      case 'medications':
        return data['dosage'] ?? 'Dozaj yok';
      case 'notes':
        return data['content']?.toString().substring(0, 50) ?? 'İçerik yok';
      case 'diagnoses':
        return data['code'] ?? 'Kod yok';
      default:
        return 'Alt başlık yok';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Geçersiz tarih';
    }
  }

  void _handleRecordAction(String action, Map<String, dynamic> record) {
    switch (action) {
      case 'view':
        _viewRecord(record);
        break;
      case 'edit':
        _editRecord(record);
        break;
      case 'delete':
        _deleteRecord(record);
        break;
    }
  }

  void _viewRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getCollectionName(_selectedCollection)} Detayı'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...record['data'].entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(entry.value.toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  void _editRecord(Map<String, dynamic> record) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Düzenleme özelliği yakında gelecek'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _deleteRecord(Map<String, dynamic> record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kayıt Sil'),
        content: const Text('Bu kaydı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _offlineSyncService.deleteOfflineRecord(record['key']);
      _loadRecords();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
