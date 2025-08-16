import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/finance_model.dart';
import '../../widgets/finance/billing_overview_widget.dart';
import '../../widgets/finance/invoice_management_widget.dart';
import '../../widgets/finance/payment_tracking_widget.dart';
import '../../widgets/finance/financial_analytics_widget.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  List<Invoice> _invoices = [];
  List<Payment> _payments = [];
  List<ClientBilling> _clientBillings = [];
  List<FinancialMetrics> _financialMetrics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    setState(() {
      _isLoading = true;
    });

    // Demo client billings
    _clientBillings = [
      ClientBilling(
        id: '1',
        clientId: 'client1',
        clientName: 'Ahmet Yılmaz',
        therapistId: 'therapist1',
        therapistName: 'Dr. Ayşe Demir',
        billingType: BillingType.session,
        sessionRate: 500.0,
        effectiveDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ClientBilling(
        id: '2',
        clientId: 'client2',
        clientName: 'Ayşe Demir',
        therapistId: 'therapist2',
        therapistName: 'Dr. Mehmet Kaya',
        billingType: BillingType.hourly,
        hourlyRate: 800.0,
        effectiveDate: DateTime.now().subtract(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      ClientBilling(
        id: '3',
        clientId: 'client3',
        clientName: 'Mehmet Kaya',
        therapistId: 'therapist1',
        therapistName: 'Dr. Ayşe Demir',
        billingType: BillingType.package,
        packageRate: 2000.0,
        effectiveDate: DateTime.now().subtract(const Duration(days: 60)),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    // Demo invoices
    _invoices = [
      Invoice(
        id: '1',
        invoiceNumber: 'INV-2024-001',
        clientId: 'client1',
        clientName: 'Ahmet Yılmaz',
        therapistId: 'therapist1',
        therapistName: 'Dr. Ayşe Demir',
        items: [
          InvoiceItem(
            id: 'item1',
            description: 'Terapi Seansı - Depresyon',
            quantity: 1,
            unitPrice: 500.0,
            totalPrice: 500.0,
            sessionId: 'session1',
            sessionDate: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
        subtotal: 500.0,
        totalAmount: 500.0,
        status: InvoiceStatus.paid,
        issueDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        paidDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Invoice(
        id: '2',
        invoiceNumber: 'INV-2024-002',
        clientId: 'client2',
        clientName: 'Ayşe Demir',
        therapistId: 'therapist2',
        therapistName: 'Dr. Mehmet Kaya',
        items: [
          InvoiceItem(
            id: 'item2',
            description: 'Terapi Seansı - Anksiyete (2 saat)',
            quantity: 2,
            unitPrice: 800.0,
            totalPrice: 1600.0,
            sessionId: 'session2',
            sessionDate: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        subtotal: 1600.0,
        totalAmount: 1600.0,
        status: InvoiceStatus.sent,
        issueDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Invoice(
        id: '3',
        invoiceNumber: 'INV-2024-003',
        clientId: 'client3',
        clientName: 'Mehmet Kaya',
        therapistId: 'therapist1',
        therapistName: 'Dr. Ayşe Demir',
        items: [
          InvoiceItem(
            id: 'item3',
            description: 'Terapi Paketi - 4 Seans',
            quantity: 1,
            unitPrice: 2000.0,
            totalPrice: 2000.0,
            notes: 'Özel paket fiyatı',
          ),
        ],
        subtotal: 2000.0,
        totalAmount: 2000.0,
        status: InvoiceStatus.overdue,
        issueDate: DateTime.now().subtract(const Duration(days: 15)),
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    // Demo payments
    _payments = [
      Payment(
        id: '1',
        invoiceId: '1',
        invoiceNumber: 'INV-2024-001',
        clientId: 'client1',
        clientName: 'Ahmet Yılmaz',
        amount: 500.0,
        status: PaymentStatus.completed,
        method: PaymentMethod.stripe,
        transactionId: 'txn_123456789',
        stripePaymentIntentId: 'pi_123456789',
        paymentDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Payment(
        id: '2',
        invoiceId: '2',
        invoiceNumber: 'INV-2024-002',
        clientId: 'client2',
        clientName: 'Ayşe Demir',
        amount: 1600.0,
        status: PaymentStatus.pending,
        method: PaymentMethod.creditCard,
        paymentDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Demo financial metrics
    _financialMetrics = [
      FinancialMetrics(
        id: '1',
        periodStart: DateTime.now().subtract(const Duration(days: 30)),
        periodEnd: DateTime.now(),
        totalRevenue: 4100.0,
        totalExpenses: 1200.0,
        netIncome: 2900.0,
        totalInvoices: 3,
        paidInvoices: 1,
        overdueInvoices: 1,
        averageInvoiceAmount: 1366.67,
        collectionRate: 33.33,
        breakdown: {
          'therapist1': 2500.0,
          'therapist2': 1600.0,
        },
        insights: [
          'Toplam gelir: ₺4,100',
          'Net kar: ₺2,900',
          'Kar marjı: %70.7',
          '1 fatura gecikmiş ödeme',
        ],
        createdAt: DateTime.now(),
      ),
    ];

    _isLoading = false;
  }

  void _addNewInvoice() {
    HapticFeedback.lightImpact();
    // TODO: Implement new invoice form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeni fatura ekleme özelliği yakında!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Finans Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addNewInvoice,
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Fatura Ekle',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement settings
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bakış', icon: Icon(Icons.dashboard)),
            Tab(text: 'Faturalar', icon: Icon(Icons.receipt)),
            Tab(text: 'Ödemeler', icon: Icon(Icons.payment)),
            Tab(text: 'Analitik', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          BillingOverviewWidget(
            invoices: _invoices,
            payments: _payments,
            clientBillings: _clientBillings,
            financialMetrics: _financialMetrics,
          ),
          
          // Invoices Tab
          InvoiceManagementWidget(
            invoices: _invoices,
            onInvoiceTap: (invoice) {
              HapticFeedback.lightImpact();
              // TODO: Navigate to invoice detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${invoice.invoiceNumber} fatura detayı'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          
          // Payments Tab
          PaymentTrackingWidget(
            payments: _payments,
            onPaymentTap: (payment) {
              HapticFeedback.lightImpact();
              // TODO: Navigate to payment detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${payment.transactionId ?? 'Ödeme'} detayı'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
          
          // Analytics Tab
          FinancialAnalyticsWidget(
            financialMetrics: _financialMetrics,
            invoices: _invoices,
            payments: _payments,
            onMetricTap: (metric) {
              HapticFeedback.lightImpact();
              // TODO: Navigate to metric detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${metric.periodStart.month}/${metric.periodStart.year} dönem analizi'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewInvoice,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Fatura'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
