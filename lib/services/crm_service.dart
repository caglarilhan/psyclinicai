import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/crm_models.dart';

class CRMService {
  static final CRMService _instance = CRMService._internal();
  factory CRMService() => _instance;
  CRMService._internal();

  bool _isInitialized = false;
  final List<Customer> _customers = [];
  final List<SalesOpportunity> _opportunities = [];
  final List<CRMActivity> _activities = [];
  final Random _random = Random();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Demo verileri yükle
    await _loadDemoData();
    _isInitialized = true;
    print('CRMService initialized with ${_customers.length} customers and ${_opportunities.length} opportunities');
  }

  Future<void> _loadDemoData() async {
    // Demo müşteriler
    _customers.addAll([
      Customer(
        id: '1',
        name: 'Dr. Ahmet Yılmaz',
        email: 'ahmet.yilmaz@klinik.com',
        phone: '+90 532 123 4567',
        type: CustomerType.healthcare,
        company: 'Merkez Klinik',
        position: 'Başhekim',
        address: 'İstanbul, Türkiye',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastContact: DateTime.now().subtract(const Duration(days: 2)),
        lifetimeValue: 15000.0,
        tags: ['VIP', 'Sağlık', 'İstanbul'],
      ),
      Customer(
        id: '2',
        name: 'Zeynep Kaya',
        email: 'zeynep.kaya@okul.edu.tr',
        phone: '+90 533 987 6543',
        type: CustomerType.education,
        company: 'İstanbul Üniversitesi',
        position: 'Psikoloji Bölümü Başkanı',
        address: 'İstanbul, Türkiye',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastContact: DateTime.now().subtract(const Duration(days: 5)),
        lifetimeValue: 8000.0,
        tags: ['Eğitim', 'Üniversite', 'Psikoloji'],
      ),
      Customer(
        id: '3',
        name: 'Mehmet Demir',
        email: 'mehmet.demir@sirket.com',
        phone: '+90 534 555 1234',
        type: CustomerType.business,
        company: 'Demir Holding',
        position: 'İK Direktörü',
        address: 'Ankara, Türkiye',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastContact: DateTime.now().subtract(const Duration(days: 1)),
        lifetimeValue: 25000.0,
        tags: ['Kurumsal', 'Holding', 'İK'],
      ),
      Customer(
        id: '4',
        name: 'Ayşe Özkan',
        email: 'ayse.ozkan@bireysel.com',
        phone: '+90 535 777 8888',
        type: CustomerType.individual,
        company: '',
        position: 'Serbest Çalışan',
        address: 'İzmir, Türkiye',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastContact: DateTime.now().subtract(const Duration(days: 3)),
        lifetimeValue: 3000.0,
        tags: ['Bireysel', 'Serbest', 'İzmir'],
      ),
      Customer(
        id: '5',
        name: 'Devlet Hastanesi',
        email: 'info@devlethastanesi.gov.tr',
        phone: '+90 232 444 5555',
        type: CustomerType.government,
        company: 'Sağlık Bakanlığı',
        position: 'Hastane Müdürü',
        address: 'İzmir, Türkiye',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastContact: DateTime.now().subtract(const Duration(days: 7)),
        lifetimeValue: 50000.0,
        tags: ['Devlet', 'Hastane', 'Sağlık'],
      ),
    ]);

    // Demo satış fırsatları
    _opportunities.addAll([
      SalesOpportunity(
        id: '1',
        customerId: '1',
        customerName: 'Dr. Ahmet Yılmaz',
        title: 'Klinik Yönetim Sistemi Lisansı',
        description: 'Merkez Klinik için 50 kullanıcılı PsyClinic AI lisansı',
        status: SalesStatus.negotiation,
        value: 15000.0,
        probability: 0.8,
        expectedCloseDate: DateTime.now().add(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        assignedTo: 'Satış Ekibi',
        tags: ['Lisans', 'Klinik', 'Yüksek Değer'],
      ),
      SalesOpportunity(
        id: '2',
        customerId: '2',
        customerName: 'Zeynep Kaya',
        title: 'Üniversite Eğitim Programı',
        description: 'İstanbul Üniversitesi Psikoloji Bölümü için eğitim programı',
        status: SalesStatus.proposal,
        value: 8000.0,
        probability: 0.6,
        expectedCloseDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        assignedTo: 'Eğitim Ekibi',
        tags: ['Eğitim', 'Üniversite', 'Program'],
      ),
      SalesOpportunity(
        id: '3',
        customerId: '3',
        customerName: 'Mehmet Demir',
        title: 'Kurumsal Çözüm Paketi',
        description: 'Demir Holding için 200 kullanıcılı kurumsal paket',
        status: SalesStatus.qualified,
        value: 25000.0,
        probability: 0.4,
        expectedCloseDate: DateTime.now().add(const Duration(days: 60)),
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        assignedTo: 'Kurumsal Satış',
        tags: ['Kurumsal', 'Yüksek Değer', 'Holding'],
      ),
      SalesOpportunity(
        id: '4',
        customerId: '4',
        customerName: 'Ayşe Özkan',
        title: 'Bireysel Terapi Paketi',
        description: 'Bireysel kullanım için terapi simülasyonu paketi',
        status: SalesStatus.lead,
        value: 3000.0,
        probability: 0.3,
        expectedCloseDate: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        assignedTo: 'Bireysel Satış',
        tags: ['Bireysel', 'Terapi', 'Simülasyon'],
      ),
      SalesOpportunity(
        id: '5',
        customerId: '5',
        customerName: 'Devlet Hastanesi',
        title: 'Hastane Entegrasyon Projesi',
        description: 'Devlet hastanesi için tam entegrasyon projesi',
        status: SalesStatus.closed,
        value: 50000.0,
        probability: 1.0,
        expectedCloseDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        assignedTo: 'Proje Ekibi',
        tags: ['Proje', 'Entegrasyon', 'Devlet'],
      ),
    ]);

    // Demo aktiviteler
    _activities.addAll([
      CRMActivity(
        id: '1',
        type: ActivityType.customerAdded,
        description: 'Yeni müşteri eklendi: Dr. Ahmet Yılmaz',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        userId: 'user_001',
        userName: 'Satış Temsilcisi',
        customerId: '1',
      ),
      CRMActivity(
        id: '2',
        type: ActivityType.opportunityCreated,
        description: 'Yeni fırsat oluşturuldu: Klinik Yönetim Sistemi',
        timestamp: DateTime.now().subtract(const Duration(days: 20)),
        userId: 'user_001',
        userName: 'Satış Temsilcisi',
        customerId: '1',
        opportunityId: '1',
      ),
      CRMActivity(
        id: '3',
        type: ActivityType.dealClosed,
        description: 'Anlaşma kapatıldı: Hastane Entegrasyon Projesi',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'user_002',
        userName: 'Proje Müdürü',
        customerId: '5',
        opportunityId: '5',
      ),
      CRMActivity(
        id: '4',
        type: ActivityType.followUp,
        description: 'Müşteri ile takip görüşmesi yapıldı',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'user_001',
        userName: 'Satış Temsilcisi',
        customerId: '1',
      ),
      CRMActivity(
        id: '5',
        type: ActivityType.opportunityCreated,
        description: 'Yeni fırsat oluşturuldu: Üniversite Eğitim Programı',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        userId: 'user_003',
        userName: 'Eğitim Uzmanı',
        customerId: '2',
        opportunityId: '2',
      ),
    ]);
  }

  // Müşteri işlemleri
  Future<List<Customer>> getCustomers() async {
    await initialize();
    return List.unmodifiable(_customers);
  }

  Future<Customer?> getCustomerById(String id) async {
    await initialize();
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCustomer(Customer customer) async {
    await initialize();
    _customers.add(customer);
    
    // Aktivite ekle
    _activities.add(CRMActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.customerAdded,
      description: 'Yeni müşteri eklendi: ${customer.name}',
      timestamp: DateTime.now(),
      userId: 'current_user',
      userName: 'Mevcut Kullanıcı',
      customerId: customer.id,
    ));
  }

  Future<void> updateCustomer(Customer customer) async {
    await initialize();
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
    }
  }

  Future<void> deleteCustomer(String id) async {
    await initialize();
    _customers.removeWhere((customer) => customer.id == id);
  }

  // Satış fırsatları işlemleri
  Future<List<SalesOpportunity>> getSalesOpportunities() async {
    await initialize();
    return List.unmodifiable(_opportunities);
  }

  Future<SalesOpportunity?> getOpportunityById(String id) async {
    await initialize();
    try {
      return _opportunities.firstWhere((opportunity) => opportunity.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addOpportunity(SalesOpportunity opportunity) async {
    await initialize();
    _opportunities.add(opportunity);
    
    // Aktivite ekle
    _activities.add(CRMActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.opportunityCreated,
      description: 'Yeni fırsat oluşturuldu: ${opportunity.title}',
      timestamp: DateTime.now(),
      userId: 'current_user',
      userName: 'Mevcut Kullanıcı',
      customerId: opportunity.customerId,
      opportunityId: opportunity.id,
    ));
  }

  Future<void> updateOpportunity(SalesOpportunity opportunity) async {
    await initialize();
    final index = _opportunities.indexWhere((o) => o.id == opportunity.id);
    if (index != -1) {
      _opportunities[index] = opportunity.copyWith(
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<void> deleteOpportunity(String id) async {
    await initialize();
    _opportunities.removeWhere((opportunity) => opportunity.id == id);
  }

  // Analitik işlemleri
  Future<CRMAnalytics> getAnalytics() async {
    await initialize();
    
    final now = DateTime.now();
    final thisMonth = now.month;
    final thisYear = now.year;
    
    // Aylık gelir hesapla
    double monthlyRevenue = 0.0;
    double quarterlyRevenue = 0.0;
    double yearlyRevenue = 0.0;
    
    for (final opportunity in _opportunities) {
      if (opportunity.status == SalesStatus.closed) {
        final closeDate = opportunity.expectedCloseDate;
        if (closeDate.month == thisMonth && closeDate.year == thisYear) {
          monthlyRevenue += opportunity.value;
        }
        if (closeDate.year == thisYear) {
          yearlyRevenue += opportunity.value;
          final quarter = ((closeDate.month - 1) / 3).floor() + 1;
          final currentQuarter = ((thisMonth - 1) / 3).floor() + 1;
          if (quarter == currentQuarter) {
            quarterlyRevenue += opportunity.value;
          }
        }
      }
    }

    // Aylık gelir trendi
    final revenueByMonth = <String, double>{};
    for (int i = 0; i < 12; i++) {
      final month = DateTime(thisYear, thisMonth - i);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      revenueByMonth[monthKey] = _random.nextDouble() * 10000;
    }

    // Müşteri tipine göre dağılım
    final customersByType = <String, int>{};
    for (final customer in _customers) {
      final typeKey = customer.type.toString().split('.').last;
      customersByType[typeKey] = (customersByType[typeKey] ?? 0) + 1;
    }

    // Pipeline aşamalarına göre değer
    final pipelineByStage = <String, double>{};
    for (final status in SalesStatus.values) {
      final opportunitiesInStage = _opportunities.where((o) => o.status == status);
      final totalValue = opportunitiesInStage.fold<double>(
        0.0, (sum, o) => sum + o.weightedValue);
      pipelineByStage[status.toString().split('.').last] = totalValue;
    }

    return CRMAnalytics(
      totalCustomers: _customers.length,
      activeCustomers: _customers.where((c) => 
        c.lastContact.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length,
      newCustomersThisMonth: _customers.where((c) => 
        c.createdAt.month == thisMonth && c.createdAt.year == thisYear)
        .length,
      monthlyRevenue: monthlyRevenue,
      quarterlyRevenue: quarterlyRevenue,
      yearlyRevenue: yearlyRevenue,
      averageDealValue: _opportunities.isEmpty ? 0.0 : 
        _opportunities.map((o) => o.value).reduce((a, b) => a + b) / _opportunities.length,
      conversionRate: _opportunities.isEmpty ? 0.0 : 
        _opportunities.where((o) => o.status == SalesStatus.closed).length / _opportunities.length,
      totalOpportunities: _opportunities.length,
      activeOpportunities: _opportunities.where((o) => o.isActive).length,
      revenueByMonth: revenueByMonth,
      customersByType: customersByType,
      pipelineByStage: pipelineByStage,
    );
  }

  // Aktivite işlemleri
  List<CRMActivity> getRecentActivities() {
    final sortedActivities = List<CRMActivity>.from(_activities);
    sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedActivities;
  }

  Future<void> addActivity(CRMActivity activity) async {
    await initialize();
    _activities.add(activity);
  }

  // Müşteri segmentasyonu
  List<CustomerSegment> getCustomerSegments() {
    final segments = <CustomerSegment>[];
    
    // VIP Müşteriler (Lifetime value > 10000)
    final vipCustomers = _customers.where((c) => c.lifetimeValue > 10000).length;
    segments.add(CustomerSegment(
      id: '1',
      name: 'VIP Müşteriler',
      description: 'Yüksek değerli müşteriler',
      color: const Color(0xFFFFD700), // Altın
      customerCount: vipCustomers,
      averageValue: _customers.where((c) => c.lifetimeValue > 10000)
          .fold(0.0, (sum, c) => sum + c.lifetimeValue) / (vipCustomers > 0 ? vipCustomers : 1),
      criteria: ['Lifetime value > ₺10,000'],
    ));

    // Kurumsal Müşteriler
    final corporateCustomers = _customers.where((c) => 
      c.type == CustomerType.business || c.type == CustomerType.government).length;
    segments.add(CustomerSegment(
      id: '2',
      name: 'Kurumsal Müşteriler',
      description: 'İş ve devlet müşterileri',
      color: const Color(0xFF4CAF50), // Yeşil
      customerCount: corporateCustomers,
      averageValue: _customers.where((c) => 
        c.type == CustomerType.business || c.type == CustomerType.government)
          .fold(0.0, (sum, c) => sum + c.lifetimeValue) / (corporateCustomers > 0 ? corporateCustomers : 1),
      criteria: ['Business veya Government tipi'],
    ));

    // Sağlık Sektörü
    final healthcareCustomers = _customers.where((c) => 
      c.type == CustomerType.healthcare).length;
    segments.add(CustomerSegment(
      id: '3',
      name: 'Sağlık Sektörü',
      description: 'Hastane ve klinik müşterileri',
      color: const Color(0xFF2196F3), // Mavi
      customerCount: healthcareCustomers,
      averageValue: _customers.where((c) => c.type == CustomerType.healthcare)
          .fold(0.0, (sum, c) => sum + c.lifetimeValue) / (healthcareCustomers > 0 ? healthcareCustomers : 1),
      criteria: ['Healthcare tipi'],
    ));

    // Bireysel Müşteriler
    final individualCustomers = _customers.where((c) => 
      c.type == CustomerType.individual).length;
    segments.add(CustomerSegment(
      id: '4',
      name: 'Bireysel Müşteriler',
      description: 'Kişisel kullanıcılar',
      color: const Color(0xFF9C27B0), // Mor
      customerCount: individualCustomers,
      averageValue: _customers.where((c) => c.type == CustomerType.individual)
          .fold(0.0, (sum, c) => sum + c.lifetimeValue) / (individualCustomers > 0 ? individualCustomers : 1),
      criteria: ['Individual tipi'],
    ));

    return segments;
  }

  // Arama ve filtreleme
  Future<List<Customer>> searchCustomers(String query) async {
    await initialize();
    if (query.isEmpty) return getCustomers();
    
    final lowercaseQuery = query.toLowerCase();
    return _customers.where((customer) =>
      customer.name.toLowerCase().contains(lowercaseQuery) ||
      customer.email.toLowerCase().contains(lowercaseQuery) ||
      customer.company.toLowerCase().contains(lowercaseQuery) ||
      customer.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  Future<List<SalesOpportunity>> getOpportunitiesByStatus(SalesStatus status) async {
    await initialize();
    return _opportunities.where((opportunity) => opportunity.status == status).toList();
  }

  Future<List<SalesOpportunity>> getOpportunitiesByCustomer(String customerId) async {
    await initialize();
    return _opportunities.where((opportunity) => opportunity.customerId == customerId).toList();
  }
}
