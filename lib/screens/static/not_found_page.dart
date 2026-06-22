import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// Shown when MaterialApp.onUnknownRoute fires — i.e. someone hit a
/// path we don't recognise. Keeps the brand shell so the visitor lands
/// on something on-brand instead of a stack trace.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return StaticPageShell(
      eyebrow: '404',
      title: "We can't find that page.",
      lede: path == null
          ? "The URL you opened doesn't exist on PsyClinicAI. Try one "
                'of these instead, or head back to the homepage.'
          : "The URL '$path' doesn't exist on PsyClinicAI. Try one of "
                'these instead, or head back to the homepage.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _shortcut(
                context,
                theme,
                cs,
                Icons.home_outlined,
                'Homepage',
                '/landing',
              ),
              _shortcut(
                context,
                theme,
                cs,
                Icons.verified_user_outlined,
                'Security',
                '/security',
              ),
              _shortcut(
                context,
                theme,
                cs,
                Icons.attach_money,
                'Pricing',
                '/landing',
              ),
              _shortcut(
                context,
                theme,
                cs,
                Icons.help_outline,
                'FAQ',
                '/landing',
              ),
              _shortcut(
                context,
                theme,
                cs,
                Icons.email_outlined,
                'Contact',
                '/contact',
              ),
            ],
          ),
          const SizedBox(height: 36),
          Text(
            'If you reached this page from a link inside PsyClinicAI, '
            'please email founders@psyclinicai.com and we will fix it '
            'fast.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcut(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    IconData icon,
    String label,
    String route,
  ) {
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).pushReplacementNamed(route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cs.primary, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
