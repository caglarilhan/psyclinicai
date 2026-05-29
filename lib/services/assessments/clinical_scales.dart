import '../../models/clinical_scale.dart';

/// Validated outcome / risk instruments, defined data-driven so one runner UI
/// serves them all. Scoring follows each instrument's published manual.
///
/// These are screeners and severity measures — decision-support only. A
/// positive screen indicates the need for a clinician's structured assessment;
/// it is never a diagnosis.
class ClinicalScales {
  ClinicalScales._();

  static const List<ScaleChoice> _freq5 = [
    ScaleChoice('Not at all', 0),
    ScaleChoice('A little bit', 1),
    ScaleChoice('Moderately', 2),
    ScaleChoice('Quite a bit', 3),
    ScaleChoice('Extremely', 4),
  ];

  static const List<ScaleChoice> _yesNo = [
    ScaleChoice('No', 0),
    ScaleChoice('Yes', 1),
  ];

  static const List<ScaleChoice> _freq5Audit = [
    ScaleChoice('Never', 0),
    ScaleChoice('Less than monthly', 1),
    ScaleChoice('Monthly', 2),
    ScaleChoice('Weekly', 3),
    ScaleChoice('Daily or almost daily', 4),
  ];

  // ───────────────────────────── AUDIT ─────────────────────────────
  // Alcohol Use Disorders Identification Test (Saunders et al., 1993, WHO).
  static const ClinicalScale audit = ClinicalScale(
    id: 'audit',
    shortName: 'AUDIT',
    title: 'AUDIT — Alcohol Use Disorders Identification Test',
    instructions:
        'Please answer about your alcohol use in the last year. Place the '
        'answer that is correct for you.',
    referenceNote: 'WHO AUDIT (Saunders et al., 1993). Score 0–40.',
    questions: [
      ScaleQuestion('How often do you have a drink containing alcohol?', [
        ScaleChoice('Never', 0),
        ScaleChoice('Monthly or less', 1),
        ScaleChoice('2–4 times a month', 2),
        ScaleChoice('2–3 times a week', 3),
        ScaleChoice('4+ times a week', 4),
      ]),
      ScaleQuestion(
          'How many drinks containing alcohol do you have on a typical day '
          'when you are drinking?', [
        ScaleChoice('1 or 2', 0),
        ScaleChoice('3 or 4', 1),
        ScaleChoice('5 or 6', 2),
        ScaleChoice('7 to 9', 3),
        ScaleChoice('10 or more', 4),
      ]),
      ScaleQuestion('How often do you have six or more drinks on one occasion?',
          _freq5Audit),
      ScaleQuestion(
          'How often during the last year have you found that you were not '
          'able to stop drinking once you had started?',
          _freq5Audit),
      ScaleQuestion(
          'How often during the last year have you failed to do what was '
          'normally expected of you because of drinking?',
          _freq5Audit),
      ScaleQuestion(
          'How often during the last year have you needed a first drink in '
          'the morning to get yourself going after a heavy session?',
          _freq5Audit),
      ScaleQuestion(
          'How often during the last year have you had a feeling of guilt or '
          'remorse after drinking?',
          _freq5Audit),
      ScaleQuestion(
          'How often during the last year have you been unable to remember '
          'what happened the night before because of your drinking?',
          _freq5Audit),
      ScaleQuestion(
          'Have you or someone else been injured because of your drinking?', [
        ScaleChoice('No', 0),
        ScaleChoice('Yes, but not in the last year', 2),
        ScaleChoice('Yes, during the last year', 4),
      ]),
      ScaleQuestion(
          'Has a relative, friend, doctor, or other health worker been '
          'concerned about your drinking or suggested you cut down?', [
        ScaleChoice('No', 0),
        ScaleChoice('Yes, but not in the last year', 2),
        ScaleChoice('Yes, during the last year', 4),
      ]),
    ],
    scorer: _scoreAudit,
  );

