/// P5 wire-up — Trust center policy catalog index page.
///
/// Renders the same auditor-facing brief as
/// `docs/handoff/CATALOG-INDEX.md`, grouped by family
/// (AI / Compliance / Security / Data / Ops / Clinical). Lets a
/// regulator land on `/trust/catalogs`, find the row for the policy
/// they're auditing, and get the regulatory anchors + the PR number
/// without grepping the repo.
///
/// **Out of scope** (separate PRs):
///   * Route binding in `lib/router/app_router.dart` (opt-in).
///   * Live `lastReviewed` badge color logic ("needs review" red
///     after 12 months).
///   * Deep-link from each row to the catalog source file via
///     GitHub blob URL (CI-generated).
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';

class PolicyCatalogIndexScreen extends StatelessWidget {
  const PolicyCatalogIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/trust/catalogs',
      title: 'Policy catalog index',
      subtitle:
          'Every pinned policy + its regulatory anchors. Auditor-defensible — search the family, find the row.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final family in PolicyCatalogIndex.families)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _FamilyCard(family: family),
            ),
          const SizedBox(height: PsySpacing.md),
          const _FullIndexHint(),
        ],
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({required this.family});

  final PolicyCatalogFamily family;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(family.title, style: t.titleMedium),
                const SizedBox(width: PsySpacing.sm),
                _CountChip(count: family.entries.length),
              ],
            ),
            const SizedBox(height: PsySpacing.xs),
            Text(family.subtitle, style: t.bodySmall),
            const Divider(),
            for (final entry in family.entries) _PolicyRow(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.entry});

  final PolicyCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              entry.id,
              style: t.labelLarge?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: t.bodyMedium),
                Text(
                  entry.regulatoryAnchors,
                  style: t.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count', style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _FullIndexHint extends StatelessWidget {
  const _FullIndexHint();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full machine-readable index',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: PsySpacing.xs),
            Text(
              'docs/handoff/CATALOG-INDEX.md ships the complete row-per-catalog table including PR number + every regulatory anchor citation. The on-screen index here is the family-grouped summary.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class PolicyCatalogEntry {
  const PolicyCatalogEntry({
    required this.id,
    required this.title,
    required this.regulatoryAnchors,
  });

  final String id;
  final String title;
  final String regulatoryAnchors;
}

class PolicyCatalogFamily {
  const PolicyCatalogFamily({
    required this.title,
    required this.subtitle,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final List<PolicyCatalogEntry> entries;
}

class PolicyCatalogIndex {
  const PolicyCatalogIndex._();

  static const List<PolicyCatalogFamily> families = [
    PolicyCatalogFamily(
      title: 'AI governance (L)',
      subtitle: 'LLM output safety, training data, oversight, override audit',
      entries: [
        PolicyCatalogEntry(
          id: 'L9',
          title: 'PHI scrub pattern',
          regulatoryAnchors: 'HIPAA Safe Harbor §164.514(b)(2)(i)',
        ),
        PolicyCatalogEntry(
          id: 'L10',
          title: 'AI usage budget',
          regulatoryAnchors: 'EU AI Act Art. 14 + cost containment',
        ),
        PolicyCatalogEntry(
          id: 'L11',
          title: 'AI hallucination warning',
          regulatoryAnchors:
              'FDA CDS Sep 2022 + Joint Commission NPSG + EU AI Act Annex III §5(b)',
        ),
        PolicyCatalogEntry(
          id: 'L12',
          title: 'Clinician override audit',
          regulatoryAnchors:
              'EU AI Act Art. 14 + HIPAA §164.312(b) + §164.316(b)(2)(i)',
        ),
      ],
    ),
    PolicyCatalogFamily(
      title: 'Compliance (K)',
      subtitle: 'GDPR + HIPAA + KVKK + consent + retention + DSAR',
      entries: [
        PolicyCatalogEntry(
          id: 'K14',
          title: 'DPIA trigger',
          regulatoryAnchors: 'GDPR Art. 35 + EDPB WP248 rev.01',
        ),
        PolicyCatalogEntry(
          id: 'K15',
          title: 'Data retention class',
          regulatoryAnchors:
              'GDPR Art. 5(1)(e) + HIPAA §164.316(b)(2)(i) + NHS England RMC',
        ),
        PolicyCatalogEntry(
          id: 'K16',
          title: 'GDPR lawful basis',
          regulatoryAnchors: 'GDPR Art. 6(1) + Art. 7(3) + Art. 9(2)',
        ),
        PolicyCatalogEntry(
          id: 'K17',
          title: 'DSAR deadline',
          regulatoryAnchors: 'GDPR Art. 12(3) + HIPAA §164.524 + §164.526',
        ),
      ],
    ),
    PolicyCatalogFamily(
      title: 'Security (N)',
      subtitle: 'Auth + key mgmt + vulnerability + DR + headers + rate limit',
      entries: [
        PolicyCatalogEntry(
          id: 'N20',
          title: 'Encryption key rotation',
          regulatoryAnchors:
              'NIST SP 800-57 + HIPAA §164.312(a)(2)(iv) + PCI DSS §3.7',
        ),
        PolicyCatalogEntry(
          id: 'N22',
          title: 'DR RPO/RTO',
          regulatoryAnchors:
              'HIPAA §164.308(a)(7)(ii)(B) + ISO 27001 A.17.1 + SOC 2 A1.2',
        ),
        PolicyCatalogEntry(
          id: 'N23',
          title: 'Authenticator Assurance Level',
          regulatoryAnchors: 'NIST SP 800-63B + HIPAA §164.312(d) + FIDO2',
        ),
        PolicyCatalogEntry(
          id: 'N24',
          title: 'Security HTTP headers',
          regulatoryAnchors: 'OWASP ASVS V14.4 + RFC 6797 + W3C CSP Level 3',
        ),
        PolicyCatalogEntry(
          id: 'N25',
          title: 'API rate limit',
          regulatoryAnchors:
              'OWASP API Top-10 API4:2023 + NIST SP 800-63B §5.2.2',
        ),
        PolicyCatalogEntry(
          id: 'N27',
          title: 'CORS allowed-origin',
          regulatoryAnchors: 'OWASP API Top-10 API8:2023 + W3C Fetch CORS',
        ),
      ],
    ),
    PolicyCatalogFamily(
      title: 'Data + ops (O)',
      subtitle: 'Tenants + env + scheduled jobs + analytics',
      entries: [
        PolicyCatalogEntry(
          id: 'O8',
          title: 'Tenant isolation policy',
          regulatoryAnchors: 'HIPAA §164.502(b) + OWASP API BOLA + SOC 2 CC6.1',
        ),
        PolicyCatalogEntry(
          id: 'O9',
          title: 'Required env var',
          regulatoryAnchors: 'SOC 2 CC8.1 + ISO 27001 A.12.1.2',
        ),
        PolicyCatalogEntry(
          id: 'O10',
          title: 'Scheduled job',
          regulatoryAnchors: 'SOC 2 CC7.1 + ISO 27001 A.12.1.3',
        ),
      ],
    ),
    PolicyCatalogFamily(
      title: 'Marketing + comms (M)',
      subtitle: 'Status page + incident comms + launch',
      entries: [
        PolicyCatalogEntry(
          id: 'M6',
          title: 'Status-page audience tier',
          regulatoryAnchors:
              'HIPAA §164.404 + GDPR Art. 33 + ISO 27001 A.16.1.5',
        ),
      ],
    ),
    PolicyCatalogFamily(
      title: 'Clinical (J)',
      subtitle: 'Assessments + crisis + escalation',
      entries: [
        PolicyCatalogEntry(
          id: 'J5',
          title: 'Crisis trigger threshold',
          regulatoryAnchors:
              'Joint Commission NPSG 15.01.01 + FDA CDS Sep 2022 + Kroenke/Spitzer/Posner',
        ),
      ],
    ),
  ];
}
