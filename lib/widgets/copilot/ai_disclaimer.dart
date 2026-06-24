/// Reusable disclaimer ribbon for every LLM-generated surface in
/// the app. Mandatory under HIPAA §164.502 (minimum-necessary +
/// clinician-as-decision-maker) + general clinical-safety best
/// practice — every AI-drafted output must be read as decision
/// support, not as a diagnosis or order.
///
/// Three variants:
///   - `AiDisclaimer.compact()` — single-line ribbon for tight
///     header bars (LiveAiPanel, dropdown, drawer).
///   - `AiDisclaimer.full()` — card with icon + body + optional
///     "what's drafted" tag. Use above any AI-drafted form.
///   - `AiDisclaimer.footer()` — quiet footnote for transcript
///     panels where the clinician has already seen the full
///     disclaimer at the top.
///
/// All variants render a stable telemetry hint
/// (`ai_disclaimer.<variant>.shown`) so we can audit coverage.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';

enum AiDisclaimerVariant { compact, full, footer }

class AiDisclaimer extends StatefulWidget {
  const AiDisclaimer._({
    required this.variant,
    required this.surface,
    this.draftedLabel,
  });

  /// Compact one-line ribbon — header / inline use.
  factory AiDisclaimer.compact({required String surface}) =>
      AiDisclaimer._(variant: AiDisclaimerVariant.compact, surface: surface);

  /// Full card — sits above a draft form / AI output. Optional
  /// `draftedLabel` like "AI-drafted SOAP" surfaces above the body.
  factory AiDisclaimer.full({required String surface, String? draftedLabel}) =>
      AiDisclaimer._(
        variant: AiDisclaimerVariant.full,
        surface: surface,
        draftedLabel: draftedLabel,
      );

  /// Quiet footnote — bottom of transcript / chat panels.
  factory AiDisclaimer.footer({required String surface}) =>
      AiDisclaimer._(variant: AiDisclaimerVariant.footer, surface: surface);

  final AiDisclaimerVariant variant;

  /// Surface id (e.g. `live_ai_panel`, `soap_note`, `treatment_plan_drafter`).
  /// Used for telemetry coverage audit.
  final String surface;

  /// Optional label that names what was drafted ("AI-drafted SOAP",
  /// "AI-suggested goals"). Only honoured by the full variant.
  final String? draftedLabel;

  @override
  State<AiDisclaimer> createState() => _AiDisclaimerState();
}

class _AiDisclaimerState extends State<AiDisclaimer> {
  @override
  void initState() {
    super.initState();
    // Fire once per mount — telemetry coverage audit can verify
    // every LLM surface has a wrapper.
    unawaited(
      Future<void>.microtask(() async {
        await TelemetryService.instance.capture(
          'ai_disclaimer.${widget.variant.name}.shown',
          properties: {'surface': widget.surface},
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case AiDisclaimerVariant.compact:
        return _CompactRibbon(surface: widget.surface);
      case AiDisclaimerVariant.full:
        return _FullCard(
          surface: widget.surface,
          draftedLabel: widget.draftedLabel,
        );
      case AiDisclaimerVariant.footer:
        return _Footer(surface: widget.surface);
    }
  }
}

class _CompactRibbon extends StatelessWidget {
  const _CompactRibbon({required this.surface});
  final String surface;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Semantics(
      label: 'AI decision support disclaimer for $surface',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.md,
          vertical: PsySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(PsyRadius.md),
          border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.smart_toy_outlined, size: 16, color: cs.primary),
            const SizedBox(width: PsySpacing.sm),
            Expanded(
              child: Text(
                'AI decision support — review clinically before acting.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullCard extends StatelessWidget {
  const _FullCard({required this.surface, this.draftedLabel});
  final String surface;
  final String? draftedLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Semantics(
      label: 'AI decision support disclaimer for $surface',
      child: Container(
        padding: const EdgeInsets.all(PsySpacing.md),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PsyRadius.md),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: cs.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draftedLabel ?? 'AI-drafted content',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'This output is decision support, not a diagnosis or '
                    'a prescription. Review every line, edit freely, and '
                    'sign only when the clinical record reflects your own '
                    'judgement.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.75),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.surface});
  final String surface;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Semantics(
      label: 'AI decision support footnote for $surface',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.md,
          vertical: PsySpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'AI-assisted. Clinician retains full responsibility.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
