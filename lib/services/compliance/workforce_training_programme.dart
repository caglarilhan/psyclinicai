/// N2 — Workforce security training programme (pinned helper).
///
/// **Why this exists**: HIPAA §164.308(a)(5) + GDPR Art. 32(4) + SOC 2
/// CC1.4 require the controller to (a) define a training curriculum,
/// (b) name who must complete which modules, (c) record completion,
/// and (d) re-train after a triggering event. The narrative version
/// lives at `docs/security/workforce-training.md`; this helper pins
/// the module + role matrix in code so the SOC 2 evidence collector
/// Cloud Function + the trust-center page + the on-call runbook all
/// resolve the same identifiers.
///
/// **Out of scope** (separate PRs):
///   * Cloud Function that reads the per-quarter CSV evidence ledger.
///   * Trust-center widget that renders the matrix.
///   * Slack bot that reminds trainees before the annual deadline.
library;

/// One module in the curriculum. Module ids are stable; the
/// content described here matches `docs/security/workforce-training.md`
/// — keep the two in sync.
class TrainingModule {
  const TrainingModule({
    required this.id,
    required this.title,
    required this.outcome,
    required this.regulatoryRefs,
  });

  /// Stable id (`m1` .. `m8`) — survives wording changes.
  final String id;
  final String title;
  final String outcome;
  final List<String> regulatoryRefs;
}

/// Cadence at which a role must complete or refresh a module set.
enum TrainingCadence {
  /// First day of employment / contract.
  onboarding,

  /// Every quarter.
  quarterly,

  /// Every twelve months from last completion.
  annual,

  /// Fires when a documented condition is met (incident the trainee
  /// was on-call for, customer onboard, contract renewal, etc.).
  triggerBased,
}

/// A workforce role + its required module set per cadence.
class TrainingRoleProfile {
  const TrainingRoleProfile({
    required this.role,
    required this.onboardingModules,
    required this.quarterlyModules,
    required this.annualModules,
    required this.triggerCondition,
  });

  /// Stable role key (`engineer_prod`, `engineer_no_prod`,
  /// `founder_ops`, `contractor_phi`, `customer_success`).
  final String role;

  /// Modules required before any data access is granted.
  final List<String> onboardingModules;

  /// Modules required each quarter — typically the phishing drill.
  final List<String> quarterlyModules;

  /// Modules required annually as full refresh.
  final List<String> annualModules;

  /// One-line description of the trigger-based re-training rule.
  final String triggerCondition;
}

/// Sanction tier — drives the documented response when a module
/// commitment is breached. Tier ordering MUST match severity; tests
/// pin this so future edits cannot accidentally invert the scale.
class SanctionTier {
  const SanctionTier({
    required this.tier,
    required this.name,
    required this.example,
    required this.action,
  });

  /// 1 (negligent) → 4 (malicious). Strictly ascending.
  final int tier;
  final String name;
  final String example;
  final String action;
}

class WorkforceTrainingProgramme {
  const WorkforceTrainingProgramme._();

  /// YYYY-MM stamp — drives the "needs review" badge on the trust
  /// page when older than 12 months.
  static const String lastReviewed = '2026-06';

  /// HIPAA + GDPR + SOC 2 anchors that legitimise the programme.
  static const List<String> authority = [
    'HIPAA §164.308(a)(5) security-awareness + training',
    'GDPR Art. 32(4) staff awareness',
    'SOC 2 CC1.4 commitment to competence',
    'SOC 2 CC2.2 communication of objectives',
    'ISO 27001 A.7.2.2 information security awareness',
  ];

