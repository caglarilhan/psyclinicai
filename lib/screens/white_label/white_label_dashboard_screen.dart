import 'package:flutter/material.dart';
import '../../config/white_label_config.dart';
import '../../utils/theme.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class WhiteLabelDashboardScreen extends StatefulWidget {
  const WhiteLabelDashboardScreen({super.key});

  @override
  State<WhiteLabelDashboardScreen> createState() => _WhiteLabelDashboardScreenState();
}

class _WhiteLabelDashboardScreenState extends State<WhiteLabelDashboardScreen> {
  final WhiteLabelConfig _config = WhiteLabelConfig();
  final WhiteLabelThemeProvider _themeProvider = WhiteLabelThemeProvider();
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  
  // Form controllers
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _brandTaglineController = TextEditingController();
  final TextEditingController _supportEmailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  
  // Color pickers
  Color _selectedPrimaryColor = const Color(0xFF2563EB);
  Color _selectedSecondaryColor = const Color(0xFF7C3AED);
  Color _selectedAccentColor = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
    _setupKeyboardShortcuts();
  }

  void _loadCurrentConfig() {
    _brandNameController.text = _config.brandName;
    _brandTaglineController.text = _config.brandTagline;
    _supportEmailController.text = _config.supportEmail;
    _websiteController.text = _config.website;
    _selectedPrimaryColor = _config.primaryColor;
    _selectedSecondaryColor = _config.secondaryColor;
    _selectedAccentColor = _config.accentColor;
  }

  @override
  void dispose() {
    _removeKeyboardShortcuts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return DesktopLayout(
      title: 'White-Label Dashboard',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Kaydet',
          onPressed: _saveConfig,
          icon: Icons.save,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Sıfırla',
          onPressed: _resetConfig,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Export',
          onPressed: _exportConfig,
          icon: Icons.download,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Import',
          onPressed: _importConfig,
          icon: Icons.upload,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Genel Bakış',
          icon: Icons.dashboard,
          onTap: () => _scrollToSection('overview'),
        ),
        DesktopSidebarItem(
          title: 'Marka Ayarları',
          icon: Icons.branding_watermark,
          onTap: () => _scrollToSection('brand'),
        ),
        DesktopSidebarItem(
          title: 'Tema Özelleştirme',
          icon: Icons.palette,
          onTap: () => _scrollToSection('theme'),
        ),
        DesktopSidebarItem(
          title: 'Önceden Tanımlı Temalar',
          icon: Icons.style,
          onTap: () => _scrollToSection('predefined'),
        ),
        DesktopSidebarItem(
          title: 'Özelleştirilmiş Özellikler',
          icon: Icons.settings,
          onTap: () => _scrollToSection('features'),
        ),
        DesktopSidebarItem(
          title: 'Konfigürasyon Yönetimi',
          icon: Icons.manage_accounts,
          onTap: () => _scrollToSection('config'),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genel Bakış
          _buildDesktopOverviewSection(),
          
          const SizedBox(height: 32),
          
          // Marka Ayarları
          _buildDesktopBrandSettingsSection(),
          
          const SizedBox(height: 32),
          
          // Tema Özelleştirme
          _buildDesktopThemeCustomizationSection(),
          
          const SizedBox(height: 32),
          
          // Önceden Tanımlanmış Temalar
          _buildDesktopPredefinedThemesSection(),
          
          const SizedBox(height: 32),
          
          // Özelleştirilmiş Özellikler
          _buildDesktopCustomFeaturesSection(),
          
          const SizedBox(height: 32),
          
          // Konfigürasyon Yönetimi
          _buildDesktopConfigManagementSection(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('White-Label Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
            tooltip: 'Konfigürasyonu Kaydet',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetConfig,
            tooltip: 'Varsayılana Sıfırla',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Bakış
            _buildOverviewSection(),
            
            const SizedBox(height: 24),
            
            // Marka Ayarları
            _buildBrandSettingsSection(),
            
            const SizedBox(height: 24),
            
            // Tema Özelleştirme
            _buildThemeCustomizationSection(),
            
            const SizedBox(height: 24),
            
            // Önceden Tanımlanmış Temalar
            _buildPredefinedThemesSection(),
            
            const SizedBox(height: 24),
            
            // Özelleştirilmiş Özellikler
            _buildCustomFeaturesSection(),
            
            const SizedBox(height: 24),
            
            // Konfigürasyon Yönetimi
            _buildConfigManagementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'White-Label Konfigürasyonu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uygulamanızı özelleştirin ve markanıza uygun hale getirin',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Konfigürasyon Durumu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  _config.isCustomTheme ? Icons.check_circle : Icons.info,
                  color: _config.isCustomTheme ? Colors.green : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durum: ${_config.getConfigStatus()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _config.isCustomTheme 
                            ? 'Özelleştirilmiş tema aktif'
                            : 'Varsayılan tema kullanılıyor',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marka Ayarları',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Marka Adı
          TextFormField(
            controller: _brandNameController,
            decoration: const InputDecoration(
              labelText: 'Marka Adı',
              hintText: 'Örn: PsyClinic AI',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Marka Sloganı
          TextFormField(
            controller: _brandTaglineController,
            decoration: const InputDecoration(
              labelText: 'Marka Sloganı',
              hintText: 'Örn: Akıllı Psikiyatri Asistanı',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Destek E-posta
          TextFormField(
            controller: _supportEmailController,
            decoration: const InputDecoration(
              labelText: 'Destek E-posta',
              hintText: 'Örn: support@psyclinici.com',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Website
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Website',
              hintText: 'Örn: https://psyclinici.com',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCustomizationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema Özelleştirme',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Ana Renk
          _buildColorPicker(
            'Ana Renk',
            _selectedPrimaryColor,
            (color) => setState(() => _selectedPrimaryColor = color),
          ),
          
          const SizedBox(height: 16),
          
          // İkincil Renk
          _buildColorPicker(
            'İkincil Renk',
            _selectedSecondaryColor,
            (color) => setState(() => _selectedSecondaryColor = color),
          ),
          
          const SizedBox(height: 16),
          
          // Vurgu Rengi
          _buildColorPicker(
            'Vurgu Rengi',
            _selectedAccentColor,
            (color) => setState(() => _selectedAccentColor = color),
          ),
          
          const SizedBox(height: 16),
          
          // Tema Önizleme
          _buildThemePreview(),
        ],
      ),
    );
  }

  Widget _buildColorPicker(String label, Color currentColor, Function(Color) onColorChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _showColorPicker(label, currentColor, onColorChanged),
          child: const Text('Değiştir'),
        ),
      ],
    );
  }

  Widget _buildThemePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema Önizleme',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ana Buton'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSecondaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('İkincil Buton'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAccentColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Vurgu Buton'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredefinedThemesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önceden Tanımlanmış Temalar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: WhiteLabelConfig.predefinedThemes.entries.map((entry) {
              final themeName = entry.key;
              final themeColors = entry.value;
              
              return _buildThemeCard(themeName, themeColors);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(String themeName, Map<String, Color> themeColors) {
    return InkWell(
      onTap: () => _loadPredefinedTheme(themeName),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Text(
              themeName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            
            // Renk önizleme
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themeColors['primary'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themeColors['secondary'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themeColors['accent'],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Özelleştirilmiş Özellikler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Özellik toggle'ları
          _buildFeatureToggle('AI Destekli Tanı', 'ai_diagnosis'),
          _buildFeatureToggle('Teleterapi', 'telehealth'),
          _buildFeatureToggle('İlaç Etkileşimi', 'medication_interaction'),
          _buildFeatureToggle('Gelişmiş Raporlama', 'advanced_reporting'),
          _buildFeatureToggle('Mobil Uygulama', 'mobile_app'),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle(String label, String featureKey) {
    final isEnabled = _config.hasCustomFeature(featureKey);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              if (value) {
                _config.updateConfig(
                  customFeatures: {..._config.customFeatures, featureKey: true},
                );
              } else {
                final features = Map<String, dynamic>.from(_config.customFeatures);
                features.remove(featureKey);
                _config.updateConfig(customFeatures: features);
              }
              setState(() {});
            },
            activeColor: _selectedPrimaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigManagementSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfigürasyon Yönetimi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportConfig,
                  icon: const Icon(Icons.download),
                  label: const Text('Dışa Aktar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.infoColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importConfig,
                  icon: const Icon(Icons.upload),
                  label: const Text('İçe Aktar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _previewConfig,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Önizle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetConfig,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Sıfırla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showColorPicker(String label, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label Seç'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _loadPredefinedTheme(String themeName) {
    _config.loadPredefinedTheme(themeName);
    _loadCurrentConfig();
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$themeName teması yüklendi'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _saveConfig() {
    _config.updateConfig(
      brandName: _brandNameController.text,
      brandTagline: _brandTaglineController.text,
      supportEmail: _supportEmailController.text,
      website: _websiteController.text,
      primaryColor: _selectedPrimaryColor,
      secondaryColor: _selectedSecondaryColor,
      accentColor: _selectedAccentColor,
      isCustomTheme: true,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konfigürasyon kaydedildi'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _resetConfig() {
    _config.resetToDefault();
    _loadCurrentConfig();
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konfigürasyon varsayılana sıfırlandı'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _exportConfig() {
    final config = _config.exportConfig();
    // TODO: JSON dosyası olarak dışa aktarma
    print('Konfigürasyon dışa aktarıldı: $config');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konfigürasyon dışa aktarıldı'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _importConfig() {
    // TODO: JSON dosyasından içe aktarma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konfigürasyon içe aktarma özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _previewConfig() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfigürasyon Önizleme'),
        content: SingleChildScrollView(
          child: Text(_config.getConfigSummary()),
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

  @override
  void dispose() {
    _brandNameController.dispose();
    _brandTaglineController.dispose();
    _supportEmailController.dispose();
    _websiteController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      _saveConfig,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _resetConfig,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      _exportConfig,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyI, LogicalKeyboardKey.control),
      _importConfig,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyI, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü bölüm metodları
  Widget _buildDesktopOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'White-Label Genel Bakış',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopTheme.desktopCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mevcut Konfigürasyon',
                  style: DesktopTheme.desktopTitleStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDesktopConfigCard(
                        'Marka Adı',
                        _config.brandName,
                        Icons.branding_watermark,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDesktopConfigCard(
                        'Tema Durumu',
                        _config.isCustomTheme ? 'Özel' : 'Varsayılan',
                        Icons.palette,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDesktopConfigCard(
                        'Destek E-posta',
                        _config.supportEmail,
                        Icons.email,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBrandSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marka Ayarları',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopTheme.desktopCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marka Bilgileri',
                  style: DesktopTheme.desktopTitleStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DesktopTheme.desktopInput(
                        label: 'Marka Adı',
                        controller: _brandNameController,
                        hintText: 'Marka adınızı girin',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DesktopTheme.desktopInput(
                        label: 'Marka Sloganı',
                        controller: _brandTaglineController,
                        hintText: 'Marka sloganınızı girin',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DesktopTheme.desktopInput(
                        label: 'Destek E-posta',
                        controller: _supportEmailController,
                        hintText: 'support@example.com',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DesktopTheme.desktopInput(
                        label: 'Website',
                        controller: _websiteController,
                        hintText: 'https://example.com',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopThemeCustomizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema Özelleştirme',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DesktopTheme.desktopCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Renk Paleti',
                        style: DesktopTheme.desktopTitleStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildDesktopColorPicker('Ana Renk', _selectedPrimaryColor, (color) {
                        setState(() => _selectedPrimaryColor = color);
                      }),
                      const SizedBox(height: 16),
                      _buildDesktopColorPicker('İkincil Renk', _selectedSecondaryColor, (color) {
                        setState(() => _selectedSecondaryColor = color);
                      }),
                      const SizedBox(height: 16),
                      _buildDesktopColorPicker('Vurgu Rengi', _selectedAccentColor, (color) {
                        setState(() => _selectedAccentColor = color);
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: DesktopTheme.desktopCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema Önizleme',
                        style: DesktopTheme.desktopTitleStyle,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedPrimaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _brandNameController.text.isEmpty ? 'Marka Adı' : _brandNameController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _brandTaglineController.text.isEmpty ? 'Marka Sloganı' : _brandTaglineController.text,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopPredefinedThemesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Önceden Tanımlanmış Temalar',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopGrid(
          children: [
            _buildDesktopThemeCard('Klasik Mavi', Colors.blue, Icons.business),
            _buildDesktopThemeCard('Modern Yeşil', Colors.green, Icons.eco),
            _buildDesktopThemeCard('Elegant Mor', Colors.purple, Icons.auto_awesome),
            _buildDesktopThemeCard('Sıcak Turuncu', Colors.orange, Icons.whatshot),
            _buildDesktopThemeCard('Profesyonel Gri', Colors.grey, Icons.work),
            _buildDesktopThemeCard('Canlı Pembe', Colors.pink, Icons.favorite),
          ],
          context: context,
        ),
      ],
    );
  }

  Widget _buildDesktopCustomFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özelleştirilmiş Özellikler',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        DesktopDataTable(
          headers: const ['Özellik', 'Durum', 'Açıklama', 'Aksiyon'],
          rows: [
            ['Özel Logo', 'Aktif', 'Marka logosu gösterimi', 'Düzenle'],
            ['Özel Renkler', 'Aktif', 'Marka renk paleti', 'Düzenle'],
            ['Özel Font', 'Pasif', 'Marka tipografisi', 'Aktifleştir'],
            ['Özel İkonlar', 'Pasif', 'Marka ikonları', 'Aktifleştir'],
            ['Özel Animasyonlar', 'Pasif', 'Marka animasyonları', 'Aktifleştir'],
          ],
          onRowTap: (index) {
            // TODO: Özellik düzenleme
          },
        ),
      ],
    );
  }

  Widget _buildDesktopConfigManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konfigürasyon Yönetimi',
          style: DesktopTheme.desktopSectionTitleStyle,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DesktopTheme.desktopButton(
                text: 'Konfigürasyonu Kaydet',
                onPressed: _saveConfig,
                icon: Icons.save,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DesktopTheme.desktopButton(
                text: 'Varsayılana Sıfırla',
                onPressed: _resetConfig,
                icon: Icons.refresh,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DesktopTheme.desktopButton(
                text: 'Dışa Aktar',
                onPressed: _exportConfig,
                icon: Icons.download,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DesktopTheme.desktopButton(
                text: 'İçe Aktar',
                onPressed: _importConfig,
                icon: Icons.upload,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopConfigCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopColorPicker(String label, Color color, Function(Color) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopThemeCard(String name, Color color, IconData icon) {
    return DesktopGridCard(
      title: name,
      subtitle: 'Tema',
      icon: icon,
      color: color,
      onTap: () {
        setState(() {
          _selectedPrimaryColor = color;
          _selectedSecondaryColor = color.withOpacity(0.7);
          _selectedAccentColor = color.withOpacity(0.5);
        });
      },
    );
  }

  void _scrollToSection(String section) {
    // TODO: Bölüme kaydırma
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$section bölümüne kaydırılıyor...')),
    );
  }
}

// Basit renk seçici widget'ı
class ColorPicker extends StatelessWidget {
  final Color pickerColor;
  final Function(Color) onColorChanged;
  final double pickerAreaHeightPercent;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.pickerAreaHeightPercent = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    ];

    return SizedBox(
      height: 300,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color == pickerColor;
          
          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