  static ScaleResult _scoreAudit(List<int> a) {
    final total = a.fold<int>(0, (s, v) => s + v);
    final ScaleSeverity sev;
    final String band;
    final String guidance;
    if (total <= 7) {
      sev = ScaleSeverity.minimal;
      band = 'Low risk';
      guidance = 'Low-risk drinking. Reinforce; no intervention indicated.';
    } else if (total <= 15) {
      sev = ScaleSeverity.moderate;
      band = 'Hazardous use';
      guidance = 'Hazardous drinking — deliver brief advice / motivational '
          'intervention and reassess.';
    } else if (total <= 19) {
      sev = ScaleSeverity.severe;
      band = 'Harmful use';
      guidance = 'Harmful drinking — brief counselling and continued '
          'monitoring; consider referral.';
    } else {
      sev = ScaleSeverity.critical;
      band = 'Possible dependence';
      guidance = 'Likely alcohol dependence — refer for diagnostic evaluation '
          'and specialist treatment.';
    }
    final flag = total >= 16;
    return ScaleResult(
      total: total,
      maxScore: 40,
      severity: sev,
      bandLabel: band,
      guidance: guidance,
      riskFlag: flag,
      riskFlagText: flag
          ? 'Score ≥16 suggests harmful use or dependence — further '
              'assessment indicated.'
          : null,
    );
  }

  // ───────────────────────────── PCL-5 ─────────────────────────────
  // PTSD Checklist for DSM-5 (Weathers et al., 2013).
  static const ClinicalScale pcl5 = ClinicalScale(
    id: 'pcl5',
    shortName: 'PCL-5',
    title: 'PCL-5 — PTSD Checklist for DSM-5',
    instructions:
        'In the past month, how much were you bothered by each problem?',
    referenceNote:
        'Weathers et al. (2013). Score 0–80; provisional PTSD threshold ≥33.',
    questions: [
      ScaleQuestion('Repeated, disturbing, and unwanted memories of the '
          'stressful experience', _freq5),
      ScaleQuestion(
          'Repeated, disturbing dreams of the stressful experience', _freq5),
      ScaleQuestion(
          'Suddenly feeling or acting as if the stressful experience were '
          'actually happening again',
          _freq5),
      ScaleQuestion(
          'Feeling very upset when something reminded you of the experience',
          _freq5),
      ScaleQuestion(
          'Strong physical reactions when reminded of the experience (heart '
          'pounding, trouble breathing, sweating)',
          _freq5),
      ScaleQuestion(
          'Avoiding memories, thoughts, or feelings related to the experience',
          _freq5),
      ScaleQuestion(
          'Avoiding external reminders (people, places, activities, objects)',
          _freq5),
      ScaleQuestion(
          'Trouble remembering important parts of the stressful experience',
          _freq5),
      ScaleQuestion(
          'Strong negative beliefs about yourself, other people, or the world',
          _freq5),
      ScaleQuestion(
          'Blaming yourself or someone else for the experience or what '
          'happened after',
          _freq5),
      ScaleQuestion(
          'Strong negative feelings such as fear, horror, anger, guilt, or '
          'shame',
          _freq5),
      ScaleQuestion(
          'Loss of interest in activities you used to enjoy', _freq5),
      ScaleQuestion('Feeling distant or cut off from other people', _freq5),
      ScaleQuestion(
          'Trouble experiencing positive feelings (e.g. love, happiness)',
          _freq5),
      ScaleQuestion('Irritable behavior, angry outbursts, or acting '
          'aggressively', _freq5),
      ScaleQuestion(
          'Taking too many risks or doing things that could cause you harm',
          _freq5),
      ScaleQuestion('Being "superalert" or watchful or on guard', _freq5),
      ScaleQuestion('Feeling jumpy or easily startled', _freq5),
      ScaleQuestion('Having difficulty concentrating', _freq5),
      ScaleQuestion('Trouble falling or staying asleep', _freq5),
    ],
    scorer: _scorePcl5,
  );

  static ScaleResult _scorePcl5(List<int> a) {
    final total = a.fold<int>(0, (s, v) => s + v);
    final ScaleSeverity sev;
    final String band;
    final String guidance;
    if (total < 33) {
      sev = total < 20 ? ScaleSeverity.minimal : ScaleSeverity.mild;
      band = 'Below provisional threshold';
      guidance = 'Below the provisional PTSD cut-off. Monitor symptoms and '
          'reassess if the clinical picture changes.';
    } else if (total < 50) {
      sev = ScaleSeverity.moderate;
      band = 'Probable PTSD';
      guidance = 'Meets the provisional PTSD threshold. Confirm with a '
          'structured interview (e.g. CAPS-5) and consider trauma-focused '
          'treatment.';
    } else {
      sev = ScaleSeverity.severe;
      band = 'Probable PTSD (high symptom load)';
      guidance = 'High symptom burden above threshold. Prioritize structured '
          'assessment and evidence-based trauma treatment.';
    }
    final flag = total >= 33;
    return ScaleResult(
      total: total,
      maxScore: 80,
      severity: sev,
      bandLabel: band,
      guidance: guidance,
      riskFlag: flag,
      riskFlagText: flag
          ? 'Score ≥33 meets the provisional PTSD threshold — a structured '
              'clinical interview is indicated.'
          : null,
    );
  }

