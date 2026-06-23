/// Externalised payer rules for US insurance claim adjudication.
/// Each [PayerRulePack] is the authoritative list of "what this
/// payer wants documented for this CPT". The denial-shield service
/// composes the pack with the clinician's note to surface the
/// concrete denial drivers + fix sentences.
///
/// Packs are intentionally const + data-only so they can:
///   1. Be unit-tested without I/O.
///   2. Be swapped in / out by sprint (Optum LOC v6 -> v7).
///   3. Power a future Settings -> Payer rules screen that lets
///      the clinician see which rules drove a denial flag.
library;

import '../../models/denial_risk.dart';

/// One concrete rule that fires when the note misses a piece of
/// documentation the payer audits.
class PayerRule {
  const PayerRule({
    required this.id,
    required this.title,
    required this.detail,
    required this.fixSentence,
    this.suggestedInsert,
    this.appliesToCptCodes,
    this.critical = false,
    this.timeBasedOnly = false,
  });

  /// Stable slug — `optum.functional_impairment`. Used for
  /// telemetry + the "which rule fired" UI tile.
  final String id;
  final String title;
  final String detail;
  final String fixSentence;

  /// Ready-to-append sentence when the remedy is "add this exact
  /// line". Null when the remedy is a coding change instead.
  final String? suggestedInsert;

  /// When non-null, the rule only applies to these CPT codes.
  /// Null = applies to every CPT the pack covers.
  final Set<String>? appliesToCptCodes;

  /// Hard blocker (almost-certain denial) vs. soft risk.
  final bool critical;

  /// When true, the rule applies only to time-based CPT codes.
  /// Shorthand for the common "psychotherapy time codes need
  /// start/stop" pattern.
  final bool timeBasedOnly;

  /// Materialise this rule as a [DenialReason] (the existing
  /// denial-shield model). Keeps the public API stable while we
  /// migrate inline rules into packs.
  DenialReason toDenialReason() => DenialReason(
    title: title,
    detail: detail,
    fixSentence: fixSentence,
    insertText: suggestedInsert,
    critical: critical,
  );
}

/// All rules for one payer.
class PayerRulePack {
  const PayerRulePack({
    required this.payer,
    required this.rules,
    this.timeBasedCodes = const {'90837', '90838'},
  });

  final Payer payer;
  final List<PayerRule> rules;

  /// Set of CPT codes considered "time-based" for this payer.
  final Set<String> timeBasedCodes;

  /// Rules that fire for the given CPT — filters by
  /// `appliesToCptCodes` + `timeBasedOnly`.
  List<PayerRule> rulesFor(String cptCode) {
    return rules.where((r) {
      if (r.appliesToCptCodes != null &&
          !r.appliesToCptCodes!.contains(cptCode)) {
        return false;
      }
      if (r.timeBasedOnly && !timeBasedCodes.contains(cptCode)) return false;
      return true;
    }).toList();
  }
}

/// Catalogue of all shipped payer packs.
class PayerRulePacks {
  const PayerRulePacks._();

  static const _medicare = PayerRulePack(
    payer: Payer.medicare,
    rules: [
      PayerRule(
        id: 'medicare.time_in_out',
        title: 'Start / stop time not documented',
        detail:
            'Medicare requires explicit start and stop times for time-based '
            'psychotherapy codes; auditors deny when only total minutes '
            'appear.',
        fixSentence:
            'Add a start / stop time line, e.g. "10:00-10:53 (53 min)".',
        suggestedInsert: 'Session start 10:00, end 10:53 (53 minutes).',
        timeBasedOnly: true,
        critical: true,
      ),
      PayerRule(
        id: 'medicare.medical_necessity',
        title: 'Medical necessity not tied to the LCD',
        detail:
            'Medicare 1862(a)(1)(A) and the applicable LCD require a clear '
            'medical-necessity statement for the specific service billed.',
        fixSentence:
            'Add a sentence linking the diagnosis to the intervention and '
            'expected functional benefit.',
      ),
    ],
  );

