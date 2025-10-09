import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../models/subscription_models.dart';
import 'audit_log_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  static const _secureStorage = FlutterSecureStorage();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'psyclinicai.enc.db');
    String? encryptionKey = await _getEncryptionKey();
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: encryptionKey,
    );
  }

  Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'db_encryption_key');
    if (key == null) {
      key = _generateRandomKey();
      await _secureStorage.write(key: 'db_encryption_key', value: key);
    }
    return key;
  }

  String _generateRandomKey() {
    return 'subscription-key-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subscriptions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        plan TEXT NOT NULL,
        status TEXT NOT NULL,
        billing_cycle TEXT NOT NULL,
        price REAL NOT NULL,
        currency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        trial_end_date TEXT,
        next_billing_date TEXT NOT NULL,
        stripe_subscription_id TEXT,
        stripe_customer_id TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_methods (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        last4 TEXT NOT NULL,
        brand TEXT NOT NULL,
        exp_month INTEGER NOT NULL,
        exp_year INTEGER NOT NULL,
        is_default INTEGER NOT NULL,
        stripe_payment_method_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE billing_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subscription_id TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        status TEXT NOT NULL,
        billing_date TEXT NOT NULL,
        paid_date TEXT,
        invoice_url TEXT,
        stripe_invoice_id TEXT,
        metadata TEXT
      )
    ''');

    await _createDefaultPlans(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _createDefaultPlans(Database db) async {
    final plans = [
      SubscriptionPlanDetails(
        plan: SubscriptionPlan.basic,
        name: 'Temel Plan',
        description: 'Küçük uygulamalar için temel özellikler',
        monthlyPrice: 29.99,
        yearlyPrice: 299.99,
        features: [
          'Maksimum 50 hasta',
          'Aylık 100 seans',
          'Temel raporlama',
          'E-posta desteği',
        ],
        maxClients: 50,
        maxSessionsPerMonth: 100,
        includesTeletherapy: false,
        includesAnalytics: false,
        includesSupport: false,
      ),
      SubscriptionPlanDetails(
        plan: SubscriptionPlan.professional,
        name: 'Profesyonel Plan',
        description: 'Büyüyen uygulamalar için gelişmiş özellikler',
        monthlyPrice: 79.99,
        yearlyPrice: 799.99,
        features: [
          'Maksimum 200 hasta',
          'Aylık 500 seans',
          'Gelişmiş raporlama',
          'Teleterapi dahil',
          'Analitik araçları',
          'Telefon desteği',
        ],
        maxClients: 200,
        maxSessionsPerMonth: 500,
        includesTeletherapy: true,
        includesAnalytics: true,
        includesSupport: true,
      ),
      SubscriptionPlanDetails(
        plan: SubscriptionPlan.enterprise,
        name: 'Kurumsal Plan',
        description: 'Büyük kurumlar için sınırsız özellikler',
        monthlyPrice: 199.99,
        yearlyPrice: 1999.99,
        features: [
          'Sınırsız hasta',
          'Sınırsız seans',
          'Özel raporlama',
          'Teleterapi dahil',
          'Gelişmiş analitik',
          'Öncelikli destek',
          'API erişimi',
        ],
        maxClients: -1, // Unlimited
        maxSessionsPerMonth: -1, // Unlimited
        includesTeletherapy: true,
        includesAnalytics: true,
        includesSupport: true,
      ),
    ];

    for (final plan in plans) {
      await db.insert('subscription_plans', plan.toJson());
    }
  }

  Future<List<SubscriptionPlanDetails>> getAvailablePlans() async {
    final db = await database;
    final result = await db.query('subscription_plans', orderBy: 'monthlyPrice ASC');
    
    return result.map((json) => SubscriptionPlanDetails.fromJson(json)).toList();
  }

  Future<SubscriptionPlanDetails?> getPlanDetails(SubscriptionPlan plan) async {
    final db = await database;
    final result = await db.query(
      'subscription_plans',
      where: 'plan = ?',
      whereArgs: [plan.name],
    );
    
    if (result.isEmpty) return null;
    return SubscriptionPlanDetails.fromJson(result.first);
  }

  Future<String> createSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    String? paymentMethodId,
    bool startTrial = false,
  }) async {
    final db = await database;
    final subscriptionId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
    
    final planDetails = await getPlanDetails(plan);
    if (planDetails == null) {
      throw Exception('Plan bulunamadı');
    }
    
    final price = billingCycle == BillingCycle.monthly 
        ? planDetails.monthlyPrice 
        : planDetails.yearlyPrice;
    
    final now = DateTime.now();
    final nextBillingDate = billingCycle == BillingCycle.monthly
        ? DateTime(now.year, now.month + 1, now.day)
        : DateTime(now.year + 1, now.month, now.day);
    
    final trialEndDate = startTrial 
        ? DateTime.now().add(const Duration(days: 14))
        : null;
    
    final subscription = Subscription(
      id: subscriptionId,
      userId: userId,
      customerId: 'cust_$userId',
      plan: plan,
      status: startTrial ? SubscriptionStatus.trialing : SubscriptionStatus.active,
      billingCycle: billingCycle,
      price: price,
      currency: 'USD',
      startDate: now,
      nextBillingDate: nextBillingDate,
      trialEndDate: trialEndDate,
      createdAt: now,
      updatedAt: now,
    );
    
    await db.insert('subscriptions', subscription.toJson());
    
    await AuditLogService().insertLog(
      action: 'subscription.create',
      details: 'Subscription created: $subscriptionId',
      userId: userId,
      resourceId: subscriptionId,
    );
    
    return subscriptionId;
  }

  Future<Subscription?> getSubscription(String subscriptionId) async {
    final db = await database;
    final result = await db.query(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [subscriptionId],
    );
    
    if (result.isEmpty) return null;
    return Subscription.fromJson(result.first);
  }

  Future<Subscription?> getActiveSubscription(String userId) async {
    final db = await database;
    final result = await db.query(
      'subscriptions',
      where: 'user_id = ? AND status IN (?, ?, ?)',
      whereArgs: [
        userId,
        SubscriptionStatus.active.name,
        SubscriptionStatus.trialing.name,
        SubscriptionStatus.pastDue.name,
      ],
      orderBy: 'created_at DESC',
    );
    
    if (result.isEmpty) return null;
    return Subscription.fromJson(result.first);
  }

  Future<bool> updateSubscription(String subscriptionId, Map<String, dynamic> updates) async {
    final db = await database;
    
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    final result = await db.update(
      'subscriptions',
      updates,
      where: 'id = ?',
      whereArgs: [subscriptionId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'subscription.update',
        details: 'Subscription updated: $subscriptionId',
        userId: 'system',
        resourceId: subscriptionId,
      );
    }
    
    return result > 0;
  }

  Future<bool> cancelSubscription(String subscriptionId, String userId) async {
    final db = await database;
    
    final updates = {
      'status': SubscriptionStatus.canceled.name,
      'end_date': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    final result = await db.update(
      'subscriptions',
      updates,
      where: 'id = ?',
      whereArgs: [subscriptionId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'subscription.cancel',
        details: 'Subscription canceled: $subscriptionId',
        userId: userId,
        resourceId: subscriptionId,
      );
    }
    
    return result > 0;
  }

  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    final db = await database;
    final result = await db.query(
      'payment_methods',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_default DESC, created_at DESC',
    );
    
    return result.map((json) => PaymentMethod.fromJson(json)).toList();
  }

  Future<String> addPaymentMethod({
    required String userId,
    required String stripePaymentMethodId,
  }) async {
    final db = await database;
    final paymentMethodId = 'pm_${DateTime.now().millisecondsSinceEpoch}';
    
    // Mock payment method (gerçek uygulamada Stripe'dan alınır)
    final paymentMethod = PaymentMethod(
      id: paymentMethodId,
      userId: userId,
      type: 'card',
      last4: '4242',
      brand: 'visa',
      expMonth: 12,
      expYear: 2025,
      isDefault: true,
      stripePaymentMethodId: stripePaymentMethodId,
      createdAt: DateTime.now(),
    );
    
    await db.insert('payment_methods', paymentMethod.toJson());
    
    await AuditLogService().insertLog(
      action: 'payment_method.add',
      details: 'Payment method added: $paymentMethodId',
      userId: userId,
      resourceId: paymentMethodId,
    );
    
    return paymentMethodId;
  }

  Future<bool> setDefaultPaymentMethod(String paymentMethodId, String userId) async {
    final db = await database;
    
    // Önce tüm payment method'ları default olmayan yap
    await db.update(
      'payment_methods',
      {'is_default': 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    // Seçilen payment method'u default yap
    final result = await db.update(
      'payment_methods',
      {'is_default': 1},
      where: 'id = ? AND user_id = ?',
      whereArgs: [paymentMethodId, userId],
    );
    
    if (result > 0) {
      await AuditLogService().insertLog(
        action: 'payment_method.set_default',
        details: 'Default payment method set: $paymentMethodId',
        userId: userId,
        resourceId: paymentMethodId,
      );
    }
    
    return result > 0;
  }

  Future<List<BillingHistory>> getBillingHistory(String userId) async {
    final db = await database;
    final result = await db.query(
      'billing_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'billing_date DESC',
    );
    
    return result.map((json) => BillingHistory.fromJson(json)).toList();
  }

  Future<void> addBillingRecord({
    required String userId,
    required String subscriptionId,
    required double amount,
    required String currency,
    required String status,
    String? invoiceUrl,
    String? stripeInvoiceId,
  }) async {
    final db = await database;
    final billingId = 'bill_${DateTime.now().millisecondsSinceEpoch}';
    
    final billingRecord = BillingHistory(
      id: billingId,
      userId: userId,
      subscriptionId: subscriptionId,
      amount: amount,
      currency: currency,
      status: status,
      billingDate: DateTime.now(),
      paidDate: status == 'paid' ? DateTime.now() : null,
      invoiceUrl: invoiceUrl,
      stripeInvoiceId: stripeInvoiceId,
    );
    
    await db.insert('billing_history', billingRecord.toJson());
    
    await AuditLogService().insertLog(
      action: 'billing.record',
      details: 'Billing record added: $billingId',
      userId: userId,
      resourceId: billingId,
    );
  }

  Future<Map<String, dynamic>> getSubscriptionStatistics(String userId) async {
    final db = await database;
    
    final totalSpentResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM billing_history 
      WHERE user_id = ? AND status = 'paid'
    ''', [userId]);
    
    final monthlyRevenueResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM billing_history 
      WHERE user_id = ? AND status = 'paid' 
      AND billing_date >= datetime('now', '-1 month')
    ''', [userId]);
    
    final activeSubscriptionsResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM subscriptions 
      WHERE user_id = ? AND status IN (?, ?, ?)
    ''', [
      userId,
      SubscriptionStatus.active.name,
      SubscriptionStatus.trialing.name,
      SubscriptionStatus.pastDue.name,
    ]);
    
    return {
      'totalSpent': totalSpentResult.first['total'] as double? ?? 0.0,
      'monthlyRevenue': monthlyRevenueResult.first['total'] as double? ?? 0.0,
      'activeSubscriptions': activeSubscriptionsResult.first['count'] as int,
    };
  }

  Future<bool> processWebhook(Map<String, dynamic> webhookData) async {
    try {
      final eventType = webhookData['type'];
      
      switch (eventType) {
        case 'invoice.payment_succeeded':
          await _handleInvoicePaymentSucceeded(webhookData);
          break;
        case 'invoice.payment_failed':
          await _handleInvoicePaymentFailed(webhookData);
          break;
        case 'customer.subscription.updated':
          await _handleSubscriptionUpdated(webhookData);
          break;
        case 'customer.subscription.deleted':
          await _handleSubscriptionDeleted(webhookData);
          break;
        default:
          // Unknown event type
          break;
      }
      
      return true;
    } catch (e) {
      await AuditLogService().insertLog(
        action: 'webhook.error',
        details: 'Webhook processing failed: $e',
        userId: 'system',
        resourceId: 'webhook',
      );
      return false;
    }
  }

  Future<void> _handleInvoicePaymentSucceeded(Map<String, dynamic> webhookData) async {
    final invoice = webhookData['data']['object'];
    final subscriptionId = invoice['subscription'];
    
    if (subscriptionId != null) {
      await updateSubscription(subscriptionId, {
        'status': SubscriptionStatus.active.name,
        'next_billing_date': DateTime.fromMillisecondsSinceEpoch(
          invoice['period_end'] * 1000,
        ).toIso8601String(),
      });
      
      await addBillingRecord(
        userId: 'user_id', // TODO: Get from subscription
        subscriptionId: subscriptionId,
        amount: (invoice['amount_paid'] / 100).toDouble(),
        currency: invoice['currency'],
        status: 'paid',
        invoiceUrl: invoice['hosted_invoice_url'],
        stripeInvoiceId: invoice['id'],
      );
    }
  }

  Future<void> _handleInvoicePaymentFailed(Map<String, dynamic> webhookData) async {
    final invoice = webhookData['data']['object'];
    final subscriptionId = invoice['subscription'];
    
    if (subscriptionId != null) {
      await updateSubscription(subscriptionId, {
        'status': SubscriptionStatus.pastDue.name,
      });
      
      await addBillingRecord(
        userId: 'user_id', // TODO: Get from subscription
        subscriptionId: subscriptionId,
        amount: (invoice['amount_due'] / 100).toDouble(),
        currency: invoice['currency'],
        status: 'failed',
        stripeInvoiceId: invoice['id'],
      );
    }
  }

  Future<void> _handleSubscriptionUpdated(Map<String, dynamic> webhookData) async {
    final subscription = webhookData['data']['object'];
    final stripeSubscriptionId = subscription['id'];
    
    final db = await database;
    final result = await db.query(
      'subscriptions',
      where: 'stripe_subscription_id = ?',
      whereArgs: [stripeSubscriptionId],
    );
    
    if (result.isNotEmpty) {
      final subscriptionId = result.first['id'] as String;
      await updateSubscription(subscriptionId, {
        'status': subscription['status'],
        'current_period_end': DateTime.fromMillisecondsSinceEpoch(
          subscription['current_period_end'] * 1000,
        ).toIso8601String(),
      });
    }
  }

  Future<void> _handleSubscriptionDeleted(Map<String, dynamic> webhookData) async {
    final subscription = webhookData['data']['object'];
    final stripeSubscriptionId = subscription['id'];
    
    final db = await database;
    final result = await db.query(
      'subscriptions',
      where: 'stripe_subscription_id = ?',
      whereArgs: [stripeSubscriptionId],
    );
    
    if (result.isNotEmpty) {
      final subscriptionId = result.first['id'] as String;
      await cancelSubscription(subscriptionId, 'system');
    }
  }
}
