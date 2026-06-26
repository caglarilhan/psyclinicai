/// K13 — Data subject identity verification policy (pinned helper).
///
/// **Why this exists**: K8 SubjectRightsTaxonomy (PR #137) records
/// that EVERY right requires identity verification (`requiresIdentity
/// Verification: true`). What it doesn't pin is HOW. GDPR Recital
/// 64 says the controller must verify "by reasonable means", KVKK
/// md. 13 same — but reasonable means depend on the channel
/// (signed-in portal vs cold email vs phone). Pinning the policy
/// here means:
///   1. The DSAR handler picks the right proof set per channel.
///   2. The DPO dashboard renders a deterministic checklist.
///   3. A request from a brand-new channel cannot bypass the
///      check — the wrap rejects it until a row is added.
///
/// **Distinct from**:
///   * K8 SubjectRightsTaxonomy: WHAT rights + SLA; K13 = HOW
///     to verify the requester before fulfilling.
///   * Auth / passkey services: those verify the LIVE session;
///     K13 verifies an out-of-band data-subject request.
///
/// **Out of scope** (separate PRs):
///   * DSAR intake UI per channel.
///   * Cloud Function that drives the verification workflow.
///   * Magic-link issuance + audit-log entry per check.
library;

/// Which channel the data-subject request arrived through.
enum RequestChannel {
  /// Signed-in patient portal — strongest signal.
  authenticatedPortal,

  /// Email to dpo@ or privacy@ — verified against the account email.
  registeredEmail,

  /// Phone call — voice + recall question.
  phoneCall,

  /// Postal letter — slowest + lowest signal.
  postalLetter,

  /// Authorised representative (lawyer, parent) — power of attorney
  /// + child evidence.
  authorisedRepresentative,
}

/// What proof level a check produces.
enum VerificationProof {
  /// Already authenticated via the portal session (best).
  liveSession,

  /// Magic-link sent to the account-on-file email + clicked.
  magicLink,

  /// Voice recall question matched against on-file data.
  voiceRecall,

  /// Government-issued photo ID checked against the patient
  /// record (used for postal + representative).
  governmentIdMatch,

  /// Power-of-attorney + child birth certificate (representative
  /// path only).
  powerOfAttorneyDoc,
}

/// One pinned verification policy.
class VerificationPolicyRecord {
  const VerificationPolicyRecord({
    required this.channel,
    required this.requiredProofs,
    required this.maxTurnaroundHours,
    required this.fallbackOnFail,
    required this.regulatoryRefs,
  });

  final RequestChannel channel;

  /// Proofs the handler MUST collect before fulfilling. All listed
  /// proofs are required (AND). Order is presentational only.
  final List<VerificationProof> requiredProofs;

  /// Max hours from request receipt to the verification step
  /// being done. Falls inside K8 internal target.
  final int maxTurnaroundHours;

  /// What channel the requester is bumped to when proof fails.
  /// `null` when the channel itself is the floor.
  final RequestChannel? fallbackOnFail;

  final List<String> regulatoryRefs;
}

class IdentityVerificationPolicy {
  const IdentityVerificationPolicy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policies. Parity with RequestChannel.values; tests
  /// enforce it.
  static const List<VerificationPolicyRecord> policies = [
    VerificationPolicyRecord(
      channel: RequestChannel.authenticatedPortal,
      requiredProofs: [VerificationProof.liveSession],
      maxTurnaroundHours: 0,
      fallbackOnFail: null,
      regulatoryRefs: [
        'GDPR Recital 64 reasonable means',
        'GDPR Art. 12(6) further info if doubt',
      ],
    ),
    VerificationPolicyRecord(
      channel: RequestChannel.registeredEmail,
      requiredProofs: [VerificationProof.magicLink],
      maxTurnaroundHours: 24,
      fallbackOnFail: RequestChannel.phoneCall,
      regulatoryRefs: ['GDPR Recital 64', 'KVKK md. 13 başvuru yönetmeliği'],
    ),
    VerificationPolicyRecord(
      channel: RequestChannel.phoneCall,
      requiredProofs: [VerificationProof.voiceRecall],
      maxTurnaroundHours: 48,
      fallbackOnFail: RequestChannel.postalLetter,
      regulatoryRefs: ['GDPR Recital 64', 'KVKK md. 13'],
    ),
    VerificationPolicyRecord(
      channel: RequestChannel.postalLetter,
      // Postal channel has the lowest baseline — require both gov
      // ID match AND magic-link to the on-file email before any
      // PHI is released.
      requiredProofs: [
        VerificationProof.governmentIdMatch,
        VerificationProof.magicLink,
      ],
      maxTurnaroundHours: 240,
      fallbackOnFail: null,
      regulatoryRefs: ['GDPR Recital 64', 'KVKK md. 13'],
    ),
    VerificationPolicyRecord(
      channel: RequestChannel.authorisedRepresentative,
      requiredProofs: [
        VerificationProof.powerOfAttorneyDoc,
        VerificationProof.governmentIdMatch,
        VerificationProof.magicLink,
      ],
      maxTurnaroundHours: 168,
      fallbackOnFail: null,
      regulatoryRefs: [
        'GDPR Recital 64',
        'GDPR Art. 8 child consent (parent path)',
        'KVKK md. 13',
      ],
    ),
  ];

  static VerificationPolicyRecord forChannel(RequestChannel c) {
    for (final p in policies) {
      if (p.channel == c) return p;
    }
    throw StateError('No verification policy for ${c.name}');
  }
}

/// True when the policy demands MORE than one proof (high-risk
/// channels). Drives the "two-step verification required" banner.
bool requiresMultipleProofs(VerificationPolicyRecord p) =>
    p.requiredProofs.length >= 2;

/// True when [proof] satisfies (is in) [policy.requiredProofs].
bool satisfiesProof({
  required VerificationPolicyRecord policy,
  required VerificationProof proof,
}) {
  return policy.requiredProofs.contains(proof);
}
