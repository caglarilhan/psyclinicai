/// L3 — AI Model Card registry.
///
/// **Why this exists**: AI Act Annex IV + MDR 745 Annex II + FDA
/// Clinical Decision Support Guidance all expect the SaMD sponsor
/// to publish a model card per LLM the device calls into. The card
/// covers: who made the model, what we use it for, what data it
/// was trained on (vendor attestation, not our claim), the risk
/// class our use falls under, and the safeguards we ship around
/// it (PHI scrub, consent gate, output gate, audit ledger).
///
/// **PsyClinicAI's classification**: a clinician-facing decision-
/// support tool that surfaces options for clinician review.
///   * EU AI Act → Annex III(5) "high-risk" if used for healthcare
///     access decisions; we are NOT — we surface CLINICAL options
///     to a licensed clinician who is the decision-maker. We treat
///     ourselves as **limited-risk** + transparency obligations
///     (Art. 50) — every AI output carries an [AiDisclaimer].
///   * MDR 745 → likely Rule 11 Class IIa once the formal
///     classification opinion lands; this PR pre-stages the
///     evidence pack.
///   * FDA CDS Guidance (Sep 2022) → "non-device CDS" because the
///     clinician can independently evaluate every output (basis +
///     criteria provided), is not time-critical, and is licensed.
///
/// Each card pins:
///   * `modelId` — the exact string passed to the vendor API.
///   * `vendor` — Anthropic / OpenAI / Google.
///   * `intendedUse` — one-sentence clinical task.
///   * `trainingDataAttestation` — link to vendor's data card.
///   * `riskClass` — our classification rationale (see above).
///   * `safeguards` — the in-app gates that wrap the call.
library;

class AiModelCard {
  const AiModelCard({
    required this.modelId,
    required this.vendor,
    required this.intendedUse,
    required this.trainingDataAttestation,
    required this.riskClass,
    required this.safeguards,
  });

  final String modelId;
  final String vendor;
  final String intendedUse;
  final String trainingDataAttestation;
  final String riskClass;

  /// Names of the in-app gates this model's calls flow through.
  /// Pinned list so a future PR removing a gate trips the
  /// audit-evidence diff loudly.
  final List<String> safeguards;
}

class AiModelCardRegistry {
  const AiModelCardRegistry._();

  /// Cards for every LLM the app calls. Append-only; deprecated
  /// models keep their card so historic audit rows still resolve.
  static const List<AiModelCard> cards = [
    AiModelCard(
      modelId: 'claude-haiku-4-5-20251001',
      vendor: 'Anthropic PBC',
      intendedUse:
          'Decision-support drafting for clinician-reviewed '
          'artifacts: safety plans, SMART treatment goals, '
          'differential diagnosis candidates, clinical chat.',
      trainingDataAttestation:
          'https://www.anthropic.com/model-cards/haiku-4-5',
      riskClass:
          'Limited-risk (EU AI Act Art. 50 transparency) + non-'
          'device CDS (FDA Sep 2022). Clinician is the decision-'
          'maker; every output is surfaced with [AiDisclaimer] and '
          'editable before persistence.',
      safeguards: [
        'ConsentGuard.requireAi (PR I2 — patient-side consent gate)',
        'PromptSafety.fence (B7 — clinician input not in system role)',
        'requireSafeOutput (L1 — lethal-means / PHI classifier)',
        'recordAiDecision (L4 — audit ledger row per call)',
        'AiDisclaimer (L5 — clinician-owns-decision banner)',
      ],
    ),
  ];

  /// Look up by modelId. Returns null when the model is not
  /// registered — caller should fail loud rather than emit calls
  /// to an undocumented model.
  static AiModelCard? forModelId(String modelId) {
    for (final c in cards) {
      if (c.modelId == modelId) return c;
    }
    return null;
  }
}
