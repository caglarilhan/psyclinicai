import 'package:flutter/material.dart';
import '../../config/white_label_config.dart';
import '../../utils/theme.dart';

class WhiteLabelDashboardScreen extends StatefulWidget {
  const WhiteLabelDashboardScreen({super.key});

  @override
  State<WhiteLabelDashboardScreen> createState() => _WhiteLabelDashboardScreenState();
}

class _WhiteLabelDashboardScreenState extends State<WhiteLabelDashboardScreen> {
  final WhiteLabelConfig _config = WhiteLabelConfig();
  final WhiteLabelThemeProvider _themeProvider = WhiteLabelThemeProvider();
  
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
  Widget build(BuildContext context) {
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
    super.dispose();
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
