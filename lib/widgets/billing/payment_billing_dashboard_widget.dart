import 'package:flutter/material.dart';
import '../../services/payment_billing_service.dart';

class PaymentBillingDashboardWidget extends StatefulWidget {
  const PaymentBillingDashboardWidget({super.key});

  @override
  State<PaymentBillingDashboardWidget> createState() => _PaymentBillingDashboardWidgetState();
}

class _PaymentBillingDashboardWidgetState extends State<PaymentBillingDashboardWidget> {
  final PaymentBillingService _billingService = PaymentBillingService();
  final TextEditingController _tenantIdController = TextEditingController();
  final TextEditingController _customUsersController = TextEditingController();
  final TextEditingController _customStorageController = TextEditingController();
  final TextEditingController _customAIRequestsController = TextEditingController();
  
  String _currentTenantId = 'demo_tenant_001';
  List<Subscription> _subscriptions = [];
  List<BillingRecord> _billingRecords = [];
  List<PaymentMethod> _paymentMethods = [];
  BillingStatistics? _statistics;
  
  bool _isLoading = false;
  String _selectedPlan = 'basic';
  String _selectedBillingCycle = 'monthly';

  @override
  void initState() {
    super.initState();
    _tenantIdController.text = _currentTenantId;
    _initializeBillingService();
    _loadBillingData();
  }

  @override
  void dispose() {
    _tenantIdController.dispose();
    _customUsersController.dispose();
    _customStorageController.dispose();
    _customAIRequestsController.dispose();
    super.dispose();
  }

