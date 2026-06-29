/// K8 — Data subject rights taxonomy (GDPR Art. 15–22 + KVKK md. 11).
///
/// **Why this exists**: today only the DSAR export (Art. 15) is
/// surfaced as a first-class flow. The other five rights (rectifi-
/// cation, erasure, restriction, portability, objection, automated-
/// decision) are handled ad-hoc by the DPO over email. Auditors +
/// patients expect documented per-right SLA + response template +
/// evidence path. This catalog pins:
///   1. Every right we MUST honour with its statutory deadline.
///   2. Single accountable owner per right (DPO for all today).
///   3. Audit log entry kind so each request is traceable in the
///      tamper-evident chain.
///
/// **Out of scope** (separate PRs):
///   * Per-right request intake UI (`/portal/rights/<kind>`).
///   * Cloud Function that fans out to the right handler.
///   * Trust-center widget rendering the rights matrix.
library;

/// The seven rights any EU data subject (and KVKK md. 11 ilgili
/// kişi) may exercise.
enum SubjectRightKind {
  /// GDPR Art. 15 / KVKK md. 11/d — right of access (DSAR).
  access,

  /// GDPR Art. 16 / KVKK md. 11/d — rectification.
  rectification,

  /// GDPR Art. 17 / KVKK md. 7 — erasure ("right to be forgotten").
  erasure,

  /// GDPR Art. 18 — restriction of processing.
  restriction,

  /// GDPR Art. 20 — data portability.
  portability,

  /// GDPR Art. 21 / KVKK md. 11/h — objection to processing.
  objection,

  /// GDPR Art. 22 / KVKK md. 11/g — not to be subject to a decision
  /// based solely on automated processing.
  automatedDecision,
}

/// One pinned subject-rights handling policy.
class SubjectRightRecord {
  const SubjectRightRecord({
    required this.kind,
    required this.label,
    required this.statutoryDeadlineDays,
    required this.internalTargetDays,
    required this.responseOwner,
    required this.responseTemplateId,
    required this.auditEntryKind,
    required this.requiresIdentityVerification,
    required this.regulatoryRefs,
  });

  final SubjectRightKind kind;

  /// Customer-facing label shown on the portal.
  final String label;

  /// Statutory deadline in calendar days. GDPR Art. 12(3) sets 30
  /// days with a possible 60-day extension; we keep the hard floor
  /// here and an internal target below.
  final int statutoryDeadlineDays;

  /// Internal target — we ship faster than the law requires so legal
  /// has buffer. Tests pin `internal < statutory`.
  final int internalTargetDays;

  /// Single accountable owner (today: dpo for all rights). Could
  /// fan out later (rectification → clinician, erasure → DPO, etc.).
  final String responseOwner;

  /// Stable id of the canned response template the handler picks
  /// (lives in a future PromptRegistry-style email template registry).
  final String responseTemplateId;

  /// What kind of entry to append to the tamper-evident audit chain
  /// when this request completes. Mirrors the audit entry vocabulary.
  final String auditEntryKind;

  /// True when the controller MUST verify the requester is who they
  /// claim before fulfilling. GDPR Recital 64; KVKK md. 13.
  final bool requiresIdentityVerification;

  final List<String> regulatoryRefs;
}

