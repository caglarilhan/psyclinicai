import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../services/regional_config_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedRole = AppConstants.userRoles.first;
  String _selectedCountry = AppConstants.targetCountries.first;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final regionalService = Provider.of<RegionalConfigService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Ayarlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kullanıcı bilgileri
                    Text(
                      'Dr. Ahmet Yılmaz',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedRole,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ahmet.yilmaz@psyclinic.ai',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hesap ayarları
            Text(
              'Hesap Ayarları',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  // Rol seçimi
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text('Kullanıcı Rolü'),
                    subtitle: Text(_selectedRole),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRoleSelectionDialog(context),
                  ),
                  const Divider(height: 1),

                  // Bölge seçimi (TR/US/EU)
                  ListTile(
                    leading: const Icon(Icons.public),
                    title: const Text('Bölge Seçimi'),
                    subtitle: Text(regionalService.currentRegion.name),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRegionSelectionDialog(context, regionalService),
                  ),
                  const Divider(height: 1),

                  // Tema seçimi
                  ListTile(
                    leading: Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: const Text('Tema'),
                    subtitle: Text(_isDarkMode ? 'Koyu' : 'Açık'),
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() => _isDarkMode = value);
                        themeService.toggleDarkMode();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Uygulama bilgileri
            Text(
              'Uygulama Bilgileri',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Versiyon'),
                    subtitle: Text(AppConstants.appVersion),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Açıklama'),
                    subtitle: Text(AppConstants.appDescription),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Desteklenen Diller'),
                    subtitle: Text(AppConstants.supportedLanguages.join(', ')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Yasal uyumluluk
            Text(
              'Yasal Uyumluluk',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: Text('${_selectedCountry} Uyumluluğu'),
                    subtitle: Text(AppConstants
                            .legalCompliance[_selectedCountry]
                            ?.join(', ') ??
                        'Bilinmiyor'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: const Text('Tanı Standardı'),
                    subtitle: Text(
                        AppConstants.diagnosisStandards[_selectedCountry] ??
                            'Bilinmiyor'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fiyatlandırma planı
            Text(
              'Fiyatlandırma Planı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: AppConstants.pricingPlans.entries.map((entry) {
                  final plan = entry.value;
                  return ListTile(
                    leading: Icon(
                      entry.key == 'Pro' ? Icons.star : Icons.check_circle,
                      color: entry.key == 'Pro'
                          ? AppTheme.warningColor
                          : AppTheme.accentColor,
                    ),
                    title: Text(entry.key),
                    subtitle: Text('${plan['price']} ${plan['currency']}/ay'),
                    trailing: Text(
                      plan['features'].join(', '),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Çıkış butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Rolü Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.userRoles.map((role) {
            return RadioListTile<String>(
              title: Text(role),
              value: role,
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() => _selectedRole = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCountrySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedef Ülke Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.targetCountries.map((country) {
            return RadioListTile<String>(
              title: Text(country),
              value: country,
              groupValue: _selectedCountry,
              onChanged: (value) {
                setState(() => _selectedCountry = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRegionSelectionDialog(BuildContext context, RegionalConfigService regionalService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bölge Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Region.values.map((region) {
            return RadioListTile<Region>(
              title: Text(region.name),
              value: region,
              groupValue: regionalService.currentRegion,
              onChanged: (value) {
                if (value != null) {
                  regionalService.setRegion(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