  // ───────────────────────────── C-SSRS ────────────────────────────
  // Columbia-Suicide Severity Rating Scale — Screener (Posner et al., 2011).
  // Categorical risk from the escalation ladder, not a simple sum.
  static const ClinicalScale cssrs = ClinicalScale(
    id: 'cssrs',
    shortName: 'C-SSRS',
    title: 'C-SSRS — Columbia Suicide Severity Rating Scale (Screener)',
    instructions:
        'Ask each question. Items 1–5 refer to the past month; item 6 covers '
        'lifetime and the past 3 months.',
    referenceNote:
        'Posner et al. (2011). Risk is categorical — any positive answer '
        'requires a full clinical risk assessment.',
    questions: [
      ScaleQuestion('1. Have you wished you were dead or wished you could go '
          'to sleep and not wake up?', _yesNo),
      ScaleQuestion(
          '2. Have you actually had any thoughts of killing yourself?', _yesNo),
      ScaleQuestion(
          '3. Have you thought about how you might do this?', _yesNo),
      ScaleQuestion(
          '4. Have you had these thoughts and had some intention of acting on '
          'them?',
          _yesNo),
      ScaleQuestion(
          '5. Have you started to work out or worked out the details of how to '
          'kill yourself, and did you intend to carry out this plan?',
          _yesNo),
      ScaleQuestion(
          '6. Have you ever done anything, started to do anything, or prepared '
          'to do anything to end your life? (lifetime, and in the past 3 '
          'months)',
          _yesNo),
    ],
    scorer: _scoreCssrs,
  );

  static ScaleResult _scoreCssrs(List<int> a) {
    bool yes(int i) => i < a.length && a[i] == 1;
    final total = a.fold<int>(0, (s, v) => s + v);

    // Highest endorsed item drives the category.
    final ScaleSeverity sev;
    final String band;
    final String guidance;
    if (yes(5)) {
      sev = ScaleSeverity.critical;
      band = 'Suicidal behavior endorsed';
      guidance = 'Positive for suicidal behavior. Conduct an immediate full '
          'risk assessment, ensure safety, and escalate per protocol.';
    } else if (yes(4) || yes(3)) {
      sev = ScaleSeverity.severe;
      band = 'Ideation with intent/plan';
      guidance = 'Active ideation with intent and/or plan. Immediate clinical '
          'risk assessment and safety planning required.';
    } else if (yes(2)) {
      sev = ScaleSeverity.moderate;
      band = 'Ideation with method';
      guidance = 'Ideation with method (no plan/intent reported). Complete a '
          'clinical risk assessment and build a safety plan.';
    } else if (yes(1) || yes(0)) {
      sev = ScaleSeverity.mild;
      band = 'Passive / active ideation';
      guidance = 'Wish to be dead or non-specific active ideation. Assess '
          'further and monitor; consider a safety plan.';
    } else {
      sev = ScaleSeverity.minimal;
      band = 'No ideation endorsed';
      guidance = 'No suicidal ideation or behavior endorsed on the screener. '
          'Continue routine monitoring.';
    }

    // Any positive answer is a flag; items 3–6 are high-priority.
    final positive = a.any((v) => v == 1);
    final highPriority = yes(2) || yes(3) || yes(4) || yes(5);
    return ScaleResult(
      total: total,
      maxScore: 6,
      severity: sev,
      bandLabel: band,
      guidance: guidance,
      riskFlag: positive,
      riskFlagText: positive
          ? (highPriority
              ? 'High-risk screen — perform an immediate full suicide risk '
                  'assessment before the patient leaves.'
              : 'Positive screen — perform a clinical risk assessment.')
          : null,
    );
  }

  static final List<ClinicalScale> all = [cssrs, pcl5, audit];

  static ClinicalScale? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
