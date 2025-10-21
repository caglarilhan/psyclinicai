import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EPrescriptionScreen extends StatefulWidget {
  const EPrescriptionScreen({super.key});

  @override
  State<EPrescriptionScreen> createState() => _EPrescriptionScreenState();
}

class _EPrescriptionScreenState extends State<EPrescriptionScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _medications = [
    {
      'id': 'MED001',
      'name': 'Fluoksetin',
      'genericName': 'Fluoxetine',
      'dosage': '20mg',
      'form': 'Tablet',
      'category': 'Antidepresan',
      'stock': 150,
      'price': 45.50,
      'prescriptionRequired': true,
      'sideEffects': ['Bulantı', 'Baş ağrısı', 'Uykusuzluk'],
      'interactions': ['MAO inhibitörleri', 'Warfarin'],
    },
    {
      'id': 'MED002',
      'name': 'Sertralin',
      'genericName': 'Sertraline',
      'dosage': '50mg',
      'form': 'Tablet',
      'category': 'Antidepresan',
      'stock': 200,
      'price': 52.30,
      'prescriptionRequired': true,
      'sideEffects': ['Mide bulantısı', 'İshal', 'Baş dönmesi'],
      'interactions': ['Pimozid', 'MAO inhibitörleri'],
    },
    {
      'id': 'MED003',
      'name': 'Lorazepam',
      'genericName': 'Lorazepam',
      'dosage': '1mg',
      'form': 'Tablet',
      'category': 'Anksiyolitik',
      'stock': 80,
      'price': 28.75,
      'prescriptionRequired': true,
      'sideEffects': ['Uyku hali', 'Baş dönmesi', 'Koordinasyon bozukluğu'],
      'interactions': ['Alkol', 'Opioidler', 'Barbitüratlar'],
    },
    {
      'id': 'MED004',
      'name': 'Risperidon',
      'genericName': 'Risperidone',
      'dosage': '2mg',
      'form': 'Tablet',
      'category': 'Antipsikotik',
      'stock': 120,
      'price': 67.80,
      'prescriptionRequired': true,
      'sideEffects': ['Ağız kuruluğu', 'Kabızlık', 'Kilo artışı'],
      'interactions': ['Karbamazepin', 'Rifampin'],
    },
  ];

  final List<Map<String, dynamic>> _prescriptions = [
    {
      'id': 'RX-2024-001',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'doctorName': 'Dr. Ayşe Demir',
      'date': DateTime(2024, 2, 15),
      'status': 'Aktif',
      'medications': [
        {
          'medicationId': 'MED001',
          'name': 'Fluoksetin',
          'dosage': '20mg',
          'frequency': 'Günde 1 kez',
          'duration': '30 gün',
          'instructions': 'Sabah yemekle birlikte alın',
        },
        {
          'medicationId': 'MED003',
          'name': 'Lorazepam',
          'dosage': '1mg',
          'frequency': 'Gerektiğinde',
          'duration': '15 gün',
          'instructions': 'Anksiyete durumunda maksimum 3 kez',
        },
      ],
      'totalAmount': 74.25,
      'insuranceCoverage': 70.0,
      'patientPayment': 22.28,
    },
    {
      'id': 'RX-2024-002',
      'patientId': 'P002',
      'patientName': 'Ayşe Demir',
      'doctorName': 'Dr. Mehmet Kaya',
      'date': DateTime(2024, 2, 14),
      'status': 'Tamamlandı',
      'medications': [
        {
          'medicationId': 'MED002',
          'name': 'Sertralin',
          'dosage': '50mg',
          'frequency': 'Günde 1 kez',
          'duration': '30 gün',
          'instructions': 'Akşam yemekle birlikte alın',
        },
      ],
      'totalAmount': 52.30,
      'insuranceCoverage': 80.0,
      'patientPayment': 10.46,
    },
    {
      'id': 'RX-2024-003',
      'patientId': 'P003',
      'patientName': 'Mehmet Kaya',
      'doctorName': 'Dr. Zeynep Can',
      'date': DateTime(2024, 2, 13),
      'status': 'İptal Edildi',
      'medications': [
        {
          'medicationId': 'MED004',
          'name': 'Risperidon',
          'dosage': '2mg',
          'frequency': 'Günde 2 kez',
          'duration': '30 gün',
          'instructions': 'Sabah ve akşam yemekle birlikte',
        },
      ],
      'totalAmount': 135.60,
      'insuranceCoverage': 75.0,
      'patientPayment': 33.90,
    },
  ];

  final List<Map<String, dynamic>> _pharmacies = [
    {
      'id': 'PH001',
      'name': 'Merkez Eczanesi',
      'address': 'Atatürk Cad. No:123, Merkez',
      'phone': '0212 555 0123',
      'distance': '0.5 km',
      'isOpen': true,
      'rating': 4.5,
      'deliveryAvailable': true,
    },
    {
      'id': 'PH002',
      'name': 'Sağlık Eczanesi',
      'address': 'Cumhuriyet Cad. No:456, Merkez',
      'phone': '0212 555 0456',
      'distance': '1.2 km',
      'isOpen': true,
      'rating': 4.2,
      'deliveryAvailable': false,
    },
    {
      'id': 'PH003',
      'name': 'Modern Eczane',
      'address': 'İstiklal Cad. No:789, Merkez',
      'phone': '0212 555 0789',
      'distance': '2.1 km',
      'isOpen': false,
      'rating': 4.7,
      'deliveryAvailable': true,
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
        title: const Text('E-Reçete Sistemi'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createPrescription,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchMedications,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.medication), text: 'İlaçlar'),
            Tab(icon: Icon(Icons.receipt), text: 'Reçeteler'),
            Tab(icon: Icon(Icons.local_pharmacy), text: 'Eczaneler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicationsTab(),
          _buildPrescriptionsTab(),
          _buildPharmaciesTab(),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        return _buildMedicationCard(_medications[index]);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        medication['genericName'],
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
                    color: medication['stock'] > 50 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stok: ${medication['stock']}',
                    style: TextStyle(
                      color: medication['stock'] > 50 ? Colors.green : Colors.orange,
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
                  child: _buildMedicationInfo('Dozaj', medication['dosage'], Icons.science),
                ),
                Expanded(
                  child: _buildMedicationInfo('Form', medication['form'], Icons.medication_liquid),
                ),
                Expanded(
                  child: _buildMedicationInfo('Fiyat', '₺${medication['price']}', Icons.attach_money),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Kategori: ${medication['category']}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yan Etkiler: ${medication['sideEffects'].join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewMedicationDetails(medication),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Detaylar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addToPrescription(medication),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Reçeteye Ekle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationInfo(String label, String value, IconData icon) {
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

  Widget _buildPrescriptionsTab() {
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
                  'Aktif Reçeteler',
                  '${_prescriptions.where((prescription) => prescription['status'] == 'Aktif').length}',
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Bu Ay Toplam',
                  '₺${_prescriptions.fold(0.0, (sum, prescription) => sum + prescription['totalAmount']).toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        
        // Reçete listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _prescriptions.length,
            itemBuilder: (context, index) {
              return _buildPrescriptionCard(_prescriptions[index]);
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

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor;
    switch (prescription['status']) {
      case 'Aktif':
        statusColor = Colors.purple[300]!;
        break;
      case 'Tamamlandı':
        statusColor = Colors.purple[600]!;
        break;
      case 'İptal Edildi':
        statusColor = Colors.purple[800]!;
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
                    prescription['id'],
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
                    prescription['status'],
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
            Text('Hasta: ${prescription['patientName']}'),
            Text('Doktor: ${prescription['doctorName']}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(prescription['date'])}'),
            const SizedBox(height: 12),
            Text(
              'İlaçlar (${prescription['medications'].length} adet):',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...prescription['medications'].map<Widget>((med) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.medication, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${med['name']} ${med['dosage']} - ${med['frequency']}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            Row(
              children: [
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
                        '₺${prescription['totalAmount'].toStringAsFixed(2)}',
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
                        'Hasta Ödemesi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₺${prescription['patientPayment'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPrescriptionDetails(prescription),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Detaylar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendToPharmacy(prescription),
                    icon: const Icon(Icons.local_pharmacy, size: 16),
                    label: const Text('Eczaneye Gönder'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmaciesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pharmacies.length,
      itemBuilder: (context, index) {
        return _buildPharmacyCard(_pharmacies[index]);
      },
    );
  }

  Widget _buildPharmacyCard(Map<String, dynamic> pharmacy) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_pharmacy,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pharmacy['address'],
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
                    color: pharmacy['isOpen'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pharmacy['isOpen'] ? 'Açık' : 'Kapalı',
                    style: TextStyle(
                      color: pharmacy['isOpen'] ? Colors.green : Colors.red,
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
                  child: _buildPharmacyInfo('Telefon', pharmacy['phone'], Icons.phone),
                ),
                Expanded(
                  child: _buildPharmacyInfo('Mesafe', pharmacy['distance'], Icons.location_on),
                ),
                Expanded(
                  child: _buildPharmacyInfo('Puan', '${pharmacy['rating']}', Icons.star),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (pharmacy['deliveryAvailable'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delivery_dining, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Teslimat',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _callPharmacy(pharmacy),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Ara'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _sendPrescriptionToPharmacy(pharmacy),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Reçete Gönder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyInfo(String label, String value, IconData icon) {
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

  void _createPrescription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Reçete'),
        content: const Text('Reçete oluşturma formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reçete oluşturma özelliği yakında eklenecek')),
              );
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _searchMedications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlaç Ara'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'İlaç adı veya etken madde',
            border: OutlineInputBorder(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arama özelliği yakında eklenecek')),
              );
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _viewMedicationDetails(Map<String, dynamic> medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medication['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Etken Madde: ${medication['genericName']}'),
              Text('Dozaj: ${medication['dosage']}'),
              Text('Form: ${medication['form']}'),
              Text('Kategori: ${medication['category']}'),
              Text('Stok: ${medication['stock']} adet'),
              Text('Fiyat: ₺${medication['price']}'),
              Text('Reçete Gerekli: ${medication['prescriptionRequired'] ? 'Evet' : 'Hayır'}'),
              const SizedBox(height: 8),
              const Text('Yan Etkiler:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...medication['sideEffects'].map<Widget>((effect) {
                return Text('• $effect');
              }).toList(),
              const SizedBox(height: 8),
              const Text('Etkileşimler:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...medication['interactions'].map<Widget>((interaction) {
                return Text('• $interaction');
              }).toList(),
            ],
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

  void _addToPrescription(Map<String, dynamic> medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medication['name']} reçeteye eklendi')),
    );
  }

  void _viewPrescriptionDetails(Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reçete ${prescription['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${prescription['patientName']}'),
              Text('Doktor: ${prescription['doctorName']}'),
              Text('Tarih: ${DateFormat('dd.MM.yyyy').format(prescription['date'])}'),
              Text('Durum: ${prescription['status']}'),
              const SizedBox(height: 16),
              const Text('İlaçlar:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...prescription['medications'].map<Widget>((med) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${med['name']} ${med['dosage']}'),
                      Text('Sıklık: ${med['frequency']}'),
                      Text('Süre: ${med['duration']}'),
                      Text('Talimatlar: ${med['instructions']}'),
                      const Divider(),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Text('Toplam Tutar: ₺${prescription['totalAmount']}'),
              Text('Sigorta Kapsaması: %${prescription['insuranceCoverage']}'),
              Text('Hasta Ödemesi: ₺${prescription['patientPayment']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reçete PDF olarak indiriliyor')),
              );
            },
            child: const Text('PDF İndir'),
          ),
        ],
      ),
    );
  }

  void _sendToPharmacy(Map<String, dynamic> prescription) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${prescription['id']} reçetesi eczaneye gönderiliyor...')),
    );
  }

  void _callPharmacy(Map<String, dynamic> pharmacy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${pharmacy['name']} aranıyor: ${pharmacy['phone']}')),
    );
  }

  void _sendPrescriptionToPharmacy(Map<String, dynamic> pharmacy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reçete ${pharmacy['name']} eczanesine gönderiliyor...')),
    );
  }
}
