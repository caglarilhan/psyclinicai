import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/session-management'),
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/appointment-calendar'),
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PsyClinicAI Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hoş Geldin Mesajı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoş geldiniz, Dr. Örnek',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Bugün ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // İstatistik Kartları
            Text(
              'Genel Bakış',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Toplam Hasta',
                  '24',
                  Icons.people,
                  AppTheme.primaryColor,
                ),
                _buildStatCard(
                  'Bu Ay Seans',
                  '18',
                  Icons.event,
                  Colors.green,
                ),
                _buildStatCard(
                  'Bekleyen Randevu',
                  '7',
                  Icons.schedule,
                  Colors.orange,
                ),
                _buildStatCard(
                  'AI Tanı',
                  '12',
                  Icons.psychology,
                  Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Hızlı İşlemler
            Text(
              'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildQuickActionCard(
                  'Yeni Hasta',
                  Icons.person_add,
                  AppTheme.primaryColor,
                  () => Navigator.pushNamed(context, '/client-management'),
                ),
                _buildQuickActionCard(
                  'Randevu Oluştur',
                  Icons.add_circle,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/appointment-calendar'),
                ),
                _buildQuickActionCard(
                  'Seans Notu',
                  Icons.note_add,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/session-management'),
                ),
                _buildQuickActionCard(
                  'AI Tanı',
                  Icons.psychology,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/diagnosis'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Son Aktiviteler
            Text(
              'Son Aktiviteler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        _getActivityIcon(index),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(_getActivityTitle(index)),
                    subtitle: Text(_getActivitySubtitle(index)),
                    trailing: Text(
                      _getActivityTime(index),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month];
  }

  IconData _getActivityIcon(int index) {
    const icons = [
      Icons.person_add,
      Icons.event,
      Icons.note_add,
      Icons.psychology,
      Icons.schedule,
    ];
    return icons[index];
  }

  String _getActivityTitle(int index) {
    const titles = [
      'Yeni hasta eklendi',
      'Randevu oluşturuldu',
      'Seans notu güncellendi',
      'AI tanı tamamlandı',
      'Randevu hatırlatması',
    ];
    return titles[index];
  }

  String _getActivitySubtitle(int index) {
    const subtitles = [
      'Ahmet Yılmaz',
      'Bugün 14:00',
      'Depresyon seansı',
      'Anksiyete bozukluğu',
      'Yarın 10:00',
    ];
    return subtitles[index];
  }

  String _getActivityTime(int index) {
    const times = [
      '2 saat önce',
      '4 saat önce',
      '1 gün önce',
      '2 gün önce',
      '3 gün önce',
    ];
    return times[index];
  }
}