import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/payment_billing_service.dart';
import '../test_config.dart';

void main() {
  group('PaymentBillingService Tests', () {
    late PaymentBillingService billingService;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    setUp(() {
      billingService = PaymentBillingService();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group('Service Initialization', () {
      test('should initialize successfully', () async {
        await billingService.initialize();
        TestConfig.assertServiceInitialized(billingService, 'PaymentBillingService');
      });

      test('should have pricing plans', () {
        final plans = billingService.pricingPlans;
        expect(plans, isNotNull);
        expect(plans.containsKey('basic'), isTrue);
        expect(plans.containsKey('professional'), isTrue);
        expect(plans.containsKey('enterprise'), isTrue);
        expect(plans.containsKey('custom'), isTrue);
      });

      test('should have plan limits', () {
        final limits = billingService.planLimits;
        expect(limits, isNotNull);
        expect(limits.containsKey('basic'), isTrue);
        expect(limits.containsKey('professional'), isTrue);
        expect(limits.containsKey('enterprise'), isTrue);
        expect(limits.containsKey('custom'), isTrue);
      });
    });

    group('Subscription Management', () {
      test('should create subscription successfully', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_001',
        );

        expect(subscription, isNotNull);
        expect(subscription.id, isNotEmpty);
        expect(subscription.tenantId, equals(subscriptionData['tenantId']));
        expect(subscription.planName, equals(subscriptionData['planName']));
        expect(subscription.status, equals(SubscriptionStatus.active));
        expect(subscription.price, equals(subscriptionData['amount']));
      });

      test('should create custom subscription', () async {
        final subscription = await billingService.createSubscription(
          tenantId: TestConfig.testTenantId,
          planName: 'custom',
          paymentMethodId: 'test_payment_method_002',
          customUsers: 50,
          customStorageGB: 200,
          customAIRequests: 15000,
        );

        expect(subscription, isNotNull);
        expect(subscription.planName, equals('custom'));
        expect(subscription.customLimits, isNotNull);
        expect(subscription.customLimits!['users'], equals(50));
        expect(subscription.customLimits!['storage_gb'], equals(200));
        expect(subscription.customLimits!['ai_requests_per_month'], equals(15000));
      });

      test('should get subscription by ID', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final createdSubscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_003',
        );

        final retrievedSubscription = await billingService.getSubscription(createdSubscription.id);
        
        expect(retrievedSubscription, isNotNull);
        expect(retrievedSubscription!.id, equals(createdSubscription.id));
        expect(retrievedSubscription.tenantId, equals(createdSubscription.tenantId));
      });

      test('should get subscriptions for tenant', () async {
        final subscriptions = await billingService.getSubscriptionsForTenant(TestConfig.testTenantId);
        expect(subscriptions, isA<List<Subscription>>());
        
        for (final subscription in subscriptions) {
          expect(subscription.tenantId, equals(TestConfig.testTenantId));
        }
      });

      test('should update subscription', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_004',
        );

        final updatedSubscription = await billingService.updateSubscription(
          subscriptionId: subscription.id,
          planName: 'enterprise',
          price: 199.99,
        );

        expect(updatedSubscription, isNotNull);
        expect(updatedSubscription.planName, equals('enterprise'));
        expect(updatedSubscription.price, equals(199.99));
      });

      test('should cancel subscription', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_005',
        );

        final cancelledSubscription = await billingService.cancelSubscription(subscription.id);
        
        expect(cancelledSubscription, isNotNull);
        expect(cancelledSubscription.status, equals(SubscriptionStatus.cancelled));
      });
    });

    group('Billing Records', () {
      test('should create billing record', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_006',
        );

        final billingRecord = await billingService.createBillingRecord(
          tenantId: subscriptionData['tenantId'],
          subscriptionId: subscription.id,
          amount: subscriptionData['amount'],
          description: subscriptionData['description'],
          type: BillingType.subscription,
        );

        expect(billingRecord, isNotNull);
        expect(billingRecord.id, isNotEmpty);
        expect(billingRecord.tenantId, equals(subscriptionData['tenantId']));
        expect(billingRecord.subscriptionId, equals(subscription.id));
        expect(billingRecord.amount, equals(subscriptionData['amount']));
        expect(billingRecord.type, equals(BillingType.subscription));
      });

      test('should get billing records for tenant', () async {
        final billingRecords = await billingService.getBillingRecordsForTenant(TestConfig.testTenantId);
        expect(billingRecords, isA<List<BillingRecord>>());
        
        for (final record in billingRecords) {
          expect(record.tenantId, equals(TestConfig.testTenantId));
        }
      });

      test('should get billing record by ID', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_007',
        );

        final createdRecord = await billingService.createBillingRecord(
          tenantId: subscriptionData['tenantId'],
          subscriptionId: subscription.id,
          amount: subscriptionData['amount'],
          description: subscriptionData['description'],
          type: BillingType.subscription,
        );

        final retrievedRecord = await billingService.getBillingRecord(createdRecord.id);
        
        expect(retrievedRecord, isNotNull);
        expect(retrievedRecord!.id, equals(createdRecord.id));
        expect(retrievedRecord.amount, equals(createdRecord.amount));
      });
    });

    group('Payment Processing', () {
      test('should process payment successfully', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_008',
        );

        final billingRecord = await billingService.createBillingRecord(
          tenantId: subscriptionData['tenantId'],
          subscriptionId: subscription.id,
          amount: subscriptionData['amount'],
          description: subscriptionData['description'],
          type: BillingType.subscription,
        );

        final paymentResult = await billingService.processPayment(
          billingRecordId: billingRecord.id,
          paymentMethodId: 'test_payment_method_008',
          amount: billingRecord.amount,
        );

        expect(paymentResult, isNotNull);
        expect(paymentResult.success, isTrue);
        expect(paymentResult.amount, equals(billingRecord.amount));
        expect(paymentResult.transactionId, isNotEmpty);
      });

      test('should handle payment failure', () async {
        final paymentResult = await billingService.processPayment(
          billingRecordId: 'invalid_billing_record',
          paymentMethodId: 'invalid_payment_method',
          amount: 100.0,
        );

        expect(paymentResult, isNotNull);
        expect(paymentResult.success, isFalse);
        expect(paymentResult.message, isNotEmpty);
      });
    });

    group('Payment Methods', () {
      test('should add payment method', () async {
        final paymentMethod = await billingService.addPaymentMethod(
          tenantId: TestConfig.testTenantId,
          type: 'credit_card',
          last4: '1234',
          brand: 'Visa',
          expiryDate: DateTime.now().add(const Duration(years: 2)),
          name: 'Test Card',
          isDefault: true,
        );

        expect(paymentMethod, isNotNull);
        expect(paymentMethod.id, isNotEmpty);
        expect(paymentMethod.tenantId, equals(TestConfig.testTenantId));
        expect(paymentMethod.type, equals('credit_card'));
        expect(paymentMethod.last4, equals('1234'));
        expect(paymentMethod.isDefault, isTrue);
      });

      test('should get payment methods for tenant', () async {
        final paymentMethods = await billingService.getPaymentMethodsForTenant(TestConfig.testTenantId);
        expect(paymentMethods, isA<List<PaymentMethod>>());
        
        for (final method in paymentMethods) {
          expect(method.tenantId, equals(TestConfig.testTenantId));
        }
      });
    });

    group('Invoice Generation', () {
      test('should generate invoice', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_009',
        );

        final billingRecord = await billingService.createBillingRecord(
          tenantId: subscriptionData['tenantId'],
          subscriptionId: subscription.id,
          amount: subscriptionData['amount'],
          description: subscriptionData['description'],
          type: BillingType.subscription,
        );

        final invoice = await billingService.generateInvoice(
          tenantId: subscriptionData['tenantId'],
          subscriptionId: subscription.id,
          periodStart: DateTime.now().subtract(const Duration(days: 30)),
          periodEnd: DateTime.now(),
          subtotal: subscriptionData['amount'],
          tax: subscriptionData['amount'] * 0.1,
          total: subscriptionData['amount'] * 1.1,
          billingRecordIds: [billingRecord.id],
        );

        expect(invoice, isNotNull);
        expect(invoice.id, isNotEmpty);
        expect(invoice.tenantId, equals(subscriptionData['tenantId']));
        expect(invoice.subscriptionId, equals(subscription.id));
        expect(invoice.invoiceNumber, isNotEmpty);
        expect(invoice.total, equals(subscriptionData['amount'] * 1.1));
      });
    });

    group('Billing Statistics', () {
      test('should get billing statistics', () async {
        final stats = await billingService.getBillingStatistics(TestConfig.testTenantId);
        
        expect(stats, isNotNull);
        expect(stats.totalSubscriptions, isA<int>());
        expect(stats.activeSubscriptions, isA<int>());
        expect(stats.totalRevenue, isA<double>());
        expect(stats.pendingPayments, isA<double>());
        expect(stats.currency, isNotEmpty);
        expect(stats.lastUpdated, isA<DateTime>());
      });
    });

    group('Stream Management', () {
      test('should emit billing events', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_010',
        );

        // Listen to billing events
        final events = <BillingEvent>[];
        final subscription = billingService.billingStream.listen(events.add);

        // Wait for async operations
        await TestConfig.waitForAsync();

        expect(events, isNotEmpty);
        
        subscription.cancel();
      });

      test('should emit payment status updates', () async {
        final subscriptionData = TestConfig.generateTestBillingData();
        
        final subscription = await billingService.createSubscription(
          tenantId: subscriptionData['tenantId'],
          planName: subscriptionData['planName'],
          paymentMethodId: 'test_payment_method_011',
        );

        final billingRecord = await billingService.createBillingRecord(
          tenantId: subscriptionData['tenantId'],
          subscriptionId: subscription.id,
          amount: subscriptionData['amount'],
          description: subscriptionData['description'],
          type: BillingType.subscription,
        );

        // Listen to payment status updates
        final paymentUpdates = <PaymentStatus>[];
        final subscription = billingService.paymentStream.listen(paymentUpdates.add);

        // Process payment
        await billingService.processPayment(
          billingRecordId: billingRecord.id,
          paymentMethodId: 'test_payment_method_011',
          amount: billingRecord.amount,
        );

        // Wait for async operations
        await TestConfig.waitForAsync();

        expect(paymentUpdates, isNotEmpty);
        
        subscription.cancel();
      });
    });

    group('Error Handling', () {
      test('should handle invalid subscription ID', () async {
        final result = await billingService.getSubscription('invalid_id');
        expect(result, isNull);
      });

      test('should handle invalid billing record ID', () async {
        final result = await billingService.getBillingRecord('invalid_id');
        expect(result, isNull);
      });

      test('should handle invalid payment method ID', () async {
        final result = await billingService.processPayment(
          billingRecordId: 'invalid_id',
          paymentMethodId: 'invalid_payment_method',
          amount: 100.0,
        );

        expect(result.success, isFalse);
      });
    });

    group('Data Validation', () {
      test('should validate subscription creation data', () {
        expect(() => billingService.createSubscription(
          tenantId: '',
          planName: 'basic',
          paymentMethodId: 'test_method',
        ), throwsA(isA<ArgumentError>()));

        expect(() => billingService.createSubscription(
          tenantId: TestConfig.testTenantId,
          planName: '',
          paymentMethodId: 'test_method',
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate billing record creation data', () {
        expect(() => billingService.createBillingRecord(
          tenantId: '',
          subscriptionId: 'test_subscription',
          amount: 100.0,
          description: 'Test',
          type: BillingType.subscription,
        ), throwsA(isA<ArgumentError>()));

        expect(() => billingService.createBillingRecord(
          tenantId: TestConfig.testTenantId,
          subscriptionId: '',
          amount: 100.0,
          description: 'Test',
          type: BillingType.subscription,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate payment method creation data', () {
        expect(() => billingService.addPaymentMethod(
          tenantId: '',
          type: 'credit_card',
          last4: '1234',
          brand: 'Visa',
          expiryDate: DateTime.now().add(const Duration(years: 1)),
        ), throwsA(isA<ArgumentError>()));

        expect(() => billingService.addPaymentMethod(
          tenantId: TestConfig.testTenantId,
          type: '',
          last4: '1234',
          brand: 'Visa',
          expiryDate: DateTime.now().add(const Duration(years: 1)),
        ), throwsA(isA<ArgumentError>()));
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent subscriptions', () async {
        final subscriptions = <Subscription>[];
        
        // Create multiple subscriptions
        for (int i = 0; i < 5; i++) {
          final subscription = await billingService.createSubscription(
            tenantId: '${TestConfig.testTenantId}_$i',
            planName: 'basic',
            paymentMethodId: 'test_payment_method_$i',
          );
          subscriptions.add(subscription);
        }

        expect(subscriptions.length, equals(5));
        
        // Verify all subscriptions
        for (final subscription in subscriptions) {
          expect(subscription.status, equals(SubscriptionStatus.active));
          expect(subscription.planName, equals('basic'));
        }
      });

      test('should handle large amounts', () async {
        final subscription = await billingService.createSubscription(
          tenantId: TestConfig.testTenantId,
          planName: 'enterprise',
          paymentMethodId: 'test_payment_method_large',
        );

        expect(subscription, isNotNull);
        expect(subscription.price, equals(199.99));
        
        final billingRecord = await billingService.createBillingRecord(
          tenantId: TestConfig.testTenantId,
          subscriptionId: subscription.id,
          amount: 999999.99,
          description: 'Large amount test',
          type: BillingType.subscription,
        );

        expect(billingRecord, isNotNull);
        expect(billingRecord.amount, equals(999999.99));
      });
    });
  });
}
