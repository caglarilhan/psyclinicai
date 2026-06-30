/// MBC1 — Measurement-Based Care dispatch + portal catalog
/// (pinned helper, PILAR 2 / PR-1).
///
/// **Why this exists**: `outcome_measure_catalog.dart` pins WHAT each
/// scale scores and WHEN it alarms; this catalog pins HOW we deliver
/// it to the patient between sessions — channel, link lifetime, public
/// surface flag, reminder cadence. The Cloud Function dispatcher (PR-2)
/// + Flutter clinician dashboard (PR-3) both bind to it.
///
/// Regulatory framing:
///   * Measurement-based care underwriting: NIH PROMIS / NQF #0420 /
///     CMS MIPS Quality Measure #134 (depression screening + follow-up).
///   * Patient-facing token URL: HIPAA §164.312(d) entity authentication —
///     short-lived signed token tied to a single patient + instrument.
///   * Public submit endpoint: HIPAA §164.502(b) minimum-necessary —
///     no PHI leaks back in the response; the patient sees only their
///     own score + severity band, never the clinician's chart.
///   * Reminder cadence: NICE QS8 (depression in adults) recommends
///     2-week re-screen for moderate+; we pin per-scale intervals
///     here and the cadence cron (PR-4) walks them.
///
/// **Out of scope** (separate PRs):
///   * SMS gateway adapter (Twilio relay) — Sprint 33.
///   * MBC payer report PDF — Sprint 32 phase 2.
///   * Adolescent variants (PHQ-A, GAD-7-A) — separate PR with their
///     own validated thresholds.
library;

/// Channel the dispatch link is delivered through. Email is the
/// always-available baseline; SMS is a higher-engagement upgrade once
/// the Twilio adapter lands; portal means the patient logs into their
/// own patient portal and sees the assessment there.
enum DispatchChannel { email, sms, portal }

/// Audience the assessment may be dispatched to.
enum DispatchAudience {
  patientAdult,
  patientAdolescent,
  caregiver,
}

class MbcDispatchRule {
  const MbcDispatchRule({
    required this.scaleId,
    required this.fullName,
    required this.intervalDays,
    required this.linkLifetimeHours,
    required this.reminderAtHours,
    required this.audiences,
    required this.channels,
    required this.publicSubmit,
    required this.maxItemsPerSession,
    required this.payerCadenceLabel,
    required this.regulatoryRefs,
  });

  /// MUST match an id in `ClinicalScales` + `OutcomeMeasureCatalog`.
  /// Parity tests pin this against the known-good set.
  final String scaleId;

  final String fullName;

  /// Days between successive dispatches per the validated guideline.
  /// MUST equal `OutcomeMeasureCatalog.byScaleId(scaleId).readminInterval`
  /// — drift test enforces this.
  final int intervalDays;

  /// How long the patient's token-signed URL is valid. Short-lived to
  /// limit the blast radius of a leaked link.
  final int linkLifetimeHours;

  /// Hours after the initial dispatch we send a single reminder if
  /// the assessment is still un-submitted. Bound at <= linkLifetime
  /// so the reminder never points at a dead link.
  final int reminderAtHours;

  final List<DispatchAudience> audiences;
  final List<DispatchChannel> channels;

  /// True when the public submit endpoint (`mbcSubmitAssessment`) is
  /// allowed for this scale. Currently all of them; flag exists so we
  /// can ship clinician-administered-only scales later (e.g. MMSE).
  final bool publicSubmit;

  /// Cap on how many items the form may render per session so a long
  /// instrument (PCL-5 = 20 items) does not feel like a wall of text.
  /// Form pagination kicks in above this. Tests pin > 0.
  final int maxItemsPerSession;

  /// Free-text label payers expect to see on the MBC report PDF for
  /// this cadence (e.g. "every 2 weeks", "monthly"). Parity test pins
  /// it appears verbatim in the TS mirror.
  final String payerCadenceLabel;

  final List<String> regulatoryRefs;
}

class MbcDispatchCatalog {
  const MbcDispatchCatalog._();

