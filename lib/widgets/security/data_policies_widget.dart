import 'package:flutter/material.dart';
import '../../models/security_models.dart';
import '../../utils/theme.dart';

class DataPoliciesWidget extends StatelessWidget {
  final List<DataRetentionPolicy> retentionPolicies;
  final List<DataAnonymizationRule> anonymizationRules;
  final Function(DataRetentionPolicy)? onPolicyTap;
  final Function(DataAnonymizationRule)? onRuleToggle;

  const DataPoliciesWidget({
    super.key,
    required this.retentionPolicies,
    required this.anonymizationRules,
    this.onPolicyTap,
    this.onRuleToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRetentionPoliciesSection(context),
        const SizedBox(height: 24),
        _buildAnonymizationSection(context),
      ],
    );
  }

  Widget _buildRetentionPoliciesSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Veri Saklama Politikaları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${retentionPolicies.length}'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (retentionPolicies.isEmpty)
              _buildEmptyState('Veri saklama politikası bulunmuyor')
            else
              ...retentionPolicies.map((policy) => _buildPolicyCard(context, policy)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymizationSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Veri Anonimleştirme Kuralları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${anonymizationRules.length}'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (anonymizationRules.isEmpty)
              _buildEmptyState('Anonimleştirme kuralı bulunmuyor')
            else
              ...anonymizationRules.map((rule) => _buildRuleCard(context, rule)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.policy,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, DataRetentionPolicy policy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(
            Icons.policy,
            color: Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          policy.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(policy.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${policy.retentionPeriod.inDays} gün',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.delete,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  policy.autoDelete ? 'Otomatik silme' : 'Manuel silme',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (policy.lastReview != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Son inceleme: ${_formatDate(policy.lastReview!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            if (policy.reviewedBy != null) ...[
              const SizedBox(height: 4),
              Text(
                policy.reviewedBy!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        onTap: () => onPolicyTap?.call(policy),
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, DataAnonymizationRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: Icon(
            Icons.visibility_off,
            color: Colors.purple,
            size: 20,
          ),
        ),
        title: Text(
          rule.fieldName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip: ${_getAnonymizationTypeText(rule.type)}'),
            if (rule.replacementValue != null) ...[
              const SizedBox(height: 4),
              Text(
                'Değiştirici: ${rule.replacementValue}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Oluşturulma: ${_formatDate(rule.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Switch(
          value: rule.isActive,
          onChanged: (value) => onRuleToggle?.call(rule),
          activeColor: Colors.purple,
        ),
      ),
    );
  }

  String _getAnonymizationTypeText(AnonymizationType type) {
    switch (type) {
      case AnonymizationType.mask:
        return 'Maskeleme (son 4 karakter)';
      case AnonymizationType.hash:
        return 'Hash\'leme';
      case AnonymizationType.replace:
        return 'Değiştirme';
      case AnonymizationType.remove:
        return 'Kaldırma';
      case AnonymizationType.randomize:
        return 'Rastgeleleştirme';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
