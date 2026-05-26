import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data/auth_service.dart';
import '../services/data/firebase_bootstrap.dart';
import '../theme/tokens.dart';

/// The single shared shell every authenticated screen sits in.
///
/// Solves DESIGN.md problem #2 (cross-page continuity): a persistent
/// [NavigationRail] (≥640px) or [Drawer] (mobile) on the left, a header with
/// breadcrumb + search + user menu on top, and a 1200px-max centered content
/// column. Screens pass their [title], a [primaryAction] CTA and a [child]
/// body — never a bare [Scaffold].
///
/// Usage:
/// ```dart
/// return AppShell(
///   routeName: '/patients',
///   title: 'Patients',
///   primaryAction: FilledButton.icon(...),
///   child: <content>,
/// );
/// ```
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.routeName,
    required this.title,
    required this.child,
    this.subtitle,
    this.primaryAction,
    this.breadcrumbs,
    this.scrollable = true,
    this.floatingActionButton,
  });

  /// Current route (e.g. `/patients`) — drives nav highlighting.
  final String routeName;

  /// Page title, rendered once as `displaySmall` at the top of the content.
  final String title;

  /// Optional one-line context under the title.
  final String? subtitle;

  /// The page's single primary CTA, shown top-right of the page header.
  final Widget? primaryAction;

  /// Breadcrumb trail. Defaults to `Home / {title}` when null.
  final List<Crumb>? breadcrumbs;

  /// The page body below the title row.
  final Widget child;

  /// When true (default) the content scrolls. Set false for screens that own
  /// their own scrolling/layout (e.g. a chat view that pins an input bar).
  final bool scrollable;

  final Widget? floatingActionButton;

  static const _maxContentWidth = 1200.0;

  static const List<_NavDest> _dests = [
    _NavDest('/dashboard', Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _NavDest('/patients', Icons.group_outlined, Icons.group, 'Patients'),
    _NavDest('/appointments', Icons.event_outlined, Icons.event, 'Calendar'),
    _NavDest('/session', Icons.graphic_eq, Icons.graphic_eq, 'Session'),
    _NavDest('/ai_chatbot', Icons.smart_toy_outlined, Icons.smart_toy, 'Assistant'),
    _NavDest('/ai_diagnosis', Icons.biotech_outlined, Icons.biotech, 'Diagnosis'),
    _NavDest('/mood_tracking', Icons.mood_outlined, Icons.mood, 'Mood'),
    _NavDest('/outcomes', Icons.insights_outlined, Icons.insights, 'Outcomes'),
    _NavDest('/superbill', Icons.receipt_long_outlined, Icons.receipt_long, 'Superbill'),
    _NavDest('/settings', Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  int? get _selectedIndex {
    final i = _dests.indexWhere((d) => d.route == routeName);
    return i >= 0 ? i : null;
  }

  void _go(BuildContext context, String route) {
    if (route == routeName) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= PsyBreakpoints.sm;

    final content = _Content(
      title: title,
      subtitle: subtitle,
      primaryAction: primaryAction,
      scrollable: scrollable,
      child: child,
    );

    if (!isWide) {
      // Mobile: header AppBar + drawer nav.
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: cs.outlineVariant)),
          title: _Breadcrumb(
            crumbs: breadcrumbs ?? _defaultCrumbs(),
            onHome: () => _go(context, '/dashboard'),
          ),
          actions: [
            IconButton(
              tooltip: 'Search patients',
              onPressed: () => _go(context, '/patients'),
              icon: const Icon(Icons.search),
            ),
            const _UserMenu(),
            const SizedBox(width: PsySpacing.sm),
          ],
        ),
        drawer: Drawer(
          backgroundColor: cs.surface,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: PsySpacing.md),
              children: [
                const _BrandHeader(),
                const SizedBox(height: PsySpacing.sm),
                for (var i = 0; i < _dests.length; i++)
                  _DrawerTile(
                    dest: _dests[i],
                    selected: i == _selectedIndex,
                    onTap: () {
                      Navigator.of(context).pop();
                      _go(context, _dests[i].route);
                    },
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: floatingActionButton,
        body: content,
      );
    }

    // Desktop / tablet: persistent rail + header + content.
    final extended = MediaQuery.sizeOf(context).width >= PsyBreakpoints.lg;
    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          _Rail(
            dests: _dests,
            selectedIndex: _selectedIndex,
            extended: extended,
            onSelect: (i) => _go(context, _dests[i].route),
          ),
          VerticalDivider(width: 1, thickness: 1, color: cs.outlineVariant),
          Expanded(
            child: Column(
              children: [
                _Header(
                  crumbs: breadcrumbs ?? _defaultCrumbs(),
                  onHome: () => _go(context, '/dashboard'),
                  onSearch: () => _go(context, '/patients'),
                ),
                Divider(height: 1, thickness: 1, color: cs.outlineVariant),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Crumb> _defaultCrumbs() => [Crumb('Home', '/dashboard'), Crumb(title, null)];
}

/// A breadcrumb segment. A null [route] marks the current (non-tappable) page.
class Crumb {
  const Crumb(this.label, this.route);
  final String label;
  final String? route;
}

class _NavDest {
  const _NavDest(this.route, this.icon, this.selectedIcon, this.label);
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

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

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold, height: 1.1),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: PsySpacing.sm),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
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
              PsySpacing.xl, PsySpacing.xxl, PsySpacing.xl, PsySpacing.huge),
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

class _Rail extends StatelessWidget {
  const _Rail({
    required this.dests,
    required this.selectedIndex,
    required this.extended,
    required this.onSelect,
  });

  final List<_NavDest> dests;
  final int? selectedIndex;
  final bool extended;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: IntrinsicHeight(
        child: NavigationRail(
          extended: extended,
          minWidth: 72,
          minExtendedWidth: 208,
          backgroundColor: cs.surface,
          selectedIndex: selectedIndex,
          groupAlignment: -1,
          labelType: extended ? null : NavigationRailLabelType.all,
          leading: const Padding(
            padding: EdgeInsets.symmetric(vertical: PsySpacing.lg),
            child: _BrandMark(),
          ),
          indicatorColor: cs.primary.withValues(alpha: 0.12),
          selectedIconTheme: IconThemeData(color: cs.primary),
          selectedLabelTextStyle: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w600,
          ),
          onDestinationSelected: onSelect,
          destinations: [
            for (final d in dests)
              NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              ),
          ],
        ),
      ),
    );
  }
}

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
          Expanded(child: _Breadcrumb(crumbs: crumbs, onHome: onHome)),
          SizedBox(width: 240, child: _SearchBox(onTap: onSearch)),
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
              Icon(Icons.search,
                  size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
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
    final children = <Widget>[];
    for (var i = 0; i < crumbs.length; i++) {
      final c = crumbs[i];
      final isLast = i == crumbs.length - 1;
      final style = theme.textTheme.bodyMedium?.copyWith(
        color: isLast ? cs.onSurface : cs.onSurface.withValues(alpha: 0.6),
        fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
      );
      if (!isLast && c.route != null) {
        children.add(InkWell(
          borderRadius: BorderRadius.circular(PsyRadius.xs),
          onTap: () {
            if (c.route == '/dashboard') {
              onHome();
            } else {
              Navigator.of(context).pushReplacementNamed(c.route!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Text(c.label, style: style),
          ),
        ));
      } else {
        children.add(Text(c.label, style: style));
      }
      if (!isLast) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xs),
          child: Icon(Icons.chevron_right,
              size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
        ));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
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
            Navigator.of(context).pushNamed('/settings');
          case 'api_keys':
            Navigator.of(context).pushNamed('/settings/api_keys');
          case 'signout':
            if (PsyFirebase.isReady) {
              await FirebaseAuthService.instance.signOut();
            }
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/landing');
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PsyRadius.lg),
      ),
      child: Icon(Icons.psychology, color: cs.primary, size: 22),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          PsySpacing.lg, PsySpacing.md, PsySpacing.lg, PsySpacing.md),
      child: Row(
        children: [
          const _BrandMark(),
          const SizedBox(width: PsySpacing.md),
          Text(
            'PsyClinicAI',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.dest,
    required this.selected,
    required this.onTap,
  });
  final _NavDest dest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PsySpacing.sm, vertical: 2),
      child: ListTile(
        selected: selected,
        selectedTileColor: cs.primary.withValues(alpha: 0.12),
        selectedColor: cs.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsyRadius.lg),
        ),
        leading: Icon(selected ? dest.selectedIcon : dest.icon),
        title: Text(
          dest.label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
