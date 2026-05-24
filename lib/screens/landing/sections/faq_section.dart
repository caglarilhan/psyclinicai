import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// 7-item FAQ — addresses the most common objections a clinician raises
/// before they will paste their card number.
class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _open;

  static const _items = <_Faq>[
    _Faq(
      q: 'Is the audio really kept on device?',
      a: 'Yes. We use the operating system\'s built-in speech-to-text — on '
          'macOS, Windows, iOS, and Android. The audio is transcribed locally '
          'and never uploaded to any server, including ours. Only the resulting '
          'text transcript is sent to the AI model you choose.',
    ),
    _Faq(
      q: 'What is BYOK and why does it matter?',
      a: 'BYOK = Bring Your Own Key. You sign a BAA directly with Anthropic '
          'and paste your API key into PsyClinicAI. That means PsyClinicAI '
          'never holds the BAA-protected data path, only orchestrates it. '
          'It also means your per-token cost is at-cost, not marked up.',
    ),
    _Faq(
      q: 'Is PsyClinicAI HIPAA-compliant?',
      a: 'PsyClinicAI is HIPAA-aligned by architecture: TLS 1.3 in transit, '
          'AES-256 at rest, no audio retention, BAA-protected AI processing '
          'via your own Anthropic account. A signed BAA covering PsyClinicAI '
          'itself is in legal review and available to founding members.',
    ),
    _Faq(
      q: 'Where is patient data stored?',
      a: 'Firestore in europe-west3 (Frankfurt) by default for EU clinicians, '
          'us-central1 for US clinicians. PHI never crosses regions. '
          'A GDPR Article 28 DPA is provided to every paying clinic.',
    ),
    _Faq(
      q: 'Can I cancel anytime?',
      a: 'Yes, monthly plans cancel anytime from the in-app settings page. '
          'Annual founding rates are honoured for the full year — but you can '
          'export every byte of your data, encrypted, before you leave.',
    ),
    _Faq(
      q: 'Does the AI replace my clinical judgement?',
      a: 'No. The AI drafts a structured note from the transcript and flags '
          'risk language; you review, edit, and sign every note. We log every '
          'AI suggestion alongside the clinician\'s edit so the audit trail '
          'is bulletproof.',
    ),
    _Faq(
      q: 'How do I get my data out?',
      a: 'One-click export from Settings → Data: a zip file with every '
          'session note, assessment, and superbill as JSON + PDF. No vendor '
          'lock-in — your patient records are yours.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('Questions clinicians ask'),
          const SizedBox(height: 12),
          const SectionTitle('Straight answers.'),
          const SizedBox(height: 12),
          const SectionSubtitle(
              'No marketing fog. If you have a question we did not answer, '
              'email founders@psyclinicai.com.'),
          const SizedBox(height: 36),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              children: List.generate(_items.length, (i) {
                final open = _open == i;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: open
                          ? cs.primary.withValues(alpha: 0.5)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _open = open ? null : i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _items[i].q,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600),
                                  ),
                                ),
                                AnimatedRotation(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  turns: open ? 0.5 : 0,
                                  child: Icon(Icons.expand_more,
                                      color: cs.primary),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Text(
                                  _items[i].a,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurface
                                        .withValues(alpha: 0.78),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              crossFadeState: open
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 200),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq {
  const _Faq({required this.q, required this.a});
  final String q;
  final String a;
}
