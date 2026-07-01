/// K12 — Cross-border transfer register (GDPR Chapter V pinned helper).
///
/// **Why this exists**: GDPR Art. 44–49 require the controller to
/// document EVERY data transfer outside the EU/EEA AND the lawful
/// basis for the transfer (adequacy decision, SCCs, DPF, derogation).
/// Today this lives in narrative form across the DPA + subprocessor
/// list; nothing pins the per-flow mapping. A new vendor add could
/// silently route PHI to a non-adequate jurisdiction.
///
/// Pins per (vendor × data class):
///   1. Source + destination jurisdiction.
///   2. Lawful transfer mechanism (adequacy / SCC / DPF / BCR /
///      derogation).
///   3. Supplementary measures (Schrems II) applied.
///   4. The TIA (Transfer Impact Assessment) reference doc.
///
/// **Distinct from**:
///   * K7 `data_classification_catalog` (PR #133): per-class
///     cross-border POLICY (allowed / forbidden); K12 = actual
///     per-flow RECORD.
///   * N6 `vendor_sla_catalog` (PR #128): per-vendor SLA; K12 =
///     per-vendor TRANSFER mechanism.
///
/// **Out of scope** (separate PRs):
///   * Auto-render DPA Annex II from this catalog.
///   * Trust-center transfer-map widget.
///   * Add a TransferImpactAssessment register for the TIA docs
///     themselves (today they live in docs/compliance/TIA_*.md).
library;

/// Lawful basis under GDPR Art. 44+.
enum TransferMechanism {
  /// Art. 45 — Commission adequacy decision. No SCCs needed.
  adequacyDecision,

  /// Art. 46(2)(c) — Standard Contractual Clauses (2021/914).
  /// Schrems II + supplementary measures required.
  standardContractualClauses,

  /// Art. 45(3) read against the EU-US Data Privacy Framework.
  /// Vendor must be self-certified.
  euUsDataPrivacyFramework,

  /// Art. 47 — Binding Corporate Rules (intra-group transfers).
  bindingCorporateRules,

  /// Art. 49 — Derogations for specific situations (rarely used).
  derogation,

  /// No transfer crosses a border — data stays inside EU/EEA.
  intraEea,
}

/// What sensitivity tier flows across the border.
enum TransferDataClass { phi, personalData, businessOps, publicData }

/// One pinned transfer record.
class TransferRecord {
  const TransferRecord({
    required this.id,
    required this.subprocessorId,
    required this.dataClass,
    required this.sourceJurisdiction,
    required this.destinationJurisdiction,
    required this.mechanism,
    required this.supplementaryMeasures,
    required this.tiaDocPath,
    required this.regulatoryRefs,
  });

  /// Stable id, e.g. `anthropic-phi-us`.
  final String id;

  /// MUST match an id in `SubprocessorRegistry`.
  final String subprocessorId;

  final TransferDataClass dataClass;

  /// Plain country / region name (e.g. `EU/EEA`, `United States`,
  /// `United Kingdom`).
  final String sourceJurisdiction;
  final String destinationJurisdiction;

  final TransferMechanism mechanism;

  /// Schrems II supplementary measures. Free-form list (e.g.
  /// "pseudonymisation before relay", "encryption at rest +
  /// in transit"). Empty for intra-EEA + adequacy-decision flows.
  final List<String> supplementaryMeasures;

  /// Path to the TIA narrative doc. `docs/compliance/TIA_*.md`.
  /// Empty when no TIA is required (intra-EEA + adequacy).
  final String tiaDocPath;

  final List<String> regulatoryRefs;
}

class CrossBorderTransferRegister {
  const CrossBorderTransferRegister._();

  /// YYYY-MM stamp — drives the "needs review" badge. Aligned with
  /// [SubprocessorRegistry.lastReviewed]. Bumped when the Groq/Gemini
  /// demo-tier transfers were added.
  static const String lastReviewed = '2026-07';

