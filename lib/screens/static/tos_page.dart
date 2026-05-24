import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// `/tos` — plain-English terms summary. Full contract signed at onboarding.
class TosPage extends StatelessWidget {
  const TosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Legal',
      title: 'Terms of service',
      lede:
          'These are the rules of the road for using PsyClinicAI. The '
          'enforceable contract is signed at onboarding; this page is the '
          'plain-English version we want every clinician to read first.',
      lastUpdated: DateTime(2026, 5, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('1. You sign the notes'),
          StaticP(
              'PsyClinicAI drafts; you review, edit, and sign every note. '
              'The signed note is the legal record. We are not a licensed '
              'clinician and do not practise medicine.'),
          StaticH2('2. We do not own your data'),
          StaticP(
              'Every byte of patient data is yours. Export at any time as '
              'JSON + PDF. We retain it only as long as you stay '
              'subscribed (plus a 30-day grace period for export).'),
          StaticH2('3. Subscription + cancellation'),
          StaticBullet(
              'Monthly + annual plans. Cancel anytime from settings.'),
          StaticBullet(
              '30-day money-back during pilot, no questions asked.'),
          StaticBullet(
              'No automatic price hike at month 7 — we email you at '
              'month 5 to confirm.'),
          StaticH2('4. Acceptable use'),
          StaticP(
              'No re-selling the platform or scraping its UI. No use '
              'against minors without lawful parental consent. No use '
              'in jurisdictions where AI-assisted clinical notes are '
              'prohibited.'),
          StaticH2('5. Warranties + liability'),
          StaticP(
              'We provide PsyClinicAI as-is. We commit to the security '
              'controls listed at /security and to the uptime band at '
              '/status. Beyond that, our liability is capped at the '
              'fees you paid in the prior 12 months.'),
          StaticH2('6. Governing law'),
          StaticP(
              'Frankfurt, Germany (EU clinicians) or Delaware, USA (US '
              'clinicians). You choose at onboarding based on residency.'),
          StaticH2('7. Changes'),
          StaticP(
              'We email every clinician 30 days before any material '
              'change. Continued use after the effective date is '
              'acceptance.'),
        ],
      ),
    );
  }
}