  Future<void> _initializeBillingService() async {
    await _billingService.initialize();
    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    setState(() => _isLoading = true);
    try {
      final subscriptions = await _billingService.getSubscriptionsForTenant(_currentTenantId);
      final billingRecords = await _billingService.getBillingRecordsForTenant(_currentTenantId);
      final paymentMethods = await _billingService.getPaymentMethodsForTenant(_currentTenantId);
      final statistics = await _billingService.getBillingStatistics(_currentTenantId);
      
      setState(() {
        _subscriptions = subscriptions;
        _billingRecords = billingRecords;
        _paymentMethods = paymentMethods;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading billing data: $e');
    }
  }

  Future<void> _createSubscription() async {
    if (_selectedPlan == 'custom' && 
        (_customUsersController.text.isEmpty || 
         _customStorageController.text.isEmpty || 
         _customAIRequestsController.text.isEmpty)) {
      _showSnackBar('Please fill all custom plan fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Create mock payment method first
      final paymentMethod = await _billingService.addPaymentMethod(
        tenantId: _currentTenantId,
        type: 'card',
        last4: '4242',
        brand: 'visa',
        expiryDate: DateTime.now().add(const Duration(years: 2)),
        name: 'Demo Card',
      );

      // Create subscription
      final subscription = await _billingService.createSubscription(
        tenantId: _currentTenantId,
        planName: _selectedPlan,
        paymentMethodId: paymentMethod.id,
        customUsers: _selectedPlan == 'custom' ? int.parse(_customUsersController.text) : null,
        customStorageGB: _selectedPlan == 'custom' ? int.parse(_customStorageController.text) : null,
        customAIRequests: _selectedPlan == 'custom' ? int.parse(_customAIRequestsController.text) : null,
      );

      _showSnackBar('✅ Subscription created successfully!');
      await _loadBillingData();
      
      // Clear custom fields
      _customUsersController.clear();
      _customStorageController.clear();
      _customAIRequestsController.clear();
      
    } catch (e) {
      _showSnackBar('❌ Failed to create subscription: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelSubscription(String subscriptionId) async {
    setState(() => _isLoading = true);
    try {
      final success = await _billingService.cancelSubscription(subscriptionId);
      if (success) {
        _showSnackBar('✅ Subscription cancelled successfully!');
        await _loadBillingData();
      } else {
        _showSnackBar('❌ Failed to cancel subscription', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ Error cancelling subscription: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processPayment(String billingRecordId) async {
    setState(() => _isLoading = true);
    try {
      final result = await _billingService.processPayment(
        billingRecordId: billingRecordId,
        paymentMethodId: _paymentMethods.isNotEmpty ? _paymentMethods.first.id : 'demo_method',
      );

      if (result.success) {
        _showSnackBar('✅ Payment processed successfully!');
        await _loadBillingData();
      } else {
        _showSnackBar('❌ Payment failed: ${result.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ Error processing payment: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 Payment & Billing Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewCards(),
            const SizedBox(height: 24),
            
            // Pricing Plans
            _buildPricingPlans(),
            const SizedBox(height: 24),
            
            // Subscription Management
            _buildSubscriptionManagement(),
            const SizedBox(height: 24),
            
            // Billing Records
            _buildBillingRecords(),
            const SizedBox(height: 24),
            
            // Payment Methods
            _buildPaymentMethods(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    if (_statistics == null) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Subscriptions',
            '${_statistics!.totalSubscriptions}',
            Colors.blue,
            Icons.subscriptions,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Active Subscriptions',
            '${_statistics!.activeSubscriptions}',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Total Revenue',
            '\$${_statistics!.totalRevenue.toStringAsFixed(2)}',
            Colors.orange,
            Icons.attach_money,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard(
            'Pending Payments',
            '\$${_statistics!.pendingPayments.toStringAsFixed(2)}',
            Colors.red,
            Icons.pending,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.price_check, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Pricing Plans',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildPlanCard(
                    'Basic',
                    '\$${_billingService.pricingPlans['basic']}',
                    _billingService.planLimits['basic']!,
                    Colors.blue,
                    _selectedPlan == 'basic',
                    () => setState(() => _selectedPlan = 'basic'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPlanCard(
                    'Professional',
                    '\$${_billingService.pricingPlans['professional']}',
                    _billingService.planLimits['professional']!,
                    Colors.green,
                    _selectedPlan == 'professional',
                    () => setState(() => _selectedPlan = 'professional'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildPlanCard(
                    'Enterprise',
                    '\$${_billingService.pricingPlans['enterprise']}',
                    _billingService.planLimits['enterprise']!,
                    Colors.orange,
                    _selectedPlan == 'enterprise',
                    () => setState(() => _selectedPlan = 'enterprise'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPlanCard(
                    'Custom',
                    'Variable',
                    _billingService.planLimits['custom']!,
                    Colors.purple,
                    _selectedPlan == 'custom',
                    () => setState(() => _selectedPlan = 'custom'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, Map<String, int> limits, Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 8 : 4,
        color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
        child: Container(
          decoration: isSelected ? BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(8),
          ) : null,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${limits['users'] == -1 ? 'Unlimited' : limits['users']} Users',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${limits['storage_gb'] == -1 ? 'Unlimited' : limits['storage_gb']} GB Storage',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${limits['ai_requests_per_month'] == -1 ? 'Unlimited' : limits['ai_requests_per_month']} AI Requests',
                style: const TextStyle(fontSize: 14),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionManagement() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.manage_accounts, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Subscription Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tenant ID
            TextField(
              controller: _tenantIdController,
              decoration: const InputDecoration(
                labelText: 'Tenant ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              onChanged: (value) {
                setState(() => _currentTenantId = value);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Custom Plan Fields (only show for custom plan)
            if (_selectedPlan == 'custom') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customUsersController,
                      decoration: const InputDecoration(
                        labelText: 'Users',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _customStorageController,
                      decoration: const InputDecoration(
                        labelText: 'Storage (GB)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storage),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: _customAIRequestsController,
                decoration: const InputDecoration(
                  labelText: 'AI Requests per Month',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.psychology),
                ),
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Billing Cycle
            DropdownButtonFormField<String>(
              value: _selectedBillingCycle,
              decoration: const InputDecoration(
                labelText: 'Billing Cycle',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) {
                setState(() => _selectedBillingCycle = value!);
              },
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createSubscription,
                icon: const Icon(Icons.add),
                label: const Text('Create Subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingRecords() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Billing Records',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_billingRecords.isEmpty)
              const Center(
                child: Text(
                  'No billing records available',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _billingRecords.length,
                itemBuilder: (context, index) {
                  final record = _billingRecords[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getBillingStatusColor(record.status),
                        child: Icon(
                          _getBillingStatusIcon(record.status),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        record.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${record.type.name.toUpperCase()} | ${_formatDate(record.createdAt)}\n'
                        'Status: ${record.status.name.toUpperCase()}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${record.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (record.status == BillingStatus.pending)
                            ElevatedButton(
                              onPressed: _isLoading ? null : () => _processPayment(record.id),
                              child: const Text('Pay'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.indigo, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Payment Methods',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_paymentMethods.isEmpty)
              const Center(
                child: Text(
                  'No payment methods available',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(
                          _getPaymentMethodIcon(method.type),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        '${method.brand.toUpperCase()} •••• ${method.last4}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Expires: ${_formatDate(method.expiryDate)}\n'
                        '${method.isDefault ? 'Default' : 'Secondary'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (method.isDefault)
                            const Chip(
                              label: Text('Default'),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Handle delete payment method
                              _showSnackBar('🗑️ Delete payment method functionality');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle add payment method
                  _showSnackBar('➕ Add payment method functionality');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBillingStatusColor(BillingStatus status) {
    switch (status) {
      case BillingStatus.paid:
        return Colors.green;
      case BillingStatus.pending:
        return Colors.orange;
      case BillingStatus.failed:
        return Colors.red;
      case BillingStatus.refunded:
        return Colors.blue;
      case BillingStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getBillingStatusIcon(BillingStatus status) {
    switch (status) {
      case BillingStatus.paid:
        return Icons.check_circle;
      case BillingStatus.pending:
        return Icons.pending;
      case BillingStatus.failed:
        return Icons.error;
      case BillingStatus.refunded:
        return Icons.refresh;
      case BillingStatus.cancelled:
        return Icons.cancel;
    }
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
