import 'package:flutter/material.dart';
import 'dart:async';
import '../services/two_factor_auth_service.dart';
import '../utils/theme.dart';

// 2FA Setup Widget
class TwoFactorAuthSetupWidget extends StatefulWidget {
  const TwoFactorAuthSetupWidget({super.key});

  @override
  State<TwoFactorAuthSetupWidget> createState() => _TwoFactorAuthSetupWidgetState();
}

class _TwoFactorAuthSetupWidgetState extends State<TwoFactorAuthSetupWidget> {
  final TwoFactorAuthService _twoFactorAuthService = TwoFactorAuthService();
  String _selectedMethod = 'totp';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSettingUp = false;

  @override
  void initState() {
    super.initState();
    _twoFactorAuthService.load2FASettings();
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
                  Icons.security,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'İki Faktörlü Doğrulama',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Method seçimi
            Text(
              'Doğrulama Yöntemi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // TOTP seçeneği
            _buildMethodOption(
              'totp',
              'Authenticator App',
              'Google Authenticator, Authy gibi uygulamalar',
              Icons.phone_android,
            ),
            
            // SMS seçeneği
            _buildMethodOption(
              'sms',
              'SMS',
              'Telefon numaranıza kod gönderilir',
              Icons.sms,
            ),
            
            // Email seçeneği
            _buildMethodOption(
              'email',
              'Email',
              'Email adresinize kod gönderilir',
              Icons.email,
            ),
            
            const SizedBox(height: 16),
            
            // Method'a göre input alanları
            if (_selectedMethod == 'sms') ...[
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                  hintText: '+90 555 123 4567',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ] else if (_selectedMethod == 'email') ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Adresi',
                  hintText: 'ornek@email.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Setup butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSettingUp ? null : _setup2FA,
                icon: _isSettingUp 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.security),
                label: Text(_isSettingUp ? 'Kuruluyor...' : '2FA Kur'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String value, String title, String description, IconData icon) {
    final isSelected = _selectedMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withValues(alpha: 0.1) 
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _setup2FA() async {
    setState(() {
      _isSettingUp = true;
    });

    try {
      bool success = false;
      
      if (_selectedMethod == 'totp') {
        success = await _twoFactorAuthService.enable2FA(method: 'totp');
      } else if (_selectedMethod == 'sms') {
        if (_phoneController.text.isNotEmpty) {
          success = await _twoFactorAuthService.enable2FA(
            method: 'sms',
            phoneNumber: _phoneController.text,
          );
        }
      } else if (_selectedMethod == 'email') {
        if (_emailController.text.isNotEmpty) {
          success = await _twoFactorAuthService.enable2FA(
            method: 'email',
            email: _emailController.text,
          );
        }
      }

      if (success) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwoFactorAuthVerificationWidget(),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('2FA kurulumu başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSettingUp = false;
      });
    }
  }
}

// 2FA Verification Widget
class TwoFactorAuthVerificationWidget extends StatefulWidget {
  const TwoFactorAuthVerificationWidget({super.key});

  @override
  State<TwoFactorAuthVerificationWidget> createState() => _TwoFactorAuthVerificationWidgetState();
}

class _TwoFactorAuthVerificationWidgetState extends State<TwoFactorAuthVerificationWidget> {
  final TwoFactorAuthService _twoFactorAuthService = TwoFactorAuthService();
  final TextEditingController _codeController = TextEditingController();
  String _currentTOTP = '';
  Timer? _totpTimer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _updateTOTP();
    _totpTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTOTP());
  }

  @override
  void dispose() {
    _totpTimer?.cancel();
    super.dispose();
  }

  void _updateTOTP() {
    setState(() {
      _currentTOTP = _twoFactorAuthService.generateTOTP();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2FA Doğrulama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR Code bölümü
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 120,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'QR Kodu Tarayın',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Google Authenticator veya benzeri bir uygulama ile QR kodu tarayın',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // TOTP kodu
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Geçerli Kod',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentTOTP,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu kod 30 saniyede bir yenilenir',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Doğrulama kodu girişi
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Doğrulama Kodu',
                hintText: '6 haneli kodu girin',
                prefixIcon: Icon(Icons.security),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            
            const SizedBox(height: 16),
            
            // Doğrula butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isVerifying ? null : _verifyCode,
                icon: _isVerifying 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isVerifying ? 'Doğrulanıyor...' : 'Doğrula'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Backup codes
            TextButton.icon(
              onPressed: _showBackupCodes,
              icon: const Icon(Icons.backup),
              label: const Text('Backup Kodları'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      final code = _codeController.text.trim();
      bool isValid = false;

      // TOTP doğrula
      if (_twoFactorAuthService.verifyTOTP(code)) {
        isValid = true;
      }
      // Backup code doğrula
      else if (_twoFactorAuthService.verifyBackupCode(code)) {
        isValid = true;
      }

      if (isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('2FA başarıyla etkinleştirildi!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geçersiz kod'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _showBackupCodes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Kodları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bu kodları güvenli bir yerde saklayın. Her kod sadece bir kez kullanılabilir.',
            ),
            const SizedBox(height: 16),
            ..._twoFactorAuthService.backupCodes.map((code) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
}

// 2FA Status Widget
class TwoFactorAuthStatusWidget extends StatefulWidget {
  const TwoFactorAuthStatusWidget({super.key});

  @override
  State<TwoFactorAuthStatusWidget> createState() => _TwoFactorAuthStatusWidgetState();
}

class _TwoFactorAuthStatusWidgetState extends State<TwoFactorAuthStatusWidget> {
  final TwoFactorAuthService _twoFactorAuthService = TwoFactorAuthService();

  @override
  void initState() {
    super.initState();
    _twoFactorAuthService.load2FASettings();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _twoFactorAuthService.get2FAStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stats['isEnabled'] ? Icons.security : Icons.security_outlined,
                  color: stats['isEnabled'] ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '2FA Durumu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Switch(
                  value: stats['isEnabled'],
                  onChanged: (value) {
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TwoFactorAuthSetupWidget(),
                        ),
                      );
                    } else {
                      _disable2FA();
                    }
                  },
                ),
              ],
            ),
            
            if (stats['isEnabled']) ...[
              const SizedBox(height: 16),
              _buildStatItem(
                'Yöntem',
                _getMethodName(stats['method']),
                Icons.phone_android,
              ),
              _buildStatItem(
                'Backup Kodları',
                '${stats['backupCodesRemaining']} kaldı',
                Icons.backup,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'totp':
        return 'Authenticator App';
      case 'sms':
        return 'SMS';
      case 'email':
        return 'Email';
      default:
        return 'Bilinmiyor';
    }
  }

  Future<void> _disable2FA() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('2FA Devre Dışı Bırak'),
        content: const Text(
          'İki faktörlü doğrulamayı devre dışı bırakmak istediğinizden emin misiniz? Bu işlem güvenliğinizi azaltacaktır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Devre Dışı Bırak'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _twoFactorAuthService.disable2FA();
      if (success) {
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('2FA devre dışı bırakıldı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }
}
