import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// `/contact` — single source of truth for talking to the team. Email
/// instead of a generic form so replies stay traceable.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Talk to us',
      title: 'Contact',
      lede:
          'We answer every email within 24 hours, often within four. '
          'Route your message to the right inbox below for the fastest '
          'reply.',
      lastUpdated: DateTime(2026, 5, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('Sales + pilots'),
          StaticP(
              'founders@psyclinicai.com — pilot pricing, onboarding, '
              'group practice quotes, custom integrations.'),
          StaticH2('Security + compliance'),
          StaticP(
              'security@psyclinicai.com — vulnerability disclosure, BAA '
              'questions, GDPR data-subject requests, audit packets.'),
          StaticH2('Privacy + data requests'),
          StaticP(
              'privacy@psyclinicai.com — access / correction / deletion. '
              'We acknowledge within 24 hours and resolve within 30 days.'),
          StaticH2('Press + partnerships'),
          StaticP(
              'press@psyclinicai.com — interview requests, press kit '
              '(logo + screenshots + boilerplate), co-marketing.'),
          StaticH2('Office'),
          StaticP(
              'PsyClinicAI · Frankfurt am Main · Germany · EU. We are a '
              'fully remote team available across US and EU time zones.'),
        ],
      ),
    );
  }
}
