import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentBillingService {
  static const String _billingKey = 'billing_records';
  static const String _subscriptionKey = 'subscriptions';
  static const String _paymentMethodsKey = 'payment_methods';
  
  // Singleton pattern
  static final PaymentBillingService _instance = PaymentBillingService._internal();
  factory PaymentBillingService() => _instance;
  PaymentBillingService._internal();

  // Stream controllers
  final StreamController<BillingEvent> _billingStreamController = 
      StreamController<BillingEvent>.broadcast();
  
  final StreamController<PaymentStatus> _paymentStreamController = 
      StreamController<PaymentStatus>.broadcast();

  // Get streams
  Stream<BillingEvent> get billingStream => _billingStreamController.stream;
  Stream<PaymentStatus> get paymentStream => _paymentStreamController.stream;

  // Billing configuration
  final Map<String, double> _pricingPlans = {
    'basic': 29.99,
    'professional': 79.99,
    'enterprise': 199.99,
    'custom': 0.0,
  };

  final Map<String, Map<String, int>> _planLimits = {
    'basic': {
      'users': 5,
      'storage_gb': 10,
      'ai_requests_per_month': 1000,
      'support': 1,
    },
    'professional': {
      'users': 25,
      'storage_gb': 100,
      'ai_requests_per_month': 10000,
      'support': 2,
    },
    'enterprise': {
      'users': 100,
      'storage_gb': 500,
      'ai_requests_per_month': 100000,
      'support': 3,
    },
    'custom': {
      'users': -1,
      'storage_gb': -1,
      'ai_requests_per_month': -1,
      'support': 4,
    },
  };

  // Initialize billing service
  Future<void> initialize() async {
    try {
      print('✅ Payment & Billing service initialized');
    } catch (e) {
      print('Error initializing billing service: $e');
    }
  }

  // Get pricing plans
  Map<String, double> get pricingPlans => _pricingPlans;
  Map<String, Map<String, int>> get planLimits => _planLimits;

  // Create subscription
  Future<Subscription> createSubscription({
    required String tenantId,
    required String planName,
    required String paymentMethodId,
    int? customUsers,
    int? customStorageGB,
    int? customAIRequests,
  }) async {
    try {
      final planPrice = _pricingPlans[planName] ?? 0.0;
      
      // Calculate custom pricing if needed
      double finalPrice = planPrice;
      if (planName == 'custom') {
        finalPrice = _calculateCustomPricing(
          users: customUsers ?? 10,
          storageGB: customStorageGB ?? 50,
          aiRequests: customAIRequests ?? 5000,
        );
      }
      
      final subscription = Subscription(
        id: _generateSecureId(),
        tenantId: tenantId,
        planName: planName,
        price: finalPrice,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        paymentMethodId: paymentMethodId,
        customLimits: planName == 'custom' ? {
          'users': customUsers ?? 10,
          'storage_gb': customStorageGB ?? 50,
          'ai_requests_per_month': customAIRequests ?? 5000,
        } : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save subscription
      await _saveSubscription(subscription);
      
      // Create initial billing record
      await createBillingRecord(
        tenantId: tenantId,
        subscriptionId: subscription.id,
        amount: finalPrice,
        description: 'Initial subscription payment - $planName plan',
        type: BillingType.subscription,
      );
      
      _billingStreamController.add(BillingEvent(
        id: _generateSecureId(),
        tenantId: tenantId,
        eventType: BillingEventType.subscription_created,
        amount: finalPrice,
        timestamp: DateTime.now(),
        details: 'Subscription created for $planName plan',
      ));
      
      print('✅ Subscription created: $planName plan for tenant $tenantId');
      return subscription;
      
    } catch (e) {
      print('Error creating subscription: $e');
      rethrow;
    }
  }

  // Calculate custom pricing
  double _calculateCustomPricing({
    required int users,
    required int storageGB,
    required int aiRequests,
  }) {
    double basePrice = 99.99;
    double userPrice = users * 2.99;
    double storagePrice = storageGB * 0.99;
    double aiPrice = (aiRequests / 1000) * 9.99;
    
    return basePrice + userPrice + storagePrice + aiPrice;
  }

  // Update subscription
  Future<Subscription?> updateSubscription({
    required String subscriptionId,
    String? planName,
    double? price,
    BillingCycle? billingCycle,
    Map<String, int>? customLimits,
  }) async {
    try {
      final subscription = await getSubscription(subscriptionId);
      if (subscription == null) return null;
      
      final updatedSubscription = subscription.copyWith(
        planName: planName ?? subscription.planName,
        price: price ?? subscription.price,
        billingCycle: billingCycle ?? subscription.billingCycle,
        customLimits: customLimits ?? subscription.customLimits,
        updatedAt: DateTime.now(),
      );
      
      await _saveSubscription(updatedSubscription);
      
      _billingStreamController.add(BillingEvent(
        id: _generateSecureId(),
        tenantId: subscription.tenantId,
        eventType: BillingEventType.subscription_updated,
        amount: updatedSubscription.price,
        timestamp: DateTime.now(),
        details: 'Subscription updated to ${updatedSubscription.planName} plan',
      ));
      
      print('✅ Subscription updated: $subscriptionId');
      return updatedSubscription;
      
    } catch (e) {
      print('Error updating subscription: $e');
      return null;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final subscription = await getSubscription(subscriptionId);
      if (subscription == null) return false;
      
      final cancelledSubscription = subscription.copyWith(
        status: SubscriptionStatus.cancelled,
        endDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _saveSubscription(cancelledSubscription);
      
      _billingStreamController.add(BillingEvent(
        id: _generateSecureId(),
        tenantId: subscription.tenantId,
        eventType: BillingEventType.subscription_cancelled,
        amount: 0.0,
        timestamp: DateTime.now(),
        details: 'Subscription cancelled',
      ));
      
      print('✅ Subscription cancelled: $subscriptionId');
      return true;
      
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    }
  }

  // Get subscription
  Future<Subscription?> getSubscription(String subscriptionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptions = await _getSubscriptions();
      return subscriptions.firstWhere((s) => s.id == subscriptionId);
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }

  // Get subscriptions for tenant
  Future<List<Subscription>> getSubscriptionsForTenant(String tenantId) async {
    try {
      final subscriptions = await _getSubscriptions();
      return subscriptions.where((s) => s.tenantId == tenantId).toList();
    } catch (e) {
      print('Error getting subscriptions for tenant: $e');
      return [];
    }
  }

  // Create billing record
  Future<BillingRecord> createBillingRecord({
    required String tenantId,
    required String subscriptionId,
    required double amount,
    required String description,
    required BillingType type,
    String? paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final billingRecord = BillingRecord(
        id: _generateSecureId(),
        tenantId: tenantId,
        subscriptionId: subscriptionId,
        amount: amount,
        currency: 'USD',
        description: description,
        type: type,
        status: BillingStatus.pending,
        paymentMethodId: paymentMethodId,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _saveBillingRecord(billingRecord);
      
      print('✅ Billing record created: ${billingRecord.id}');
      return billingRecord;
      
    } catch (e) {
      print('Error creating billing record: $e');
      rethrow;
    }
  }

  // Process payment
  Future<PaymentResult> processPayment({
    required String billingRecordId,
    required String paymentMethodId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final billingRecord = await getBillingRecord(billingRecordId);
      if (billingRecord == null) {
        throw Exception('Billing record not found');
      }
      
      // Simulate payment processing
      await Future.delayed(const Duration(milliseconds: 2000));
      
      final random = Random();
      final success = random.nextDouble() > 0.05; // 95% success rate
      
      if (success) {
        // Update billing record status
        final updatedRecord = billingRecord.copyWith(
          status: BillingStatus.paid,
          updatedAt: DateTime.now(),
        );
        await _saveBillingRecord(updatedRecord);
        
        // Send payment success event
        _paymentStreamController.add(PaymentStatus(
          id: _generateSecureId(),
          billingRecordId: billingRecordId,
          status: PaymentStatusType.success,
          amount: billingRecord.amount,
          timestamp: DateTime.now(),
          transactionId: _generateSecureId(),
          details: 'Payment processed successfully',
        ));
        
        print('✅ Payment processed successfully: ${billingRecord.id}');
        return PaymentResult(
          success: true,
          transactionId: _generateSecureId(),
          amount: billingRecord.amount,
          message: 'Payment processed successfully',
        );
      } else {
        // Update billing record status
        final updatedRecord = billingRecord.copyWith(
          status: BillingStatus.failed,
          updatedAt: DateTime.now(),
        );
        await _saveBillingRecord(updatedRecord);
        
        // Send payment failure event
        _paymentStreamController.add(PaymentStatus(
          id: _generateSecureId(),
          billingRecordId: billingRecordId,
          status: PaymentStatusType.failed,
          amount: billingRecord.amount,
          timestamp: DateTime.now(),
          transactionId: null,
          details: 'Payment processing failed',
        ));
        
        print('❌ Payment processing failed: ${billingRecord.id}');
        return PaymentResult(
          success: false,
          transactionId: null,
          amount: billingRecord.amount,
          message: 'Payment processing failed',
        );
      }
      
    } catch (e) {
      print('Error processing payment: $e');
      return PaymentResult(
        success: false,
        transactionId: null,
        amount: 0.0,
        message: 'Error: $e',
      );
    }
  }

  // Get billing records for tenant
  Future<List<BillingRecord>> getBillingRecordsForTenant(String tenantId) async {
    try {
      final records = await _getBillingRecords();
      return records.where((r) => r.tenantId == tenantId).toList();
    } catch (e) {
      print('Error getting billing records for tenant: $e');
      return [];
    }
  }

  // Get billing record
  Future<BillingRecord?> getBillingRecord(String billingRecordId) async {
    try {
      final records = await _getBillingRecords();
      return records.firstWhere((r) => r.id == billingRecordId);
    } catch (e) {
      print('Error getting billing record: $e');
      return null;
    }
  }

  // Add payment method
  Future<PaymentMethod> addPaymentMethod({
    required String tenantId,
    required String type,
    required String last4,
    required String brand,
    required DateTime expiryDate,
    String? name,
  }) async {
    try {
      final paymentMethod = PaymentMethod(
        id: _generateSecureId(),
        tenantId: tenantId,
        type: type,
        last4: last4,
        brand: brand,
        expiryDate: expiryDate,
        name: name,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _savePaymentMethod(paymentMethod);
      
      print('✅ Payment method added: ${paymentMethod.id}');
      return paymentMethod;
      
    } catch (e) {
      print('Error adding payment method: $e');
      rethrow;
    }
  }

  // Get payment methods for tenant
  Future<List<PaymentMethod>> getPaymentMethodsForTenant(String tenantId) async {
    try {
      final methods = await _getPaymentMethods();
      return methods.where((m) => m.tenantId == tenantId).toList();
    } catch (e) {
      print('Error getting payment methods for tenant: $e');
      return [];
    }
  }

  // Generate invoice
  Future<Invoice> generateInvoice({
    required String tenantId,
    required String subscriptionId,
    required DateTime periodStart,
    required DateTime periodEnd,
    List<String>? billingRecordIds,
  }) async {
    try {
      final subscription = await getSubscription(subscriptionId);
      if (subscription == null) {
        throw Exception('Subscription not found');
      }
      
      // Get billing records for the period
      final records = await getBillingRecordsForTenant(tenantId);
      final periodRecords = records.where((r) => 
        r.createdAt.isAfter(periodStart) && 
        r.createdAt.isBefore(periodEnd)
      ).toList();
      
      final totalAmount = periodRecords.fold<double>(
        0.0, (sum, record) => sum + record.amount
      );
      
      final invoice = Invoice(
        id: _generateSecureId(),
        tenantId: tenantId,
        subscriptionId: subscriptionId,
        invoiceNumber: _generateInvoiceNumber(),
        periodStart: periodStart,
        periodEnd: periodEnd,
        subtotal: totalAmount,
        tax: totalAmount * 0.08, // 8% tax
        total: totalAmount * 1.08,
        currency: 'USD',
        status: InvoiceStatus.generated,
        billingRecordIds: periodRecords.map((r) => r.id).toList(),
        dueDate: periodEnd.add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('✅ Invoice generated: ${invoice.invoiceNumber}');
      return invoice;
      
    } catch (e) {
      print('Error generating invoice: $e');
      rethrow;
    }
  }

  // Generate invoice number
  String _generateInvoiceNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'INV-${timestamp.toString().substring(8)}-$random';
  }

  // Save subscription
  Future<void> _saveSubscription(Subscription subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptions = await _getSubscriptions();
      
      final index = subscriptions.indexWhere((s) => s.id == subscription.id);
      if (index >= 0) {
        subscriptions[index] = subscription;
      } else {
        subscriptions.add(subscription);
      }
      
      await prefs.setString(_subscriptionKey, json.encode(
        subscriptions.map((s) => s.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving subscription: $e');
    }
  }

  // Get subscriptions
  Future<List<Subscription>> _getSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionsJson = prefs.getString(_subscriptionKey);
      
      if (subscriptionsJson != null) {
        final subscriptions = json.decode(subscriptionsJson) as List<dynamic>;
        return subscriptions.map((json) => Subscription.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting subscriptions: $e');
      return [];
    }
  }

  // Save billing record
  Future<void> _saveBillingRecord(BillingRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = await _getBillingRecords();
      
      final index = records.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        records[index] = record;
      } else {
        records.add(record);
      }
      
      await prefs.setString(_billingKey, json.encode(
        records.map((r) => r.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving billing record: $e');
    }
  }

  // Get billing records
  Future<List<BillingRecord>> _getBillingRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_billingKey);
      
      if (recordsJson != null) {
        final records = json.decode(recordsJson) as List<dynamic>;
        return records.map((json) => BillingRecord.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting billing records: $e');
      return [];
    }
  }

  // Save payment method
  Future<void> _savePaymentMethod(PaymentMethod method) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methods = await _getPaymentMethods();
      
      final index = methods.indexWhere((m) => m.id == method.id);
      if (index >= 0) {
        methods[index] = method;
      } else {
        methods.add(method);
      }
      
      await prefs.setString(_paymentMethodsKey, json.encode(
        methods.map((m) => m.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving payment method: $e');
    }
  }

  // Get payment methods
  Future<List<PaymentMethod>> _getPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodsJson = prefs.getString(_paymentMethodsKey);
      
      if (methodsJson != null) {
        final methods = json.decode(methodsJson) as List<dynamic>;
        return methods.map((json) => PaymentMethod.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting payment methods: $e');
      return [];
    }
  }

  // Generate secure ID
  String _generateSecureId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Get billing statistics
  Future<BillingStatistics> getBillingStatistics(String tenantId) async {
    try {
      final subscriptions = await getSubscriptionsForTenant(tenantId);
      final billingRecords = await getBillingRecordsForTenant(tenantId);
      
      final activeSubscriptions = subscriptions.where((s) => 
        s.status == SubscriptionStatus.active
      ).length;
      
      final totalRevenue = billingRecords
          .where((r) => r.status == BillingStatus.paid)
          .fold<double>(0.0, (sum, r) => sum + r.amount);
      
      final pendingPayments = billingRecords
          .where((r) => r.status == BillingStatus.pending)
          .fold<double>(0.0, (sum, r) => sum + r.amount);
      
      return BillingStatistics(
        totalSubscriptions: subscriptions.length,
        activeSubscriptions: activeSubscriptions,
        totalRevenue: totalRevenue,
        pendingPayments: pendingPayments,
        currency: 'USD',
        lastUpdated: DateTime.now(),
      );
      
    } catch (e) {
      print('Error getting billing statistics: $e');
      return BillingStatistics(
        totalSubscriptions: 0,
        activeSubscriptions: 0,
        totalRevenue: 0.0,
        pendingPayments: 0.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Dispose resources
  void dispose() {
    _billingStreamController.close();
    _paymentStreamController.close();
  }
}

// Data classes
class Subscription {
  final String id;
  final String tenantId;
  final String planName;
  final double price;
  final String currency;
  final BillingCycle billingCycle;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentMethodId;
  final Map<String, int>? customLimits;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.tenantId,
    required this.planName,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.paymentMethodId,
    this.customLimits,
    required this.createdAt,
    required this.updatedAt,
  });

  Subscription copyWith({
    String? id,
    String? tenantId,
    String? planName,
    double? price,
    String? currency,
    BillingCycle? billingCycle,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethodId,
    Map<String, int>? customLimits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      customLimits: customLimits ?? this.customLimits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'planName': planName,
      'price': price,
      'currency': currency,
      'billingCycle': billingCycle.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'customLimits': customLimits,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      tenantId: json['tenantId'],
      planName: json['planName'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == json['billingCycle'],
        orElse: () => BillingCycle.monthly,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      paymentMethodId: json['paymentMethodId'],
      customLimits: json['customLimits'] != null 
          ? Map<String, int>.from(json['customLimits'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum BillingCycle {
  monthly,
  quarterly,
  yearly,
}

enum SubscriptionStatus {
  active,
  cancelled,
  expired,
  suspended,
}

class BillingRecord {
  final String id;
  final String tenantId;
  final String subscriptionId;
  final double amount;
  final String currency;
  final String description;
  final BillingType type;
  final BillingStatus status;
  final String? paymentMethodId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BillingRecord({
    required this.id,
    required this.tenantId,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.type,
    required this.status,
    this.paymentMethodId,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  BillingRecord copyWith({
    String? id,
    String? tenantId,
    String? subscriptionId,
    double? amount,
    String? currency,
    String? description,
    BillingType? type,
    BillingStatus? status,
    String? paymentMethodId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillingRecord(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'type': type.name,
      'status': status.name,
      'paymentMethodId': paymentMethodId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      id: json['id'],
      tenantId: json['tenantId'],
      subscriptionId: json['subscriptionId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      description: json['description'],
      type: BillingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BillingType.subscription,
      ),
      status: BillingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BillingStatus.pending,
      ),
      paymentMethodId: json['paymentMethodId'],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum BillingType {
  subscription,
  usage,
  overage,
  setup,
  support,
}

enum BillingStatus {
  pending,
  paid,
  failed,
  refunded,
  cancelled,
}

class PaymentMethod {
  final String id;
  final String tenantId;
  final String type;
  final String last4;
  final String brand;
  final DateTime expiryDate;
  final String? name;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethod({
    required this.id,
    required this.tenantId,
    required this.type,
    required this.last4,
    required this.brand,
    required this.expiryDate,
    this.name,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'type': type,
      'last4': last4,
      'brand': brand,
      'expiryDate': expiryDate.toIso8601String(),
      'name': name,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      tenantId: json['tenantId'],
      type: json['type'],
      last4: json['last4'],
      brand: json['brand'],
      expiryDate: DateTime.parse(json['expiryDate']),
      name: json['name'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Invoice {
  final String id;
  final String tenantId;
  final String subscriptionId;
  final String invoiceNumber;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final InvoiceStatus status;
  final List<String> billingRecordIds;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.tenantId,
    required this.subscriptionId,
    required this.invoiceNumber,
    required this.periodStart,
    required this.periodEnd,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    required this.status,
    required this.billingRecordIds,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum InvoiceStatus {
  generated,
  sent,
  paid,
  overdue,
  cancelled,
}

class BillingEvent {
  final String id;
  final String tenantId;
  final BillingEventType eventType;
  final double amount;
  final DateTime timestamp;
  final String details;

  const BillingEvent({
    required this.id,
    required this.tenantId,
    required this.eventType,
    required this.amount,
    required this.timestamp,
    required this.details,
  });
}

enum BillingEventType {
  subscription_created,
  subscription_updated,
  subscription_cancelled,
  payment_processed,
  payment_failed,
  invoice_generated,
}

class PaymentStatus {
  final String id;
  final String billingRecordId;
  final PaymentStatusType status;
  final double amount;
  final DateTime timestamp;
  final String? transactionId;
  final String details;

  const PaymentStatus({
    required this.id,
    required this.billingRecordId,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.transactionId,
    required this.details,
  });
}

enum PaymentStatusType {
  success,
  failed,
  pending,
  cancelled,
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final double amount;
  final String message;

  const PaymentResult({
    required this.success,
    this.transactionId,
    required this.amount,
    required this.message,
  });
}

class BillingStatistics {
  final int totalSubscriptions;
  final int activeSubscriptions;
  final double totalRevenue;
  final double pendingPayments;
  final String currency;
  final DateTime lastUpdated;

  const BillingStatistics({
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.totalRevenue,
    required this.pendingPayments,
    required this.currency,
    required this.lastUpdated,
  });
}
