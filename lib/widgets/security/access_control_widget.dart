import 'package:flutter/material.dart';
import '../../models/security_models.dart';
import '../../utils/theme.dart';

class AccessControlWidget extends StatelessWidget {
  final List<AccessControlPolicy> policies;
  final Function(AccessControlPolicy)? onPolicyTap;
  final Function(AccessControlPolicy, bool)? onPolicyToggle;

  const AccessControlWidget({
    super.key,
    required this.policies,
    this.onPolicyTap,
    this.onPolicyToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                  'Erişim Kontrol Politikaları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${policies.length}'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (policies.isEmpty)
              _buildEmptyState()
            else
              ...policies.map((policy) => _buildPolicyCard(context, policy)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.lock,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Erişim kontrol politikası bulunmuyor',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Güvenlik politikalarınızı tanımlayın',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, AccessControlPolicy policy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: policy.isActive 
              ? Colors.green.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            Icons.lock,
            color: policy.isActive ? Colors.green : Colors.grey,
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
            Wrap(
              spacing: 8,
              children: [
                _buildChip('Roller', policy.roles.join(', '), Colors.blue),
                _buildChip('Kaynaklar', policy.resources.join(', '), Colors.orange),
                _buildChip('İzinler', policy.permissions.join(', '), Colors.green),
              ],
            ),
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
                  'Oluşturulma: ${_formatDate(policy.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (policy.lastModified != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.update,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Güncelleme: ${_formatDate(policy.lastModified!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            if (policy.createdBy != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Oluşturan: ${policy.createdBy}',
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
            Switch(
              value: policy.isActive,
              onChanged: (value) => onPolicyToggle?.call(policy, value),
              activeColor: Colors.green,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: policy.isActive ? Colors.green.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                policy.isActive ? 'Aktif' : 'Pasif',
                style: TextStyle(
                  fontSize: 10,
                  color: policy.isActive ? Colors.green.shade800 : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => onPolicyTap?.call(policy),
      ),
    );
  }

  Widget _buildChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Flexible(
            child: Text(
              value.length > 20 ? '${value.substring(0, 20)}...' : value,
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
