/// Synthetic clinical vignettes for the **demo mode** banner on PILAR 1
/// (Ambient Scribe) and PILAR 4 (Treatment Plan Drafter).
///
/// **Why this exists**: the bootstrap launch is gated behind a
/// "⚠️ Synthetic data only — do NOT enter real PHI" banner because
/// the free-tier LLM providers (Groq, Gemini) do not carry a HIPAA
/// BAA. A clinician evaluating the demo needs realistic input to
/// see the AI's output — but if they paste a real session transcript
/// we have a compliance problem. This catalog gives them five
/// **pre-built non-PHI cases** they can load with one tap.
///
/// Every vignette here:
///   * Uses fictional demographics explicitly marked "(fictional, ...)"
///   * Carries a clinical presentation rich enough to exercise the
///     SOAP scribe (MSE, risk, plan) and the plan drafter
///     (presenting problems matching a catalog protocol)
///   * Cites no real patient session
library;

class SyntheticVignette {
  const SyntheticVignette({
    required this.id,
    required this.label,
    required this.disorderHint,
    required this.modalityHint,
    required this.transcript,
    required this.presentingProblems,
    required this.contextNote,
  });

  /// Stable id surfaced in audit rows.
  final String id;

  /// Picker dropdown label.
  final String label;

  /// Plan drafter pre-selects this disorder. Free text — matches one
  /// of the `TpDisorderId` enum names.
  final String disorderHint;

  /// Plan drafter pre-selects this modality. Free text — matches one
  /// of the `TpModality` enum names.
  final String modalityHint;

  /// Realistic 5-10 sentence session transcript the Scribe ingests.
  /// Synthetic: no real patient.
  final String transcript;

  /// Bullet list the Plan Drafter pre-fills.
  final List<String> presentingProblems;

  /// Optional history note the Drafter's "additional context" field
  /// pre-fills.
  final String contextNote;
}

class SyntheticVignetteCatalog {
  const SyntheticVignetteCatalog._();

  static const String lastReviewed = '2026-06';

