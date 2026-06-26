/// K6 helper — pinned copy + regulatory anchor + UX policy for each
/// [ConsentKind].
///
/// **Why this exists**: every consent surface (intake form, consent
/// center modal, DSAR export header, audit-log row) must (a) name the
/// consent, (b) cite the law it implements, (c) tell the patient what
/// happens on revoke, and (d) decide whether the surface is opt-in or
/// opt-out by default. Pinning that in one place keeps the surfaces
/// from diverging — a copy change here triggers tests that fail at
/// build time if a kind is missed.
///
/// **Out of scope** (separate PRs):
///   * K6 UI modals per kind (HIPAA NOPP / GDPR / AI / audio /
///     telehealth / marketing).
///   * Per-kind audit log entry templates.
///   * DSAR export per-kind header rows.
library;

import '../../models/consent_entry.dart';

/// Default presentation policy for the consent surface.
enum ConsentDefaultPolicy {
  /// User MUST take a positive action to grant. The legal-floor for
  /// special-category data under GDPR Art. 9 + KVKK md. 6.
  explicitOptIn,

  /// Granted by default but revocable. Only acceptable for non-PHI
  /// optional services like product marketing email.
  optOut,

  /// Granted as a consequence of accepting the underlying service
  /// agreement (e.g. HIPAA NOPP acknowledgment is gated by sign-up).
  serviceAgreementGated,
}

/// Pinned record per consent kind.
class ConsentKindRecord {
  const ConsentKindRecord({
    required this.kind,
    required this.modalTitle,
    required this.modalSummary,
    required this.regulatoryRefs,
    required this.defaultPolicy,
    required this.requiresClinicianCountersign,
    required this.revocationSlaHours,
  });

  final ConsentKind kind;

  /// Modal heading shown to the patient. Localised separately; this
  /// is the English canonical (KVKK record is in Turkish).
  final String modalTitle;

  /// One-paragraph summary the patient reads before acknowledging.
  /// The full text lives in `assets/legal/<kind>.md`; this is the
  /// "what am I agreeing to" tldr.
  final String modalSummary;

  /// Laws + standards the consent is grounded in. Audited by the
  /// DPO + counsel.
  final List<String> regulatoryRefs;

  /// How the surface should present this consent by default.
  final ConsentDefaultPolicy defaultPolicy;

  /// True when revoking the consent has clinical-care implications
  /// that a clinician must acknowledge in the audit trail (e.g.
  /// closing the chart after GDPR revocation).
  final bool requiresClinicianCountersign;

  /// Max time from a valid revoke request to the downstream effect
  /// taking hold. GDPR Art. 7(3) says "as easy to withdraw as to
  /// give"; KVKK md. 7 says "ivedilikle" (without delay) — we hold
  /// ourselves to a numeric SLA per kind.
  final int revocationSlaHours;
}

class ConsentKindCatalog {
  const ConsentKindCatalog._();

