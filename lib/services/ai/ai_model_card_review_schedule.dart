/// L7 — AI model card annual review schedule (pinned helper).
///
/// **Why this exists**: every model card registered in
/// `ai_model_card.dart` (L3) is a public commitment about a model's
/// intended use, limits, and risk profile. EU AI Act Art. 13
/// (transparency) + Art. 14 (human oversight) + FDA CDS Guidance
/// (clinical decision support) all require that commitment to be
/// re-evaluated as the model changes — Anthropic ships a new Claude,
/// our prompt registry adds a new task, the safety guard updates a
/// risk category. This catalog pins:
///   1. Which model cards must be re-reviewed each cycle.
///   2. Who signs the review (DPO + clinical advisor co-sign for
///      clinical-tier cards).
///   3. The reminder window so the cron fires 60 days before due.
///
/// **Out of scope** (separate PRs):
///   * Review-reminder Cloud Function.
///   * Trust-center widget rendering the schedule.
///   * Wire ai_model_card.dart to surface "last reviewed" per card
///     once L3 lands on main.
library;

/// Review cadence — most cards stay annual; clinical-tier moves to
/// semi-annual.
enum ModelCardReviewCadence { semiAnnual, annual }

/// One pinned review record.
class ModelCardReviewRecord {
  const ModelCardReviewRecord({
    required this.modelCardId,
    required this.cadence,
    required this.reviewerRoles,
    required this.reminderDaysBefore,
    required this.evidencePathTemplate,
    required this.regulatoryRefs,
  });

  /// Stable id matching `AiModelCard.id` in L3 — parity pinned
  /// against the known-good id set in tests.
  final String modelCardId;

  final ModelCardReviewCadence cadence;

  /// Multiple co-signers per card; clinical-tier requires DPO +
  /// clinical advisor. Single-role list also allowed for
  /// non-clinical cards.
  final List<String> reviewerRoles;

  /// How many days before the review deadline the reminder fires.
  /// MUST be > 0 and < cadence-in-days.
  final int reminderDaysBefore;

  final String evidencePathTemplate;
  final List<String> regulatoryRefs;
}

class AiModelCardReviewSchedule {
  const AiModelCardReviewSchedule._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned schedule. Append-only — deprecated cards stay so
  /// historic review logs resolve.
  static const List<ModelCardReviewRecord> reviews = [
    ModelCardReviewRecord(
      modelCardId: 'claude-3-5-sonnet-clinical-draft',
      cadence: ModelCardReviewCadence.semiAnnual,
      reviewerRoles: ['dpo', 'clinical_advisor'],
      reminderDaysBefore: 60,
      evidencePathTemplate:
          'docs/ai/cards/<YYYY-mm>/claude-3-5-sonnet-clinical-draft.MANUAL.md',
      regulatoryRefs: [
        'EU AI Act Art. 13 transparency',
        'EU AI Act Art. 14 human oversight',
        'FDA CDS Guidance (Sep 2022)',
        'MDR 745 Rule 11 Class IIa',
      ],
    ),
    ModelCardReviewRecord(
      modelCardId: 'claude-3-5-sonnet-soap-summary',
      cadence: ModelCardReviewCadence.semiAnnual,
      reviewerRoles: ['dpo', 'clinical_advisor'],
      reminderDaysBefore: 60,
      evidencePathTemplate:
          'docs/ai/cards/<YYYY-mm>/claude-3-5-sonnet-soap-summary.MANUAL.md',
      regulatoryRefs: [
        'EU AI Act Art. 13',
        'EU AI Act Art. 14',
        'FDA CDS Guidance (Sep 2022)',
      ],
    ),
    ModelCardReviewRecord(
      modelCardId: 'claude-3-5-sonnet-cssrs-triage',
      cadence: ModelCardReviewCadence.semiAnnual,
      reviewerRoles: ['dpo', 'clinical_advisor', 'ciso'],
      reminderDaysBefore: 60,
      evidencePathTemplate:
          'docs/ai/cards/<YYYY-mm>/claude-3-5-sonnet-cssrs-triage.MANUAL.md',
      regulatoryRefs: [
        'EU AI Act Annex III §5(b) safety component',
        'FDA CDS Guidance (Sep 2022)',
        'Joint Commission NPSG 15.01.01',
      ],
    ),
    ModelCardReviewRecord(
      modelCardId: 'llama-3-3-70b-rag-grounded',
      cadence: ModelCardReviewCadence.annual,
      reviewerRoles: ['dpo'],
      reminderDaysBefore: 60,
      evidencePathTemplate:
          'docs/ai/cards/<YYYY>/llama-3-3-70b-rag-grounded.MANUAL.md',
      regulatoryRefs: ['EU AI Act Art. 13 transparency'],
    ),
    ModelCardReviewRecord(
      modelCardId: 'no-show-predictor-v1',
      cadence: ModelCardReviewCadence.annual,
      reviewerRoles: ['dpo', 'product_lead'],
      reminderDaysBefore: 45,
      evidencePathTemplate:
          'docs/ai/cards/<YYYY>/no-show-predictor-v1.MANUAL.md',
      regulatoryRefs: ['EU AI Act Art. 13', 'GDPR Art. 22 automated decision'],
    ),
  ];

  static ModelCardReviewRecord? byModelCardId(String id) {
    for (final r in reviews) {
      if (r.modelCardId == id) return r;
    }
    return null;
  }
}

/// Days remaining until review is due. ISO date format `YYYY-MM-DD`.
/// Negative when overdue. Tests pin behaviour at +days / exact-day /
/// overdue boundaries.
int daysUntilModelCardReview({
  required ModelCardReviewRecord record,
  required String lastReviewedIso,
  required DateTime today,
}) {
  final last = DateTime.parse(lastReviewedIso);
  final cycleDays = record.cadence == ModelCardReviewCadence.semiAnnual
      ? 180
      : 365;
  final due = last.add(Duration(days: cycleDays));
  return due.difference(today).inDays;
}

/// True when [today] is inside the reminder window for the card.
bool isInModelCardReviewWindow({
  required ModelCardReviewRecord record,
  required String lastReviewedIso,
  required DateTime today,
}) {
  final left = daysUntilModelCardReview(
    record: record,
    lastReviewedIso: lastReviewedIso,
    today: today,
  );
  return left >= 0 && left <= record.reminderDaysBefore;
}
