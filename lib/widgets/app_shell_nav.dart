// Part of [AppShell]. Left-side navigation widgets: the persistent
// desktop rail, the matching mobile drawer + tab bar, and the brand
// chrome that sits above them.
//
// HIGH-class refactor slice (audit 2026-06-21): pulled out of
// app_shell.dart. `part of` so `_NavDest` stays file-private.

part of 'app_shell.dart';

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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    // Brand asset is the mint rounded square gear-in-head silhouette —
    // same illustration as the login _Logo + the iOS app icon. Sidebar
    // shows it at 36x36; the asset itself already carries the rounded
    // corner so we only ClipRRect to align with the surrounding
    // PsyRadius.lg scale.
    return ClipRRect(
      borderRadius: BorderRadius.circular(PsyRadius.lg),
      child: Image.asset(
        'assets/branding/logo-master.png',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        semanticLabel: 'PsyClinicAI logo',
      ),
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
        PsySpacing.lg,
        PsySpacing.md,
        PsySpacing.lg,
        PsySpacing.md,
      ),
      child: Row(
        children: [
          const _BrandMark(),
          const SizedBox(width: PsySpacing.md),
          Text(
            'PsyClinicAI',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.sm,
        vertical: 2,
      ),
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

class _MobileTabBar extends StatelessWidget {
  const _MobileTabBar({
    required this.dests,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_NavDest> dests;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  // HIG: <=5 destinations. We surface the five most-used clinician
  // routes; the drawer still carries the long tail.
  static const _primaryRoutes = [
    '/dashboard',
    '/patients',
    '/appointments',
    '/session',
    '/settings',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = <_NavDest>[];
    for (final r in _primaryRoutes) {
      final found = dests.where((d) => d.route == r).toList();
      if (found.isNotEmpty) filtered.add(found.first);
    }
    final activeIndex = filtered.indexWhere(
      (d) =>
          d.route ==
          (selectedIndex >= 0 && selectedIndex < dests.length
              ? dests[selectedIndex].route
              : ''),
    );
    return NavigationBar(
      selectedIndex: activeIndex < 0 ? 0 : activeIndex,
      destinations: [
        for (final d in filtered)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          ),
      ],
      onDestinationSelected: (i) {
        final destIndex = dests.indexWhere((d) => d.route == filtered[i].route);
        if (destIndex >= 0) onSelect(destIndex);
      },
    );
  }
}
