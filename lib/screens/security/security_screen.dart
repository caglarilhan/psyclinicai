import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isBiometricEnabled = false;
  bool _isTwoFactorEnabled = false;
  bool _isEncryptionEnabled = true;
  bool _isAuditLogEnabled = true;
  bool _isSessionTimeoutEnabled = true;
  
  int _sessionTimeoutMinutes = 30;
  String _encryptionLevel = 'AES-256';
  String _lastLogin = '2024-02-15 14:30:25';
  String _lastSecurityCheck = '2024-02-15 09:15:00';
  
  final List<SecurityEvent> _securityEvents = [
    SecurityEvent(
      id: '1',
      type: SecurityEventType.login,
      description: 'Başarılı giriş',
      timestamp: DateTime(2024, 2, 15, 14, 30),
      ipAddress: '192.168.1.100',
      userAgent: 'Chrome 120.0.0',
      severity: SecuritySeverity.info,
    ),
    SecurityEvent(
      id: '2',
      type: SecurityEventType.failedLogin,
      description: 'Başarısız giriş denemesi',
      timestamp: DateTime(2024, 2, 15, 14, 25),
      ipAddress: '192.168.1.101',
      userAgent: 'Firefox 119.0.0',
      severity: SecuritySeverity.warning,
    ),
    SecurityEvent(
      id: '3',
      type: SecurityEventType.dataAccess,
      description: 'Hasta verisi erişimi',
      timestamp: DateTime(2024, 2, 15, 14, 20),
      ipAddress: '192.168.1.100',
      userAgent: 'Chrome 120.0.0',
      severity: SecuritySeverity.info,
    ),
    SecurityEvent(
      id: '4',
      type: SecurityEventType.passwordChange,
      description: 'Şifre değiştirildi',
      timestamp: DateTime(2024, 2, 15, 10, 15),
      ipAddress: '192.168.1.100',
      userAgent: 'Chrome 120.0.0',
      severity: SecuritySeverity.info,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      setState(() {
        _isBiometricEnabled = isAvailable && availableBiometrics.isNotEmpty;
      });
    } catch (e) {
      print('Biometric check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik Ayarları'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: _runSecurityCheck,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Güvenlik Durumu Kartı
            _buildSecurityStatusCard(),
            const SizedBox(height: 24),
            
            // Kimlik Doğrulama Ayarları
            _buildSectionTitle('Kimlik Doğrulama'),
            _buildAuthSettingsCard(),
            const SizedBox(height: 24),
            
            // Veri Güvenliği
            _buildSectionTitle('Veri Güvenliği'),
            _buildDataSecurityCard(),
            const SizedBox(height: 24),
            
            // Oturum Ayarları
            _buildSectionTitle('Oturum Ayarları'),
            _buildSessionSettingsCard(),
            const SizedBox(height: 24),
            
            // Güvenlik Olayları
            _buildSectionTitle('Son Güvenlik Olayları'),
            _buildSecurityEventsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    int securityScore = _calculateSecurityScore();
    Color scoreColor = _getScoreColor(securityScore);
    String scoreText = _getScoreText(securityScore);

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
          children: [
            Icon(
              Icons.security,
                  color: colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Güvenlik Durumu',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
            Text(
                        'Son kontrol: $_lastSecurityCheck',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$securityScore/100',
                    style: const TextStyle(
                      color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              scoreText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAuthSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              title: 'Biyometrik Kimlik Doğrulama',
              subtitle: 'Parmak izi veya yüz tanıma ile giriş',
              value: _isBiometricEnabled,
              onChanged: _isBiometricEnabled ? _toggleBiometric : null,
              icon: Icons.fingerprint,
            ),
            const Divider(),
            _buildSwitchTile(
              title: 'İki Faktörlü Kimlik Doğrulama',
              subtitle: 'SMS veya e-posta ile doğrulama kodu',
              value: _isTwoFactorEnabled,
              onChanged: _toggleTwoFactor,
              icon: Icons.sms,
            ),
            const Divider(),
            _buildInfoTile(
              title: 'Son Giriş',
              subtitle: _lastLogin,
              icon: Icons.login,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSecurityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              title: 'Veri Şifreleme',
              subtitle: 'Tüm hasta verileri şifrelenir',
              value: _isEncryptionEnabled,
              onChanged: null, // Her zaman açık olmalı
              icon: Icons.lock,
            ),
            const Divider(),
            _buildInfoTile(
              title: 'Şifreleme Seviyesi',
              subtitle: _encryptionLevel,
              icon: Icons.security,
            ),
            const Divider(),
            _buildSwitchTile(
              title: 'Audit Log',
              subtitle: 'Tüm işlemler kayıt altına alınır',
              value: _isAuditLogEnabled,
              onChanged: _toggleAuditLog,
              icon: Icons.assignment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              title: 'Otomatik Oturum Kapatma',
              subtitle: 'Belirli süre sonra oturumu kapat',
              value: _isSessionTimeoutEnabled,
              onChanged: _toggleSessionTimeout,
              icon: Icons.timer,
            ),
            if (_isSessionTimeoutEnabled) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Oturum Süresi'),
                subtitle: Text('$_sessionTimeoutMinutes dakika'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _sessionTimeoutMinutes > 5 ? _decreaseSessionTimeout : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _sessionTimeoutMinutes < 120 ? _increaseSessionTimeout : null,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityEventsCard() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                const Text(
                  'Son Güvenlik Olayları',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _viewAllEvents,
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
          ),
          ..._securityEvents.take(3).map((event) => _buildSecurityEventTile(event)),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildSecurityEventTile(SecurityEvent event) {
    Color severityColor = _getSeverityColor(event.severity);
    IconData severityIcon = _getSeverityIcon(event.severity);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: severityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(severityIcon, color: severityColor, size: 20),
      ),
      title: Text(event.description),
      subtitle: Text(
        '${event.ipAddress} • ${_formatDateTime(event.timestamp)}',
      ),
      trailing: Text(
        _formatTime(event.timestamp),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      onTap: () => _showEventDetails(event),
    );
  }

  int _calculateSecurityScore() {
    int score = 0;
    if (_isBiometricEnabled) score += 25;
    if (_isTwoFactorEnabled) score += 25;
    if (_isEncryptionEnabled) score += 25;
    if (_isAuditLogEnabled) score += 15;
    if (_isSessionTimeoutEnabled) score += 10;
    return score;
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreText(int score) {
    if (score >= 80) return 'Güvenlik seviyeniz yüksek';
    if (score >= 60) return 'Güvenlik seviyeniz orta';
    return 'Güvenlik seviyeniz düşük - iyileştirme gerekli';
  }

  Color _getSeverityColor(SecuritySeverity severity) {
    switch (severity) {
      case SecuritySeverity.info:
        return Colors.blue;
      case SecuritySeverity.warning:
        return Colors.orange;
      case SecuritySeverity.error:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(SecuritySeverity severity) {
    switch (severity) {
      case SecuritySeverity.info:
        return Icons.info;
      case SecuritySeverity.warning:
        return Icons.warning;
      case SecuritySeverity.error:
        return Icons.error;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _toggleBiometric(bool value) async {
    if (value) {
      try {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Biyometrik kimlik doğrulama için parmak izinizi kullanın',
        );
        
        if (didAuthenticate) {
          setState(() {
            _isBiometricEnabled = value;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biyometrik kimlik doğrulama etkinleştirildi')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biyometrik kimlik doğrulama hatası: $e')),
        );
      }
    } else {
      setState(() {
        _isBiometricEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biyometrik kimlik doğrulama devre dışı bırakıldı')),
      );
    }
  }

  void _toggleTwoFactor(bool value) {
    setState(() {
      _isTwoFactorEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value 
          ? 'İki faktörlü kimlik doğrulama etkinleştirildi'
          : 'İki faktörlü kimlik doğrulama devre dışı bırakıldı'),
      ),
    );
  }

  void _toggleAuditLog(bool value) {
    setState(() {
      _isAuditLogEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value 
          ? 'Audit log etkinleştirildi'
          : 'Audit log devre dışı bırakıldı'),
      ),
    );
  }

  void _toggleSessionTimeout(bool value) {
    setState(() {
      _isSessionTimeoutEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value 
          ? 'Otomatik oturum kapatma etkinleştirildi'
          : 'Otomatik oturum kapatma devre dışı bırakıldı'),
      ),
    );
  }

  void _increaseSessionTimeout() {
    setState(() {
      _sessionTimeoutMinutes += 5;
    });
  }

  void _decreaseSessionTimeout() {
    setState(() {
      _sessionTimeoutMinutes -= 5;
    });
  }

  void _runSecurityCheck() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Güvenlik kontrolü çalıştırılıyor...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _lastSecurityCheck = DateTime.now().toString().substring(0, 19);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Güvenlik kontrolü tamamlandı'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _viewAllEvents() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Güvenlik Olayları'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _securityEvents.length,
            itemBuilder: (context, index) {
              final event = _securityEvents[index];
              return _buildSecurityEventTile(event);
            },
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

  void _showEventDetails(SecurityEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tür', _getEventTypeText(event.type)),
            _buildDetailRow('Tarih', _formatDateTime(event.timestamp)),
            _buildDetailRow('Saat', _formatTime(event.timestamp)),
            _buildDetailRow('IP Adresi', event.ipAddress),
            _buildDetailRow('Tarayıcı', event.userAgent),
            _buildDetailRow('Önem', _getSeverityText(event.severity)),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getEventTypeText(SecurityEventType type) {
    switch (type) {
      case SecurityEventType.login:
        return 'Giriş';
      case SecurityEventType.failedLogin:
        return 'Başarısız Giriş';
      case SecurityEventType.dataAccess:
        return 'Veri Erişimi';
      case SecurityEventType.passwordChange:
        return 'Şifre Değişikliği';
    }
  }

  String _getSeverityText(SecuritySeverity severity) {
    switch (severity) {
      case SecuritySeverity.info:
        return 'Bilgi';
      case SecuritySeverity.warning:
        return 'Uyarı';
      case SecuritySeverity.error:
        return 'Hata';
    }
  }
}

// Güvenlik Olayı Modeli
class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final String description;
  final DateTime timestamp;
  final String ipAddress;
  final String userAgent;
  final SecuritySeverity severity;

  SecurityEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
    required this.severity,
  });
}

enum SecurityEventType {
  login,
  failedLogin,
  dataAccess,
  passwordChange,
}

enum SecuritySeverity {
  info,
  warning,
  error,
}