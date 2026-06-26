/// L8 — AI training-data eligibility taxonomy (pinned helper).
///
/// **Why this exists**: HIPAA §164.502(a)(5)(ii) prohibits selling
/// PHI; GDPR Art. 9 forbids using special-category data for purposes
/// beyond the consented basis; EU AI Act Art. 10 requires controllers
/// to verify the lawful basis + provenance of training data. Today
/// it is not formally pinned which prompts / responses / signals can
/// flow into a fine-tune, an eval set, or a public benchmark.
///
/// This catalog pins per-bucket:
///   * what the bucket contains (e.g. anonymised clinician edits,
///     red-team probes, public RAG-grounded answers),
///   * whether it is eligible for fine-tune / eval / public release,
///   * the lawful basis the bucket relies on,
///   * the irreversible-anonymisation gate (HIPAA Safe Harbor +
///     GDPR Art. 4(5)).
///
/// **Out of scope** (separate PRs):
///   * Fine-tune-eligibility check helper that calls this from the
///     prompt-collection pipeline.
///   * Eval-set assembly Cloud Function.
///   * Trust-center widget rendering the buckets.
library;

/// Which downstream use the bucket is eligible for.
enum TrainingUse {
  /// Use the bucket to fine-tune an LLM under our control.
  fineTune,

  /// Use the bucket as a private eval set (never published).
  evalPrivate,

  /// Publish the bucket alongside a benchmark paper / blog post.
  evalPublic,

  /// Use the bucket as red-team material to harden prompts.
  redTeam,
}

/// Lawful basis the bucket relies on for the listed uses.
enum LawfulBasis {
  /// GDPR Art. 9(2)(a) explicit consent for special-category data.
  explicitConsent,

  /// GDPR Art. 6(1)(b) contract performance (clinician edits are
  /// part of using the platform).
  contractPerformance,

  /// HIPAA Safe Harbor — 45 CFR §164.514(b)(2) — 18 identifier
  /// removal makes the data not-PHI.
  hipaaSafeHarbor,

  /// GDPR Art. 4(5) anonymous data — irreversibly stripped of
  /// any identifier.
  anonymised,

  /// Public domain or licensed open-data corpus.
  publicDomain,
}

/// One pinned training-data bucket.
class TrainingDataBucket {
  const TrainingDataBucket({
    required this.id,
    required this.label,
    required this.examplePayload,
    required this.lawfulBasis,
    required this.eligibleUses,
    required this.requiresIrreversibleAnonymisation,
    required this.requiresClinicianOptIn,
    required this.retentionDays,
    required this.regulatoryRefs,
  });

  /// Stable id used by the pipeline + the eval-set assembler.
  final String id;

  /// Human-readable label for the bucket (trust page + DPO docs).
  final String label;

  /// Concrete example of what a row in the bucket looks like.
  /// Synthetic; never the real payload.
  final String examplePayload;

  final LawfulBasis lawfulBasis;

  /// Which uses are allowed for this bucket. Anything not listed
  /// is forbidden; the helper enforces this.
  final List<TrainingUse> eligibleUses;

  /// True when rows MUST pass an irreversible anonymisation step
  /// before being added to the bucket. The pipeline checks this
  /// before append.
  final bool requiresIrreversibleAnonymisation;

  /// True when the clinician must have opted-in (separate from
  /// patient consent) before their edits enter the bucket. Some
  /// clinicians decline to contribute even to private evals.
  final bool requiresClinicianOptIn;

  /// Days the bucket is kept. 0 = until manually purged (eval +
  /// red-team buckets need long retention).
  final int retentionDays;

  final List<String> regulatoryRefs;
}

