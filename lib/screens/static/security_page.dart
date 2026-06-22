import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// `/security` — public security & compliance overview.
class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Trust',
      title: 'Security & Compliance',
      lede:
          'PsyClinicAI is built with the assumption that every byte we touch '
          'is regulated health data. This page documents how we keep it safe — '
          'in plain language, with no marketing varnish.',
      lastUpdated: DateTime(2026, 5, 23),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('1. Data flow at a glance'),
          StaticP(
            'Live therapy audio is transcribed by the operating system on '
            'the clinician device. The audio stream never leaves the device '
            'and is never written to disk by PsyClinicAI. Only the resulting '
            'plain-text transcript is sent — over TLS 1.3 — to the AI vendor '
            'the clinician has chosen (BYOK).',
          ),
          StaticBullet('Audio: clinician device only. No retention.'),
          StaticBullet(
            'Transcript: clinician device + chosen AI vendor (Anthropic '
            'today). Held only for the duration of the API call.',
          ),
          StaticBullet(
            "AI-drafted note: stored in Firestore under the clinic owner's "
            'tenant, encrypted at rest (AES-256) by Google Cloud.',
          ),
          StaticBullet(
            'Superbill PDFs + assessment scores: stored alongside the '
            'patient record, scoped to the clinic owner.',
          ),
          StaticH2('2. Encryption'),
          StaticBullet(
            'In transit: TLS 1.3 everywhere — public web, '
            'Firestore, AI vendor APIs.',
          ),
          StaticBullet(
            'At rest: AES-256 via Google Cloud envelope encryption. '
            'Key rotation handled by Google Cloud KMS.',
          ),
          StaticBullet(
            'Local browser storage: never used for PHI. Only the BYOK '
            'API key fingerprint and the user session.',
          ),
          StaticH2('3. Tenant isolation'),
          StaticP(
            'Solo-practice model: every clinician owns a single tenant '
            'whose ID equals their Firebase Auth UID. Firestore security '
            'rules deny all cross-tenant reads and writes by default. '
            'Group practices share a clinic ID assigned at sign-up; access '
            'is granted via per-clinician role in the same tenant document.',
          ),
          StaticH2('4. Authentication'),
          StaticBullet('Email + password sign-in via Firebase Authentication.'),
          StaticBullet(
            'Password reset emails sent by Firebase; no link is logged '
            'or replayed by PsyClinicAI.',
          ),
          StaticBullet(
            '2FA + SSO (SAML / Google Workspace) shipping with the '
            'Practice tier in Sprint E.',
          ),
          StaticH2('5. Sub-processors'),
          StaticBullet(
            'Google Cloud / Firebase — hosting, Firestore, Cloud KMS, '
            'Cloud Functions. EU multi-region by default; US clinicians '
            'opt into us-central1.',
          ),
          StaticBullet(
            'Anthropic (via BYOK) — generates SOAP / DAP / BIRP notes. '
            'The clinician signs the BAA directly; PsyClinicAI never '
            'holds the BAA-protected data path.',
          ),
          StaticBullet(
            'Hetzner — fall-back static hosting in Frankfurt (EU). '
            'Serves the public landing page only; no PHI ever lands here.',
          ),
          StaticH2('6. Compliance'),
          StaticBullet(
            'HIPAA-aligned by architecture: minimum-necessary access, '
            'tenant isolation, audit log on every write, BAA-protected '
            "AI processing via the clinician's own Anthropic account.",
          ),
          StaticBullet(
            'GDPR — Article 28 DPA available to every paying clinic. '
            'EU data residency by default. Right-to-erasure shipping in '
            'Sprint E.',
          ),
          StaticBullet(
            'KVKK (Türkiye) — VERBİS pre-registration template '
            'available for TR clinicians on request.',
          ),
          StaticH2('7. Vulnerability disclosure'),
          StaticP(
            'Found a vulnerability? Email security@psyclinicai.com with '
            'the steps to reproduce. We acknowledge within 24 hours, '
            'triage within 72 hours, and credit you in our release notes '
            'unless you ask us not to.',
          ),
          StaticH2('8. Backups & disaster recovery'),
          StaticBullet(
            'Firestore: daily snapshot, 30-day retention. Point-in-time '
            'recovery up to 7 days.',
          ),
          StaticBullet(
            'Hetzner static host: nightly rsync to off-site cold storage.',
          ),
          StaticBullet(
            'Quarterly DR drill — restore an isolated copy and verify '
            'integrity of a synthetic patient cohort.',
          ),
        ],
      ),
    );
  }
}
