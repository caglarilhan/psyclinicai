import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Comparison vs. major EHRs.
class ComparisonTableSection extends StatelessWidget {
  const ComparisonTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final rows = <_Row>[
      _Row('Ambient AI session notes',
          psy: 'Built-in',
          simple: 'Care Aide (beta)',
          therapy: 'TherapyFuel',
          upheal: 'Built-in'),
      _Row('On-device transcription (no audio leaves device)',
          psy: 'Yes', simple: 'No', therapy: 'No', upheal: 'No'),
      _Row('BYOK — pick your own AI vendor',
          psy: 'Yes', simple: 'No', therapy: 'No', upheal: 'No'),
      _Row('Superbill PDF generator',
          psy: 'Built-in',
          simple: 'Add-on',
          therapy: 'Built-in',
          upheal: 'Coming 2026'),
      _Row('PHQ-9 / GAD-7 longitudinal dashboard',
          psy: 'Built-in',
          simple: 'Manual',
          therapy: 'Manual',
          upheal: 'Built-in'),
      _Row('Multi-jurisdiction compliance (HIPAA + GDPR + KVKK)',
          psy: 'Built-in',
          simple: 'HIPAA only',
          therapy: 'HIPAA only',
          upheal: 'HIPAA + GDPR'),
      _Row('EU data residency by default',
          psy: 'Yes', simple: 'No', therapy: 'No', upheal: 'Opt-in'),
      _Row('Founding price (solo)',
          psy: r'$49 / mo',
          simple: r'$49–99 / mo',
          therapy: r'$59–99 / mo',
          upheal: r'$69 / mo'),
    ];

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('Side by side'),
          const SizedBox(height: 12),
          const SectionTitle('How we compare.'),
          const SizedBox(height: 12),
          const SectionSubtitle(
              'Apples-to-apples on the capabilities that move the needle.'),
          const SizedBox(height: 32),
          _Table(rows: rows, theme: theme, cs: cs),
          const SizedBox(height: 12),
          Text(
            "Competitor data sourced from each vendor's public product pages, May 2026.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row {
  _Row(this.feature,
      {required this.psy,
      required this.simple,
      required this.therapy,
      required this.upheal});
  final String feature;
  final String psy;
  final String simple;
  final String therapy;
  final String upheal;
}

class _Table extends StatelessWidget {
  const _Table(
      {required this.rows, required this.theme, required this.cs});
  final List<_Row> rows;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final header = TableRow(
      decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08)),
      children: [
        _HeaderCell('Feature', theme, cs),
        _HeaderCell('PsyClinicAI', theme, cs, highlight: true),
        _HeaderCell('SimplePractice', theme, cs),
        _HeaderCell('TherapyNotes', theme, cs),
        _HeaderCell('Upheal', theme, cs),
      ],
    );
    final rowsBuilt = rows.map(
      (r) => TableRow(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        children: [
          _Cell(r.feature, theme, cs, bold: true),
          _Cell(r.psy, theme, cs, highlight: true),
          _Cell(r.simple, theme, cs),
          _Cell(r.therapy, theme, cs),
          _Cell(r.upheal, theme, cs),
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
        },
        children: [header, ...rowsBuilt],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, this.theme, this.cs,
      {this.highlight = false});
  final String text;
  final ThemeData theme;
  final ColorScheme cs;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: highlight
          ? BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              border: Border(
                left: BorderSide(color: cs.primary, width: 3),
                right: BorderSide(color: cs.primary, width: 3),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (highlight)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'OUR PICK',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? cs.primary : cs.onSurface,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, this.theme, this.cs,
      {this.bold = false, this.highlight = false});
  final String text;
  final ThemeData theme;
  final ColorScheme cs;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: highlight
          ? BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              border: Border(
                left: BorderSide(color: cs.primary, width: 3),
                right: BorderSide(color: cs.primary, width: 3),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: highlight ? cs.primary : cs.onSurface,
          height: 1.4,
        ),
      ),
    );
  }
}