  static const String lastReviewed = '2026-06';
  static const int schemaVersion = 1;

  /// Pinned dispatch rules. Append-only.
  static const List<MbcDispatchRule> rules = [
    MbcDispatchRule(
      scaleId: 'phq9',
      fullName: 'Patient Health Questionnaire-9 (PHQ-9)',
      intervalDays: 14,
      linkLifetimeHours: 72,
      reminderAtHours: 48,
      audiences: [DispatchAudience.patientAdult],
      channels: [DispatchChannel.email, DispatchChannel.sms],
      publicSubmit: true,
      maxItemsPerSession: 9,
      payerCadenceLabel: 'every 2 weeks',
      regulatoryRefs: [
        'NICE CG90 depression in adults',
        'CMS MIPS #134',
        'Joint Commission NPSG 15.01.01 (item 9)',
      ],
    ),
    MbcDispatchRule(
      scaleId: 'gad7',
      fullName: 'Generalised Anxiety Disorder-7 (GAD-7)',
      intervalDays: 14,
      linkLifetimeHours: 72,
      reminderAtHours: 48,
      audiences: [DispatchAudience.patientAdult],
      channels: [DispatchChannel.email, DispatchChannel.sms],
      publicSubmit: true,
      maxItemsPerSession: 7,
      payerCadenceLabel: 'every 2 weeks',
      regulatoryRefs: [
        'NICE CG113 generalised anxiety disorder',
        'CMS MIPS #134',
      ],
    ),
    MbcDispatchRule(
      scaleId: 'who5',
      fullName: 'WHO-5 Wellbeing Index',
      intervalDays: 28,
      linkLifetimeHours: 96,
      reminderAtHours: 72,
      audiences: [DispatchAudience.patientAdult],
      channels: [DispatchChannel.email, DispatchChannel.portal],
      publicSubmit: true,
      maxItemsPerSession: 5,
      payerCadenceLabel: 'monthly',
      regulatoryRefs: [
        'Topp et al. (2015) WHO-5 systematic review',
      ],
    ),
    MbcDispatchRule(
      scaleId: 'audit',
      fullName: 'AUDIT — Alcohol Use Disorders Identification Test',
      intervalDays: 84,
      linkLifetimeHours: 96,
      reminderAtHours: 72,
      audiences: [DispatchAudience.patientAdult],
      channels: [DispatchChannel.email],
      publicSubmit: true,
      maxItemsPerSession: 10,
      payerCadenceLabel: 'quarterly',
      regulatoryRefs: [
        'NICE CG115 alcohol-use disorders',
      ],
    ),
    MbcDispatchRule(
      scaleId: 'pcl5',
      fullName: 'PCL-5 — PTSD Checklist for DSM-5',
      intervalDays: 28,
      linkLifetimeHours: 96,
      reminderAtHours: 72,
      audiences: [DispatchAudience.patientAdult],
      channels: [DispatchChannel.email, DispatchChannel.portal],
      publicSubmit: true,
      maxItemsPerSession: 10,
      payerCadenceLabel: 'monthly',
      regulatoryRefs: [
        'NICE NG116 post-traumatic stress disorder',
      ],
    ),
  ];

  static MbcDispatchRule byScaleId(String id) {
    for (final r in rules) {
      if (r.scaleId == id) return r;
    }
    throw StateError('No MBC dispatch rule for scaleId=$id');
  }
}

/// True when the [now] timestamp is past the last dispatch for this
/// patient + scale + the catalog interval. Pure for unit testing.
bool isDueForDispatch({
  required MbcDispatchRule rule,
  required DateTime? lastDispatchedAt,
  required DateTime now,
}) {
  if (lastDispatchedAt == null) return true;
  final due =
      lastDispatchedAt.add(Duration(days: rule.intervalDays));
  return !now.isBefore(due);
}

/// Token expiry the dispatcher writes when minting a link. Pure for
/// unit testing.
DateTime tokenExpiryFor({
  required MbcDispatchRule rule,
  required DateTime dispatchedAt,
}) =>
    dispatchedAt.add(Duration(hours: rule.linkLifetimeHours));
