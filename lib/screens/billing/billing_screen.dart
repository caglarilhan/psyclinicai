import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-2024-001',
      'patient': 'Ahmet Yılmaz',
      'date': DateTime(2024, 2, 15),
      'dueDate': DateTime(2024, 3, 15),
      'amount': 450.0,
      'status': 'Ödendi',
      'items': [
        {'name': 'Psikiyatri Konsültasyonu', 'quantity': 1, 'price': 300.0},
        {'name': 'Psikoterapi Seansı', 'quantity': 2, 'price': 150.0},
      ],
    },
    {
      'id': 'INV-2024-002',
      'patient': 'Ayşe Demir',
      'date': DateTime(2024, 2, 14),
      'dueDate': DateTime(2024, 3, 14),
      'amount': 600.0,
      'status': 'Beklemede',
      'items': [
        {'name': 'Psikiyatri Konsültasyonu', 'quantity': 1, 'price': 300.0},
        {'name': 'Psikoterapi Seansı', 'quantity': 4, 'price': 300.0},
      ],
    },
    {
      'id': 'INV-2024-003',
      'patient': 'Mehmet Kaya',
      'date': DateTime(2024, 2, 13),
      'dueDate': DateTime(2024, 3, 13),
      'amount': 750.0,
      'status': 'Gecikmiş',
      'items': [
        {'name': 'Psikiyatri Konsültasyonu', 'quantity': 1, 'price': 300.0},
        {'name': 'Psikoterapi Seansı', 'quantity': 6, 'price': 450.0},
      ],
    },
  ];

  final List<Map<String, dynamic>> _payments = [
    {
      'id': 'PAY-001',
      'invoiceId': 'INV-2024-001',
      'patient': 'Ahmet Yılmaz',
      'amount': 450.0,
      'date': DateTime(2024, 2, 16),
      'method': 'Kredi Kartı',
      'status': 'Başarılı',
    },
    {
      'id': 'PAY-002',
      'invoiceId': 'INV-2024-004',
      'patient': 'Zeynep Can',
      'amount': 300.0,
      'date': DateTime(2024, 2, 12),
      'method': 'Banka Havalesi',
      'status': 'Beklemede',
    },
  ];

  final List<Map<String, dynamic>> _insuranceClaims = [
    {
      'id': 'CLM-001',
      'patient': 'Ahmet Yılmaz',
      'insuranceCompany': 'SGK',
      'amount': 450.0,
      'date': DateTime(2024, 2, 15),
      'status': 'Onaylandı',
      'claimNumber': 'SGK-2024-001234',
    },
    {
      'id': 'CLM-002',
      'patient': 'Ayşe Demir',
      'insuranceCompany': 'Allianz',
      'amount': 600.0,
      'date': DateTime(2024, 2, 14),
      'status': 'İnceleniyor',
      'claimNumber': 'ALL-2024-005678',
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
        title: const Text('Faturalandırma'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createInvoice,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt), text: 'Faturalar'),
            Tab(icon: Icon(Icons.payment), text: 'Ödemeler'),
            Tab(icon: Icon(Icons.local_hospital), text: 'Sigorta'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoicesTab(),
          _buildPaymentsTab(),
          _buildInsuranceTab(),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab() {
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
                  'Toplam Fatura',
                  '₺${_invoices.fold(0.0, (sum, invoice) => sum + invoice['amount']).toStringAsFixed(0)}',
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Bekleyen',
                  '₺${_invoices.where((invoice) => invoice['status'] == 'Beklemede').fold(0.0, (sum, invoice) => sum + invoice['amount']).toStringAsFixed(0)}',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),
        
        // Fatura listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _invoices.length,
            itemBuilder: (context, index) {
              return _buildInvoiceCard(_invoices[index]);
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

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color statusColor;
    switch (invoice['status']) {
      case 'Ödendi':
        statusColor = Colors.green;
        break;
      case 'Beklemede':
        statusColor = Colors.orange;
        break;
      case 'Gecikmiş':
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
                    invoice['id'],
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
                    invoice['status'],
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
            Text(
              'Hasta: ${invoice['patient']}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Tarih: ${DateFormat('dd.MM.yyyy').format(invoice['date'])}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Vade: ${DateFormat('dd.MM.yyyy').format(invoice['dueDate'])}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Toplam: ₺${invoice['amount'].toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewInvoice(invoice),
                  child: const Text('Görüntüle'),
                ),
                ElevatedButton(
                  onPressed: () => _sendInvoice(invoice),
                  child: const Text('Gönder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(_payments[index]);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final theme = Theme.of(context);
    
    Color statusColor;
    switch (payment['status']) {
      case 'Başarılı':
        statusColor = Colors.green;
        break;
      case 'Beklemede':
        statusColor = Colors.orange;
        break;
      case 'Başarısız':
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
                    payment['id'],
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
                    payment['status'],
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
            Text('Hasta: ${payment['patient']}'),
            Text('Fatura: ${payment['invoiceId']}'),
            Text('Yöntem: ${payment['method']}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(payment['date'])}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Tutar: ₺${payment['amount'].toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewPayment(payment),
                  child: const Text('Detaylar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _insuranceClaims.length,
      itemBuilder: (context, index) {
        return _buildInsuranceCard(_insuranceClaims[index]);
      },
    );
  }

  Widget _buildInsuranceCard(Map<String, dynamic> claim) {
    final theme = Theme.of(context);
    
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
            Text('Hasta: ${claim['patient']}'),
            Text('Sigorta: ${claim['insuranceCompany']}'),
            Text('Talep No: ${claim['claimNumber']}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(claim['date'])}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Tutar: ₺${claim['amount'].toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewClaim(claim),
                  child: const Text('Detaylar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createInvoice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Fatura'),
        content: const Text('Fatura oluşturma formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fatura oluşturma özelliği yakında eklenecek')),
              );
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _exportReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rapor İhracı'),
        content: const Text('Faturalandırma raporları ihraç edilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rapor ihracı başlatıldı')),
              );
            },
            child: const Text('İhrac Et'),
          ),
        ],
      ),
    );
  }

  void _viewInvoice(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fatura ${invoice['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${invoice['patient']}'),
              Text('Tarih: ${DateFormat('dd.MM.yyyy').format(invoice['date'])}'),
              Text('Vade: ${DateFormat('dd.MM.yyyy').format(invoice['dueDate'])}'),
              Text('Durum: ${invoice['status']}'),
              const SizedBox(height: 16),
              const Text('Kalemler:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...invoice['items'].map<Widget>((item) {
                return Text('• ${item['name']} x${item['quantity']} = ₺${item['price']}');
              }).toList(),
              const SizedBox(height: 16),
              Text(
                'Toplam: ₺${invoice['amount'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
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
                const SnackBar(content: Text('Fatura PDF olarak indiriliyor')),
              );
            },
            child: const Text('PDF İndir'),
          ),
        ],
      ),
    );
  }

  void _sendInvoice(Map<String, dynamic> invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${invoice['id']} faturası gönderiliyor...')),
    );
  }

  void _viewPayment(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ödeme ${payment['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hasta: ${payment['patient']}'),
            Text('Fatura: ${payment['invoiceId']}'),
            Text('Yöntem: ${payment['method']}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(payment['date'])}'),
            Text('Durum: ${payment['status']}'),
            Text('Tutar: ₺${payment['amount'].toStringAsFixed(2)}'),
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

  void _viewClaim(Map<String, dynamic> claim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sigorta Talebi ${claim['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hasta: ${claim['patient']}'),
            Text('Sigorta: ${claim['insuranceCompany']}'),
            Text('Talep No: ${claim['claimNumber']}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(claim['date'])}'),
            Text('Durum: ${claim['status']}'),
            Text('Tutar: ₺${claim['amount'].toStringAsFixed(2)}'),
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
