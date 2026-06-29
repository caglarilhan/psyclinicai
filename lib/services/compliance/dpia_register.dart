/// N8 — DPIA register (pinned helper).
///
/// **Why this exists**: GDPR Art. 35 forces the controller to run a
/// Data Protection Impact Assessment for high-risk processing, and
/// Art. 35(11) forces a *review* "where necessary" — in practice
/// auditors expect a documented review cadence per DPIA. Today
/// the only DPIA narrative is `docs/compliance/DPIA_AI_ASSISTANCE.md`
/// (a single activity). This register pins every distinct high-risk
/// activity so:
///   1. A new high-risk activity cannot ship without a DPIA row +
///      the corresponding narrative in `docs/compliance/`.
///   2. The trust-center page renders the register with each DPIA's
///      next review date.
///   3. A weekly Cloud Function can flag DPIAs whose review window
///      is closing (60 days before `nextReviewIso`).
///
/// **Out of scope** (separate PRs):
///   * Cloud Function that emits the review-reminder cron.
///   * Trust-center widget rendering the register.
///   * Per-DPIA narrative markdown files (one already exists for
///     AI assistance; the others land as separate docs PRs).
library;

/// Art. 35(3) triggers that make a DPIA mandatory.
enum DpiaTrigger {
  /// 35(3)(a) — systematic + extensive evaluation that supports
  /// decisions about the data subject.
  systematicEvaluation,

  /// 35(3)(b) — large-scale processing of special-category data
  /// under Art. 9.
  largeScaleSpecialCategory,

  /// 35(3)(c) — systematic monitoring of publicly accessible areas
  /// on a large scale.
  systematicMonitoring,

  /// EDPB list trigger — innovative use / new technology applied to
  /// personal data.
  innovativeTechnology,

  /// EDPB list trigger — cross-border transfer to a third country
  /// without an adequacy decision.
  crossBorderTransfer,
}

/// Residual risk after mitigating controls are applied.
enum DpiaResidualRisk {
  /// Mitigated to a level that does not require Art. 36 prior
  /// consultation with the supervisory authority.
  low,

  /// Acceptable with continued monitoring; flagged on the trust
  /// page.
  medium,

  /// Triggers Art. 36 prior consultation before processing starts.
  high,
}

/// One pinned DPIA record.
class DpiaRecord {
  const DpiaRecord({
    required this.id,
    required this.activity,
    required this.triggers,
    required this.residualRisk,
    required this.firstDraftedIso,
    required this.nextReviewIso,
    required this.owner,
    required this.evidencePath,
    required this.ropaActivityId,
  });

  /// Stable id (`dpia-ai-assistance`, `dpia-telehealth`, etc.).
  final String id;

  /// Plain-English activity name shown on the trust page.
  final String activity;

  final List<DpiaTrigger> triggers;
  final DpiaResidualRisk residualRisk;

  /// First drafted date in ISO `YYYY-MM-DD`.
  final String firstDraftedIso;

  /// Next review deadline in ISO `YYYY-MM-DD`. MUST be ≤ 12 months
  /// from `firstDraftedIso` (annual cadence) for any record whose
  /// residual risk is medium or high.
  final String nextReviewIso;

  /// Single accountable owner (typically `dpo`).
  final String owner;

  /// Path to the per-DPIA narrative markdown.
  final String evidencePath;

  /// Cross-reference into the ROPA so a regulator can walk the
  /// Art. 30 register straight into the Art. 35 assessment.
  final String ropaActivityId;
}

class DpiaRegister {
  const DpiaRegister._();

  /// YYYY-MM stamp — drives the trust-page "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned DPIA register. Append-only; deprecated entries stay so
  /// historic regulator submissions still resolve.
  static const List<DpiaRecord> entries = [
    DpiaRecord(
      id: 'dpia-ai-assistance',
      activity: 'AI-assisted clinical documentation (Anthropic relay)',
      triggers: [
        DpiaTrigger.systematicEvaluation,
        DpiaTrigger.largeScaleSpecialCategory,
        DpiaTrigger.crossBorderTransfer,
        DpiaTrigger.innovativeTechnology,
      ],
      residualRisk: DpiaResidualRisk.medium,
      firstDraftedIso: '2026-06-02',
      nextReviewIso: '2027-06-02',
      owner: 'dpo',
      evidencePath: 'docs/compliance/DPIA_AI_ASSISTANCE.md',
      ropaActivityId: 'ai-assistance',
    ),
    DpiaRecord(
      id: 'dpia-telehealth',
      activity: 'Telehealth video + audio sessions',
      triggers: [
        DpiaTrigger.largeScaleSpecialCategory,
        DpiaTrigger.crossBorderTransfer,
      ],
      residualRisk: DpiaResidualRisk.medium,
      firstDraftedIso: '2026-06-26',
      nextReviewIso: '2027-06-26',
      owner: 'dpo',
      evidencePath: 'docs/compliance/DPIA_TELEHEALTH.md',
      ropaActivityId: 'telehealth',
    ),
    DpiaRecord(
      id: 'dpia-audio-transcription',
      activity: 'Session audio capture + on-device transcription',
      triggers: [
        DpiaTrigger.largeScaleSpecialCategory,
        DpiaTrigger.innovativeTechnology,
      ],
      residualRisk: DpiaResidualRisk.medium,
      firstDraftedIso: '2026-06-26',
      nextReviewIso: '2027-06-26',
      owner: 'dpo',
      evidencePath: 'docs/compliance/DPIA_AUDIO_TRANSCRIPTION.md',
      ropaActivityId: 'audio-recording',
    ),
    DpiaRecord(
      id: 'dpia-patient-portal',
      activity: 'Patient self-service portal (PWA)',
      triggers: [
        DpiaTrigger.largeScaleSpecialCategory,
        DpiaTrigger.systematicEvaluation,
      ],
      residualRisk: DpiaResidualRisk.low,
      firstDraftedIso: '2026-06-26',
      nextReviewIso: '2027-06-26',
      owner: 'dpo',
      evidencePath: 'docs/compliance/DPIA_PATIENT_PORTAL.md',
      ropaActivityId: 'patient-portal',
    ),
    DpiaRecord(
      id: 'dpia-billing',
      activity: 'Billing + payment (Stripe Connect)',
      triggers: [DpiaTrigger.crossBorderTransfer],
      residualRisk: DpiaResidualRisk.low,
      firstDraftedIso: '2026-06-26',
      nextReviewIso: '2027-06-26',
      owner: 'dpo',
      evidencePath: 'docs/compliance/DPIA_BILLING.md',
      ropaActivityId: 'billing',
    ),
  ];

  static DpiaRecord? byId(String id) {
    for (final r in entries) {
      if (r.id == id) return r;
    }
    return null;
  }
}

/// Days remaining until [record.nextReviewIso] from [today]. Negative
/// when the deadline has passed. Tests pin this so the reminder
/// Cloud Function can fire 60 days before due.
int daysUntilReview(DpiaRecord record, DateTime today) {
  final next = DateTime.parse(record.nextReviewIso);
  return next.difference(today).inDays;
}

/// True when the residual risk requires Art. 36 prior consultation
/// with the supervisory authority before processing starts.
bool requiresPriorConsultation(DpiaRecord record) =>
    record.residualRisk == DpiaResidualRisk.high;