  static const _medicaid = PayerRulePack(
    payer: Payer.medicaid,
    rules: [
      PayerRule(
        id: 'medicaid.golden_thread',
        title: 'Golden thread missing',
        detail:
            'State Medicaid programmes audit for the "golden thread": '
            'presenting problem -> treatment plan goal -> today\'s '
            'intervention -> measurable outcome.',
        fixSentence:
            'Reference the active treatment plan goal that this '
            "session's intervention addresses.",
        critical: true,
      ),
      PayerRule(
        id: 'medicaid.functional_impairment',
        title: 'Functional impairment not documented',
        detail:
            'Medicaid medical-necessity requires explicit functional '
            'impairment language in work, school, family, or self-care '
            'domains.',
        fixSentence:
            'Add a functional-impairment line in at least one '
            'domain (work, school, family, or self-care).',
        suggestedInsert:
            'Patient reports 30% productivity decline at work due to '
            'rumination episodes lasting 90+ minutes per day.',
      ),
      PayerRule(
        id: 'medicaid.prior_auth',
        title: 'Prior authorisation not referenced',
        detail:
            'Some Medicaid plans require prior authorisation for outpatient '
            'behavioural health beyond a threshold.',
        fixSentence:
            'Reference the prior authorisation number in the claim notes.',
      ),
    ],
  );

  static const _uhcOptum = PayerRulePack(
    payer: Payer.uhcOptum,
    rules: [
      PayerRule(
        id: 'optum.loc_alignment',
        title: 'Level of care not aligned with the Optum guideline',
        detail:
            'Optum Level of Care Guidelines drive most outpatient behavioural '
            'health denials. The note must show the patient meets criteria '
            'for the level being billed.',
        fixSentence:
            'Add a sentence mapping the patient to the Optum LOC criteria '
            'for outpatient psychotherapy.',
        critical: true,
      ),
      PayerRule(
        id: 'optum.measurable_goal',
        title: 'No measurable treatment plan goal cited',
        detail:
            'Optum audits psychotherapy claims for an active, measurable '
            'goal reference. SMART goals or quantified outcomes pass.',
        fixSentence:
            'Add the active SMART goal the session worked on (e.g. "reduce '
            'GAD-7 by at least 5 over 12 weeks").',
      ),
      PayerRule(
        id: 'optum.functional_impairment',
        title: 'Functional impairment not documented',
        detail:
            'Optum requires functional-impairment documentation in at '
            'least one domain.',
        fixSentence:
            'Add a functional-impairment line citing work, school, '
            'family, or self-care impact.',
        suggestedInsert:
            'Patient reports avoidance of social settings has dropped '
            'two close friendships in the past month.',
      ),
      PayerRule(
        id: 'optum.outcome_measure',
        title: 'No outcome measure recorded this quarter',
        detail:
            'Optum often requires a recent validated outcome score (PHQ-9, '
            'GAD-7, PCL-5) within 90 days for continuation.',
        fixSentence:
            'Administer and record a validated outcome measure within '
            'the last 90 days.',
      ),
    ],
  );

  static const _bcbs = PayerRulePack(
    payer: Payer.bcbs,
    rules: [
      PayerRule(
        id: 'bcbs.interqual',
        title: 'InterQual / MCG criteria not referenced',
        detail:
            'BCBS plans typically use InterQual or MCG criteria for medical '
            'necessity. The note should map to the relevant criterion set.',
        fixSentence:
            'Reference the InterQual / MCG criterion set the session '
            'meets for outpatient behavioural health.',
      ),
      PayerRule(
        id: 'bcbs.cpt_alignment',
        title: 'CPT level of service not justified',
        detail:
            'BCBS denies when the documented time + complexity does not '
            'match the billed CPT.',
        fixSentence: 'Add explicit start / stop time + complexity factors.',
        timeBasedOnly: true,
      ),
    ],
  );

  static const _aetna = PayerRulePack(
    payer: Payer.aetna,
    rules: [
      PayerRule(
        id: 'aetna.cpb_criteria',
        title: 'Aetna Clinical Policy Bulletin criteria not referenced',
        detail:
            'Aetna uses Clinical Policy Bulletins (CPBs) for outpatient '
            'behavioural-health medical-necessity decisions.',
        fixSentence:
            'Map the documented presentation to the relevant Aetna CPB.',
      ),
    ],
  );

  static const _cigna = PayerRulePack(
    payer: Payer.cigna,
    rules: [
      PayerRule(
        id: 'cigna.goal_link',
        title: 'No active goal linked to this session',
        detail:
            'Cigna behavioural-health audits look for an explicit tie '
            'between the intervention and a measurable treatment goal.',
        fixSentence:
            "Link this session's intervention to a specific measurable "
            "goal on the patient's active treatment plan.",
      ),
    ],
  );

  /// All packs shipped today.
  static const Map<Payer, PayerRulePack> byPayer = {
    Payer.medicare: _medicare,
    Payer.medicaid: _medicaid,
    Payer.uhcOptum: _uhcOptum,
    Payer.bcbs: _bcbs,
    Payer.aetna: _aetna,
    Payer.cigna: _cigna,
  };

  static PayerRulePack forPayer(Payer p) =>
      byPayer[p] ?? const PayerRulePack(payer: Payer.medicare, rules: []);
}