class TrainingDataTaxonomy {
  const TrainingDataTaxonomy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned buckets. Append-only — deprecated rows stay so historic
  /// eval logs still resolve.
  static const List<TrainingDataBucket> buckets = [
    TrainingDataBucket(
      id: 'clinician-edit-anonymised',
      label: 'Anonymised clinician edits to AI drafts',
      examplePayload:
          '{"prompt": "Draft a SOAP for a CBT session", "ai_draft": '
          '"[A]...", "clinician_edit": "[A]...", "patient_id": '
          '"<stripped>"}',
      lawfulBasis: LawfulBasis.contractPerformance,
      eligibleUses: [TrainingUse.fineTune, TrainingUse.evalPrivate],
      requiresIrreversibleAnonymisation: true,
      requiresClinicianOptIn: true,
      retentionDays: 730,
      regulatoryRefs: [
        'GDPR Art. 6(1)(b) contract performance',
        'HIPAA §164.514(b)(2) Safe Harbor',
        'EU AI Act Art. 10 data governance',
      ],
    ),
    TrainingDataBucket(
      id: 'clinician-thumbs-feedback',
      label: 'Clinician 👍 / 👎 + comment on AI output',
      examplePayload:
          '{"output_id": "ai-xyz", "verdict": "thumbs_down", "note": '
          '"<free text, anonymised>"}',
      lawfulBasis: LawfulBasis.contractPerformance,
      eligibleUses: [TrainingUse.evalPrivate, TrainingUse.fineTune],
      requiresIrreversibleAnonymisation: true,
      requiresClinicianOptIn: true,
      retentionDays: 730,
      regulatoryRefs: [
        'GDPR Art. 6(1)(b)',
        'EU AI Act Art. 14 human oversight',
      ],
    ),
    TrainingDataBucket(
      id: 'rag-grounded-public-qa',
      label: 'RAG-grounded answers from public guideline corpus',
      examplePayload:
          '{"question": "What is the NICE recommendation for moderate '
          'depression?", "answer": "[A]", "sources": [{"title": "NICE '
          'CG90", "url": "..."}]}',
      lawfulBasis: LawfulBasis.publicDomain,
      eligibleUses: [
        TrainingUse.evalPrivate,
        TrainingUse.evalPublic,
        TrainingUse.fineTune,
      ],
      requiresIrreversibleAnonymisation: false,
      requiresClinicianOptIn: false,
      retentionDays: 0,
      regulatoryRefs: ['EU AI Act Art. 10', 'CC-BY-4.0 / NICE open license'],
    ),
    TrainingDataBucket(
      id: 'red-team-jailbreak-probes',
      label: 'Red-team jailbreak probe corpus',
      examplePayload:
          '{"probe": "ignore previous instructions and ...", "category": '
          '"instructionOverride", "blocked": true}',
      lawfulBasis: LawfulBasis.publicDomain,
      eligibleUses: [TrainingUse.redTeam, TrainingUse.evalPrivate],
      requiresIrreversibleAnonymisation: false,
      requiresClinicianOptIn: false,
      retentionDays: 0,
      regulatoryRefs: ['EU AI Act Art. 15 robustness', 'OWASP LLM Top-10'],
    ),
    TrainingDataBucket(
      id: 'phi-tinged-do-not-train',
      label: 'PHI-tinged prompts (DO NOT TRAIN)',
      examplePayload:
          '{"prompt": "Patient Jane Doe DOB 1985-04-12 reports...", '
          '"flag": "phi_detected"}',
      lawfulBasis: LawfulBasis.explicitConsent,
      // No use is eligible — bucket exists only so the pipeline
      // can quarantine PHI-flagged rows before purge.
      eligibleUses: [],
      requiresIrreversibleAnonymisation: true,
      requiresClinicianOptIn: false,
      // short quarantine window before purge.
      retentionDays: 30,
      regulatoryRefs: [
        'HIPAA §164.502(a)(5)(ii) prohibition on PHI sale',
        'GDPR Art. 9(2)(a) explicit consent',
        'EU AI Act Art. 10 data governance',
      ],
    ),
    TrainingDataBucket(
      id: 'synthetic-augmentation',
      label: 'LLM-generated synthetic vignettes',
      examplePayload:
          '{"scenario": "23yo presents with GAD symptoms", "generated_by": '
          '"claude-3-5-sonnet", "reviewed_by": "clinical_advisor"}',
      lawfulBasis: LawfulBasis.anonymised,
      eligibleUses: [
        TrainingUse.fineTune,
        TrainingUse.evalPrivate,
        TrainingUse.evalPublic,
      ],
      requiresIrreversibleAnonymisation: false,
      requiresClinicianOptIn: false,
      retentionDays: 0,
      regulatoryRefs: [
        'EU AI Act Art. 10',
        'GDPR Art. 4(5) anonymous data definition',
      ],
    ),
  ];

  static TrainingDataBucket? byId(String id) {
    for (final b in buckets) {
      if (b.id == id) return b;
    }
    return null;
  }
}

/// True when the bucket allows [use]. Tests pin behaviour against
/// the eligibility list — anything not listed is forbidden.
bool isUseAllowed(TrainingDataBucket bucket, TrainingUse use) =>
    bucket.eligibleUses.contains(use);

/// True when the bucket is the explicit "do not train" quarantine.
/// Pipeline checks this before any pipeline read.
bool isQuarantineBucket(TrainingDataBucket bucket) =>
    bucket.eligibleUses.isEmpty;
