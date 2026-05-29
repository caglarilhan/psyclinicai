import '../../models/denial_risk.dart';
import '../copilot/compliance_check_service.dart';
import 'cpt_lookup_service.dart';

/// Denial Shield — payer- and CPT-aware claim-rejection risk for a progress
/// note. Composes the generic documentation rubric ([ComplianceCheckService])
/// with two things that drive most US behavioral-health denials:
///   1. CPT ↔ note alignment (the billed code must match documented time +
///      modality; 90837 is the single most-audited code).
///   2. Payer emphasis — Medicaid/Optum hammer the "golden thread" (measurable
///      goals + functional impairment); Medicare hammers start/stop time, etc.
///
/// Output reframes documentation gaps as **money at risk** with the exact
/// sentence to add. Decision-support — payer rules and reimbursement vary and
/// change; this estimates risk, it does not guarantee payment.
class DenialShieldService {
  const DenialShieldService();

  /// Time-based psychotherapy codes that require explicit start/stop time.
  static const Set<String> _timeBased = {
    '90832', '90834', '90837', '90846', '90847', '90839',
  };

  /// CPT → inclusive minute band (min, max). null max = open-ended.
  static const Map<String, (int, int?)> _bands = {
    '90832': (16, 37),
    '90834': (38, 52),
    '90837': (53, null),
    '90846': (26, null),
    '90847': (26, null),
    '90839': (30, null),
  };

  /// The lower-time alternative to suggest when a session runs short.
  static const Map<String, String> _downcode = {
    '90837': '90834',
    '90834': '90832',
  };

  /// Which rubric checks each payer treats as denial drivers (beyond coding).
  static const Map<Payer, List<String>> _payerCritical = {
    Payer.medicare: ['time', 'plan'],
    Payer.medicaid: ['goal_linkage', 'functional_impairment'],
    Payer.bcbs: ['functional_impairment', 'intervention'],
    Payer.uhcOptum: ['goal_linkage', 'functional_impairment'],
    Payer.aetna: ['intervention', 'response'],
    Payer.cigna: ['functional_impairment', 'risk'],
  };

  /// One-line note on what each payer is strict about (shown in the UI).
  static String payerFocus(Payer p) => switch (p) {
        Payer.medicare =>
          'Strict on start/stop time and a documented plan/signature.',
        Payer.medicaid =>
          'Requires measurable treatment-plan goals + functional impairment.',
        Payer.bcbs => 'Wants documented impairment and a named intervention.',
        Payer.uhcOptum =>
          'Optum audits the golden thread — goal linkage + impairment.',
        Payer.aetna => 'Wants the named intervention and the client response.',
        Payer.cigna => 'Wants functional impairment and risk addressed.',
      };

  DenialRisk assess({
    required String note,
    required String cptCode,
    required Payer payer,
    required ComplianceReport audit,
    int? durationMinutes,
  }) {
    final cpt = CptLookupService.instance.byCode(cptCode);
    final cptLabel = cpt?.shortLabel ?? cptCode;
    final revenue = cpt?.nationalAverageUsd.toDouble();
    final reasons = <DenialReason>[];

    final mins = durationMinutes ?? _parseMinutes(note);
    final band = _bands[cptCode];

    // 1 — CPT ↔ documented time.
    if (band != null && mins != null && mins < band.$1) {
      final lower = _downcode[cptCode];
      reasons.add(DenialReason(
        critical: true,
        title: 'Documented time does not support $cptCode',
        detail:
            '${payer.short} will downcode or deny — $mins min is below the '
            '${band.$1}-minute threshold for $cptCode.',
        fixSentence: lower != null
            ? 'Either bill $lower instead, or document the full session length '
                'with exact start–stop times.'
            : 'Document the full session length with exact start–stop times.',
      ));
    }

    // 1b — 90837 (60 min) extended-session medical necessity.
    if (cptCode == '90837' && !_hasMedicalNecessity(note)) {
      reasons.add(const DenialReason(
        critical: true,
        title:
            '90837 lacks a medical-necessity reason for the extended session',
        detail: '90837 (53+ min) is the most-audited psychotherapy code; '
            'without a stated reason it is routinely denied or downcoded.',
        fixSentence: 'Add why the extended session was clinically required — '
            'e.g. "53+ minutes were medically necessary for trauma processing '
            'given symptom severity."',
        insertText: 'The extended 53+ minute session was medically necessary '
            'given symptom severity and the depth of material addressed.',
      ));
    }

    // 1c — time-based code with no start/stop time at all.
    if (_timeBased.contains(cptCode) && !_hasClockTime(note) && mins == null) {
      reasons.add(DenialReason(
        critical: true,
        title: 'No session time documented',
        detail:
            'Time-based code $cptCode requires the session length on the note.',
        fixSentence:
            'Document exact start and stop times (e.g. "10:02–10:55").',
      ));
    }

    // 2 — payer-weighted documentation gaps (from the rubric).
    final failing = {
      for (final c in audit.checks)
        if (c.status != CheckStatus.pass) c.id
    };
    for (final id in _payerCritical[payer] ?? const <String>[]) {
      if (failing.contains(id)) {
        final r = _payerReason(id, payer);
        if (r != null) reasons.add(r);
      }
    }

    final level = reasons.any((r) => r.critical)
        ? DenialLevel.high
        : reasons.isNotEmpty
            ? DenialLevel.medium
            : DenialLevel.low;

    return DenialRisk(
      level: level,
      payer: payer,
      cptCode: cptCode,
      cptLabel: cptLabel,
      reasons: reasons,
      revenueAtRisk: reasons.isEmpty ? null : revenue,
    );
  }

