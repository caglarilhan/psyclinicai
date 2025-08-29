import 'package:flutter/material.dart';
import '../../models/appointment_models.dart';
import '../../utils/theme.dart';

class AppointmentCardWidget extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AppointmentCardWidget({
    super.key,
    required this.appointment,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.clientName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(appointment.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTypeText(appointment.type),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              
              if (appointment.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  appointment.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              if (appointment.duration != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${appointment.duration!.inMinutes} dakika',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        appointment.therapistId ?? 'Terapist atanmamış',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (onEdit != null) ...[
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: 'Düzenle',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (onDelete != null) ...[
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 18),
                          tooltip: 'Sil',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.red,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(appointment.status),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        return AppTheme.infoColor;
      case AppointmentStatus.confirmed:
        return AppTheme.successColor;
      case AppointmentStatus.completed:
        return AppTheme.primaryColor;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Planlandı';
      case AppointmentStatus.confirmed:
        return 'Onaylandı';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal';
      case AppointmentStatus.noShow:
        return 'Gelmedi';
    }
  }

  String _getTypeText(AppointmentType type) {
    switch (type) {
      case AppointmentType.individual:
        return 'Bireysel';
      case AppointmentType.group:
        return 'Grup';
      case AppointmentType.emergency:
        return 'Acil';
      case AppointmentType.followUp:
        return 'Takip';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateText;
    if (appointmentDate.isAtSameMomentAs(today)) {
      dateText = 'Bugün';
    } else if (appointmentDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      dateText = 'Yarın';
    } else {
      dateText = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeText = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateText $timeText';
  }
}
