import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class OfflineModeWidget extends StatefulWidget {
  const OfflineModeWidget({super.key});

  @override
  State<OfflineModeWidget> createState() => _OfflineModeWidgetState();
}

class _OfflineModeWidgetState extends State<OfflineModeWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _syncController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _syncAnimation;

  bool _isOffline = true;
  bool _isSyncing = false;
  int _syncedItems = 0;
  int _totalItems = 15;

  final List<OfflineItem> _offlineItems = [
    OfflineItem(
      id: '1',
      title: 'Seans Notları',
      type: OfflineItemType.session,
      size: '2.3 MB',
      lastSync: DateTime.now().subtract(const Duration(hours: 3)),
      isSynced: false,
    ),
    OfflineItem(
      id: '2',
      title: 'İlaç Veritabanı',
      type: OfflineItemType.medication,
      size: '15.7 MB',
      lastSync: DateTime.now().subtract(const Duration(days: 1)),
      isSynced: true,
    ),
    OfflineItem(
      id: '3',
      title: 'Eğitim Materyalleri',
      type: OfflineItemType.education,
      size: '8.9 MB',
      lastSync: DateTime.now().subtract(const Duration(days: 2)),
      isSynced: false,
    ),
    OfflineItem(
      id: '4',
      title: 'Hasta Rehberleri',
      type: OfflineItemType.guide,
      size: '5.2 MB',
      lastSync: DateTime.now().subtract(const Duration(hours: 12)),
      isSynced: true,
    ),
    OfflineItem(
      id: '5',
      title: 'Tanı Kodları',
      type: OfflineItemType.diagnosis,
      size: '3.1 MB',
      lastSync: DateTime.now().subtract(const Duration(days: 3)),
      isSynced: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkConnectionStatus();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _syncController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _syncAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _syncController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _checkConnectionStatus() {
    // Simulate connection check
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isOffline = false;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _syncController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.blue.shade50,
            Colors.indigo.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _isOffline ? Colors.grey.shade600 : Colors.blue.shade600,
                  _isOffline ? Colors.grey.shade500 : Colors.indigo.shade600,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          _isOffline ? Icons.cloud_off : Icons.cloud_sync,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOffline ? 'Çevrimdışı Mod' : 'Çevrimiçi Mod',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _isOffline
                            ? 'İnternet bağlantısı yok, çevrimdışı içerikler kullanılabilir'
                            : 'İnternet bağlantısı mevcut, senkronizasyon yapılabilir',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isOffline ? Icons.wifi_off : Icons.wifi,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Status
                  _buildConnectionStatus(),
                  const SizedBox(height: 24),

                  // Sync Progress
                  if (!_isOffline) ...[
                    _buildSyncProgress(),
                    const SizedBox(height: 24),
                  ],

                  // Offline Content
                  _buildOfflineContent(),
                  const SizedBox(height: 24),

                  // Sync Actions
                  if (!_isOffline) ...[
                    _buildSyncActions(),
                    const SizedBox(height: 24),
                  ],

                  // Offline Features
                  _buildOfflineFeatures(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOffline ? Colors.grey.shade300 : Colors.blue.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isOffline ? Colors.grey.shade100 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isOffline ? Icons.cloud_off : Icons.cloud_done,
              color: _isOffline ? Colors.grey.shade600 : Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOffline ? 'Çevrimdışı' : 'Çevrimiçi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isOffline
                            ? Colors.grey.shade700
                            : Colors.blue.shade700,
                      ),
                ),
                Text(
                  _isOffline
                      ? 'İnternet bağlantısı yok, çevrimdışı içerikler kullanılabilir'
                      : 'İnternet bağlantısı mevcut, tüm özellikler kullanılabilir',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isOffline ? Colors.grey.shade200 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isOffline ? Icons.signal_wifi_off : Icons.signal_wifi_4_bar,
              color: _isOffline ? Colors.grey.shade600 : Colors.green.shade600,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sync, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Senkronizasyon Durumu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Senkronize Edilen',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_syncedItems/$_totalItems',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toplam Boyut',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '35.2 MB',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _syncAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _syncAnimation.value * (_syncedItems / _totalItems),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çevrimdışı İçerikler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._offlineItems.map((item) => _buildOfflineItemCard(item)),
      ],
    );
  }

  Widget _buildOfflineItemCard(OfflineItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isSynced ? Colors.green.shade300 : Colors.orange.shade300,
          width: item.isSynced ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getItemTypeColor(item.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getItemTypeIcon(item.type),
              color: _getItemTypeColor(item.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (item.isSynced) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${item.size} • ${_formatLastSync(item.lastSync)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          if (!item.isSynced && !_isOffline) ...[
            IconButton(
              onPressed: () => _syncItem(item),
              icon: Icon(
                Icons.sync,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senkronizasyon',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _startFullSync,
                icon: _isSyncing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isSyncing
                    ? 'Senkronize Ediliyor...'
                    : 'Tam Senkronizasyon'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSyncing ? null : _checkForUpdates,
                icon: const Icon(Icons.update),
                label: const Text('Güncellemeleri Kontrol Et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo.shade600,
                  side: BorderSide(color: Colors.indigo.shade600),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineFeatures() {
    final offlineFeatures = [
      OfflineFeature(
        title: 'Çevrimdışı İlaç Rehberi',
        description: 'Temel ilaç bilgileri ve etkileşimler',
        icon: Icons.medication,
        color: Colors.green,
        isAvailable: true,
      ),
      OfflineFeature(
        title: 'Semptom Takibi',
        description: 'Günlük semptom kayıtları ve grafikler',
        icon: Icons.trending_up,
        color: Colors.blue,
        isAvailable: true,
      ),
      OfflineFeature(
        title: 'Acil Durum Kontakları',
        description: 'Kayıtlı acil durum numaraları',
        icon: Icons.emergency,
        color: Colors.red,
        isAvailable: true,
      ),
      OfflineFeature(
        title: 'Seans Notları',
        description: 'Yerel kayıtlı seans notları',
        icon: Icons.edit_note,
        color: Colors.purple,
        isAvailable: true,
      ),
      OfflineFeature(
        title: 'Eğitim Materyalleri',
        description: 'İndirilen eğitim içerikleri',
        icon: Icons.school,
        color: Colors.orange,
        isAvailable: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çevrimdışı Özellikler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: offlineFeatures.length,
          itemBuilder: (context, index) =>
              _buildOfflineFeatureCard(offlineFeatures[index]),
        ),
      ],
    );
  }

  Widget _buildOfflineFeatureCard(OfflineFeature feature) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: feature.isAvailable
              ? feature.color.withOpacity(0.3)
              : Colors.grey.shade300,
          width: feature.isAvailable ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: feature.isAvailable
                  ? feature.color.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: feature.isAvailable ? feature.color : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            feature.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: feature.isAvailable
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            feature.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: feature.isAvailable
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: feature.isAvailable
                  ? Colors.green.shade100
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feature.isAvailable ? 'Kullanılabilir' : 'Çevrimiçi Gerekli',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: feature.isAvailable
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getItemTypeColor(OfflineItemType type) {
    switch (type) {
      case OfflineItemType.session:
        return Colors.purple;
      case OfflineItemType.medication:
        return Colors.green;
      case OfflineItemType.education:
        return Colors.orange;
      case OfflineItemType.guide:
        return Colors.blue;
      case OfflineItemType.diagnosis:
        return Colors.red;
    }
  }

  IconData _getItemTypeIcon(OfflineItemType type) {
    switch (type) {
      case OfflineItemType.session:
        return Icons.edit_note;
      case OfflineItemType.medication:
        return Icons.medication;
      case OfflineItemType.education:
        return Icons.school;
      case OfflineItemType.guide:
        return Icons.book;
      case OfflineItemType.diagnosis:
        return Icons.medical_services;
    }
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) return 'Şimdi';
    if (difference.inMinutes < 60) return '${difference.inMinutes} dk önce';
    if (difference.inHours < 24) return '${difference.inHours} saat önce';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    return '${lastSync.day}/${lastSync.month}/${lastSync.year}';
  }

  void _syncItem(OfflineItem item) {
    // TODO: Implement individual item sync
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} senkronize ediliyor...')),
    );
  }

  void _startFullSync() {
    setState(() {
      _isSyncing = true;
    });

    // Simulate sync process
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isSyncing = false;
        _syncedItems = _totalItems;
      });

      _syncController.forward().then((_) => _syncController.reset());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Senkronizasyon tamamlandı!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    });
  }

  void _checkForUpdates() {
    // TODO: Implement update check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Güncellemeler kontrol ediliyor...')),
    );
  }
}

enum OfflineItemType {
  session,
  medication,
  education,
  guide,
  diagnosis,
}

class OfflineItem {
  final String id;
  final String title;
  final OfflineItemType type;
  final String size;
  final DateTime lastSync;
  bool isSynced;

  OfflineItem({
    required this.id,
    required this.title,
    required this.type,
    required this.size,
    required this.lastSync,
    required this.isSynced,
  });
}

class OfflineFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isAvailable;

  OfflineFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isAvailable,
  });
}
