import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/faq` — public FAQ. Drives schema.org FAQPage payload + organic
/// search traffic (rapor 12 seo-audit).
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Frequently asked',
      title: 'Answers we get every week.',
      lede:
          'Did not find your question? Email founders@psyclinicai.com '
          'and we will write the answer back to you within 24 hours.',
      lastUpdated: DateTime(2026, 6, 2),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Faq(
            q: 'Is the patient audio ever uploaded?',
            a:
                'No. Audio is transcribed on the clinician device by the '
                'operating system speech engine and discarded immediately. '
                'Only the plain-text transcript is sent — over TLS 1.3 — '
                'to the AI vendor the clinician picked under BYOK.',
          ),
          _Faq(
            q:
                'How is PsyClinicAI HIPAA-aligned without being a covered '
                'entity?',
            a:
                'We are the Business Associate (45 CFR §160.103). A signed '
                'BAA goes out before any US PHI is uploaded. We meet '
                'Administrative, Physical and Technical Safeguards under '
                '§164.308–§164.312 and notify in 60 days (target 72 h).',
          ),
          _Faq(
            q: 'Where does my data live?',
            a:
                'You choose at provisioning: EU (Frankfurt, eur3) or US '
                '(Iowa, us-central1). We do not cross-replicate clinical '
                'records between regions. KMS keys, audit logs and '
                'transactional email pipelines follow the region.',
          ),
          _Faq(
            q: 'Can I export everything if I cancel?',
            a:
                'Yes. Settings → Data export gives you a JSON bundle with '
                'every record we hold (GDPR Article 20 portability). '
                'Account deletion runs a 30-day grace period before a '
                'scheduled job pseudonymises the remainder.',
          ),
          _Faq(
            q: 'Why BYOK instead of a managed AI?',
            a:
                'Three reasons: (1) clinicians can route their AI spend '
                'through their own books, (2) we never sit between a '
                'transcript and Anthropic, (3) you can rotate or revoke '
                'the key without filing a ticket with us. A server-side '
                'proxy with KMS-wrapped keys lands Sprint 19 for clinics '
                'that prefer the managed path.',
          ),
          _Faq(
            q: 'Is the AI making the diagnosis?',
            a:
                'No. The AI surfaces DSM-5 differential candidates with the '
                'criteria they met and the criteria still missing. The '
                'clinician accepts, rejects or modifies — every decision '
                'is signed and logged. We do not make a clinical decision.',
          ),
          _Faq(
            q: 'Does the platform meet the EU AI Act risk-tier rules?',
            a:
                'The AI features fall into the "limited risk" tier because '
                'they generate text the clinician reviews and signs. The '
                'AI diagnosis surface is being classified as MDR Class IIa '
                'CDSS; CE marking work is ongoing with a notified body.',
          ),
          SizedBox(height: PsySpacing.xxl),
        ],
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq({required this.q, required this.a});
  final String q;
  final String a;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [StaticH2(q), StaticP(a)],
      ),
    );
  }
}
