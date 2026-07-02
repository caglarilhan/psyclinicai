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
      lastUpdated: DateTime(2026, 7),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('1. You sign the notes'),
          StaticP(
            'PsyClinicAI drafts; you review, edit, and sign every note. '
            'The signed note is the legal record. We are not a licensed '
            'clinician and do not practise medicine.',
          ),
          StaticH2('2. We do not own your data'),
          StaticP(
            'Every byte of patient data is yours. Export at any time as '
            'JSON + PDF. We retain it only as long as you stay '
            'subscribed (plus a 30-day grace period for export).',
          ),
          StaticH2('3. Service tiers + the LLM you get'),
          StaticP(
            'PsyClinicAI ships in three tiers, and each tier calls a '
            'different LLM back-end. You choose the tier per workspace.',
          ),
          StaticBullet(
            'Demo tier — Groq (llama-3.3) with Google Gemini fallback. '
            'Free. Blocked from processing PHI: only the synthetic '
            'vignettes we ship in the app may be sent. No BAA is offered '
            'for Demo tier and none is required, because Demo tier does '
            'not process real patient data.',
          ),
          StaticBullet(
            'BYOK tier — you bring your own Anthropic (or OpenAI) API '
            "key. You sign the vendor's BAA and DPA directly; PsyClinicAI "
            'never sees or stores that key server-side beyond the '
            'per-request relay. HIPAA and GDPR liability for the LLM '
            'processing stays with the vendor you contracted.',
          ),
          StaticBullet(
            'Pro tier — PsyClinicAI-hosted Anthropic access under our own '
            'BAA + DPA. Covered under this ToS end-to-end.',
          ),
          StaticH2('4. BAA delegation (US clinicians)'),
          StaticP(
            'HIPAA §164.308(b)(1) requires a signed BAA before any '
            'Business Associate touches PHI. On Demo tier this is moot '
            '— we do not accept PHI there. On BYOK tier the clinician is '
            'responsible for signing the Anthropic (or OpenAI) BAA '
            'directly; PsyClinicAI records the acceptance timestamp at '
            'settings → BYOK LLM keys → "I have signed the HIPAA BAA" '
            "and treats that checkbox as the clinician's attestation. "
            'On Pro tier PsyClinicAI signs the upstream BAA and takes on '
            'the Business Associate role.',
          ),
          StaticH2('5. Subscription + cancellation'),
          StaticBullet('Monthly + annual plans. Cancel anytime from settings.'),
          StaticBullet('30-day money-back during pilot, no questions asked.'),
          StaticBullet(
            'No automatic price hike at month 7 — we email you at '
            'month 5 to confirm.',
          ),
          StaticH2('6. Acceptable use'),
          StaticP(
            'No re-selling the platform or scraping its UI. No use '
            'against minors without lawful parental consent. No use '
            'in jurisdictions where AI-assisted clinical notes are '
            'prohibited. Do not paste real patient data into a '
            'Demo-tier workspace — that would place PHI in front of an '
            'LLM you have not signed a BAA with, and is a breach of '
            'this ToS on the clinician side.',
          ),
          StaticH2('7. Warranties + liability'),
          StaticP(
            'We provide PsyClinicAI as-is. We commit to the security '
            'controls listed at /security and to the uptime band at '
            '/status. Beyond that, our liability is capped at the '
            'fees you paid in the prior 12 months.',
          ),
          StaticH2('8. Governing law'),
          StaticP(
            'Frankfurt, Germany (EU clinicians) or Delaware, USA (US '
            'clinicians). You choose at onboarding based on residency.',
          ),
          StaticH2('9. Changes'),
          StaticP(
            'We email every clinician 30 days before any material '
            'change. Continued use after the effective date is '
            'acceptance.',
          ),
        ],
      ),
    );
  }
}
