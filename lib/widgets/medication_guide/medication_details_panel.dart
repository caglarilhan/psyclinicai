import 'package:flutter/material.dart';
import '../../models/medication_guide_model.dart';
import '../../utils/theme.dart';

class MedicationDetailsPanel extends StatefulWidget {
  final MedicationModel medication;

  const MedicationDetailsPanel({
    super.key,
    required this.medication,
  });

  @override
  State<MedicationDetailsPanel> createState() => _MedicationDetailsPanelState();
}

class _MedicationDetailsPanelState extends State<MedicationDetailsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // İlaç başlığı ve kategori
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.medication.categoryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: widget.medication.categoryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İlaç adı ve kategori
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.medication.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.medication.genericName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.medication.categoryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.medication.categoryName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Alt kategori ve endikasyonlar
              if (widget.medication.subcategory.isNotEmpty) ...[
                Text(
                  'Alt Kategori: ${widget.medication.subcategory}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Endikasyonlar
              if (widget.medication.indications.isNotEmpty) ...[
                Text(
                  'Endikasyonlar:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.medication.indications.map((indication) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        indication,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Genel'),
              Tab(icon: Icon(Icons.medication), text: 'Dozaj'),
              Tab(icon: Icon(Icons.warning), text: 'Yan Etkiler'),
              Tab(icon: Icon(Icons.block), text: 'Kontrendikasyonlar'),
              Tab(icon: Icon(Icons.science), text: 'Farmakoloji'),
              Tab(icon: Icon(Icons.verified), text: 'Onay Durumu'),
            ],
          ),
        ),

        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(),
              _buildDosageTab(),
              _buildSideEffectsTab(),
              _buildContraindicationsTab(),
              _buildPharmacologyTab(),
              _buildApprovalTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'İlaç Adı',
            widget.medication.name,
            Icons.medication,
          ),
          _buildInfoSection(
            'Etken Madde',
            widget.medication.genericName,
            Icons.science,
          ),
          _buildInfoSection(
            'Marka Adları',
            widget.medication.brandNames.join(', '),
            Icons.branding_watermark,
          ),
          _buildInfoSection(
            'Kategori',
            '${widget.medication.categoryName} (${widget.medication.subcategory})',
            Icons.category,
          ),
          _buildInfoSection(
            'Endikasyonlar',
            widget.medication.indications.join('\n'),
            Icons.healing,
          ),
          _buildInfoSection(
            'Uygulama Yolu',
            widget.medication.administration,
            Icons.directions,
          ),
          _buildInfoSection(
            'Etki Mekanizması',
            widget.medication.mechanism,
            Icons.psychology,
          ),
          _buildInfoSection(
            'Maliyet',
            widget.medication.cost,
            Icons.attach_money,
          ),
          _buildInfoSection(
            'Bulunabilirlik',
            widget.medication.availability,
            Icons.inventory,
          ),
        ],
      ),
    );
  }

  Widget _buildDosageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Standart Dozaj',
            widget.medication.dosage,
            Icons.schedule,
          ),
          _buildInfoSection(
            'Uygulama Yolu',
            widget.medication.administration,
            Icons.directions,
          ),
          _buildInfoSection(
            'Yarılanma Ömrü',
            widget.medication.halfLife,
            Icons.timer,
          ),
          _buildInfoSection(
            'Metabolizma',
            widget.medication.metabolism,
            Icons.biotech,
          ),
          _buildInfoSection(
            'Atılım',
            widget.medication.excretion,
            Icons.water_drop,
          ),
          if (widget.medication.notes != null) ...[
            const SizedBox(height: 20),
            _buildInfoSection(
              'Özel Notlar',
              widget.medication.notes!,
              Icons.note,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSideEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yan Etkiler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.medication.sideEffects.map((effect) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red[200] ?? Colors.red[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.red[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      effect,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          Text(
            'Uyarılar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.medication.warnings.map((warning) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContraindicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kontrendikasyonlar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.medication.contraindications.map((contraindication) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.block,
                    color: Colors.red[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      contraindication,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Gebelik ve emzirme kategorileri
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.medication.pregnancyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.medication.pregnancyColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pregnant_woman,
                        color: widget.medication.pregnancyColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gebelik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.medication.pregnancyColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: ${widget.medication.pregnancyCategory}',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.medication.pregnancyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.medication.lactationColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.medication.lactationColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.child_care,
                        color: widget.medication.lactationColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Emzirme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.medication.lactationColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: ${widget.medication.lactationCategory}',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.medication.lactationColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacologyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Etki Mekanizması',
            widget.medication.mechanism,
            Icons.psychology,
          ),
          _buildInfoSection(
            'Yarılanma Ömrü',
            widget.medication.halfLife,
            Icons.timer,
          ),
          _buildInfoSection(
            'Metabolizma',
            widget.medication.metabolism,
            Icons.biotech,
          ),
          _buildInfoSection(
            'Atılım',
            widget.medication.excretion,
            Icons.water_drop,
          ),
          const SizedBox(height: 24),
          Text(
            'İlaç Etkileşimleri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.medication.interactions.map((interaction) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sync,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      interaction,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildApprovalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Onay Durumu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),

          // Onay durumları
          ...widget.medication.approvalStatus.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.medication
                    .getApprovalStatusColor(entry.key)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.medication.getApprovalStatusColor(entry.key),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getApprovalIcon(entry.value),
                    color: widget.medication.getApprovalStatusColor(entry.key),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.medication
                                .getApprovalStatusColor(entry.key),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.medication
                                .getApprovalStatusColor(entry.key),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          if (widget.medication.lastUpdated != null) ...[
            const SizedBox(height: 24),
            _buildInfoSection(
              'Son Güncelleme',
              '${widget.medication.lastUpdated!.day}/${widget.medication.lastUpdated!.month}/${widget.medication.lastUpdated!.year}',
              Icons.update,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getApprovalIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      case 'withdrawn':
        return Icons.remove_circle;
      default:
        return Icons.help;
    }
  }
}