  /// The eight modules. Append-only — deprecated modules stay so
  /// historic CSV ledgers always resolve.
  static const List<TrainingModule> modules = [
    TrainingModule(
      id: 'm1',
      title: 'What PHI / personal data we touch',
      outcome: 'Trainee classifies 10 sample fields as PHI / not-PHI.',
      regulatoryRefs: [
        'HIPAA §164.103 ePHI definition',
        'GDPR Art. 4(1) + Art. 9(1)',
      ],
    ),
    TrainingModule(
      id: 'm2',
      title: 'Acceptable use + workstation security',
      outcome: 'Trainee signs acceptable-use addendum.',
      regulatoryRefs: [
        'HIPAA §164.310(c) workstation security',
        'ISO 27001 A.6.2.1',
      ],
    ),
    TrainingModule(
      id: 'm3',
      title: 'Secrets handling',
      outcome: 'Trainee performs one supervised rotation in staging tenant.',
      regulatoryRefs: [
        'HIPAA §164.308(a)(3) workforce security',
        'SOC 2 CC6.1 logical access',
      ],
    ),
    TrainingModule(
      id: 'm4',
      title: 'Phishing + social engineering',
      outcome: 'Trainee passes quarterly phishing-drill click rate < 5%.',
      regulatoryRefs: ['SOC 2 CC2.3 communication of objectives'],
    ),
    TrainingModule(
      id: 'm5',
      title: 'Reporting an incident',
      outcome:
          'Trainee files a tabletop incident in `#incidents` within 30 '
          'minutes, no retaliation for false alarms.',
      regulatoryRefs: ['HIPAA §164.308(a)(6) security incident procedures'],
    ),
    TrainingModule(
      id: 'm6',
      title: 'Clinical safety + AI guardrails',
      outcome:
          'Trainee recognises hallucination patterns + escalates `phi_'
          'detected=true` outputs to a clinician advisor before customer '
          'reply.',
      regulatoryRefs: [
        'FDA CDS Guidance Sep 2022',
        'MDR 745 Rule 11 Class IIa',
      ],
    ),
    TrainingModule(
      id: 'm7',
      title: 'Customer comms posture',
      outcome:
          'Trainee uses the plural brand voice + routes all incident '
          'comms through the status page (never DMs).',
      regulatoryRefs: ['SOC 2 CC2.3 external comms'],
    ),
    TrainingModule(
      id: 'm8',
      title: 'Production access discipline (engineers only)',
      outcome:
          'Trainee can recite the deny-by-default rule + show one '
          'runbook-backed prod operation.',
      regulatoryRefs: [
        'HIPAA §164.308(a)(4) info access management',
        'SOC 2 CC6.3 manage logical access',
      ],
    ),
  ];

  /// Role → required module sets. Append-only.
  static const List<TrainingRoleProfile> roles = [
    TrainingRoleProfile(
      role: 'engineer_prod',
      onboardingModules: ['m1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8'],
      quarterlyModules: ['m4'],
      annualModules: ['m1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8'],
      triggerCondition:
          'After any SEV1/SEV2 incident this engineer was on-call for.',
    ),
    TrainingRoleProfile(
      role: 'engineer_no_prod',
      onboardingModules: ['m1', 'm2', 'm3', 'm4', 'm5'],
      quarterlyModules: ['m4'],
      annualModules: ['m1', 'm2', 'm3', 'm4', 'm5'],
      triggerCondition:
          'After any SEV1/SEV2 incident this engineer was on-call for.',
    ),
    TrainingRoleProfile(
      role: 'founder_ops',
      onboardingModules: ['m1', 'm2', 'm4', 'm6', 'm7'],
      quarterlyModules: ['m4'],
      annualModules: ['m1', 'm2', 'm4', 'm6', 'm7'],
      triggerCondition: 'Before any board / customer demo.',
    ),
    TrainingRoleProfile(
      role: 'contractor_phi',
      onboardingModules: ['m1', 'm2', 'm3', 'm4', 'm5', 'm8'],
      quarterlyModules: [],
      annualModules: ['m1', 'm2', 'm3', 'm4', 'm5', 'm8'],
      triggerCondition: 'Before contract renewal.',
    ),
    TrainingRoleProfile(
      role: 'customer_success',
      onboardingModules: ['m1', 'm2', 'm4', 'm7'],
      quarterlyModules: ['m4'],
      annualModules: ['m1', 'm2', 'm4', 'm7'],
      triggerCondition: 'After any new clinic onboard.',
    ),
  ];

  /// Four-tier sanction ladder — keep monotonic (1 < 2 < 3 < 4).
  static const List<SanctionTier> sanctions = [
    SanctionTier(
      tier: 1,
      name: 'Negligent',
      example: 'One missed quarterly module, no PHI impact.',
      action: 'Coaching + 7-day re-training window.',
    ),
    SanctionTier(
      tier: 2,
      name: 'Reckless',
      example: 'Sharing a secret on chat, no exploit observed.',
      action:
          'Written warning + secret rotation + role temporarily downgraded.',
    ),
    SanctionTier(
      tier: 3,
      name: 'Knowing',
      example: 'Exporting PHI to personal device, bypassing audit chain.',
      action: 'Suspension + counsel review + breach assessment.',
    ),
    SanctionTier(
      tier: 4,
      name: 'Malicious',
      example: 'Exfil for sale / unauthorised account creation.',
      action: 'Termination + civil + criminal referral.',
    ),
  ];

  static TrainingModule? moduleById(String id) {
    for (final m in modules) {
      if (m.id == id) return m;
    }
    return null;
  }

  static TrainingRoleProfile? roleByKey(String role) {
    for (final r in roles) {
      if (r.role == role) return r;
    }
    return null;
  }
}

/// Union of modules a role MUST complete across onboarding + quarterly
/// + annual cadences. Used by the SOC 2 evidence collector to gate
/// access and by the trust page to render a single-cell coverage badge.
Set<String> requiredModuleIdsFor(TrainingRoleProfile role) {
  return {
    ...role.onboardingModules,
    ...role.quarterlyModules,
    ...role.annualModules,
  };
}
