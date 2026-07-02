import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/help` — support hub. Top-of-funnel FAQ + inbox routing.
///
/// Distinct from `/contact` (single email index) and `/faq` (marketing
/// copy answering pre-purchase objections). This page catches the
/// clinician *already using the product* who needs a hand.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Support',
      title: 'Help center',
      lede:
          'The fastest path to a fix. If your question is not below, '
          'email the address that fits — every inbox has a human on '
          'call during EU + US business hours.',
      lastUpdated: DateTime(2026, 7),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            title: 'Setup + BYOK',
            entries: [
              _Faq(
                q: 'How do I enable AI drafting?',
                a: 'Settings → BYOK LLM keys (cloud) → paste your Anthropic '
                    'API key → tick the BAA acceptance checkbox → Save. The '
                    'next SOAP or plan draft will route through your key.',
              ),
              _Faq(
                q: 'Can I try the AI without a key?',
                a: 'Yes — every workspace ships with Demo tier turned on. '
                    'Demo tier uses Groq (with Google Gemini fallback) '
                    'against the synthetic vignettes we ship. Never paste '
                    'real patient data into a Demo workspace.',
              ),
              _Faq(
                q: 'How does the Demo → BYOK switch work?',
                a: 'The moment you save a BYOK key, the chain reprioritises '
                    'to Anthropic-first for that clinician and Demo '
                    'providers step out of the path. No redeploy needed.',
              ),
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
          _Section(
            title: 'Clinical workflow',
            entries: [
              _Faq(
                q: 'Where do my SOAP drafts live?',
                a: 'Dashboard → "Draft SOAP" tile → each draft carries the '
                    'schema version + provider tag so you can trace which '
                    'model wrote which section before you sign.',
              ),
              _Faq(
                q: 'How do I resolve a PHI redaction flag?',
                a: 'Draft review shows the redaction count. Tap the section '
                    'tab, replace the [REDACTED] token with the correct '
                    'text (or leave it blank), then sign — the signed note '
                    'is the legal record.',
              ),
              _Faq(
                q: 'Can I roll back a signed note?',
                a: 'Signed notes are append-only. To correct, add a new '
                    "addendum linked to the original — that's the audit "
                    'trail HIPAA §164.312(b) requires.',
              ),
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
          _Section(
            title: 'Data + privacy',
            entries: [
              _Faq(
                q: 'How do I export my data?',
                a: 'Settings → Data → Export. You get every note + '
                    'assessment as JSON plus a rendered PDF bundle, '
                    'delivered to the email on file.',
              ),
              _Faq(
                q: 'How do I close my account?',
                a: 'Settings → Data → Delete my account. We hard-delete '
                    'after a 30-day grace window and log the erasure '
                    'timestamp for GDPR Art. 17.',
              ),
              _Faq(
                q: 'Where is my clinical data stored?',
                a: 'EU-Central (Frankfurt) by default. The residency pin is '
                    'set once at onboarding and cannot be changed silently '
                    '— we email 30 days ahead of any move.',
              ),
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
          _Section(
            title: 'When to email whom',
            entries: [
              _Faq(
                q: 'Something is broken in the app.',
                a: 'founders@psyclinicai.com — attach a screenshot + the '
                    'time the error hit. Same-day reply.',
              ),
              _Faq(
                q: 'I found a security bug.',
                a: 'security@psyclinicai.com — PGP available on request. '
                    'We acknowledge within 24 hours.',
              ),
              _Faq(
                q: 'I have a GDPR data-subject request.',
                a: 'privacy@psyclinicai.com — we acknowledge within 24 '
                    'hours and resolve within 30 days.',
              ),
              _Faq(
                q: 'I want a BAA / DPA signed.',
                a: 'legal@psyclinicai.com — counter-signed PDF returns '
                    'within 1 business day.',
              ),
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
          _StatusLink(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.entries});
  final String title;
  final List<_Faq> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaticH2(title),
        for (final e in entries) _FaqTile(faq: e),
      ],
    );
  }
}

class _Faq {
  const _Faq({required this.q, required this.a});
  final String q;
  final String a;
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});
  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: Container(
        padding: const EdgeInsets.all(PsySpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(PsyRadius.md),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.q,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              faq.a,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
                height: 1.55,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLink extends StatelessWidget {
  const _StatusLink();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.monitor_heart_outlined, color: cs.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Suspect a platform issue? Check the live status page.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/status'),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('Open /status'),
        ),
      ],
    );
  }
}
