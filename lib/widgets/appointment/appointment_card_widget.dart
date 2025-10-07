import 'package:flutter/material.dart';
import '../../models/appointment_models.dart';
import '../teletherapy/teletherapy_session_widget.dart';

class AppointmentCardWidget extends StatelessWidget {
  final Appointment appointment;
  const AppointmentCardWidget({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.clientName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${appointment.dateTime} • ${appointment.type}'),
            const SizedBox(height: 8),
            TeletherapySessionWidget(
              clientName: appointment.clientName,
              therapistName: appointment.therapistName,
            )
          ],
        ),
      ),
    );
  }
}
