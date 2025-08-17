import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/offline_sync_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/biometric_auth_service.dart';
import '../../services/theme_service.dart';

class OfflineModeWidget extends StatefulWidget {
  const OfflineModeWidget({Key? key}) : super(key: key);

  @override
  State<OfflineModeWidget> createState() => _OfflineModeWidgetState();
}

class _OfflineModeWidgetState extends State<OfflineModeWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Services
  final OfflineSyncService _offlineSyncService = OfflineSyncService();
  final PushNotificationService _pushNotificationService = PushNotificationService();
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final ThemeService _themeService = ThemeService();

  // State variables
  bool _isOnline = false;
  bool _isSyncing = false;
  SyncStatus? _syncStatus;
  BiometricStatus _biometricStatus = BiometricStatus.unknown;
  bool _isDarkMode = false;
  bool _isExpanded = false;

  // Stream subscriptions
  StreamSubscription<bool>? _onlineStatusSubscription;
  StreamSubscription<SyncProgress>? _syncProgressSubscription;
  StreamSubscription<SyncError>? _syncErrorSubscription;
  StreamSubscription<BiometricStatus>? _biometricStatusSubscription;
  StreamSubscription<bool>? _darkModeSubscription;

  @override
  void initState() {
    super.initState();
    
    // Animation controllers
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Animations
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Initialize services and listeners
    _initializeServices();
    _setupStreamListeners();
  }

  Future<void> _initializeServices() async {
    try {
      await _offlineSyncService.initialize();
      await _pushNotificationService.initialize();
      await _biometricAuthService.initialize();
      await _themeService.initialize();
      
      // Initial status
      _updateOnlineStatus(_offlineSyncService.isOnline);
      _updateBiometricStatus(_biometricAuthService.currentStatus);
      _updateDarkMode(_themeService.isDarkMode);
      
      // Get initial sync status
      _updateSyncStatus(await _offlineSyncService.getSyncStatus());
      
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  void _setupStreamListeners() {
    // Online status
    _onlineStatusSubscription = _offlineSyncService.onlineStatusStream.listen((isOnline) {
      _updateOnlineStatus(isOnline);
    });

    // Sync progress
    _syncProgressSubscription = _offlineSyncService.syncProgressStream.listen((progress) {
      _updateSyncProgress(progress);
    });

    // Sync errors
    _syncErrorSubscription = _offlineSyncService.syncErrorStream.listen((error) {
      _showSyncError(error);
    });

    // Biometric status
    _biometricStatusSubscription = _biometricAuthService.statusStream.listen((status) {
      _updateBiometricStatus(status);
    });

    // Dark mode
    _darkModeSubscription = _themeService.darkModeStream.listen((isDark) {
      _updateDarkMode(isDark);
    });
  }

  void _updateOnlineStatus(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });
    
    if (isOnline) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _updateSyncStatus(SyncStatus status) {
    setState(() {
      _syncStatus = status;
      _isSyncing = status.isSyncing;
    });
  }

  void _updateSyncProgress(SyncProgress progress) {
    if (progress.status == 'syncing') {
      setState(() {
        _isSyncing = true;
      });
    } else if (progress.status == 'completed') {
      setState(() {
        _isSyncing = false;
      });
      
      // Refresh sync status
      _offlineSyncService.getSyncStatus().then(_updateSyncStatus);
    }
  }

  void _updateBiometricStatus(BiometricStatus status) {
    setState(() {
      _biometricStatus = status;
    });
  }

  void _updateDarkMode(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _showSyncError(SyncError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sync Hatası: ${error.message}'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Tekrar Dene',
          textColor: Colors.white,
          onPressed: () => _triggerManualSync(),
        ),
      ),
    );
  }

  Future<void> _triggerManualSync() async {
    try {
      await _offlineSyncService.triggerManualSync();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync başlatılamadı: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isOnline ? _pulseAnimation.value : 1.0,
            child: _buildMainWidget(),
          );
        },
      ),
    );
  }

  Widget _buildMainWidget() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: _isExpanded ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          if (_isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      leading: _buildStatusIcon(),
      title: Text(
        _isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _isOnline ? Colors.green : Colors.red,
        ),
      ),
      subtitle: _buildSubtitle(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSyncing) _buildSyncIndicator(),
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: _toggleExpanded,
          ),
        ],
      ),
      onTap: _toggleExpanded,
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color iconColor;
    
    if (_isOnline) {
      iconData = Icons.wifi;
      iconColor = Colors.green;
    } else {
      iconData = Icons.wifi_off;
      iconColor = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildSubtitle() {
    if (_isSyncing) {
      return const Text('Senkronize ediliyor...');
    } else if (_syncStatus != null) {
      if (_syncStatus!.needsSync) {
        return Text('${_syncStatus!.pendingRecords} kayıt bekliyor');
      } else {
        return const Text('Güncel');
      }
    } else {
      return const Text('Durum kontrol ediliyor...');
    }
  }

  Widget _buildSyncIndicator() {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: 8),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSyncStatusSection(),
          const SizedBox(height: 16),
          _buildBiometricSection(),
          const SizedBox(height: 16),
          _buildThemeSection(),
          const SizedBox(height: 16),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildSyncStatusSection() {
    if (_syncStatus == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senkronizasyon Durumu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildSyncProgressBar(),
        const SizedBox(height: 8),
        _buildSyncStats(),
      ],
    );
  }

  Widget _buildSyncProgressBar() {
    final progress = _syncStatus!.syncProgress / 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            _syncStatus!.hasErrors ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_syncStatus!.syncProgress.toStringAsFixed(1)}% tamamlandı',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSyncStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Toplam',
            '${_syncStatus!.totalRecords}',
            Icons.storage,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Bekleyen',
            '${_syncStatus!.pendingRecords}',
            Icons.pending,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Senkron',
            '${_syncStatus!.syncedRecords}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Hata',
            '${_syncStatus!.errorRecords}',
            Icons.error,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biyometrik Kimlik Doğrulama',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _getBiometricIcon(),
              color: _getBiometricColor(),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getBiometricStatusText(),
                style: TextStyle(
                  color: _getBiometricColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: _biometricStatus == BiometricStatus.enabled,
              onChanged: _biometricStatus == BiometricStatus.available
                  ? (value) => _toggleBiometric(value)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  IconData _getBiometricIcon() {
    switch (_biometricStatus) {
      case BiometricStatus.enabled:
        return Icons.fingerprint;
      case BiometricStatus.available:
        return Icons.fingerprint_outlined;
      case BiometricStatus.notAvailable:
        return Icons.fingerprint;
      case BiometricStatus.notSupported:
        return Icons.device_unknown;
      case BiometricStatus.error:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getBiometricColor() {
    switch (_biometricStatus) {
      case BiometricStatus.enabled:
        return Colors.green;
      case BiometricStatus.available:
        return Colors.blue;
      case BiometricStatus.notAvailable:
        return Colors.orange;
      case BiometricStatus.notSupported:
        return Colors.grey;
      case BiometricStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getBiometricStatusText() {
    switch (_biometricStatus) {
      case BiometricStatus.enabled:
        return 'Etkin';
      case BiometricStatus.available:
        return 'Kullanılabilir';
      case BiometricStatus.notAvailable:
        return 'Kullanılamaz';
      case BiometricStatus.notSupported:
        return 'Desteklenmiyor';
      case BiometricStatus.error:
        return 'Hata';
      default:
        return 'Bilinmiyor';
    }
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: _isDarkMode ? Colors.purple : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isDarkMode ? 'Koyu Tema' : 'Açık Tema',
                style: TextStyle(
                  color: _isDarkMode ? Colors.purple : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: _isDarkMode,
              onChanged: (value) => _toggleTheme(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eylemler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Senkron Et'),
                onPressed: _isOnline && !_isSyncing ? _triggerManualSync : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Ayarlar'),
                onPressed: () => _showSettingsDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _toggleBiometric(bool enabled) async {
    try {
      if (enabled) {
        await _biometricAuthService.enableBiometric();
      } else {
        await _biometricAuthService.disableBiometric();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biyometrik ayar değiştirilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleTheme() async {
    try {
      await _themeService.toggleDarkMode();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tema değiştirilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const OfflineSettingsDialog(),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    
    _onlineStatusSubscription?.cancel();
    _syncProgressSubscription?.cancel();
    _syncErrorSubscription?.cancel();
    _biometricStatusSubscription?.cancel();
    _darkModeSubscription?.cancel();
    
    super.dispose();
  }
}

// Settings Dialog
class OfflineSettingsDialog extends StatefulWidget {
  const OfflineSettingsDialog({Key? key}) : super(key: key);

  @override
  State<OfflineSettingsDialog> createState() => _OfflineSettingsDialogState();
}

class _OfflineSettingsDialogState extends State<OfflineSettingsDialog> {
  final OfflineSyncService _offlineSyncService = OfflineSyncService();
  final PushNotificationService _pushNotificationService = PushNotificationService();
  
  Map<String, bool> _notificationSettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _pushNotificationService.getNotificationSettings();
      setState(() {
        _notificationSettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    try {
      _notificationSettings[key] = value;
      
      await _pushNotificationService.updateNotificationSettings(
        appointmentReminders: _notificationSettings['appointment_reminders'] ?? true,
        medicationReminders: _notificationSettings['medication_reminders'] ?? true,
        emergencyAlerts: _notificationSettings['emergency_alerts'] ?? true,
        systemUpdates: _notificationSettings['system_updates'] ?? false,
        soundEnabled: _notificationSettings['sound_enabled'] ?? true,
        vibrationEnabled: _notificationSettings['vibration_enabled'] ?? true,
      );
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ayar güncellenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Offline Mod Ayarları'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bildirim Ayarları',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNotificationSetting(
                    'Randevu Hatırlatıcıları',
                    'appointment_reminders',
                    Icons.calendar_today,
                  ),
                  _buildNotificationSetting(
                    'İlaç Hatırlatıcıları',
                    'medication_reminders',
                    Icons.medication,
                  ),
                  _buildNotificationSetting(
                    'Acil Durum Uyarıları',
                    'emergency_alerts',
                    Icons.warning,
                  ),
                  _buildNotificationSetting(
                    'Sistem Güncellemeleri',
                    'system_updates',
                    Icons.system_update,
                  ),
                  _buildNotificationSetting(
                    'Ses',
                    'sound_enabled',
                    Icons.volume_up,
                  ),
                  _buildNotificationSetting(
                    'Titreşim',
                    'vibration_enabled',
                    Icons.vibration,
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        ElevatedButton(
          onPressed: () => _clearOfflineData(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Verileri Temizle'),
        ),
      ],
    );
  }

  Widget _buildNotificationSetting(String title, String key, IconData icon) {
    return SwitchListTile(
      title: Text(title),
      secondary: Icon(icon),
      value: _notificationSettings[key] ?? false,
      onChanged: (value) => _updateNotificationSetting(key, value),
    );
  }

  Future<void> _clearOfflineData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Temizle'),
        content: const Text(
          'Tüm offline veriler silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _offlineSyncService.clearOfflineData();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline veriler temizlendi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler temizlenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
