// Part of [AppShell]. Top header: breadcrumb on the left, a tap-to-jump
// search box in the middle, the user menu (avatar + Settings / API keys
// / Sign-out) on the right. Breadcrumb collapses to the current page
// label on phones; the same widget is reused as the mobile AppBar title.
//
// HIGH-class refactor slice (audit 2026-06-21): pulled out of
// app_shell.dart. `part of` shares the main library's
// FirebaseAuthService + PsyFirebase imports.

part of 'app_shell.dart';

class _Header extends StatelessWidget {
  const _Header({
    required this.crumbs,
    required this.onHome,
    required this.onSearch,
  });

  final List<Crumb> crumbs;
  final VoidCallback onHome;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: _Breadcrumb(crumbs: crumbs, onHome: onHome),
          ),
          SizedBox(width: 240, child: _SearchBox(onTap: onSearch)),
          const SizedBox(width: PsySpacing.md),
          const SubscriptionChip(),
          const SizedBox(width: PsySpacing.md),
          const _UserMenu(),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(PsyRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: PsySpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsyRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 18,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: PsySpacing.sm),
              Flexible(
                child: Text(
                  'Search patients',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.crumbs, required this.onHome});
  final List<Crumb> crumbs;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // On a phone the full "Home › Patients › John Demo › Safety plan" chain
    // collides with the search + avatar in the AppBar — show just the current
    // page label there. The full trail still renders on desktop.
    final isPhone = MediaQuery.sizeOf(context).width < PsyBreakpoints.md;
    if (isPhone && crumbs.isNotEmpty) {
      return Text(
        crumbs.last.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }
    final children = <Widget>[];
    for (var i = 0; i < crumbs.length; i++) {
      final c = crumbs[i];
      final isLast = i == crumbs.length - 1;
      final style = theme.textTheme.bodyMedium?.copyWith(
        color: isLast ? cs.onSurface : cs.onSurface.withValues(alpha: 0.6),
        fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
      );
      if (!isLast && c.route != null) {
        children.add(
          InkWell(
            borderRadius: BorderRadius.circular(PsyRadius.xs),
            onTap: () {
              if (c.route == '/dashboard') {
                onHome();
              } else {
                unawaited(Navigator.of(context).pushReplacementNamed(c.route!));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Text(c.label, style: style),
            ),
          ),
        );
      } else {
        children.add(Text(c.label, style: style));
      }
      if (!isLast) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xs),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        );
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    FirebaseAuthService? auth;
    try {
      auth = context.watch<FirebaseAuthService>();
    } catch (_) {
      auth = null;
    }
    final name = auth?.profile?.fullName ?? 'Clinician';
    final initials = _initials(name);

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PsyRadius.lg),
      ),
      onSelected: (v) async {
        switch (v) {
          case 'settings':
            unawaited(Navigator.of(context).pushNamed('/settings'));
          case 'api_keys':
            unawaited(Navigator.of(context).pushNamed('/settings/api_keys'));
          case 'signout':
            if (PsyFirebase.isReady) {
              await FirebaseAuthService.instance.signOut();
            }
            if (context.mounted) {
              unawaited(Navigator.of(context).pushReplacementNamed('/landing'));
            }
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'settings',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
          ),
        ),
        PopupMenuItem(
          value: 'api_keys',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.key_outlined),
            title: Text('API keys'),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'signout',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Sign out'),
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 16,
        backgroundColor: cs.primary.withValues(alpha: 0.12),
        child: Text(
          initials,
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
