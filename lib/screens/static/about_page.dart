import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// `/about` — mission, founder, why-now.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Company',
      title: 'Built so clinicians keep their evenings.',
      lede:
          'PsyClinicAI exists to give therapists and psychiatrists the same '
          'ambient-AI leverage that lawyers and developers already get — '
          "without ever asking them to send a patient's voice to the cloud.",
      lastUpdated: DateTime(2026, 5, 23),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('Why we started'),
          StaticP(
              'Therapists spend a median 64 hours per month writing session '
              'notes and chasing insurance superbills — work that does not '
              'change a single patient outcome but eats their evenings, '
              'their relationships, and their will to keep practising.'),
          StaticP(
              'Existing EHRs either ignore AI or wrap it in a private label '
              'that locks the clinician into an opaque vendor. We took the '
              'opposite approach: the clinician brings their own AI key '
              '(BYOK), keeps the audio on-device, and owns every byte of '
              'the resulting record.'),
          StaticH2('What we believe'),
          StaticBullet(
              'Audio should never leave the device that captured it.'),
          StaticBullet(
              'The clinician — not the vendor — owns the patient record.'),
          StaticBullet('AI drafts. Humans sign. Every edit is logged.'),
          StaticBullet(
              'Compliance is an architecture decision, not a marketing badge.'),
          StaticH2('Who we are'),
          StaticP(
              "We're an engineering team partnered with licensed clinical "
              "advisors who review every prompt and every severity band. "
              "Frankfurt-headquartered for EU data residency; available "
              "across US time zones for pilot support. We do not publish "
              "team headshots — clinicians evaluate us on the product and "
              "the architecture, not the marketing photos."),
          StaticH2('Roadmap milestones'),
          StaticBullet(
              'Q2 2026 — Live AI Co-Pilot, Superbill, MBC (shipped).'),
          StaticBullet(
              'Q2 2026 — Firestore persistence + multi-tenant rules '
              '(shipped).'),
          StaticBullet(
              'Q3 2026 — Patient CRUD + outcome dashboard (in flight).'),
          StaticBullet(
              'Q3 2026 — Sentry + PostHog observability, Lighthouse CI.'),
          StaticBullet(
              'Q4 2026 — 2FA / SSO, Stripe live billing, mobile native '
              'parity.'),
          StaticH2('Press / partnerships'),
          StaticP(
              'Email founders@psyclinicai.com. Press kit (logo, screenshots, '
              'boilerplate) on request.'),
        ],
      ),
    );
  }
}
