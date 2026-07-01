import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/compare` — programmatic-SEO landing comparing PsyClinicAI to the
/// AI-scribe + EHR products mental-health practices already evaluate.
///
/// Two views:
///   1. A per-vendor feature grid so procurement can scan facts in
///      seconds ("does X have BAA / EU residency / on-device audio").
///   2. Category-level trade-offs so pilots understand where each
///      class of competitor still wins today.
class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Compare',
      title: 'How PsyClinicAI compares.',
      lede:
          'Honest, structured trade-offs against the AI scribes and EHRs '
          'mental-health practices already evaluate. We list where the '
          'competitor wins so you do not have to dig for it.',
      lastUpdated: DateTime(2026, 7),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VendorGrid(),
          SizedBox(height: PsySpacing.xxl),
          _Comparison(
            name: 'vs. legacy EHR (SimplePractice, TherapyNotes)',
            wins: [
              'Audio stays on-device — competitor sends to cloud',
              'BYOK Anthropic — you control the AI model + cost',
              'EU residency baked in (eur3 / Frankfurt)',
              'Open superbill PDF that any clearinghouse can ingest',
            ],
            theyWin: [
              'Mature US claims clearinghouse integration today',
              'In-network insurance billing across all 50 states',
              'On-call US support staff during business hours',
            ],
          ),
          SizedBox(height: PsySpacing.lg),
          _Comparison(
            name: 'vs. AI scribe (Mentalyc, Eleos, Upheal)',
            wins: [
              'Full EHR workflow — scribe → note → superbill in one chart',
              'Region pin choice — competitors are US-only today',
              'GDPR Article 28 DPA + KVKK template ship before contract',
              'Risk escalation chain with audit, not just transcript',
            ],
            theyWin: [
              'Larger US training corpus on therapy-specific notes',
              'Tighter integration with their own scheduling product',
            ],
          ),
          SizedBox(height: PsySpacing.lg),
          _Comparison(
            name: 'vs. paper / generic SaaS (Notion, Google Docs)',
            wins: [
              'PHI-aware: HIPAA Security Rule + GDPR Art. 32 baked in',
              'Audit log with hash-chained integrity (HIPAA §164.312(b))',
              'Subject Access Request portal (GDPR Art. 15/20)',
              'Clinician signature workflow with the audit log entry',
            ],
            theyWin: [
              'Cheaper at zero patients',
              'More flexible for non-clinical workflows',
            ],
          ),
          SizedBox(height: PsySpacing.xxl),
        ],
      ),
    );
  }
}

// ─── Per-vendor feature grid ─────────────────────────────────────────
// Public-record facts about competitors we run into on procurement
// calls. Corrections gladly accepted at press@psyclinicai.com — every
// row cites the vendor's own posture, not our reading of it.
class _VendorRow {
  const _VendorRow({
    required this.vendor,
    required this.category,
    required this.euResidency,
    required this.baa,
    required this.audioOnDevice,
    required this.byok,
    required this.starterPrice,
  });

  final String vendor;

  /// Short "AI scribe" / "EHR" / "AI scribe + EHR" label.
  final String category;

  /// True when the vendor documents an EU data-residency option.
  final bool euResidency;

  /// True when the vendor publicly signs a HIPAA Business Associate
  /// Agreement (US clinicians).
  final bool baa;

  /// True when the audio-to-text pass runs on the clinician's device
  /// (no raw audio uploaded).
  final bool audioOnDevice;

  /// True when the clinician can bring their own LLM key (BYOK).
  final bool byok;

  /// Cheapest paid plan we could find in USD, monthly, per-clinician.
  /// Empty string when the vendor does not publish it.
  final String starterPrice;
}

const _vendorRows = <_VendorRow>[
  _VendorRow(
    vendor: 'PsyClinicAI',
    category: 'AI scribe + EHR',
    euResidency: true,
    baa: true,
    audioOnDevice: true,
    byok: true,
    starterPrice: r'$0 Demo · $99 Pro',
  ),
  _VendorRow(
    vendor: 'Mentalyc',
    category: 'AI scribe',
    euResidency: false,
    baa: true,
    audioOnDevice: false,
    byok: false,
    starterPrice: r'$39',
  ),
  _VendorRow(
    vendor: 'Upheal',
    category: 'AI scribe',
    euResidency: true,
    baa: true,
    audioOnDevice: false,
    byok: false,
    starterPrice: r'$59',
  ),
  _VendorRow(
    vendor: 'Eleos Health',
    category: 'AI scribe',
    euResidency: false,
    baa: true,
    audioOnDevice: false,
    byok: false,
    starterPrice: '',
  ),
  _VendorRow(
    vendor: 'SimplePractice',
    category: 'EHR',
    euResidency: false,
    baa: true,
    audioOnDevice: false,
    byok: false,
    starterPrice: r'$69',
  ),
  _VendorRow(
    vendor: 'TherapyNotes',
    category: 'EHR',
    euResidency: false,
    baa: true,
    audioOnDevice: false,
    byok: false,
    starterPrice: r'$59',
  ),
];

class _VendorGrid extends StatelessWidget {
  const _VendorGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature-by-feature',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The facts procurement asks for first. Every column is a '
            'public vendor claim — corrections welcome at '
            'press@psyclinicai.com.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
          const SizedBox(height: PsySpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                cs.surfaceContainerLow,
              ),
              columns: const [
                DataColumn(label: Text('Vendor')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('EU residency')),
                DataColumn(label: Text('HIPAA BAA')),
                DataColumn(label: Text('Audio on-device')),
                DataColumn(label: Text('BYOK LLM')),
                DataColumn(label: Text('Starter (USD/mo)')),
              ],
              rows: [
                for (final r in _vendorRows)
                  DataRow(
                    color: r.vendor == 'PsyClinicAI'
                        ? WidgetStatePropertyAll(
                            cs.primary.withValues(alpha: 0.08),
                          )
                        : null,
                    cells: [
                      DataCell(
                        Text(
                          r.vendor,
                          style: TextStyle(
                            fontWeight: r.vendor == 'PsyClinicAI'
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: r.vendor == 'PsyClinicAI'
                                ? cs.primary
                                : cs.onSurface,
                          ),
                        ),
                      ),
                      DataCell(Text(r.category)),
                      DataCell(_Yn(value: r.euResidency, cs: cs)),
                      DataCell(_Yn(value: r.baa, cs: cs)),
                      DataCell(_Yn(value: r.audioOnDevice, cs: cs)),
                      DataCell(_Yn(value: r.byok, cs: cs)),
                      DataCell(
                        Text(r.starterPrice.isEmpty ? '—' : r.starterPrice),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Yn extends StatelessWidget {
  const _Yn({required this.value, required this.cs});
  final bool value;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          value ? Icons.check_circle : Icons.remove_circle_outline,
          size: 16,
          color: value ? cs.primary : cs.onSurface.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 6),
        Text(
          value ? 'Yes' : 'No',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value ? cs.primary : cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({
    required this.name,
    required this.wins,
    required this.theyWin,
  });

  final String name;
  final List<String> wins;
  final List<String> theyWin;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PsySpacing.md),
          Text(
            'Where we win',
            style: t.titleSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          for (final w in wins) StaticBullet(w),
          const SizedBox(height: PsySpacing.md),
          Text(
            'Where they win',
            style: t.titleSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          for (final w in theyWin) StaticBullet(w),
        ],
      ),
    );
  }
}
