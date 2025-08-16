import 'package:flutter/material.dart';
import '../../models/client_model.dart';

class ClientListWidget extends StatelessWidget {
  final List<ClientModel> clients;
  final Function(ClientModel) onClientTap;

  const ClientListWidget({
    super.key,
    required this.clients,
    required this.onClientTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return ClientCard(
          client: client,
          onTap: () => onClientTap(client),
        );
      },
    );
  }
}

class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onTap;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (client.status) {
      case ClientStatus.active:
        return Colors.green;
      case ClientStatus.inactive:
        return Colors.grey;
      case ClientStatus.discharged:
        return Colors.blue;
      case ClientStatus.onHold:
        return Colors.orange;
      case ClientStatus.emergency:
        return Colors.red;
    }
  }

  Color _getRiskColor() {
    switch (client.riskLevel) {
      case ClientRiskLevel.low:
        return Colors.green;
      case ClientRiskLevel.medium:
        return Colors.orange;
      case ClientRiskLevel.high:
        return Colors.red;
      case ClientRiskLevel.critical:
        return Colors.purple;
    }
  }

  String _getStatusText() {
    switch (client.status) {
      case ClientStatus.active:
        return 'Aktif';
      case ClientStatus.inactive:
        return 'Pasif';
      case ClientStatus.discharged:
        return 'Taburcu';
      case ClientStatus.onHold:
        return 'Beklemede';
      case ClientStatus.emergency:
        return 'Acil';
    }
  }

  String _getRiskText() {
    switch (client.riskLevel) {
      case ClientRiskLevel.low:
        return 'Düşük';
      case ClientRiskLevel.medium:
        return 'Orta';
      case ClientRiskLevel.high:
        return 'Yüksek';
      case ClientRiskLevel.critical:
        return 'Kritik';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        client.firstName[0] + client.lastName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Client Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${client.age} yaşında',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (client.primaryDiagnosis != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            client.primaryDiagnosis!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status Indicators
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRiskColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getRiskColor().withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getRiskText(),
                          style: TextStyle(
                            color: _getRiskColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Contact Info
              if (client.phoneNumber != null || client.email != null) ...[
                Row(
                  children: [
                    if (client.phoneNumber != null) ...[
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        client.phoneNumber!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (client.phoneNumber != null && client.email != null) ...[
                      const SizedBox(width: 24),
                    ],
                    if (client.email != null) ...[
                      Icon(
                        Icons.email,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          client.email!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Session Info
              Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.calendar_today,
                    label: 'İlk Seans',
                    value: _formatDate(client.firstSessionDate),
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    icon: Icons.schedule,
                    label: 'Toplam Seans',
                    value: '${client.totalSessions}',
                  ),
                  const SizedBox(width: 24),
                  if (client.lastSessionDate != null)
                    _buildInfoItem(
                      icon: Icons.update,
                      label: 'Son Seans',
                      value: _formatDate(client.lastSessionDate!),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility),
                      label: const Text('Görüntüle'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement quick actions
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Seans Ekle'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Bugün';
    } else if (difference == 1) {
      return 'Dün';
    } else if (difference < 7) {
      return '$difference gün önce';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks hafta önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
