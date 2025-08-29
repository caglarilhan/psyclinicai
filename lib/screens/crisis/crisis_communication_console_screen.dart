import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/crisis_communication_service.dart';
import '../../services/flag_system_service.dart';
import '../../models/flag_system_models.dart';

/// Kriz İletişim Konsolu Ekranı
/// Tüm kriz iletişim girişimlerini görüntüler ve yönetir
class CrisisCommunicationConsoleScreen extends StatefulWidget {
  const CrisisCommunicationConsoleScreen({super.key});

  @override
  State<CrisisCommunicationConsoleScreen> createState() => _CrisisCommunicationConsoleScreenState();
}

class _CrisisCommunicationConsoleScreenState extends State<CrisisCommunicationConsoleScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 Kriz İletişim Konsolu'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CrisisCommunicationService>().notifyListeners();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<CrisisCommunicationService>(
              builder: (context, communicationService, child) {
                final communications = communicationService.communicationHistory;
                final filteredCommunications = _filterCommunications(communications);
                
                if (filteredCommunications.isEmpty) {
                  return const Center(
                    child: Text('Henüz iletişim girişimi bulunmuyor'),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredCommunications.length,
                  itemBuilder: (context, index) {
                    final communication = filteredCommunications[index];
                    return _buildCommunicationCard(communication);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTestCrisisDialog(context),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.phone),
        label: const Text('Test Kriz'),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Filtre çipleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tümü'),
                  selected: _selectedFilter == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'all';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Telefon'),
                  selected: _selectedFilter == 'phone_call',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'phone_call';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('SMS'),
                  selected: _selectedFilter == 'sms',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'sms';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Email'),
                  selected: _selectedFilter == 'email',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'email';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Acil Servis'),
                  selected: _selectedFilter == 'emergency_service',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = 'emergency_service';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Arama çubuğu
          TextField(
            decoration: InputDecoration(
              hintText: 'İletişim ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationCard(Map<String, dynamic> communication) {
    final type = communication['type'] as String;
    final status = communication['status'] as String;
    final target = communication['target'] as String;
    final timestamp = DateTime.parse(communication['timestamp']);
    final metadata = communication['metadata'] as Map<String, dynamic>;
    
    // İletişim türüne göre icon ve renk
    IconData icon;
    Color color;
    String typeText;
    
    switch (type) {
      case 'phone_call':
        icon = Icons.phone;
        color = Colors.green;
        typeText = 'Telefon Araması';
        break;
      case 'sms':
        icon = Icons.sms;
        color = Colors.blue;
        typeText = 'SMS';
        break;
      case 'email':
        icon = Icons.email;
        color = Colors.orange;
        typeText = 'Email';
        break;
      case 'emergency_service':
        icon = Icons.emergency;
        color = Colors.red;
        typeText = 'Acil Servis';
        break;
      case 'emergency_contact':
        icon = Icons.contact_emergency;
        color = Colors.purple;
        typeText = 'Acil Durum Kişisi';
        break;
      default:
        icon = Icons.message;
        color = Colors.grey;
        typeText = 'Bilinmeyen';
    }

    // Duruma göre renk
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'successful':
        statusColor = Colors.green;
        statusText = 'Başarılı';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = 'Başarısız';
        break;
      case 'attempting':
        statusColor = Colors.orange;
        statusText = 'Deneniyor';
        break;
      case 'pending':
        statusColor = Colors.grey;
        statusText = 'Bekliyor';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Bilinmeyen';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hedef: $target',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Zaman: ${_formatDateTime(timestamp)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (metadata['patientName'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hasta: ${metadata['patientName']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (metadata['crisisType'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Kriz Türü: ${metadata['crisisType']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (metadata['severity'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Şiddet: ${metadata['severity']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (communication['completedAt'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Tamamlanma: ${_formatDateTime(DateTime.parse(communication['completedAt']))}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCommunicationDetails(communication),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Detaylar'),
                  ),
                ),
                const SizedBox(width: 8),
                if (status == 'failed') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _retryCommunication(communication),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterCommunications(List<Map<String, dynamic>> communications) {
    var filtered = communications;
    
    // Tür filtresi
    if (_selectedFilter != 'all') {
      filtered = filtered.where((c) => c['type'] == _selectedFilter).toList();
    }
    
    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final target = c['target'].toString().toLowerCase();
        final patientName = c['metadata']?['patientName']?.toString().toLowerCase() ?? '';
        final crisisType = c['metadata']?['crisisType']?.toString().toLowerCase() ?? '';
        
        return target.contains(_searchQuery.toLowerCase()) ||
               patientName.contains(_searchQuery.toLowerCase()) ||
               crisisType.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showCommunicationDetails(Map<String, dynamic> communication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İletişim Detayları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${communication['id']}'),
              Text('Tür: ${communication['type']}'),
              Text('Hedef: ${communication['target']}'),
              Text('Durum: ${communication['status']}'),
              Text('Zaman: ${_formatDateTime(DateTime.parse(communication['timestamp']))}'),
              if (communication['completedAt'] != null)
                Text('Tamamlanma: ${_formatDateTime(DateTime.parse(communication['completedAt']))}'),
              const SizedBox(height: 16),
              const Text('Meta Veriler:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...communication['metadata'].entries.map((entry) => 
                Text('${entry.key}: ${entry.value}'),
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

  void _retryCommunication(Map<String, dynamic> communication) {
    // Tekrar deneme işlemi (gerçek uygulamada implement edilecek)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İletişim tekrar deneniyor...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showTestCrisisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Kriz Oluştur'),
        content: const Text('Test amaçlı bir kriz flag\'ı oluşturmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createTestCrisis();
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _createTestCrisis() async {
    try {
      final flagService = context.read<FlagSystemService>();
      await flagService.createCrisisFlag(
        patientId: 'test_patient_001',
        clinicianId: 'test_clinician_001',
        type: CrisisType.suicidalIdeation,
        severity: CrisisSeverity.critical,
        description: 'Test kriz durumu - Otomatik iletişim testi',
        symptoms: ['Test belirti 1', 'Test belirti 2'],
        riskFactors: ['Test risk faktörü'],
        immediateActions: ['Test eylem'],
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test kriz oluşturuldu! İletişim başlatılıyor...'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
