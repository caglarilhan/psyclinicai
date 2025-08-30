import 'package:flutter/material.dart';
import '../../models/security_models.dart';
import '../../utils/theme.dart';

class SecurityIncidentsWidget extends StatelessWidget {
  final List<SecurityIncident> incidents;
  final Function(SecurityIncident)? onIncidentTap;
  final Function(SecurityIncident)? onResolveIncident;

  const SecurityIncidentsWidget({
    super.key,
    required this.incidents,
    this.onIncidentTap,
    this.onResolveIncident,
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
                  'Güvenlik Olayları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${incidents.length}'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (incidents.isEmpty)
              _buildEmptyState()
            else
              ...incidents.map((incident) => _buildIncidentCard(context, incident)),
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
            Icons.security,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Güvenlik olayı bulunmuyor',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sistem güvenli ve stabil çalışıyor',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, SecurityIncident incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIncidentColor(incident.severity).withOpacity(0.1),
          child: Icon(
            _getIncidentIcon(incident.type),
            color: _getIncidentColor(incident.severity),
            size: 20,
          ),
        ),
        title: Text(
          incident.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(incident.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(incident.detectedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.people,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${incident.affectedUsers.length} kullanıcı',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(incident.severity.name.toUpperCase()),
              backgroundColor: _getIncidentColor(incident.severity).withOpacity(0.2),
              labelStyle: TextStyle(
                color: _getIncidentColor(incident.severity),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!incident.isResolved && onResolveIncident != null) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => onResolveIncident!(incident),
                child: const Text(
                  'Çöz',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        onTap: () => onIncidentTap?.call(incident),
      ),
    );
  }

  IconData _getIncidentIcon(SecurityIncidentType type) {
    switch (type) {
      case SecurityIncidentType.unauthorizedAccess:
        return Icons.person_off;
      case SecurityIncidentType.dataBreach:
        return Icons.data_usage;
      case SecurityIncidentType.malware:
        return Icons.bug_report;
      case SecurityIncidentType.phishing:
        return Icons.fishing;
      case SecurityIncidentType.socialEngineering:
        return Icons.psychology;
      case SecurityIncidentType.physicalSecurity:
        return Icons.security;
      case SecurityIncidentType.networkAttack:
        return Icons.wifi_off;
      case SecurityIncidentType.other:
        return Icons.warning;
    }
  }

  Color _getIncidentColor(SecurityIncidentSeverity severity) {
    switch (severity) {
      case SecurityIncidentSeverity.low:
        return Colors.green;
      case SecurityIncidentSeverity.medium:
        return Colors.orange;
      case SecurityIncidentSeverity.high:
        return Colors.red;
      case SecurityIncidentSeverity.critical:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
