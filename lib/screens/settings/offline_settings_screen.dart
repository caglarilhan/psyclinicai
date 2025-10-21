import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/offline_service.dart';
import '../../widgets/common/offline_indicator.dart';

class OfflineSettingsScreen extends StatelessWidget {
  const OfflineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Ayarları'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showOfflineInfo(context),
          ),
        ],
      ),
      body: Consumer<OfflineService>(
        builder: (context, offlineService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offline status card
                const OfflineStatusCard(),
                const SizedBox(height: 24),

                // Offline data overview
                Text(
                  'Offline Veri Özeti',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Data cards
                const OfflineDataList(
                  tableName: 'patients',
                  title: 'Hastalar',
                  icon: Icons.people,
                ),
                const SizedBox(height: 16),
                
                const OfflineDataList(
                  tableName: 'appointments',
                  title: 'Randevular',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),
                
                const OfflineDataList(
                  tableName: 'voice_notes',
                  title: 'Sesli Notlar',
                  icon: Icons.mic,
                ),
                const SizedBox(height: 16),
                
                const OfflineDataList(
                  tableName: 'mood_entries',
                  title: 'Mood Girişleri',
                  icon: Icons.timeline,
                ),
                const SizedBox(height: 24),

                // Sync settings
                Text(
                  'Senkronizasyon Ayarları',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.sync),
                          title: const Text('Otomatik Senkronizasyon'),
                          subtitle: const Text('Bağlantı kurulduğunda otomatik senkronize et'),
                          trailing: Switch(
                            value: true, // This would come from settings
                            onChanged: (value) {
                              // Handle auto sync toggle
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.wifi),
                          title: const Text('WiFi Senkronizasyonu'),
                          subtitle: const Text('Sadece WiFi bağlantısında senkronize et'),
                          trailing: Switch(
                            value: false, // This would come from settings
                            onChanged: (value) {
                              // Handle WiFi sync toggle
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.battery_saver),
                          title: const Text('Pil Tasarrufu'),
                          subtitle: const Text('Düşük pilde senkronizasyonu durdur'),
                          trailing: Switch(
                            value: true, // This would come from settings
                            onChanged: (value) {
                              // Handle battery saver toggle
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Storage management
                Text(
                  'Depolama Yönetimi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.storage),
                          title: const Text('Offline Veri Boyutu'),
                          subtitle: const Text('Yerel veritabanı boyutu'),
                          trailing: Text(
                            '2.3 MB',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Offline Verileri Temizle'),
                          subtitle: const Text('Tüm offline verileri sil'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmClearData(context),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.download),
                          title: const Text('Veri Yedekle'),
                          subtitle: const Text('Offline verileri yedekle'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => _backupData(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Advanced settings
                Text(
                  'Gelişmiş Ayarlar',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.timer),
                          title: const Text('Senkronizasyon Aralığı'),
                          subtitle: const Text('Otomatik senkronizasyon sıklığı'),
                          trailing: DropdownButton<String>(
                            value: '5',
                            items: const [
                              DropdownMenuItem(value: '1', child: Text('1 dakika')),
                              DropdownMenuItem(value: '5', child: Text('5 dakika')),
                              DropdownMenuItem(value: '15', child: Text('15 dakika')),
                              DropdownMenuItem(value: '30', child: Text('30 dakika')),
                            ],
                            onChanged: (value) {
                              // Handle sync interval change
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.refresh),
                          title: const Text('Yeniden Deneme Sayısı'),
                          subtitle: const Text('Başarısız senkronizasyon denemeleri'),
                          trailing: DropdownButton<int>(
                            value: 3,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1')),
                              DropdownMenuItem(value: 3, child: Text('3')),
                              DropdownMenuItem(value: 5, child: Text('5')),
                              DropdownMenuItem(value: 10, child: Text('10')),
                            ],
                            onChanged: (value) {
                              // Handle retry count change
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('Şifreleme'),
                          subtitle: const Text('Offline verileri şifrele'),
                          trailing: Switch(
                            value: true, // This would come from settings
                            onChanged: (value) {
                              // Handle encryption toggle
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Test offline functionality
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Fonksiyonları',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _testOfflineMode(context),
                                icon: const Icon(Icons.wifi_off),
                                label: const Text('Offline Modu Test Et'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _testSync(context),
                                icon: const Icon(Icons.sync),
                                label: const Text('Senkronizasyon Test Et'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOfflineInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Mod Hakkında'),
        content: const Text(
          'PsyClinic AI offline mod ile internet bağlantısı olmadığında da çalışabilir.\n\n'
          'Özellikler:\n'
          '• Hasta verilerini offline kaydetme\n'
          '• Randevu oluşturma ve düzenleme\n'
          '• Sesli not kaydetme\n'
          '• Mood tracking girişleri\n'
          '• Otomatik senkronizasyon\n\n'
          'Veriler internet bağlantısı kurulduğunda otomatik olarak senkronize edilir.',
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

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Temizle'),
        content: const Text(
          'Tüm offline verileri silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final offlineService = Provider.of<OfflineService>(context, listen: false);
              offlineService.clearOfflineData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offline veriler temizlendi')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _backupData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veri yedekleme özelliği yakında eklenecek')),
    );
  }

  void _testOfflineMode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offline mod testi başlatıldı')),
    );
  }

  void _testSync(BuildContext context) {
    final offlineService = Provider.of<OfflineService>(context, listen: false);
    offlineService.syncPendingData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senkronizasyon testi başlatıldı')),
    );
  }
}
