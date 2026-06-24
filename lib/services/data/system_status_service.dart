/// In-process system-status provider. Today serves the in-app
/// status banner from in-memory defaults (all-operational); future
/// PR wires it to a Firestore `status/current` doc or a Cloud
/// Function probe endpoint without changing the consumer API.
///
/// The banner consumer subscribes to [statusListenable] and
/// rebuilds when [overallSeverity] flips.
library;

import 'package:flutter/foundation.dart';

enum SystemId {
  firebaseAuth,
  firestoreEU,
  firestoreUS,
  anthropic,
  stripe,
  email,
}

enum StatusSeverity { operational, degraded, down }

extension StatusSeverityX on StatusSeverity {
  /// Higher number = worse. Used by [SystemStatusService.overallSeverity]
  /// to surface the worst subsystem state in the banner.
  int get rank => switch (this) {
    StatusSeverity.operational => 0,
    StatusSeverity.degraded => 1,
    StatusSeverity.down => 2,
  };

  String get label => switch (this) {
    StatusSeverity.operational => 'Operational',
    StatusSeverity.degraded => 'Degraded',
    StatusSeverity.down => 'Outage',
  };
}

extension SystemIdX on SystemId {
  String get label => switch (this) {
    SystemId.firebaseAuth => 'Firebase Authentication',
    SystemId.firestoreEU => 'Firestore — EU tenants',
    SystemId.firestoreUS => 'Firestore — US tenants',
    SystemId.anthropic => 'Anthropic API',
    SystemId.stripe => 'Stripe billing',
    SystemId.email => 'Outbound email',
  };
}

class SystemStatus {
  const SystemStatus({
    required this.system,
    required this.severity,
    required this.updatedAt,
    this.message,
  });

  final SystemId system;
  final StatusSeverity severity;
  final DateTime updatedAt;
  final String? message;
}

class SystemStatusService {
  SystemStatusService._() {
    _statuses.value = _allOperationalSnapshot();
  }

  static final SystemStatusService instance = SystemStatusService._();

  final ValueNotifier<List<SystemStatus>> _statuses =
      ValueNotifier<List<SystemStatus>>(<SystemStatus>[]);

  ValueListenable<List<SystemStatus>> get statusListenable => _statuses;

  List<SystemStatus> get current => List.unmodifiable(_statuses.value);

  /// The worst severity across every tracked subsystem.
  StatusSeverity get overallSeverity {
    var worst = StatusSeverity.operational;
    for (final s in _statuses.value) {
      if (s.severity.rank > worst.rank) worst = s.severity;
    }
    return worst;
  }

  /// Returns the degraded / down subsystems only. Used by the banner
  /// so we never render the operational ones inline.
  List<SystemStatus> get nonOperational => _statuses.value
      .where((s) => s.severity != StatusSeverity.operational)
      .toList(growable: false);

  /// Replaces the current snapshot. Wired by the probe in a future
  /// PR; today the only callers are tests + the bootstrap default.
  void setStatuses(List<SystemStatus> next) {
    _statuses.value = List<SystemStatus>.unmodifiable(next);
  }

  /// Convenience used by tests to flip a single subsystem without
  /// rebuilding the whole snapshot.
  @visibleForTesting
  void setSeverity(
    SystemId id,
    StatusSeverity severity, {
    String? message,
    DateTime? at,
  }) {
    final next = [
      for (final s in _statuses.value)
        if (s.system == id)
          SystemStatus(
            system: id,
            severity: severity,
            updatedAt: at ?? DateTime.now().toUtc(),
            message: message,
          )
        else
          s,
    ];
    setStatuses(next);
  }

  @visibleForTesting
  void debugReset() {
    _statuses.value = _allOperationalSnapshot();
  }

  List<SystemStatus> _allOperationalSnapshot() {
    final now = DateTime.now().toUtc();
    return [
      for (final id in SystemId.values)
        SystemStatus(
          system: id,
          severity: StatusSeverity.operational,
          updatedAt: now,
        ),
    ];
  }
}
