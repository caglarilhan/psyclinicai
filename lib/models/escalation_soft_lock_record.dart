/// Stable dismissal-reason taxonomy (Sprint 14 polish).
///
/// We used to store the i18n ARB key directly in
/// `dismissReasonCode`. That broke as soon as a clinician's locale
/// changed (Sprint 10 ARB binding) or an ARB key was renamed — old
/// rows held stale strings the dashboard could not surface. This
/// enum is the canonical truth; ARB only renders the label.
enum EscalationDismissReason {
  hospitalized('hospitalized'),
  familyPresent('family_present'),
  supervisorHandoff('supervisor_handoff'),
  inSessionPlan('in_session_plan'),
  other('other');

  const EscalationDismissReason(this.id);
  final String id;

  static EscalationDismissReason fromId(String? id) {
    if (id == null) return EscalationDismissReason.other;
    // Forward-compat with the old ARB-key strings that lived in
    // earlier rows. Map the legacy `dismissReason*` slugs onto the
    // new stable codes.
    const legacy = <String, EscalationDismissReason>{
      'dismissReasonHospitalized': EscalationDismissReason.hospitalized,
      'dismissReasonFamilyPresent': EscalationDismissReason.familyPresent,
      'dismissReasonSupervisorHandoff':
          EscalationDismissReason.supervisorHandoff,
      'dismissReasonInSessionPlan': EscalationDismissReason.inSessionPlan,
      'dismissReasonOther': EscalationDismissReason.other,
    };
    final legacyMatch = legacy[id];
    if (legacyMatch != null) return legacyMatch;
    for (final r in EscalationDismissReason.values) {
      if (r.id == id) return r;
    }
    return EscalationDismissReason.other;
  }
}

/// Firestore-shaped representation of a C-SSRS imminent / immediate
/// dismissal soft-lock (Sprint 10 — cross-device persistence).
///
/// Sprint 6 introduced an in-memory `EscalationSoftLock` registry so
/// the dashboard banner survives within a single session. This model
/// is the on-disk counterpart: a row in the `escalation_soft_locks`
/// collection that lets *another* clinician on the same caseload
/// (oncall, supervisor) see the lock the moment they open the chart,
/// even on a different device.
///
/// Rows are NEVER hard-deleted on follow-up. Setting [stale] true lets
/// the audit chain prove "this lock was here, it was followed up at
/// T, and the safety plan was completed by clinician X". Cleanup is
/// done by the `escalationSoftLockCleanup` Cloud Function.
class EscalationSoftLockRecord {
  const EscalationSoftLockRecord({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.dismissingClinicianId,
    required this.severity,
    required this.tier,
    required this.dismissReasonCode,
    required this.dismissedAt,
    required this.followUpDueAt,
    this.supervisorHandoffId,
    this.stale = false,
  });

  factory EscalationSoftLockRecord.fromJson(Map<String, dynamic> json) =>
      EscalationSoftLockRecord(
        id: json['id'] as String? ?? '',
        clinicId: json['clinicId'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        dismissingClinicianId: json['dismissingClinicianId'] as String? ?? '',
        severity: json['severity'] as String? ?? '',
        tier: json['tier'] as String? ?? '',
        dismissReasonCode: json['dismissReasonCode'] as String? ?? '',
        dismissedAt:
            DateTime.tryParse(json['dismissedAt'] as String? ?? '') ??
            DateTime.now().toUtc(),
        followUpDueAt:
            DateTime.tryParse(json['followUpDueAt'] as String? ?? '') ??
            DateTime.now().toUtc(),
        supervisorHandoffId: json['supervisorHandoffId'] as String?,
        stale: json['stale'] as bool? ?? false,
      );

  /// Window after dismissal during which the lock blocks the next
  /// AI assistance call and surfaces a dashboard banner. 24h matches
  /// the Sprint 6 in-memory implementation and aligns with the SAMHSA
  /// crisis follow-up window.
  static const Duration followUpWindow = Duration(hours: 24);

  final String id;
  final String clinicId;
  final String patientId;

  /// The clinician who dismissed the imminent / immediate modal.
  final String dismissingClinicianId;

  /// Canonical C-SSRS severity (`severe` / `critical`).
  final String severity;

  /// Tier captured at dismissal (`immediate` / `imminent`).
  final String tier;

  /// One of the dismissReason* keys in the ARB i18n file. Never
  /// free-text; keeps audit categorisation possible.
  final String dismissReasonCode;

  final DateTime dismissedAt;

  /// Pre-computed for fast Firestore queries instead of re-deriving on
  /// every read. Set by the caller, not by the constructor.
  final DateTime followUpDueAt;

  /// When a supervisor / on-call accepts the handoff, this stores the
  /// supervisor review id so the audit trail can follow the chain.
  final String? supervisorHandoffId;

  /// Cleanup Cloud Function sets this true once [followUpDueAt] has
  /// passed without a documented follow-up. UI still shows the row in
  /// a "needs review" tab; the row never disappears.
  final bool stale;

  /// True while the 24-hour follow-up window is still open AND the
  /// row has not been marked stale by the cleanup cron.
  bool isActiveAt(DateTime now) {
    if (stale) return false;
    return now.toUtc().isBefore(followUpDueAt.toUtc());
  }

  EscalationSoftLockRecord copyWith({
    String? supervisorHandoffId,
    bool? stale,
  }) => EscalationSoftLockRecord(
    id: id,
    clinicId: clinicId,
    patientId: patientId,
    dismissingClinicianId: dismissingClinicianId,
    severity: severity,
    tier: tier,
    dismissReasonCode: dismissReasonCode,
    dismissedAt: dismissedAt,
    followUpDueAt: followUpDueAt,
    supervisorHandoffId: supervisorHandoffId ?? this.supervisorHandoffId,
    stale: stale ?? this.stale,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'clinicId': clinicId,
    'patientId': patientId,
    'dismissingClinicianId': dismissingClinicianId,
    'severity': severity,
    'tier': tier,
    'dismissReasonCode': dismissReasonCode,
    'dismissedAt': dismissedAt.toIso8601String(),
    'followUpDueAt': followUpDueAt.toIso8601String(),
    if (supervisorHandoffId != null) 'supervisorHandoffId': supervisorHandoffId,
    'stale': stale,
  };

  /// Pure helper — convenience for callers to derive `followUpDueAt`
  /// without duplicating the [followUpWindow] constant.
  static DateTime dueAtFromDismissal(DateTime dismissedAt) =>
      dismissedAt.toUtc().add(followUpWindow);
}
