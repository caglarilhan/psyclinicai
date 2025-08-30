import 'package:flutter/material.dart';
import '../services/push_notification_service.dart';
import '../utils/theme.dart';

// Push Notification Center Widget
class PushNotificationCenterWidget extends StatefulWidget {
  const PushNotificationCenterWidget({super.key});

  @override
  State<PushNotificationCenterWidget> createState() => _PushNotificationCenterWidgetState();
}

class _PushNotificationCenterWidgetState extends State<PushNotificationCenterWidget> {
  final PushNotificationService _notificationService = PushNotificationService();
  List<Map<String, dynamic>> _notifications = [];
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    
    // Listen to new notifications
    _notificationService.notificationStream.listen((notification) {
      setState(() {
        _notifications.insert(0, notification);
      });
    });
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _notificationService.notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _selectedCategory == 'all' 
        ? _notifications 
        : _notifications.where((n) => n['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.notifications,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('Bildirimler'),
            if (_notificationService.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_notificationService.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showNotificationSettings,
            icon: const Icon(Icons.settings),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Tümünü Okundu İşaretle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Tümünü Temizle'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),
          
          // Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(filteredNotifications),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendTestNotification,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('all', 'Tümü'),
          ..._notificationService.categories.entries.map((entry) => 
            _buildCategoryChip(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    final count = category == 'all' 
        ? _notifications.length 
        : _notifications.where((n) => n['category'] == category).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bildirim yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bildirimler burada görünecek',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] == true;
    final category = notification['category'] ?? 'system';
    final categoryName = _notificationService.categories[category] ?? 'Sistem';
    final timestamp = notification['timestamp'] ?? '';
    final data = notification['data'] ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(category),
          child: Icon(
            _getCategoryIcon(category),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification['title'] ?? '',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['body'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCategoryColor(category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                _markAsRead(notification['id']);
                break;
              case 'delete':
                _deleteNotification(notification['id']);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Okundu İşaretle'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Sil'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'session':
        return Colors.blue;
      case 'appointment':
        return Colors.green;
      case 'emergency':
        return Colors.red;
      case 'reminder':
        return Colors.orange;
      case 'marketing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'session':
        return Icons.psychology;
      case 'appointment':
        return Icons.calendar_today;
      case 'emergency':
        return Icons.emergency;
      case 'reminder':
        return Icons.alarm;
      case 'marketing':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} gün önce';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} saat önce';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} dakika önce';
      } else {
        return 'Az önce';
      }
    } catch (e) {
      return '';
    }
  }

  void _markAsRead(String notificationId) {
    _notificationService.markAsRead(notificationId);
    _loadNotifications();
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    _loadNotifications();
  }

  void _deleteNotification(String notificationId) {
    _notificationService.deleteNotification(notificationId);
    _loadNotifications();
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Bildirimleri Temizle'),
        content: const Text('Tüm bildirimleri silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              _notificationService.clearNotifications();
              _loadNotifications();
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final category = notification['category'];
    final data = notification['data'] ?? {};

    switch (category) {
      case 'session':
        _handleSessionNotification(data);
        break;
      case 'appointment':
        _handleAppointmentNotification(data);
        break;
      case 'emergency':
        _handleEmergencyNotification(data);
        break;
      default:
        _showNotificationDetails(notification);
        break;
    }
  }

  void _handleSessionNotification(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seans Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Müşteri: ${data['clientName'] ?? 'Bilinmiyor'}'),
            Text('Seans Türü: ${data['sessionType'] ?? 'Bilinmiyor'}'),
            Text('Zaman: ${data['sessionTime'] ?? 'Bilinmiyor'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _handleAppointmentNotification(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevu Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Müşteri: ${data['clientName'] ?? 'Bilinmiyor'}'),
            Text('Randevu Türü: ${data['appointmentType'] ?? 'Bilinmiyor'}'),
            Text('Zaman: ${data['appointmentTime'] ?? 'Bilinmiyor'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _handleEmergencyNotification(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acil Durum'),
        content: const Text('Bu acil durum bildirimi. Lütfen hemen gerekli önlemleri alın.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? ''),
        content: Text(notification['body'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirim Ayarları'),
        content: const NotificationSettingsWidget(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() {
    _notificationService.sendNotification(
      title: 'Test Bildirimi',
      body: 'Bu bir test bildirimidir. ${DateTime.now().toString()}',
      category: 'system',
      data: {'type': 'test'},
    );
  }
}

// Notification Settings Widget
class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget> createState() => _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  final PushNotificationService _notificationService = PushNotificationService();
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.loadNotificationSettings();
    setState(() {
      _settings = settings;
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    setState(() {
      _settings[key] = value;
    });
    await _notificationService.updateNotificationSettings(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 400,
      child: ListView(
        children: [
          _buildSettingSwitch(
            'Seans Hatırlatmaları',
            'sessionReminders',
            Icons.psychology,
          ),
          _buildSettingSwitch(
            'Randevu Hatırlatmaları',
            'appointmentReminders',
            Icons.calendar_today,
          ),
          _buildSettingSwitch(
            'Acil Durum Bildirimleri',
            'emergencyNotifications',
            Icons.emergency,
          ),
          _buildSettingSwitch(
            'Pazarlama Bildirimleri',
            'marketingNotifications',
            Icons.campaign,
          ),
          _buildSettingSwitch(
            'Sistem Bildirimleri',
            'systemNotifications',
            Icons.settings,
          ),
          const Divider(),
          _buildSettingSwitch(
            'Ses',
            'soundEnabled',
            Icons.volume_up,
          ),
          _buildSettingSwitch(
            'Titreşim',
            'vibrationEnabled',
            Icons.vibration,
          ),
          _buildSettingSwitch(
            'Sessiz Saatler',
            'quietHoursEnabled',
            Icons.bedtime,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(String title, String key, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: Switch(
        value: _settings[key] ?? false,
        onChanged: (value) => _updateSetting(key, value),
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}

// Notification Stats Widget
class NotificationStatsWidget extends StatefulWidget {
  const NotificationStatsWidget({super.key});

  @override
  State<NotificationStatsWidget> createState() => _NotificationStatsWidgetState();
}

class _NotificationStatsWidgetState extends State<NotificationStatsWidget> {
  final PushNotificationService _notificationService = PushNotificationService();
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _stats = _notificationService.getNotificationStats();
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
                  Icons.notifications,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bildirim İstatistikleri',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatItem(
              'Toplam Bildirim',
              '${_stats['totalNotifications'] ?? 0}',
              Icons.notifications,
              Colors.blue,
            ),
            
            _buildStatItem(
              'Okunmamış',
              '${_stats['unreadCount'] ?? 0}',
              Icons.mark_email_unread,
              Colors.orange,
            ),
            
            _buildStatItem(
              'Zamanlanmış',
              '${_stats['scheduledCount'] ?? 0}',
              Icons.schedule,
              Colors.green,
            ),
            
            _buildStatItem(
              'Aktif Zamanlanmış',
              '${_stats['activeScheduledCount'] ?? 0}',
              Icons.timer,
              Colors.purple,
            ),
            
            _buildStatItem(
              'İzin Durumu',
              _stats['hasPermission'] == true ? 'Verildi' : 'Verilmedi',
              Icons.security,
              _stats['hasPermission'] == true ? Colors.green : Colors.red,
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
}
