/// L12 — AI clinician override audit policy (pinned helper).
///
/// **Why this exists**: L11 hallucination warning catalog tells the
/// AI review UI which warnings force a `block`, force a `verify`,
/// or are `acceptWithCaveat`. But clinicians are the licensed
/// decision-makers — they can OVERRIDE the AI verdict. EU AI Act
/// Art. 14 (human oversight) and FDA CDS Guidance (Sep 2022)
/// explicitly require that the human can refuse, edit, or pass-
/// through the AI suggestion. The audit trail of that override is
/// the regulatory artifact that proves human oversight is real and
/// not theatrical.
///
/// This catalog pins per override outcome:
///   1. Outcome (acceptedSuggestion / editedSuggestion /
///      rejectedSuggestion / overrodeBlock).
///   2. Whether the override REQUIRES a clinician justification
///      string (`requiresJustification`).
///   3. Whether the override is `secondReviewerRequired` (four-
///      eyes on patient-harm blocks).
///   4. Audit retention class (regulatory minimum + clinical use).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * L4 decision_logger — logs every AI inference; L12 logs the
///     clinician's response to the inference.
///   * L7 model_card — describes the model's capabilities + limits;
///     L12 captures real-world override rate as oversight evidence.
///   * L11 hallucination_warning_catalog — what the AI surfaces to
///     the clinician; L12 what the clinician does back.
///
/// **Out of scope** (separate PRs):
///   * Override rate analytics dashboard.
///   * Two-person review workflow UI (N18 workflow tie-in).
///   * Override pattern drift detector (L7 model card update gate).
library;

/// What the clinician did with the AI verdict.
enum OverrideOutcome {
  /// Accepted the AI suggestion verbatim.
  acceptedSuggestion,

  /// Edited the AI suggestion before publishing.
  editedSuggestion,

  /// Rejected the AI suggestion and wrote their own.
  rejectedSuggestion,

  /// Overrode a `block` verdict from L11 — published anyway.
  /// Highest scrutiny.
  overrodeBlock,

  /// Overrode a `verify` verdict — published without external
  /// cross-reference. Medium scrutiny.
  overrodeVerify,
}

/// Audit retention class — drives Firestore TTL + cold-storage
/// promotion.
enum OverrideRetentionClass {
  /// 1 year hot, 6 years cold. Default for routine accept/edit.
  routineClinical,

  /// 6 years hot, 25 years cold. For `overrodeBlock` + suicide-risk
  /// linked overrides. Matches HIPAA §164.316(b)(2)(i) +
  /// Joint Commission record retention.
  patientSafetyCritical,
}

/// One pinned override policy.
class OverrideAuditRecord {
  const OverrideAuditRecord({
    required this.id,
    required this.outcome,
    required this.description,
    required this.requiresJustification,
    required this.secondReviewerRequired,
    required this.retention,
    required this.regulatoryRefs,
  });

  final String id;
  final OverrideOutcome outcome;

  /// Plain-English description shown in the override UI.
  final String description;

  /// True when the clinician MUST type a free-form reason before
  /// the override is recorded. Tests pin which outcomes require it.
  final bool requiresJustification;

  /// True when a second licensed clinician MUST co-sign the
  /// override before publish (four-eyes). Reserved for the
  /// patient-harm escalation lane.
  final bool secondReviewerRequired;

  final OverrideRetentionClass retention;

  final List<String> regulatoryRefs;
}

class ClinicianOverrideAuditPolicy {
  const ClinicianOverrideAuditPolicy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policy table. Append-only.
  static const List<OverrideAuditRecord> records = [
    OverrideAuditRecord(
      id: 'accepted-suggestion',
      outcome: OverrideOutcome.acceptedSuggestion,
      description:
          'Clinician accepted the AI suggestion verbatim. Audit logs the inference id + clinician id + timestamp only.',
      requiresJustification: false,
      secondReviewerRequired: false,
      retention: OverrideRetentionClass.routineClinical,
      regulatoryRefs: [
        'EU AI Act Art. 14 human oversight (accept is still an oversight act)',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    OverrideAuditRecord(
      id: 'edited-suggestion',
      outcome: OverrideOutcome.editedSuggestion,
      description:
          'Clinician edited the AI suggestion before publishing. Audit logs the inference id, before/after diff, clinician id, timestamp.',
      requiresJustification: false,
      secondReviewerRequired: false,
      retention: OverrideRetentionClass.routineClinical,
      regulatoryRefs: [
        'EU AI Act Art. 14 human oversight',
        'HIPAA §164.312(b) audit controls',
      ],
    ),
    OverrideAuditRecord(
      id: 'rejected-suggestion',
      outcome: OverrideOutcome.rejectedSuggestion,
      description:
          'Clinician rejected the AI suggestion entirely. Justification REQUIRED so model card can learn from rejection patterns.',
      requiresJustification: true,
      secondReviewerRequired: false,
      retention: OverrideRetentionClass.routineClinical,
      regulatoryRefs: [
        'EU AI Act Art. 14 human oversight',
        'EU AI Act Art. 13 transparency (rejection feeds back into post-market monitoring)',
      ],
    ),
    OverrideAuditRecord(
      id: 'overrode-block',
      outcome: OverrideOutcome.overrodeBlock,
      description:
          'Clinician overrode an L11 `block` verdict (e.g. fabricated medication / demographic confusion / internal contradiction). Highest scrutiny — both justification and second-reviewer required.',
      requiresJustification: true,
      secondReviewerRequired: true,
      retention: OverrideRetentionClass.patientSafetyCritical,
      regulatoryRefs: [
        'FDA CDS Guidance (Sep 2022) — software functions intended to inform clinical management',
        'Joint Commission NPSG 03.06.01 / 01.01.01 / 15.01.01',
        'EU AI Act Art. 14 human oversight + Annex III §5(b)',
        'HIPAA §164.316(b)(2)(i) 6-year retention',
      ],
    ),
    OverrideAuditRecord(
      id: 'overrode-verify',
      outcome: OverrideOutcome.overrodeVerify,
      description:
          'Clinician overrode an L11 `verify` verdict (e.g. fabricated citation / DSM code) without external cross-reference. Justification REQUIRED; second reviewer not mandatory.',
      requiresJustification: true,
      secondReviewerRequired: false,
      retention: OverrideRetentionClass.routineClinical,
      regulatoryRefs: [
        'EU AI Act Art. 14 human oversight',
        'COPE 2019 citation best practice',
      ],
    ),
  ];

  static OverrideAuditRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static OverrideAuditRecord? byOutcome(OverrideOutcome o) {
    for (final r in records) {
      if (r.outcome == o) return r;
    }
    return null;
  }
}

/// True when the outcome demands a free-form clinician
/// justification before being recorded.
bool requiresJustification(OverrideOutcome o) {
  final r = ClinicianOverrideAuditPolicy.byOutcome(o);
  return r?.requiresJustification ?? false;
}

/// True when a second licensed clinician must co-sign the override
/// before publish (four-eyes patient-harm escalation lane).
bool requiresSecondReviewer(OverrideOutcome o) {
  final r = ClinicianOverrideAuditPolicy.byOutcome(o);
  return r?.secondReviewerRequired ?? false;
}
