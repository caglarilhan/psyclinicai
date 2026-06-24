import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// `/privacy` — plain-English privacy summary. Full GDPR Article 28 DPA
/// + HIPAA notice available on request before any contract is signed.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Legal',
      title: 'Privacy policy',
      lede:
          'This is a plain-English summary. Our full GDPR Article 28 DPA '
          'and HIPAA-aligned privacy notice are available on request '
          '(founders@psyclinicai.com) before any contract is signed.',
      lastUpdated: DateTime(2026, 5, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('1. What we collect'),
          StaticBullet(
            'Account data: clinician name, email, role, NPI (optional), '
            'BAA acceptance timestamp.',
          ),
          StaticBullet(
            'Operational data: session metadata (timestamp, duration), '
            'AI note markdown, superbill PDFs, assessment answers.',
          ),
          StaticBullet('No raw audio. No browser cookies beyond your session.'),
          StaticH2('2. What we never collect'),
          StaticBullet(
            'Audio recordings. Transcription happens on your device; '
            'we never store the raw recording.',
          ),
          StaticBullet('Patient identity beyond what you choose to enter.'),
          StaticBullet(
            'Third-party analytics that identify clinicians or '
            'patients individually.',
          ),
          StaticH2('3. How long we keep it'),
          StaticBullet('Active account: as long as you stay subscribed.'),
          StaticBullet(
            'After cancellation: 30-day grace period for data export, '
            'then a hard-delete sweep with an audit-log entry.',
          ),
          StaticBullet(
            'GDPR right-to-erasure: one-click in Settings → Data → '
            'Delete my account.',
          ),
          StaticH2('4. Who we share with'),
          StaticBullet(
            'Anthropic (your BYOK key) — only the session transcript '
            'for the duration of one API call. You signed their BAA.',
          ),
          StaticBullet(
            'Google Cloud / Firebase — encrypted-at-rest storage of '
            'your tenant. EU region by default.',
          ),
          StaticBullet('No marketing, no resale, no ad networks. Ever.'),
          StaticH2('5. Your rights'),
          StaticBullet(
            'Access — see all your data via Settings → Data → Export.',
          ),
          StaticBullet('Correction — edit any field in the app.'),
          StaticBullet(
            'Deletion — one click; 30-day cooling-off period after '
            'which the data is unrecoverable.',
          ),
          StaticBullet(
            'Complaint — your local DPA (GDPR), HHS Office for Civil '
            'Rights (HIPAA), or KVKK (Türkiye).',
          ),
          StaticH2('6. Contact'),
          StaticP(
            'Email privacy@psyclinicai.com. We acknowledge within '
            '24 hours and resolve within 30 days, sooner where the '
            'law requires.',
          ),
          _KvkkLink(),
        ],
      ),
    );
  }
}

class _KvkkLink extends StatelessWidget {
  const _KvkkLink();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/legal/kvkk'),
          icon: Icon(Icons.menu_book_outlined, color: cs.primary),
          label: const Text('Türkçe: KVKK md. 10 aydınlatma metni'),
        ),
      ),
    );
  }
}
