import 'package:flutter/material.dart';
import '../../config/country_config.dart';
import '../../utils/theme.dart';

class CountrySelectorWidget extends StatefulWidget {
  final Function(String)? onCountryChanged;
  final String? initialCountry;
  final bool showLabel;
  final bool showFlag;
  final bool showNativeName;
  final String? labelText;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const CountrySelectorWidget({
    super.key,
    this.onCountryChanged,
    this.initialCountry,
    this.showLabel = true,
    this.showFlag = true,
    this.showNativeName = true,
    this.labelText,
    this.margin,
    this.width,
  });

  @override
  State<CountrySelectorWidget> createState() => _CountrySelectorWidgetState();
}

class _CountrySelectorWidgetState extends State<CountrySelectorWidget> {
  String _selectedCountry = CountryConfig.currentCountry;
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCountry != null) {
      _selectedCountry = widget.initialCountry!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(8),
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel) ...[
            Text(
              widget.labelText ?? 'Ülke Seçimi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
          ],
          CompositedTransformTarget(
            link: _layerLink,
            child: InkWell(
              onTap: _showCountrySelector,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.showFlag) ...[
                      Text(
                        CountryConfig.supportedCountries[_selectedCountry]!['flag'],
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CountryConfig.supportedCountries[_selectedCountry]!['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (widget.showNativeName) ...[
                            const SizedBox(height: 2),
                            Text(
                              CountryConfig.supportedCountries[_selectedCountry]!['nativeName'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCountrySelector() {
    if (_isOverlayVisible) {
      _hideOverlay();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildCountryOverlay(),
    );

    Overlay.of(context).insert(_overlayEntry);
    _isOverlayVisible = true;
  }

  void _hideOverlay() {
    if (_isOverlayVisible) {
      _overlayEntry.remove();
      _isOverlayVisible = false;
    }
  }

  Widget _buildCountryOverlay() {
    return Positioned(
      width: 300,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 60),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ülke Seçimi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _hideOverlay,
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Country List
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: CountryConfig.allSupportedCountries.length,
                    itemBuilder: (context, index) {
                      final countryCode = CountryConfig.allSupportedCountries[index];
                      final countryInfo = CountryConfig.supportedCountries[countryCode]!;
                      final isSelected = countryCode == _selectedCountry;
                      
                      return InkWell(
                        onTap: () => _selectCountry(countryCode),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                : null,
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                countryInfo['flag'],
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      countryInfo['name'],
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? AppTheme.primaryColor : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      countryInfo['nativeName'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            countryInfo['primarySystem'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.secondaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            countryInfo['currency'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.accentColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seçilen ülkeye göre ilaç sistemi ve özellikler otomatik olarak ayarlanır',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
    );
  }

  void _selectCountry(String countryCode) {
    setState(() {
      _selectedCountry = countryCode;
    });
    
    CountryConfig.changeCountry(countryCode);
    widget.onCountryChanged?.call(countryCode);
    _hideOverlay();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              CountryConfig.supportedCountries[countryCode]!['flag'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${CountryConfig.supportedCountries[countryCode]!['name']} seçildi',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isOverlayVisible) {
      _hideOverlay();
    }
    super.dispose();
  }
}

// Ülke bilgi kartı widget'ı
class CountryInfoCard extends StatelessWidget {
  final String countryCode;
  final bool showDetails;
  final VoidCallback? onTap;

  const CountryInfoCard({
    super.key,
    required this.countryCode,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final countryInfo = CountryConfig.supportedCountries[countryCode]!;
    
    return Card(
      margin: const EdgeInsets.all(8),
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
                    countryInfo['flag'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          countryInfo['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          countryInfo['nativeName'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (showDetails) ...[
                const SizedBox(height: 16),
                _buildInfoRow('Birincil Sistem', countryInfo['primarySystem']),
                _buildInfoRow('Düzenleyici Kurum', countryInfo['regulatoryBody']),
                _buildInfoRow('İlaç Veritabanı', countryInfo['drugDatabase']),
                _buildInfoRow('Para Birimi', countryInfo['currency']),
                _buildInfoRow('Dil', countryInfo['language']),
                _buildInfoRow('Zaman Dilimi', countryInfo['timezone']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