  /// Pinned vignettes. Append-only.
  static const List<SyntheticVignette> vignettes = [
    SyntheticVignette(
      id: 'demo-mdd-cbt',
      label: 'Major Depressive Disorder · CBT (45-year-old, 2-week onset)',
      disorderHint: 'majorDepressiveDisorder',
      modalityHint: 'cbt',
      transcript:
          'Patient (fictional, 45-year-old educator) reports two weeks of '
          'low mood after a layoff. Sleep onset takes 60-90 minutes, '
          'middle-of-night waking three times a week. Appetite reduced, '
          'lost 2 kg in three weeks. Anhedonia: stopped jogging and book '
          'club. Denies suicidal ideation or self-harm intent — "I would '
          'never act on it." Concentration impaired; misplaced laptop twice '
          'last week. Energy 3/10. Wants to feel like themselves before '
          'the next interview cycle. No prior episodes, no psychotropics, '
          'no substance use beyond two glasses of wine on weekends.',
      presentingProblems: [
        'Two-week onset of low mood after job loss',
        'Sleep onset latency 60-90 min, middle-of-night waking',
        'Anhedonia: stopped jogging + book club',
        'Concentration impairment affecting daily tasks',
        'No suicidal ideation; engaged + future-oriented',
      ],
      contextNote:
          'First episode. No psychiatric history. No medications. Strong '
          'support network (partner + adult children).',
    ),
    SyntheticVignette(
      id: 'demo-gad-cbt',
      label: 'Generalised Anxiety Disorder · CBT (32-year-old)',
      disorderHint: 'generalisedAnxietyDisorder',
      modalityHint: 'cbt',
      transcript:
          'Patient (fictional, 32-year-old product manager) reports '
          'persistent worry "about everything" for the last 8 months, '
          'worsened in the past 6 weeks. Worry topics: work performance, '
          "parents' health, finances, climate. Physical: muscle tension "
          '(jaw + shoulders), restless evenings, racing thoughts at sleep '
          'onset. GAD-7 self-administered last week scored 14. PHQ-9 '
          'scored 7. No panic attacks. Caffeine 3 cups/day, no alcohol. '
          'Tried mindfulness app for 2 weeks, "helped a little." Wants '
          'tools they can use between sessions.',
      presentingProblems: [
        '8-month course of generalised worry, worsened past 6 weeks',
        'Muscle tension (jaw, shoulders) + sleep-onset rumination',
        'GAD-7 = 14 (moderate), PHQ-9 = 7 (mild)',
        'Cognitive avoidance + reassurance-seeking pattern',
      ],
      contextNote: 'No prior treatment. Motivated, skills-oriented.',
    ),
    SyntheticVignette(
      id: 'demo-ptsd-cbt',
      label: 'PTSD · Trauma-Focused CBT (28-year-old, MVA)',
      disorderHint: 'ptsd',
      modalityHint: 'cbt',
      transcript:
          'Patient (fictional, 28-year-old paramedic) presents 4 months '
          'after a multi-vehicle accident on duty. Intrusive memories of '
          'the scene 3-5 times daily, triggered by sirens. Avoids the '
          'route to the original station; switched assignments. Sleep: '
          'nightmares 2-3 nights/week, waking with sweat. Hypervigilance '
          'driving. PCL-5 today = 47. Reports irritability with partner. '
          "Denies SI but says \"I don't feel like the same person.\" No "
          'substance increase. Wants to keep working but functioning is '
          'slipping.',
      presentingProblems: [
        '4-month post-MVA PTSD presentation; PCL-5 = 47',
        'Intrusions (3-5x daily, siren-triggered)',
        'Avoidance: route + station change',
        'Nightmares 2-3 nights/week + hypervigilance',
        'Functional impact: irritability, identity shift',
      ],
      contextNote:
          'High-risk modality — supervisor co-sign required per catalog. '
          'Frontline first-responder. Strong identity tied to role.',
    ),
    SyntheticVignette(
      id: 'demo-aud-mi',
      label: 'Alcohol Use Disorder · MI (52-year-old)',
      disorderHint: 'alcoholUseDisorder',
      modalityHint: 'mi',
      transcript:
          'Patient (fictional, 52-year-old senior accountant) reports '
          'drinking has crept up over the last 5 years. Currently 4-6 '
          'standard drinks most weeknights, 8-10 on Fridays. AUDIT '
          'screening last week scored 22. Two failed cut-down attempts. '
          'Wife issued an ultimatum about therapy after a missed school '
          'event. Liver enzymes mildly elevated per recent physical. '
          'Sleep fragmented. Mood lower mornings, "lifts" with the first '
          'drink. Engaged in coming today but ambivalent about full '
          'abstinence; open to "cutting back."',
      presentingProblems: [
        'AUDIT = 22 (severe), 5-year progression',
        'Two failed self-cut-down attempts',
        'Partner-imposed ultimatum (external motivation)',
        'Mild hepatic enzyme elevation',
        'Ambivalent about abstinence; receptive to harm reduction',
      ],
      contextNote:
          'High-risk modality — supervisor co-sign required. Coordinate '
          'with PCP re: hepatic monitoring.',
    ),
    SyntheticVignette(
      id: 'demo-insomnia-cbti',
      label: 'Insomnia Disorder · CBT-I (38-year-old)',
      disorderHint: 'insomniaDisorder',
      modalityHint: 'cbti',
      transcript:
          'Patient (fictional, 38-year-old software engineer) reports '
          '6-month course of difficulty falling asleep + early-morning '
          'waking. Sleep latency 45-90 min; wakes at 04:30 unable to '
          'return to sleep 5-7 days/week. Total sleep ~5h. Daytime '
          'fatigue, irritability, decreased concentration at work. No '
          'pain, no apnea symptoms per partner. Started using phone in '
          'bed 8 months ago. Caffeine: 2 espressos before noon only. '
          'No alcohol. Has tried melatonin OTC with little effect. '
          'Functional but increasingly distressed.',
      presentingProblems: [
        '6-month chronic insomnia (onset + early-morning waking)',
        'Sleep efficiency ~70% (5h sleep / 7h time in bed)',
        'Daytime fatigue + concentration loss',
        'Sleep-incompatible behaviour: phone in bed',
        'Failed self-treatment (melatonin)',
      ],
      contextNote:
          'No co-morbid anxiety / mood by report. Strong fit for CBT-I.',
    ),
  ];

  static SyntheticVignette? byId(String id) {
    for (final v in vignettes) {
      if (v.id == id) return v;
    }
    return null;
  }
}
