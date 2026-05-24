import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Product gallery — real screenshots so visitors *see* the product.
class ProductGallerySection extends StatefulWidget {
  const ProductGallerySection({super.key});

  @override
  State<ProductGallerySection> createState() => _ProductGallerySectionState();
}

class _ProductGallerySectionState extends State<ProductGallerySection> {
  int _selected = 0;

  static const _shots = <_Shot>[
    _Shot(
      tab: 'Live AI Co-Pilot',
      caption:
          'Three-panel layout: session note, live AI panel, client info. The pulsing dot means the on-device microphone is active; the transcript fills in real time, and Stop generates a SOAP note.',
      asset: 'assets/landing/session.png',
    ),
    _Shot(
      tab: 'Superbill',
      caption:
          'CPT + ICD-10 picker, provider + patient fields, real-time totals. Generate PDF produces a CMS-1500-aligned superbill the client submits to their insurer.',
      asset: 'assets/landing/superbill.png',
    ),
    _Shot(
      tab: 'PHQ-9 / GAD-7',
      caption:
          'Standardised depression and anxiety screeners, one question at a time, with severity-band scoring and built-in clinical-action guidance. Risk flags surface immediately.',
      asset: 'assets/landing/phq9.png',
    ),
    _Shot(
      tab: 'Dashboard',
      caption:
          'Role-aware home: patient roster, recent activity, AI analytics. Clinic admins see different KPIs than solo therapists.',
      asset: 'assets/landing/dashboard.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return LandingTokens.sectionContainer(
      context: context,
      background: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow('See it in motion'),
          const SizedBox(height: 12),
          const SectionTitle('Real product. Not mockups.'),
          const SizedBox(height: 12),
          const SectionSubtitle(
              'Click any tab to see the actual UI a paying clinician will use.'),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_shots.length, (i) {
              final sel = i == _selected;
              return ChoiceChip(
                label: Text(_shots[i].tab),
                selected: sel,
                onSelected: (_) => setState(() => _selected = i),
                labelStyle: TextStyle(
                  color: sel ? Colors.white : cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: cs.primary,
                backgroundColor: cs.surfaceContainerHighest,
              );
            }),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: _ShotView(
              key: ValueKey(_selected),
              shot: _shots[_selected],
              theme: theme,
              cs: cs,
            ),
          ),
        ],
      ),
    );
  }
}

class _Shot {
  const _Shot(
      {required this.tab, required this.caption, required this.asset});
  final String tab;
  final String caption;
  final String asset;
}

class _ShotView extends StatelessWidget {
  const _ShotView({
    super.key,
    required this.shot,
    required this.theme,
    required this.cs,
  });
  final _Shot shot;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final isWide = c.maxWidth >= 900;
        final image = Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              shot.asset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 320,
                color: cs.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Text(shot.asset,
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5))),
              ),
            ),
          ),
        );
        final caption = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(shot.tab,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(shot.caption,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                    height: 1.55,
                  )),
            ],
          ),
        );
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: image),
                  const SizedBox(width: 24),
                  Expanded(flex: 4, child: caption),
                ],
              )
            : Column(children: [image, const SizedBox(height: 16), caption]);
      },
    );
  }
}
