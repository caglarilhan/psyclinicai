import 'package:flutter/material.dart';
import '../../utils/desktop_theme.dart';

class DesktopGrid extends StatelessWidget {
  final List<DesktopGridItem> items;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const DesktopGrid({
    super.key,
    required this.items,
    this.crossAxisCount,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidebarWidth = DesktopTheme.getSidebarWidth(context);
    final availableWidth = width - sidebarWidth - 32;
    
    int columns = crossAxisCount ?? 2;
    if (availableWidth >= 2000) columns = 4;
    else if (availableWidth >= 1600) columns = 3;
    else if (availableWidth >= 1200) columns = 2;
    else columns = 1;

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio ?? 1.5,
        crossAxisSpacing: crossAxisSpacing ?? 16,
        mainAxisSpacing: mainAxisSpacing ?? 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return DesktopGridCard(
          title: item.title,
          subtitle: item.subtitle,
          icon: item.icon,
          color: item.color,
          onTap: item.onTap,
          actions: item.actions,
          badge: item.badge,
        );
      },
    );
  }
}

class DesktopGridItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final Widget? badge;

  const DesktopGridItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.actions,
    this.badge,
  });
}

class DesktopGridCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final Widget? badge;

  const DesktopGridCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.actions,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopTheme.desktopCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (color ?? DesktopTheme.desktopPrimary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color ?? DesktopTheme.desktopPrimary,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Badge
                  if (badge != null) badge!,
                ],
              ),
              
              // Actions
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Masaüstü için data table widget'ı
class DesktopDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool sortAscending;
  final int? sortColumnIndex;
  final Function(int, bool)? onSort;
  final DataTableSource? source;
  final bool showCheckboxColumn;
  final bool showFirstLastButtons;
  final int? rowsPerPage;
  final List<int>? availableRowsPerPage;

  const DesktopDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.onSort,
    this.source,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = true,
    this.rowsPerPage,
    this.availableRowsPerPage,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopTheme.desktopCard(
      child: DataTable(
        columns: columns,
        rows: rows,
        sortAscending: sortAscending,
        sortColumnIndex: sortColumnIndex,
        onSelectAll: (value) {
          // Handle select all
        },
        showCheckboxColumn: showCheckboxColumn,
        dataRowHeight: 56,
        headingRowHeight: 56,
        horizontalMargin: 16,
        columnSpacing: 16,
        dividerThickness: 1,
        border: TableBorder.all(
          color: DesktopTheme.desktopBorder,
          width: 1,
        ),
      ),
    );
  }
}

// Masaüstü için list widget'ı
class DesktopList extends StatelessWidget {
  final List<DesktopListItem> items;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? emptyWidget;

  const DesktopList({
    super.key,
    required this.items,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DesktopListCard(
            title: item.title,
            subtitle: item.subtitle,
            leading: item.leading,
            trailing: item.trailing,
            onTap: item.onTap,
            color: item.color,
          ),
        );
      },
    );
  }
}

class DesktopListItem {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const DesktopListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.color,
  });
}

class DesktopListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const DesktopListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopTheme.desktopCard(
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: subtitle != null ? Text(
          subtitle!,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ) : null,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

// Masaüstü için chart widget'ı
class DesktopChart extends StatelessWidget {
  final String title;
  final Widget chart;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const DesktopChart({
    super.key,
    required this.title,
    required this.chart,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopTheme.desktopCard(
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          
          // Chart Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

// Masaüstü için form widget'ı
class DesktopForm extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final EdgeInsets? padding;

  const DesktopForm({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopTheme.desktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: padding ?? const EdgeInsets.all(20),
              child: Column(
                children: children,
              ),
            ),
          ),
          
          // Form Actions
          if (actions != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
