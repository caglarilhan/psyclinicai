import 'package:flutter/material.dart';
import '../../models/subscription_models.dart';
import '../../services/subscription_service.dart';
import '../../utils/theme.dart';

class SubscriptionPlansWidget extends StatefulWidget {
  final String userId;
  final Function(SubscriptionPlan, BillingCycle)? onPlanSelected;

  const SubscriptionPlansWidget({
    super.key,
    required this.userId,
    this.onPlanSelected,
  });

  @override
  State<SubscriptionPlansWidget> createState() => _SubscriptionPlansWidgetState();
}

class _SubscriptionPlansWidgetState extends State<SubscriptionPlansWidget> {
  final _subscriptionService = SubscriptionService();
  List<SubscriptionPlanDetails> _plans = [];
  BillingCycle _selectedBillingCycle = BillingCycle.monthly;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _subscriptionService.getAvailablePlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Planlar yüklenemedi: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Billing Cycle Toggle
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aylık',
                style: TextStyle(
                  color: _selectedBillingCycle == BillingCycle.monthly
                      ? AppTheme.primaryColor
                      : Colors.grey,
                  fontWeight: _selectedBillingCycle == BillingCycle.monthly
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              Switch(
                value: _selectedBillingCycle == BillingCycle.yearly,
                onChanged: (value) {
                  setState(() {
                    _selectedBillingCycle = value 
                        ? BillingCycle.yearly 
                        : BillingCycle.monthly;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              Text(
                'Yıllık',
                style: TextStyle(
                  color: _selectedBillingCycle == BillingCycle.yearly
                      ? AppTheme.primaryColor
                      : Colors.grey,
                  fontWeight: _selectedBillingCycle == BillingCycle.yearly
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (_selectedBillingCycle == BillingCycle.yearly)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '2 Ay Ücretsiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Plans Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              return _buildPlanCard(plan);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlanDetails plan) {
    final price = _selectedBillingCycle == BillingCycle.monthly
        ? plan.monthlyPrice
        : plan.yearlyPrice;
    
    final isPopular = plan.plan == SubscriptionPlan.professional;
    
    return Card(
      elevation: isPopular ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPopular 
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plan.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Popüler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '/${_selectedBillingCycle == BillingCycle.monthly ? 'ay' : 'yıl'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Features
            Expanded(
              child: ListView.builder(
                itemCount: plan.features.length,
                itemBuilder: (context, index) {
                  final feature = plan.features[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Select Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectPlan(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular 
                      ? AppTheme.primaryColor 
                      : Colors.grey[300],
                  foregroundColor: isPopular 
                      ? Colors.white 
                      : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Seç',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPopular ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPlan(SubscriptionPlanDetails plan) {
    if (widget.onPlanSelected != null) {
      widget.onPlanSelected!(plan.plan, _selectedBillingCycle);
    } else {
      _showPlanDetails(plan);
    }
  }

  void _showPlanDetails(SubscriptionPlanDetails plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.description),
            const SizedBox(height: 16),
            Text(
              'Özellikler:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Start subscription process
            },
            child: const Text('Abone Ol'),
          ),
        ],
      ),
    );
  }
}
