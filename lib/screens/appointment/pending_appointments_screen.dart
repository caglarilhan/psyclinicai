import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment_model.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  const PendingAppointmentsScreen({super.key});

  @override
  State<PendingAppointmentsScreen> createState() => _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      await _appointmentService.initialize();
      // Yaklaşan randevuları tarih/saat artan sırayla listele
      final upcoming = _appointmentService.getUpcomingAppointments();
      setState(() {
        _appointments = upcoming;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Randevular yüklenemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bekleyen Randevular'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final a = _appointments[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.schedule, color: AppTheme.primaryColor),
                        ),
                        title: Text(a.clientName),
                        subtitle: Text(_formatRange(a.startTime, a.endTime)),
                        trailing: Text(
                          a.status,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: a.status.toLowerCase() == 'scheduled' ? AppTheme.warningColor : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Bekleyen randevu bulunmuyor', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatRange(DateTime start, DateTime end) {
    String two(int n) => n.toString().padLeft(2, '0');
    final day = '${two(start.day)}.${two(start.month)}.${start.year}';
    final from = '${two(start.hour)}:${two(start.minute)}';
    final to = '${two(end.hour)}:${two(end.minute)}';
    return '$day  $from - $to';
  }
}


