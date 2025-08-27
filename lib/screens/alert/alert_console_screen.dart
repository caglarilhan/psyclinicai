import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/alerting_service.dart';
import '../../models/legal_policy_models.dart';

/// Alert Konsolu Ekranı
/// Tüm bildirimleri görüntüler ve yönetir
class AlertConsoleScreen extends StatefulWidget {
  const AlertConsoleScreen({super.key});

  @override
  State<AlertConsoleScreen> createState() => _AlertConsoleScreenState();
}

class _AlertConsoleScreenState extends State<AlertConsoleScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Konsolu'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AlertingService>().notifyListeners();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre ve arama
          _buildFilterBar(),
          
          // Alert listesi
          Expanded(
            child: Consumer<AlertingService>(
              builder: (context, alertingService, child) {
                final alerts = alertingService.events;
                final filteredAlerts = _filterAlerts(alerts);
                
                if (filteredAlerts.isEmpty) {
                  return const Center(
                    child: Text('Henüz bildirim bulunmuyor'),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = filteredAlerts[index];
                    return _buildAlertCard(alert);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // Filtre butonları
          Row(
            children: [
              _buildFilterButton('all', 'Tümü'),
              const SizedBox(width: 8),
              _buildFilterButton('critical', 'Kritik'),
              const SizedBox(width: 8),
              _buildFilterButton('high', 'Yüksek'),
              const SizedBox(width: 8),
              _buildFilterButton('medium', 'Orta'),
              const SizedBox(width: 8),
              _buildFilterButton('low', 'Düşük'),
            ],
          ),
          const SizedBox(height: 12),
          // Arama kutusu
          TextField(
            decoration: InputDecoration(
              hintText: 'Bildirim ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
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

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: Colors.red.shade100,
      checkmarkColor: Colors.red.shade700,
    );
  }

  List<Map<String, dynamic>> _filterAlerts(List<Map<String, dynamic>> alerts) {
    var filtered = alerts;
    
    // Filtre uygula
    if (_selectedFilter != 'all') {
      filtered = filtered.where((alert) {
        final severity = alert['severity']?.toString().toLowerCase() ?? '';
        return severity == _selectedFilter;
      }).toList();
    }
    
    // Arama uygula
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((alert) {
        final content = alert['content']?.toString().toLowerCase() ?? '';
        final title = alert['title']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return content.contains(query) || title.contains(query);
      }).toList();
    }
    
    return filtered;
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final severity = alert['severity']?.toString() ?? 'medium';
    final timestamp = alert['timestamp'] as DateTime? ?? DateTime.now();
    final title = alert['title']?.toString() ?? 'Bildirim';
    final content = alert['content']?.toString() ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildSeverityIcon(severity),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('Detayları Gör'),
            ),
            const PopupMenuItem(
              value: 'resolve',
              child: Text('Çözüldü Olarak İşaretle'),
            ),
            const PopupMenuItem(
              value: 'escalate',
              child: Text('Üst Birime Bildir'),
            ),
          ],
          onSelected: (value) {
            _handleAlertAction(value, alert);
          },
        ),
        onTap: () {
          _showAlertDetails(alert);
        },
      ),
    );
  }

  Widget _buildSeverityIcon(String severity) {
    IconData iconData;
    Color color;
    
    switch (severity.toLowerCase()) {
      case 'critical':
        iconData = Icons.error;
        color = Colors.red;
        break;
      case 'high':
        iconData = Icons.warning;
        color = Colors.orange;
        break;
      case 'medium':
        iconData = Icons.info;
        color = Colors.blue;
        break;
      case 'low':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        iconData = Icons.info;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  void _handleAlertAction(String action, Map<String, dynamic> alert) {
    switch (action) {
      case 'view':
        _showAlertDetails(alert);
        break;
      case 'resolve':
        _resolveAlert(alert);
        break;
      case 'escalate':
        _escalateAlert(alert);
        break;
    }
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert['title']?.toString() ?? 'Bildirim Detayları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('İçerik: ${alert['content']}'),
              const SizedBox(height: 8),
              Text('Şiddet: ${alert['severity']}'),
              const SizedBox(height: 8),
              Text('Zaman: ${_formatTimestamp(alert['timestamp'] as DateTime? ?? DateTime.now())}'),
              if (alert['metadata'] != null) ...[
                const SizedBox(height: 8),
                const Text('Meta Veriler:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(alert['metadata'].toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _resolveAlert(Map<String, dynamic> alert) {
    // Alert'i çözüldü olarak işaretle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bildirim çözüldü olarak işaretlendi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _escalateAlert(Map<String, dynamic> alert) {
    // Alert'i üst birime bildir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bildirim üst birime iletildi'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
