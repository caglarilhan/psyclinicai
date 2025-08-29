import 'package:flutter/material.dart';
import '../../config/region_config.dart';
import '../../utils/theme.dart';

class RegionSelectorWidget extends StatefulWidget {
  final Function(String)? onRegionChanged;
  final bool showLabel;

  const RegionSelectorWidget({
    super.key,
    this.onRegionChanged,
    this.showLabel = true,
  });

  @override
  State<RegionSelectorWidget> createState() => _RegionSelectorWidgetState();
}

class _RegionSelectorWidgetState extends State<RegionSelectorWidget> {
  String _selectedRegion = RegionConfig.activeRegion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            'Bölge / Ülke',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRegion,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(Icons.public, color: AppTheme.primaryColor),
            ),
            items: RegionConfig.regions.entries.map((entry) {
              final region = entry.value;
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    _getFlagIcon(entry.key),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            region.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${region.diagnosisStandard} • ${region.legalCompliance.join(', ')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null && newValue != _selectedRegion) {
                setState(() {
                  _selectedRegion = newValue;
                });
                
                // Bölgeyi değiştir
                RegionConfig.setRegion(newValue);
                
                // Callback'i çağır
                widget.onRegionChanged?.call(newValue);
                
                // Kullanıcıya bilgi ver
                if (mounted) {
                  final regionInfo = RegionConfig.activeRegionInfo;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bölge ${regionInfo.name} olarak değiştirildi'),
                      backgroundColor: AppTheme.primaryColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Bölge bilgileri
        _buildRegionInfo(),
      ],
    );
  }

  Widget _buildRegionInfo() {
    final regionInfo = RegionConfig.activeRegionInfo;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Aktif Bölge: ${regionInfo.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Bölge özellikleri
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('Tanı: ${regionInfo.diagnosisStandard}', Icons.medical_services),
              _buildFeatureChip('Para: ${regionInfo.currency}', Icons.attach_money),
              _buildFeatureChip('Dil: ${regionInfo.language}', Icons.language),
              if (regionInfo.isBilingual())
                _buildFeatureChip('Çok Dilli', Icons.translate),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Uyarılar
          if (regionInfo.warnings.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.orange[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bölgesel Uyarılar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...regionInfo.warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(left: 26, top: 2),
                    child: Text(
                      '• $warning',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFlagIcon(String regionCode) {
    // Basit flag emoji'leri
    const Map<String, String> flags = {
      'US': '🇺🇸',
      'EU': '🇪🇺',
      'UK': '🇬🇧',
      'CA': '🇨🇦',
      'TR': '🇹🇷',
    };
    
    return Text(
      flags[regionCode] ?? '🌍',
      style: const TextStyle(fontSize: 24),
    );
  }
}

// Bölge bilgi kartı
class RegionInfoCard extends StatelessWidget {
  final String regionCode;
  final VoidCallback? onTap;

  const RegionInfoCard({
    super.key,
    required this.regionCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final regionInfo = RegionConfig.regions[regionCode]!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getFlagIcon(regionCode),
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            regionInfo.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            regionInfo.diagnosisStandard,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (regionCode == RegionConfig.activeRegion)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Özellikler
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildFeatureTag('${regionInfo.currency}', Icons.attach_money),
                    _buildFeatureTag(regionInfo.language, Icons.language),
                    if (regionInfo.isBilingual())
                      _buildFeatureTag('Çok Dilli', Icons.translate),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Uyumluluk
                Text(
                  'Uyumluluk: ${regionInfo.legalCompliance.join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getFlagIcon(String regionCode) {
    const Map<String, String> flags = {
      'US': '🇺🇸',
      'EU': '🇪🇺',
      'UK': '🇬🇧',
      'CA': '🇨🇦',
      'TR': '🇹🇷',
    };
    
    return flags[regionCode] ?? '🌍';
  }
}
