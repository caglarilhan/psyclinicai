import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// `/press` — press kit landing. Real assets ship in Sprint E; until then
/// this page tells journalists what we will provide and how to ask.
class PressPage extends StatelessWidget {
  const PressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Press',
      title: 'Press kit',
      lede:
          'Working on a story about ambient-AI in mental-health practice? '
          'Here is what we provide and how to reach us. We answer press '
          'enquiries within 24 hours.',
      lastUpdated: DateTime(2026, 5, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('What we provide'),
          StaticBullet(
              'Logo + icon — SVG + PNG at 1×, 2×, 3× density, on light '
              'and dark backgrounds.'),
          StaticBullet(
              'Product screenshots — 1440×900, dashboard / live session / '
              'superbill / outcomes dashboard.'),
          StaticBullet(
              'Brand boilerplate — 50-, 100-, and 200-word descriptions '
              'of PsyClinicAI.'),
          StaticBullet(
              'Founder bio + headshot — on request, signed release.'),
          StaticBullet(
              'Customer pull-quotes — anonymised, pending pilot member '
              'consent.'),
          StaticH2('How to request'),
          StaticP(
              'Email press@psyclinicai.com with your outlet, deadline, '
              'and angle. We reply with assets within 24 hours.'),
          StaticH2('Boilerplate (100 words)'),
          StaticP(
              'PsyClinicAI is the AI co-pilot for therapists and '
              'psychiatrists. Built for clinicians who want their '
              'evenings back, it transcribes live therapy sessions '
              'on-device — audio never leaves the device — and drafts '
              'clinical-grade SOAP / DAP / BIRP notes in under 30 '
              'seconds, then generates the CMS-1500-aligned superbill '
              'the client submits to their insurer. PsyClinicAI is '
              'HIPAA-aligned by architecture, ships with a GDPR Article '
              '28 DPA, and stores patient data in EU residency by '
              'default. Founded 2026, headquartered in Frankfurt.'),
        ],
      ),
    );
  }
}
