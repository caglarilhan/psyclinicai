import 'package:flutter/material.dart';

import '_landing_tokens.dart';

/// Footer — 4-column site map + brand + legal copy.
class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.onLink});

  /// Called with a short identifier the host can resolve to a route or URL,
  /// e.g. `pricing`, `security`, `privacy`, `dpa`, `contact`.
  final void Function(String linkId) onLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 768
        ? LandingTokens.sectionHorizontalPaddingDesktop
        : LandingTokens.sectionHorizontalPaddingMobile;

    final cols = <_FooterColumn>[
      _FooterColumn('Product', const [
        _Link('Features', 'features'),
        _Link('Pricing', 'pricing'),
        _Link('Security', 'security'),
        _Link('Roadmap', 'roadmap'),
      ]),
      _FooterColumn('Company', const [
        _Link('About', 'about'),
        _Link('Contact', 'contact'),
        _Link('Press kit', 'press'),
      ]),
      _FooterColumn('Resources', const [
        _Link('Help center', 'help'),
        _Link('Status', 'status'),
        _Link('Changelog', 'changelog'),
      ]),
      _FooterColumn('Legal', const [
        _Link('Privacy policy', 'privacy'),
        _Link('Terms of service', 'tos'),
        _Link('HIPAA BAA', 'baa'),
        _Link('GDPR DPA', 'dpa'),
      ]),
    ];

    return Container(
      width: double.infinity,
      color: cs.surfaceContainerHighest,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LandingTokens.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (ctx, c) {
                  final isWide = c.maxWidth >= 980;
                  final brand = SizedBox(
                    width: isWide ? 280 : c.maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/branding/logo-master.png',
                              width: 36,
                              height: 36,
                              filterQuality: FilterQuality.high,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PsyClinicAI',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'The AI co-pilot for therapists and psychiatrists. '
                          'Built for clinicians, audited for compliance.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.72),
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Chip('HIPAA-aligned', cs),
                            _Chip('GDPR Article 28', cs),
                            _Chip('EU residency', cs),
                          ],
                        ),
                      ],
                    ),
                  );
                  final colGrid = SizedBox(
                    width: isWide ? c.maxWidth - 280 - 32 : c.maxWidth,
                    child: Wrap(
                      spacing: 32,
                      runSpacing: 32,
                      children: cols
                          .map(
                            (col) => SizedBox(
                              width: isWide
                                  ? ((c.maxWidth - 280 - 32) - 32 * 3) / 4
                                  : (c.maxWidth - 32) / 2,
                              child: _ColumnView(
                                col: col,
                                theme: theme,
                                cs: cs,
                                onLink: onLink,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [brand, const SizedBox(width: 32), colGrid],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            brand,
                            const SizedBox(height: 32),
                            colGrid,
                          ],
                        );
                },
              ),
              const SizedBox(height: 36),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    '© 2026 PsyClinicAI. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'Made with care in Frankfurt, EU.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterColumn {
  _FooterColumn(this.title, this.links);
  final String title;
  final List<_Link> links;
}

class _Link {
  const _Link(this.label, this.id);
  final String label;
  final String id;
}

class _ColumnView extends StatelessWidget {
  const _ColumnView({
    required this.col,
    required this.theme,
    required this.cs,
    required this.onLink,
  });
  final _FooterColumn col;
  final ThemeData theme;
  final ColorScheme cs;
  final void Function(String id) onLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          col.title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ...col.links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onLink(l.id),
              child: Text(
                l.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.78),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.cs);
  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