  DenialReason? _payerReason(String id, Payer payer) {
    final who = payer.short;
    switch (id) {
      case 'functional_impairment':
        return DenialReason(
          critical: payer == Payer.medicaid || payer == Payer.uhcOptum,
          title: 'Functional impairment not documented',
          detail:
              '$who denies psychotherapy without a documented impact on daily '
              'functioning (medical necessity).',
          fixSentence:
              'Add how symptoms impair functioning — e.g. "Anxiety prevents '
              'the client from concentrating at work and led to missed shifts."',
          insertText:
              'Symptoms impair the client’s daily functioning — including '
              'concentration at work and reduced engagement in relationships.',
        );
      case 'goal_linkage':
        return DenialReason(
          critical: payer == Payer.medicaid || payer == Payer.uhcOptum,
          title: 'No treatment-plan goal linkage',
          detail:
              '$who requires the note to tie to a measurable treatment-plan '
              'goal — the "golden thread".',
          fixSentence:
              'Reference the goal worked on and progress — e.g. "Targeted Goal '
              '1 (reduce panic to <2/week); client reports 3 this week, down '
              'from 5."',
          insertText:
              'This session targeted the client’s active treatment-plan goal; '
              'progress toward it was reviewed.',
        );
      case 'intervention':
        return DenialReason(
          title: 'Intervention not specifically named',
          detail:
              '$who rejects "provided supportive therapy" — it needs the named '
              'evidence-based technique.',
          fixSentence:
              'Name the technique used — e.g. "Used cognitive restructuring to '
              'challenge catastrophic predictions about the interview."',
          insertText:
              'Delivered a specific evidence-based intervention targeting the '
              'presenting symptoms this session.',
        );
      case 'response':
        return DenialReason(
          title: 'Client response to the intervention not documented',
          detail: '$who wants evidence the intervention was delivered and how '
              'the client responded.',
          fixSentence:
              'Add the response — e.g. "Client engaged, identified two '
              'automatic thoughts and practiced a reframe in session."',
          insertText:
              'The client engaged with the intervention and demonstrated '
              'understanding in session.',
        );
      case 'risk':
        return DenialReason(
          title: 'Risk / safety not addressed',
          detail: '$who expects risk addressed explicitly, even when absent.',
          fixSentence:
              'Add a risk line — e.g. "Denies SI/HI; no acute safety concerns."',
          insertText: 'Risk reviewed: denies SI/HI; no acute safety concerns.',
        );
      case 'time':
        return DenialReason(
          critical: payer == Payer.medicare,
          title: 'Start/stop time missing',
          detail: '$who requires exact start and stop times for time-based '
              'psychotherapy codes.',
          fixSentence: 'Document start and stop times (e.g. "10:02–10:55").',
        );
      case 'plan':
        return DenialReason(
          title: 'No plan / next steps documented',
          detail:
              '$who expects a forward plan (frequency, homework, referral).',
          fixSentence:
              'Add the plan — e.g. "Continue weekly; assigned a daily thought '
              'record; reassess GAD-7 in 4 weeks."',
          insertText:
              'Plan: continue weekly sessions; assigned between-session '
              'homework; reassess at the next visit.',
        );
    }
    return null;
  }

  int? _parseMinutes(String note) {
    final m = RegExp(r'(\d{1,3})\s*(?:min\b|minute)', caseSensitive: false)
        .firstMatch(note);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  bool _hasClockTime(String note) =>
      RegExp(r'\d{1,2}:\d{2}').hasMatch(note) ||
      RegExp(r'\b(start|stop|started|ended|duration)\b', caseSensitive: false)
          .hasMatch(note);

  bool _hasMedicalNecessity(String note) => RegExp(
        r'\b(medically necessary|medical necessity|due to|because|severity|trauma|crisis|complex|extended)',
        caseSensitive: false,
      ).hasMatch(note);
}
