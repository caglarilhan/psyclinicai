// Part of [AppShell]. Hosts the page-body widget so the main shell file
// can stay focused on the rail/header/breadcrumb wiring.
//
// HIGH-class refactor (audit 2026-06-21): split app_shell.dart into
// content + nav + header parts. `part of` keeps file-private types
// (incl. `AppShell._maxContentWidth`) shared with the main library so
// the 30+ screens importing `app_shell.dart` are unaffected.

part of 'app_shell.dart';

class _Content extends StatelessWidget {
  const _Content({
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    required this.scrollable,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? primaryAction;
  final bool scrollable;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isPhone = MediaQuery.sizeOf(context).width < PsyBreakpoints.md;
    // Mobile titles step down to headlineMedium (-15%) to feel less shouty
    // on a 390px viewport — desktop keeps displaySmall for executive weight.
    final titleStyle = isPhone
        ? theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.15,
          )
        : theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.1,
          );
    // Mobile subtitle steps down from bodyMedium → bodySmall (~13px) to
    // feel like a clinical document rather than a marketing hero. Per
    // user critique: 'bazı body metinleri 20px civarı görünüyor —
    // profesyonel hukuk/klinik doküman sayfalarında biraz kaba duruyor'.
    final subtitleStyle = isPhone
        ? theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
            height: 1.45,
          )
        : theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          );

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text(title, style: titleStyle)),
              if (subtitle != null) ...[
                const SizedBox(height: PsySpacing.sm),
                Text(subtitle!, style: subtitleStyle),
              ],
            ],
          ),
        ),
        if (primaryAction != null) ...[
          const SizedBox(width: PsySpacing.xl),
          primaryAction!,
        ],
      ],
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: PsySpacing.xl),
        scrollable ? child : Expanded(child: child),
      ],
    );

    final padded = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppShell._maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PsySpacing.xl,
            PsySpacing.xxl,
            PsySpacing.xl,
            PsySpacing.huge,
          ),
          child: column,
        ),
      ),
    );

    return Container(
      color: cs.surfaceContainerLowest,
      width: double.infinity,
      child: scrollable ? SingleChildScrollView(child: padded) : padded,
    );
  }
}