class SubjectRightsTaxonomy {
  const SubjectRightsTaxonomy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned taxonomy. Append-only.
  static const List<SubjectRightRecord> rights = [
    SubjectRightRecord(
      kind: SubjectRightKind.access,
      label: 'Right of access (DSAR)',
      statutoryDeadlineDays: 30,
      internalTargetDays: 14,
      responseOwner: 'dpo',
      responseTemplateId: 'rights_response_access_v1',
      auditEntryKind: 'subject_rights.access.completed',
      requiresIdentityVerification: true,
      regulatoryRefs: [
        'GDPR Art. 15 right of access',
        'GDPR Art. 12(3) one-month response',
        'KVKK md. 11/d veri talep etme',
      ],
    ),
    SubjectRightRecord(
      kind: SubjectRightKind.rectification,
      label: 'Rectification',
      statutoryDeadlineDays: 30,
      internalTargetDays: 7,
      responseOwner: 'dpo',
      responseTemplateId: 'rights_response_rectification_v1',
      auditEntryKind: 'subject_rights.rectification.completed',
      requiresIdentityVerification: true,
      regulatoryRefs: [
        'GDPR Art. 16 rectification',
        'KVKK md. 11/d düzeltilmesini isteme',
      ],
    ),
    SubjectRightRecord(
      kind: SubjectRightKind.erasure,
      label: 'Erasure (right to be forgotten)',
      statutoryDeadlineDays: 30,
      internalTargetDays: 14,
      responseOwner: 'dpo',
      responseTemplateId: 'rights_response_erasure_v1',
      auditEntryKind: 'subject_rights.erasure.completed',
      requiresIdentityVerification: true,
      regulatoryRefs: ['GDPR Art. 17 erasure', 'KVKK md. 7 silme / yok etme'],
    ),
    SubjectRightRecord(
      kind: SubjectRightKind.restriction,
      label: 'Restriction of processing',
      statutoryDeadlineDays: 30,
      internalTargetDays: 7,
      responseOwner: 'dpo',
      responseTemplateId: 'rights_response_restriction_v1',
      auditEntryKind: 'subject_rights.restriction.completed',
      requiresIdentityVerification: true,
      regulatoryRefs: ['GDPR Art. 18 restriction'],
    ),
    SubjectRightRecord(
      kind: SubjectRightKind.portability,
      label: 'Data portability',
      statutoryDeadlineDays: 30,
      internalTargetDays: 14,
      responseOwner: 'dpo',
      responseTemplateId: 'rights_response_portability_v1',
      auditEntryKind: 'subject_rights.portability.completed',
      requiresIdentityVerification: true,
      regulatoryRefs: ['GDPR Art. 20 portability'],
    ),
    SubjectRightRecord(
      kind: SubjectRightKind.objection,
      label: 'Objection to processing',
      statutoryDeadlineDays: 30,
      internalTargetDays: 7,
      responseOwner: 'dpo',
      responseTemplateId: 'rights_response_objection_v1',
      auditEntryKind: 'subject_rights.objection.completed',
      requiresIdentityVerification: true,
      regulatoryRefs: ['GDPR Art. 21 objection', 'KVKK md. 11/h itiraz hakkı'],
    ),
    SubjectRightRecord(
      kind: SubjectRightKind.automatedDecision,
      label: 'Human review of automated decisions',
      statutoryDeadlineDays: 30,
      internalTargetDays: 5,
      responseOwner: 'dpo',
      responseTemplateId: 'rights_response_automated_decision_v1',
      auditEntryKind: 'subject_rights.automated_decision.completed',
      requiresIdentityVerification: true,
      regulatoryRefs: [
        'GDPR Art. 22 automated individual decision',
        'KVKK md. 11/g otomatik sistemler',
      ],
    ),
  ];

  static SubjectRightRecord? forKind(SubjectRightKind kind) {
    for (final r in rights) {
      if (r.kind == kind) return r;
    }
    return null;
  }
}

/// Days remaining until the statutory deadline given a [filedIso]
/// date and [today]. Negative when overdue. Drives the DPO
/// dashboard's "breach imminent" banner.
int daysUntilStatutoryDeadline({
  required SubjectRightRecord record,
  required String filedIso,
  required DateTime today,
}) {
  final filed = DateTime.parse(filedIso);
  final due = filed.add(Duration(days: record.statutoryDeadlineDays));
  return due.difference(today).inDays;
}

/// True when [today] is still inside the internal target window.
/// Drives "green / amber / red" colour on the DPO dashboard.
bool isWithinInternalTarget({
  required SubjectRightRecord record,
  required String filedIso,
  required DateTime today,
}) {
  final filed = DateTime.parse(filedIso);
  final target = filed.add(Duration(days: record.internalTargetDays));
  return !today.isAfter(target);
}
