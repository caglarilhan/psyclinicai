import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/ds/psy_card.dart';

/// `/portal/appointments` — Patient-side appointment list. Skeleton.
class PortalAppointmentsScreen extends StatelessWidget {
  const PortalAppointmentsScreen({super.key, this.items});

  /// Override for tests. Production wires this to a repository.
  final List<PortalAppointmentRow>? items;

  @override
  Widget build(BuildContext context) {
    final rows =
        items ??
        <PortalAppointmentRow>[
          PortalAppointmentRow(
            title: 'Therapy session',
            when: DateTime.now().add(const Duration(days: 1)),
            location: 'Video session',
            clinician: 'Dr. Smith',
          ),
          PortalAppointmentRow(
            title: 'Follow-up',
            when: DateTime.now().add(const Duration(days: 8)),
            location: 'Clinic, Berlin',
            clinician: 'Dr. Smith',
          ),
        ];
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(PsySpacing.lg),
          itemCount: rows.length,
          itemBuilder: (_, i) {
            final r = rows[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: PsyCard(
                child: Row(
                  children: [
                    const Icon(Icons.event_available_outlined),
                    const SizedBox(width: PsySpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${r.when.toIso8601String().substring(0, 16)}  ·  '
                            '${r.location}  ·  ${r.clinician}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      // Rescheduling flow ships in a follow-up sprint;
                      // disabling the button avoids a dead click.
                      onPressed: null,
                      child: const Text('Reschedule'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PortalAppointmentRow {
  const PortalAppointmentRow({
    required this.title,
    required this.when,
    required this.location,
    required this.clinician,
  });
  final String title;
  final DateTime when;
  final String location;
  final String clinician;
}
