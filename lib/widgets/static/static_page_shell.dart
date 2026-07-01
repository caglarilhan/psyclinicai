import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../landing/demo_modal.dart';

/// Shared layout for static / marketing pages (security, about, changelog,
/// status). Renders a top app bar, hero header, max-width content area,
/// optional "last updated" line, and a simplified mini-footer.
class StaticPageShell extends StatelessWidget {
  const StaticPageShell({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.lede,
    required this.child,
    this.lastUpdated,
  });

  final String title;
  final String eyebrow;
  final String lede;
  final Widget child;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: _ShellAppBar(
        onHome: () => Navigator.of(context).pushReplacementNamed('/landing'),
        onDemo: () => DemoModal.show(context),
        onStart: () => Navigator.of(context).pushNamed('/login'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(
            title: title,
            eyebrow: eyebrow,
            lede: lede,
            theme: theme,
            cs: cs,
          ),
          Container(
            color: cs.surface,
            padding: EdgeInsets.symmetric(
              horizontal: _hPadding(context),
              vertical: PsySpacing.xxxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: child,
              ),
            ),
          ),
          if (lastUpdated != null)
            Container(
              color: cs.surface,
              padding: EdgeInsets.symmetric(
                horizontal: _hPadding(context),
                vertical: PsySpacing.xl,
              ),
              alignment: Alignment.center,
              child: Text(
                'Last updated ${_fmt(lastUpdated!)}.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          _MiniFooter(
            cs: cs,
            theme: theme,
            onHome: () =>
                Navigator.of(context).pushReplacementNamed('/landing'),
          ),
        ],
      ),
    );
  }

  static double _hPadding(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= PsyBreakpoints.md
      ? PsySpacing.huge
      : PsySpacing.xl;

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ShellAppBar({
    required this.onHome,
    required this.onDemo,
    required this.onStart,
  });

  final VoidCallback onHome;
  final VoidCallback onDemo;
  final VoidCallback onStart;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppBar(
      title: InkWell(
        onTap: onHome,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology, color: cs.primary, size: 26),
            const SizedBox(width: PsySpacing.sm),
            Text(
              'PsyClinicAI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDemo,
          child: Text('Watch demo', style: TextStyle(color: cs.onSurface)),
        ),
        const SizedBox(width: PsySpacing.sm),
        FilledButton(onPressed: onStart, child: const Text('Start free')),
        const SizedBox(width: PsySpacing.lg),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.eyebrow,
    required this.lede,
    required this.theme,
    required this.cs,
  });
  final String title;
  final String eyebrow;
  final String lede;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final hPad = StaticPageShell._hPadding(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withValues(alpha: 0.06), cs.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      padding: EdgeInsets.fromLTRB(
        hPad,
        PsySpacing.huge,
        hPad,
        PsySpacing.xxxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: PsySpacing.lg),
              Text(
                lede,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniFooter extends StatelessWidget {
  const _MiniFooter({
    required this.cs,
    required this.theme,
    required this.onHome,
  });
  final ColorScheme cs;
  final ThemeData theme;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.xl,
        vertical: PsySpacing.xxl,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onHome,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology, color: cs.primary, size: 22),
                const SizedBox(width: PsySpacing.sm),
                Text(
                  'PsyClinicAI',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          Text(
            '© 2026 PsyClinicAI · Made with care in Frankfurt, EU.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// h2 inside a static page.
class StaticH2 extends StatelessWidget {
  const StaticH2(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: PsySpacing.xxl,
        bottom: PsySpacing.md,
      ),
      // `header: true` lets screen readers jump section-to-section on
      // long legal pages (WCAG 2.4.6 headings, 1.3.1 info+relationships).
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Section paragraph.
class StaticP extends StatelessWidget {
  const StaticP(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: Text(
        text,
        style: t.bodyLarge?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.78),
          height: 1.6,
        ),
      ),
    );
  }
}

/// Bullet line.
class StaticBullet extends StatelessWidget {
  const StaticBullet(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: t.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
