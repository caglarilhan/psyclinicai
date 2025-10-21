import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _insuranceCompanies = [
    {
      'id': 'SGK',
      'name': 'Sosyal Güvenlik Kurumu',
      'logo': 'assets/logos/sgk.png',
      'coverage': 70.0,
      'status': 'Aktif',
      'apiEndpoint': 'https://api.sgk.gov.tr',
      'lastSync': DateTime(2024, 2, 15, 10, 30),
    },
    {
      'id': 'ALLIANZ',
      'name': 'Allianz Sigorta',
      'logo': 'assets/logos/allianz.png',
      'coverage': 80.0,
      'status': 'Aktif',
      'apiEndpoint': 'https://api.allianz.com.tr',
      'lastSync': DateTime(2024, 2, 14, 15, 45),
    },
    {
      'id': 'AKSIGORTA',
      'name': 'Aksigorta',
      'logo': 'assets/logos/aksigorta.png',
      'coverage': 75.0,
      'status': 'Aktif',
      'apiEndpoint': 'https://api.aksigorta.com.tr',
      'lastSync': DateTime(2024, 2, 13, 09, 20),
    },
    {
      'id': 'MAPFRE',
      'name': 'Mapfre Sigorta',
      'logo': 'assets/logos/mapfre.png',
      'coverage': 65.0,
      'status': 'Bakımda',
      'apiEndpoint': 'https://api.mapfre.com.tr',
      'lastSync': DateTime(2024, 2, 10, 14, 15),
    },
  ];

  final List<Map<String, dynamic>> _patientInsurance = [
    {
      'id': '1',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'insuranceCompany': 'SGK',
      'policyNumber': 'SGK-2024-001234',
      'coverageType': 'Tam Kapsama',
      'coverageAmount': 10000.0,
      'remainingAmount': 8500.0,
      'validFrom': DateTime(2024, 1, 1),
      'validTo': DateTime(2024, 12, 31),
      'status': 'Aktif',
    },
    {
      'id': '2',
      'patientId': 'P002',
      'patientName': 'Ayşe Demir',
      'insuranceCompany': 'Allianz',
      'policyNumber': 'ALL-2024-005678',
      'coverageType': 'Kısmi Kapsama',
      'coverageAmount': 5000.0,
      'remainingAmount': 3200.0,
      'validFrom': DateTime(2024, 2, 1),
      'validTo': DateTime(2025, 1, 31),
      'status': 'Aktif',
    },
    {
      'id': '3',
      'patientId': 'P003',
      'patientName': 'Mehmet Kaya',
      'insuranceCompany': 'Aksigorta',
      'policyNumber': 'AKS-2024-009876',
      'coverageType': 'Tam Kapsama',
      'coverageAmount': 8000.0,
      'remainingAmount': 0.0,
      'validFrom': DateTime(2023, 12, 1),
      'validTo': DateTime(2024, 11, 30),
      'status': 'Tükendi',
    },
  ];

  final List<Map<String, dynamic>> _claims = [
    {
      'id': 'CLM-001',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'insuranceCompany': 'SGK',
      'policyNumber': 'SGK-2024-001234',
      'claimAmount': 450.0,
      'approvedAmount': 315.0,
      'claimDate': DateTime(2024, 2, 15),
      'status': 'Onaylandı',
      'description': 'Psikiyatri konsültasyonu ve ilaç tedavisi',
      'documents': ['Reçete', 'Rapor', 'Fatura'],
    },
    {
      'id': 'CLM-002',
      'patientId': 'P002',
      'patientName': 'Ayşe Demir',
      'insuranceCompany': 'Allianz',
      'policyNumber': 'ALL-2024-005678',
      'claimAmount': 600.0,
      'approvedAmount': 0.0,
      'claimDate': DateTime(2024, 2, 14),
      'status': 'İnceleniyor',
      'description': 'Psikoterapi seansları',
      'documents': ['Terapi Raporu', 'Fatura'],
    },
    {
      'id': 'CLM-003',
      'patientId': 'P003',
      'patientName': 'Mehmet Kaya',
      'insuranceCompany': 'Aksigorta',
      'policyNumber': 'AKS-2024-009876',
      'claimAmount': 750.0,
      'approvedAmount': 0.0,
      'claimDate': DateTime(2024, 2, 13),
      'status': 'Reddedildi',
      'description': 'Bipolar bozukluk tedavisi',
      'documents': ['Tıbbi Rapor', 'Fatura'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sigorta Entegrasyonu'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncAllInsurances,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addInsuranceCompany,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Sigorta Şirketleri'),
            Tab(icon: Icon(Icons.person), text: 'Hasta Sigortaları'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Talepler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInsuranceCompaniesTab(),
          _buildPatientInsuranceTab(),
          _buildClaimsTab(),
        ],
      ),
    );
  }

  Widget _buildInsuranceCompaniesTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Özet kartları
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Aktif Şirketler',
                  '${_insuranceCompanies.where((company) => company['status'] == 'Aktif').length}',
                  Icons.business,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Ortalama Kapsama',
                  '%${(_insuranceCompanies.fold(0.0, (sum, company) => sum + (company['coverage'] as double)) / _insuranceCompanies.length).toStringAsFixed(0)}',
                  Icons.security,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ),
        
        // Sigorta şirketleri listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _insuranceCompanies.length,
            itemBuilder: (context, index) {
              return _buildInsuranceCompanyCard(_insuranceCompanies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCompanyCard(Map<String, dynamic> company) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor;
    switch (company['status']) {
      case 'Aktif':
        statusColor = Colors.green;
        break;
      case 'Bakımda':
        statusColor = Colors.orange;
        break;
      case 'Pasif':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${company['id']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    company['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Kapsama',
                    '%${(company['coverage'] as double).toStringAsFixed(0)}',
                    Icons.security,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Son Senkronizasyon',
                    DateFormat('dd.MM.yyyy').format(company['lastSync']),
                    Icons.sync,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _syncCompany(company),
                    icon: const Icon(Icons.sync, size: 16),
                    label: const Text('Senkronize Et'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewCompanyDetails(company),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Detaylar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInsuranceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _patientInsurance.length,
      itemBuilder: (context, index) {
        return _buildPatientInsuranceCard(_patientInsurance[index]);
      },
    );
  }

  Widget _buildPatientInsuranceCard(Map<String, dynamic> insurance) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor;
    switch (insurance['status']) {
      case 'Aktif':
        statusColor = Colors.green;
        break;
      case 'Tükendi':
        statusColor = Colors.red;
        break;
      case 'Süresi Dolmuş':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    final coveragePercentage = (insurance['remainingAmount'] / insurance['coverageAmount']) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    insurance['patientName'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    insurance['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Sigorta: ${insurance['insuranceCompany']}'),
            Text('Poliçe No: ${insurance['policyNumber']}'),
            Text('Kapsama Türü: ${insurance['coverageType']}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalan Tutar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₺${insurance['remainingAmount'].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toplam Tutar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₺${insurance['coverageAmount'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: coveragePercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                coveragePercentage > 50 ? Colors.green : 
                coveragePercentage > 25 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _checkCoverage(insurance),
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Kapsama Kontrol'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewInsuranceDetails(insurance),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Detaylar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _claims.length,
      itemBuilder: (context, index) {
        return _buildClaimCard(_claims[index]);
      },
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor;
    switch (claim['status']) {
      case 'Onaylandı':
        statusColor = Colors.green;
        break;
      case 'İnceleniyor':
        statusColor = Colors.orange;
        break;
      case 'Reddedildi':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    claim['id'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    claim['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Hasta: ${claim['patientName']}'),
            Text('Sigorta: ${claim['insuranceCompany']}'),
            Text('Poliçe: ${claim['policyNumber']}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(claim['claimDate'])}'),
            const SizedBox(height: 8),
            Text(
              claim['description'],
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Talep Tutarı',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₺${claim['claimAmount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onaylanan Tutar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₺${claim['approvedAmount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: claim['approvedAmount'] > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Belgeler: ${claim['documents'].join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewClaimDetails(claim),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Detaylar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _trackClaim(claim),
                    icon: const Icon(Icons.track_changes, size: 16),
                    label: const Text('Takip Et'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _syncAllInsurances() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Sigortaları Senkronize Et'),
        content: const Text('Tüm sigorta şirketleriyle veri senkronizasyonu başlatılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Senkronizasyon başlatıldı')),
              );
            },
            child: const Text('Senkronize Et'),
          ),
        ],
      ),
    );
  }

  void _addInsuranceCompany() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Sigorta Şirketi'),
        content: const Text('Yeni sigorta şirketi ekleme formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sigorta şirketi ekleme özelliği yakında eklenecek')),
              );
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _syncCompany(Map<String, dynamic> company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${company['name']} senkronizasyonu başlatıldı')),
    );
  }

  void _viewCompanyDetails(Map<String, dynamic> company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(company['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${company['id']}'),
            Text('Kapsama: %${(company['coverage'] as double).toStringAsFixed(0)}'),
            Text('Durum: ${company['status']}'),
            Text('API Endpoint: ${company['apiEndpoint']}'),
            Text('Son Senkronizasyon: ${DateFormat('dd.MM.yyyy HH:mm').format(company['lastSync'])}'),
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

  void _checkCoverage(Map<String, dynamic> insurance) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${insurance['patientName']} kapsama kontrolü yapılıyor...')),
    );
  }

  void _viewInsuranceDetails(Map<String, dynamic> insurance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${insurance['patientName']} - Sigorta Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sigorta: ${insurance['insuranceCompany']}'),
            Text('Poliçe No: ${insurance['policyNumber']}'),
            Text('Kapsama Türü: ${insurance['coverageType']}'),
            Text('Toplam Tutar: ₺${insurance['coverageAmount']}'),
            Text('Kalan Tutar: ₺${insurance['remainingAmount']}'),
            Text('Geçerlilik: ${DateFormat('dd.MM.yyyy').format(insurance['validFrom'])} - ${DateFormat('dd.MM.yyyy').format(insurance['validTo'])}'),
            Text('Durum: ${insurance['status']}'),
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

  void _viewClaimDetails(Map<String, dynamic> claim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Talep ${claim['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hasta: ${claim['patientName']}'),
            Text('Sigorta: ${claim['insuranceCompany']}'),
            Text('Poliçe: ${claim['policyNumber']}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(claim['claimDate'])}'),
            Text('Durum: ${claim['status']}'),
            Text('Talep Tutarı: ₺${claim['claimAmount']}'),
            Text('Onaylanan Tutar: ₺${claim['approvedAmount']}'),
            Text('Açıklama: ${claim['description']}'),
            Text('Belgeler: ${claim['documents'].join(', ')}'),
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

  void _trackClaim(Map<String, dynamic> claim) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${claim['id']} talep takibi başlatıldı')),
    );
  }
}
