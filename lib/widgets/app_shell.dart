import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/data/auth_service.dart';
import '../services/data/firebase_bootstrap.dart';
import '../theme/tokens.dart';
import 'command_palette.dart';
import 'command_palette_registry.dart';

part 'app_shell_content.dart';
part 'app_shell_header.dart';
part 'app_shell_nav.dart';

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
    _NavDest(
      '/dashboard',
      Icons.dashboard_outlined,
      Icons.dashboard,
      'Dashboard',
    ),
    _NavDest('/patients', Icons.group_outlined, Icons.group, 'Patients'),
    _NavDest('/appointments', Icons.event_outlined, Icons.event, 'Calendar'),
    _NavDest('/session', Icons.graphic_eq, Icons.graphic_eq, 'Session'),
    _NavDest(
      '/ai_chatbot',
      Icons.smart_toy_outlined,
      Icons.smart_toy,
      'Assistant',
    ),
    _NavDest(
      '/ai_diagnosis',
      Icons.biotech_outlined,
      Icons.biotech,
      'Diagnosis',
    ),
    _NavDest('/mood_tracking', Icons.mood_outlined, Icons.mood, 'Mood'),
    _NavDest('/outcomes', Icons.insights_outlined, Icons.insights, 'Outcomes'),
    _NavDest(
      '/superbill',
      Icons.receipt_long_outlined,
      Icons.receipt_long,
      'Superbill',
    ),
    _NavDest('/settings', Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  int? get _selectedIndex {
    final i = _dests.indexWhere((d) => d.route == routeName);
    return i >= 0 ? i : null;
  }

  void _go(BuildContext context, String route) {
    if (route == routeName) return;
    unawaited(Navigator.of(context).pushReplacementNamed(route));
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

    final Scaffold scaffold;
    if (!isWide) {
      // Mobile: header AppBar + drawer nav.
      scaffold = Scaffold(
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
        bottomNavigationBar: _MobileTabBar(
          dests: _dests,
          selectedIndex: _selectedIndex ?? 0,
          onSelect: (i) => _go(context, _dests[i].route),
        ),
      );
    } else {
      // Desktop / tablet: persistent rail + header + content.
      final extended = MediaQuery.sizeOf(context).width >= PsyBreakpoints.lg;
      scaffold = Scaffold(
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

    void openPalette() {
      unawaited(
        CommandPalette.show(context, entries: buildAppCommands(context)),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): openPalette,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            openPalette,
      },
      child: Focus(autofocus: true, child: scaffold),
    );
  }

  List<Crumb> _defaultCrumbs() => [
    const Crumb('Home', '/dashboard'),
    Crumb(title, null),
  ];
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
