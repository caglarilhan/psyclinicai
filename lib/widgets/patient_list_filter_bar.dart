import 'package:flutter/material.dart';

import '../services/data/patient_filter.dart';
import '../theme/tokens.dart';

/// Chip bar that binds `PatientFilter` to the patient list (plan §19).
///
/// Stateless — the parent owns the `PatientFilter` value and rebuilds
/// the list when [onChanged] fires. The widget never mutates the
/// filter; it returns a fresh instance per chip tap (matches the
/// immutable copy-on-write API in `patient_filter.dart`).
class PatientListFilterBar extends StatelessWidget {
  const PatientListFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  final PatientFilter filter;
  final ValueChanged<PatientFilter> onChanged;

  String _statusLabel(PatientStatusFilter s) {
    switch (s) {
      case PatientStatusFilter.active:
        return 'Active';
      case PatientStatusFilter.stable:
        return 'Stable';
      case PatientStatusFilter.followUp:
        return 'Follow-up';
      case PatientStatusFilter.inactive:
        return 'Inactive';
    }
  }

  String _riskLabel(PatientRiskFilter r) {
    switch (r) {
      case PatientRiskFilter.high:
        return 'High risk';
      case PatientRiskFilter.medium:
        return 'Medium risk';
      case PatientRiskFilter.low:
        return 'Low risk';
    }
  }

  String _seenLabel(LastSeenFilter l) {
    switch (l) {
      case LastSeenFilter.within24h:
        return 'Seen ≤ 24h';
      case LastSeenFilter.within7d:
        return 'Seen ≤ 7d';
      case LastSeenFilter.within30d:
        return 'Seen ≤ 30d';
      case LastSeenFilter.over30d:
        return 'Seen > 30d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: PsySpacing.sm,
      runSpacing: PsySpacing.sm,
      children: [
        for (final s in PatientStatusFilter.values)
          FilterChip(
            label: Text(_statusLabel(s)),
            selected: filter.statuses.contains(s),
            onSelected: (_) => onChanged(filter.toggleStatus(s)),
          ),
        for (final r in PatientRiskFilter.values)
          FilterChip(
            label: Text(_riskLabel(r)),
            selected: filter.risks.contains(r),
            onSelected: (_) => onChanged(filter.toggleRisk(r)),
          ),
        for (final l in LastSeenFilter.values)
          ChoiceChip(
            label: Text(_seenLabel(l)),
            selected: filter.lastSeen == l,
            onSelected: (selected) {
              onChanged(filter.withLastSeen(selected ? l : null));
            },
          ),
        if (!filter.isEmpty)
          ActionChip(
            avatar: const Icon(Icons.clear, size: 16),
            label: const Text('Clear filters'),
            onPressed: () => onChanged(PatientFilter.empty),
          ),
      ],
    );
  }
}
