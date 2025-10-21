import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/drug_database_service.dart';
import '../services/region_service.dart';

class DrugDetailPopup extends StatelessWidget {
  final DrugInfo drug;
  final VoidCallback? onAddToPrescription;

  const DrugDetailPopup({
    super.key,
    required this.drug,
    this.onAddToPrescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final region = context.watch<RegionService>().currentRegionCode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: drug.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              drug.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.medication, size: 30),
                            ),
                          )
                        : const Icon(Icons.medication, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drug.brandName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          drug.genericName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          drug.activeIngredient,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Temel Bilgiler
                    _buildInfoSection(
                      context,
                      'Temel Bilgiler',
                      Icons.info_outline,
                      [
                        _buildInfoRow('Kategori', drug.category),
                        _buildInfoRow('ATC Kodu', drug.atcCode),
                        _buildInfoRow('Geri Ödeme Kodu', drug.reimbursementCode),
                        _buildInfoRow('Hamilelik Kategorisi', drug.pregnancyCategory),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dozaj ve Formlar
                    _buildInfoSection(
                      context,
                      'Dozaj ve Formlar',
                      Icons.science,
                      [
                        _buildInfoRow('Dozajlar', drug.dosages.join(', ')),
                        _buildInfoRow('Formlar', drug.forms.join(', ')),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Endikasyon
                    _buildInfoSection(
                      context,
                      'Endikasyon',
                      Icons.medical_services,
                      [
                        Text(drug.indication),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Kontrendikasyonlar
                    if (drug.contraindications.isNotEmpty)
                      _buildInfoSection(
                        context,
                        'Kontrendikasyonlar',
                        Icons.warning,
                        drug.contraindications.map((contra) => 
                          Text('• $contra')).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Yan Etkiler
                    if (drug.sideEffects.isNotEmpty)
                      _buildInfoSection(
                        context,
                        'Yan Etkiler',
                        Icons.report_problem,
                        drug.sideEffects.map((effect) => 
                          Text('• $effect')).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Ülke-Özel Bilgiler
                    _buildCountrySpecificInfo(context, region),

                    const SizedBox(height: 16),

                    // Uyarılar
                    if (drug.warnings[region]?.isNotEmpty == true)
                      _buildInfoSection(
                        context,
                        'Uyarılar',
                        Icons.warning_amber,
                        [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              border: Border.all(color: Colors.orange[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              drug.warnings[region]!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showFullImage(context),
                      icon: const Icon(Icons.image),
                      label: const Text('Tam Resim'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAddToPrescription,
                      icon: const Icon(Icons.add),
                      label: const Text('Reçeteye Ekle'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildCountrySpecificInfo(BuildContext context, String region) {
    final countryInfo = drug.countrySpecific;
    if (countryInfo.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    
    return _buildInfoSection(
      context,
      'Ülke-Özel Bilgiler ($region)',
      Icons.public,
      [
        if (countryInfo['price'] != null)
          _buildInfoRow('Fiyat', countryInfo['price']),
        if (countryInfo['sgkCode'] != null)
          _buildInfoRow('SGK Kodu', countryInfo['sgkCode']),
        if (countryInfo['ndcCode'] != null)
          _buildInfoRow('NDC Kodu', countryInfo['ndcCode']),
        if (countryInfo['emaCode'] != null)
          _buildInfoRow('EMA Kodu', countryInfo['emaCode']),
        if (countryInfo['prescriptionRequired'] != null)
          _buildInfoRow(
            'Reçete Gerekli', 
            countryInfo['prescriptionRequired'] ? 'Evet' : 'Hayır'
          ),
      ],
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(drug.brandName),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Flexible(
                child: drug.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          drug.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                            const Center(
                              child: Icon(Icons.medication, size: 100),
                            ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.medication, size: 100),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// İlaç kartı widget'ı (liste için)
class DrugCard extends StatelessWidget {
  final DrugInfo drug;
  final VoidCallback? onTap;

  const DrugCard({
    super.key,
    required this.drug,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // İlaç resmi
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: drug.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          drug.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.medication, color: colorScheme.primary),
                        ),
                      )
                    : Icon(Icons.medication, color: colorScheme.primary),
              ),
              
              const SizedBox(width: 12),
              
              // İlaç bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drug.brandName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      drug.genericName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(drug.category),
                          backgroundColor: colorScheme.secondaryContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (drug.dosages.isNotEmpty)
                          Chip(
                            label: Text(drug.dosages.first),
                            backgroundColor: Colors.grey[200],
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Ok ikonu
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