  /// YYYY-MM stamp — drives the trust-page "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned per-kind metadata. Order MUST match `ConsentKind.values`
  /// so a future enum addition fails the parity test rather than
  /// silently shipping without copy.
  static const List<ConsentKindRecord> entries = [
    ConsentKindRecord(
      kind: ConsentKind.hipaaNopp,
      modalTitle: 'HIPAA Notice of Privacy Practices',
      modalSummary:
          'We use and disclose your protected health information only as '
          'permitted by HIPAA — to treat you, to bill for care, and for '
          'limited healthcare-operations purposes. You can ask for a copy '
          'of your record, request corrections, or restrict certain '
          'disclosures at any time.',
      regulatoryRefs: [
        'HIPAA Privacy Rule 45 CFR §164.520 (Notice of Privacy Practices)',
        'HIPAA §164.524 right of access',
        'HIPAA §164.526 right to amend',
      ],
      defaultPolicy: ConsentDefaultPolicy.serviceAgreementGated,
      requiresClinicianCountersign: false,
      revocationSlaHours: 72,
    ),
    ConsentKindRecord(
      kind: ConsentKind.gdprProcessing,
      modalTitle: 'GDPR — processing of your health data',
      modalSummary:
          'We process your health data to provide your clinical care and '
          'comply with our legal duties. You can withdraw consent, ask for '
          'a copy, correct errors, or request erasure under GDPR Art. 15–'
          '17 at any time. Withdrawing this consent typically means the '
          'platform can no longer host your chart.',
      regulatoryRefs: [
        'GDPR Art. 6(1)(a) consent',
        'GDPR Art. 9(2)(a) explicit consent for health data',
        'GDPR Art. 7(3) withdrawal as easy as granting',
        'GDPR Art. 13 information at collection',
      ],
      defaultPolicy: ConsentDefaultPolicy.explicitOptIn,
      requiresClinicianCountersign: true,
      revocationSlaHours: 72,
    ),
    ConsentKindRecord(
      kind: ConsentKind.kvkkSpecialCategoryHealth,
      modalTitle: 'KVKK md. 6 — Özel nitelikli sağlık verisi açık rızası',
      modalSummary:
          'Özel nitelikli sağlık verilerinizi (tanı, tedavi notları, '
          'görüşme kayıtları) işleyebilmemiz için açık rızanız gerekir. '
          'Bu rızayı her zaman geri çekebilirsiniz; geri çekme talebi '
          'KVKK md. 7 uyarınca silme/yok etme prosedürünü tetikler ve '
          'klinisyenin dosyaya erişimini durdurur.',
      regulatoryRefs: [
        'KVKK md. 6 özel nitelikli kişisel verilerin işlenmesi',
        'KVKK md. 6/2 — açık rıza',
        'KVKK md. 7 silme / yok etme',
        'KVKK md. 11 ilgili kişinin hakları',
      ],
      defaultPolicy: ConsentDefaultPolicy.explicitOptIn,
      requiresClinicianCountersign: true,
      revocationSlaHours: 24,
    ),
    ConsentKindRecord(
      kind: ConsentKind.aiProcessing,
      modalTitle: 'AI-assisted documentation',
      modalSummary:
          'With your consent, our platform may use AI to draft session '
          'notes, summarise outcomes, and surface clinical suggestions for '
          'your clinician to review. AI suggestions are never the final '
          'decision and are tagged in the chart. You can turn AI assistance '
          'off at any time without affecting your care.',
      regulatoryRefs: [
        'EU AI Act Art. 14 human oversight (Annex III §5(b))',
        'FDA CDS Guidance Sep 2022',
        'GDPR Art. 22 automated decision-making',
      ],
      defaultPolicy: ConsentDefaultPolicy.explicitOptIn,
      requiresClinicianCountersign: false,
      revocationSlaHours: 1,
    ),
    ConsentKindRecord(
      kind: ConsentKind.audioRecording,
      modalTitle: 'Session audio recording',
      modalSummary:
          'With your consent, we record the audio of your session so your '
          'clinician can review it later and so the platform can generate '
          'a transcript. Recordings are encrypted at rest and only your '
          'clinician + you can access them. You can revoke at any time; '
          'recording stops within an hour and existing recordings are '
          'deleted within 30 days unless your clinician opts to retain '
          'specific files under their professional obligations.',
      regulatoryRefs: [
        'GDPR Art. 9(2)(a) explicit consent',
        'HIPAA §164.508 authorization (when audio is used beyond TPO)',
        'KVKK md. 6/2',
      ],
      defaultPolicy: ConsentDefaultPolicy.explicitOptIn,
      requiresClinicianCountersign: false,
      revocationSlaHours: 1,
    ),
    ConsentKindRecord(
      kind: ConsentKind.telehealth,
      modalTitle: 'Telehealth sessions',
      modalSummary:
          'You consent to receiving care via secure video / phone sessions, '
          'including the privacy and connection risks specific to remote '
          'care. You can switch to in-person care at any time without '
          'affecting your therapeutic relationship.',
      regulatoryRefs: [
        'HHS Telehealth notice (April 2023 PHE end)',
        'State telehealth informed-consent statutes (varies)',
        'GDPR Art. 6(1)(a)',
      ],
      defaultPolicy: ConsentDefaultPolicy.explicitOptIn,
      requiresClinicianCountersign: false,
      revocationSlaHours: 24,
    ),
    ConsentKindRecord(
      kind: ConsentKind.marketing,
      modalTitle: 'Product updates + research invitations',
      modalSummary:
          'With your permission, we email you product updates, optional '
          'research invitations, and occasional newsletters. We never use '
          'your clinical content for marketing. Unsubscribe at any time '
          'from the link in every email.',
      regulatoryRefs: [
        'GDPR Art. 6(1)(a) consent',
        'CAN-SPAM Act §7704 unsubscribe',
        'KVKK md. 5/1 açık rıza (ticari elektronik ileti)',
      ],
      defaultPolicy: ConsentDefaultPolicy.optOut,
      requiresClinicianCountersign: false,
      revocationSlaHours: 24,
    ),
  ];

  static ConsentKindRecord forKind(ConsentKind kind) {
    for (final r in entries) {
      if (r.kind == kind) return r;
    }
    throw StateError(
      'No ConsentKindRecord pinned for ${kind.id} — every enum '
      'value MUST have a record. Add it to ConsentKindCatalog.entries.',
    );
  }
}