  /// Pinned register. Append-only — historical flows stay so the
  /// regulator's question "what was the basis on date X" resolves.
  static const List<TransferRecord> transfers = [
    TransferRecord(
      id: 'hetzner-phi-eu',
      subprocessorId: 'hetzner',
      dataClass: TransferDataClass.phi,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'EU/EEA',
      mechanism: TransferMechanism.intraEea,
      supplementaryMeasures: [],
      tiaDocPath: '',
      regulatoryRefs: ['No transfer mechanism required (Art. 44 N/A)'],
    ),
    TransferRecord(
      id: 'firebase-personal-eu',
      subprocessorId: 'firebase-auth',
      dataClass: TransferDataClass.personalData,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'EU/EEA',
      mechanism: TransferMechanism.intraEea,
      supplementaryMeasures: [],
      tiaDocPath: '',
      regulatoryRefs: ['EU multi-region Firestore + Auth (Art. 44 N/A)'],
    ),
    TransferRecord(
      id: 'anthropic-phi-us',
      subprocessorId: 'anthropic',
      dataClass: TransferDataClass.phi,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'United States',
      mechanism: TransferMechanism.standardContractualClauses,
      supplementaryMeasures: [
        'Pseudonymisation via PHI scrub before relay (L9)',
        'TLS 1.3 in transit',
        'No model training on PHI',
        'BYOK option (customer-controlled key)',
      ],
      tiaDocPath: 'docs/compliance/TIA_ANTHROPIC.md',
      regulatoryRefs: [
        'GDPR Art. 46(2)(c) SCC 2021/914 Module 2',
        'Schrems II (C-311/18)',
      ],
    ),
    TransferRecord(
      id: 'stripe-billing-us',
      subprocessorId: 'stripe',
      dataClass: TransferDataClass.businessOps,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'United States',
      mechanism: TransferMechanism.standardContractualClauses,
      supplementaryMeasures: [
        'PCI DSS v4.0 §3.2 storage controls',
        'No clinical content; billing metadata only',
      ],
      tiaDocPath: 'docs/compliance/TIA_STRIPE.md',
      regulatoryRefs: ['GDPR Art. 46(2)(c) SCC 2021/914', 'PCI DSS v4.0'],
    ),
    TransferRecord(
      id: 'sentry-business-us',
      subprocessorId: 'sentry',
      dataClass: TransferDataClass.businessOps,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'United States',
      mechanism: TransferMechanism.standardContractualClauses,
      supplementaryMeasures: [
        'PHI scrub before relay (L9)',
        'Source-map upload only — no user payloads',
      ],
      tiaDocPath: 'docs/compliance/TIA_SENTRY.md',
      regulatoryRefs: ['GDPR Art. 46(2)(c) SCC 2021/914'],
    ),
    TransferRecord(
      id: 'cloudflare-business-global',
      subprocessorId: 'cloudflare',
      dataClass: TransferDataClass.businessOps,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'Global edge (EU routing preferred)',
      mechanism: TransferMechanism.standardContractualClauses,
      supplementaryMeasures: [
        'EU SCCs + DPA',
        'Enterprise data localization (EU)',
      ],
      tiaDocPath: 'docs/compliance/TIA_CLOUDFLARE.md',
      regulatoryRefs: ['GDPR Art. 46(2)(c)'],
    ),
    // Demo-tier LLM providers — synthetic transcript text ONLY. Tenant
    // policy blocks these providers for workspaces that hold PHI, so
    // the transfer class stays at businessOps (synthetic vignettes are
    // not personal data). PHI-carrying tenants must switch to BYOK.
    TransferRecord(
      id: 'groq-demo-us',
      subprocessorId: 'groq',
      dataClass: TransferDataClass.businessOps,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'United States',
      mechanism: TransferMechanism.standardContractualClauses,
      supplementaryMeasures: [
        'Demo tier only — synthetic vignettes, no PHI, no personal data',
        'Tenant policy blocks Groq for PHI-carrying workspaces',
        'TLS 1.3 in transit',
      ],
      tiaDocPath: 'docs/compliance/TIA_GROQ.md',
      regulatoryRefs: [
        'GDPR Art. 46(2)(c) SCC 2021/914 Module 2',
        'Schrems II (C-311/18)',
      ],
    ),
    TransferRecord(
      id: 'gemini-demo-us',
      subprocessorId: 'google-gemini',
      dataClass: TransferDataClass.businessOps,
      sourceJurisdiction: 'EU/EEA',
      destinationJurisdiction: 'United States',
      mechanism: TransferMechanism.standardContractualClauses,
      supplementaryMeasures: [
        'Demo tier only — synthetic vignettes, no PHI, no personal data',
        'Tenant policy blocks Gemini for PHI-carrying workspaces',
        'TLS 1.3 in transit',
      ],
      tiaDocPath: 'docs/compliance/TIA_GEMINI.md',
      regulatoryRefs: [
        'GDPR Art. 46(2)(c) SCC 2021/914 Module 2',
        'Schrems II (C-311/18)',
      ],
    ),
  ];

  static TransferRecord? byId(String id) {
    for (final t in transfers) {
      if (t.id == id) return t;
    }
    return null;
  }

  static List<TransferRecord> bySubprocessor(String subprocessorId) {
    return transfers.where((t) => t.subprocessorId == subprocessorId).toList();
  }

  static List<TransferRecord> outsideEea() {
    return transfers
        .where((t) => t.mechanism != TransferMechanism.intraEea)
        .toList();
  }
}

/// True when the transfer requires a TIA narrative on file.
/// Intra-EEA + adequacy decisions are exempt.
bool requiresTia(TransferRecord t) {
  if (t.mechanism == TransferMechanism.intraEea) return false;
  if (t.mechanism == TransferMechanism.adequacyDecision) return false;
  return true;
}

/// True when the destination is outside the EU/EEA.
bool isCrossBorder(TransferRecord t) =>
    t.mechanism != TransferMechanism.intraEea;
