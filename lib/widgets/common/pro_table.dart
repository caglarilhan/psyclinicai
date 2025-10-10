import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

class ProTable extends StatelessWidget {
  final List<ProTableColumn> columns;
  final List<Map<String, dynamic>> data;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final bool showHeader;
  final bool showBorder;
  final bool showStripes;
  final Color? headerBackgroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;
  final double? rowHeight;
  final bool sortable;
  final Function(String columnKey, bool ascending)? onSort;
  final String? sortColumn;
  final bool? sortAscending;
  final bool loading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Function(Map<String, dynamic> row)? onRowTap;
  final Function(Map<String, dynamic> row)? onRowLongPress;

  const ProTable({
    super.key,
    required this.columns,
    required this.data,
    this.title,
    this.subtitle,
    this.action,
    this.showHeader = true,
    this.showBorder = true,
    this.showStripes = true,
    this.headerBackgroundColor,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.borderRadius,
    this.titleStyle,
    this.subtitleStyle,
    this.headerStyle,
    this.cellStyle,
    this.rowHeight,
    this.sortable = false,
    this.onSort,
    this.sortColumn,
    this.sortAscending,
    this.loading = false,
    this.loadingWidget,
    this.emptyWidget,
    this.onRowTap,
    this.onRowLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tablePadding = padding ?? AppSpacing.paddingAllLG;
    final tableBorderRadius = borderRadius ?? AppSpacing.cardRadius;
    final tableBackgroundColor = backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final tableBorderColor = borderColor ?? (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final tableHeaderBackgroundColor = headerBackgroundColor ?? (isDark ? AppColors.neutral800 : AppColors.neutral100);
    final tableRowHeight = rowHeight ?? 48.0;

    return Container(
      padding: tablePadding,
      decoration: BoxDecoration(
        color: tableBackgroundColor,
        borderRadius: BorderRadius.circular(tableBorderRadius),
        border: showBorder
            ? Border.all(
                color: tableBorderColor,
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.elevationSm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null || action != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: titleStyle ?? AppTypography.headlineSmall.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (subtitle != null) ...[
                        AppSpacing.heightXS,
                        Text(
                          subtitle!,
                          style: subtitleStyle ?? AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            AppSpacing.heightMD,
          ],
          if (loading)
            loadingWidget ?? _buildLoadingWidget(isDark)
          else if (data.isEmpty)
            emptyWidget ?? _buildEmptyWidget(isDark)
          else
            _buildTable(isDark, tableHeaderBackgroundColor, tableBorderColor, tableRowHeight),
        ],
      ),
    );
  }

  Widget _buildTable(bool isDark, Color headerBackgroundColor, Color borderColor, double rowHeight) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          if (showHeader) _buildHeader(isDark, headerBackgroundColor, borderColor, rowHeight),
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return _buildRow(
              row,
              index,
              isDark,
              borderColor,
              rowHeight,
              showStripes && index % 2 == 1,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color headerBackgroundColor, Color borderColor, double rowHeight) {
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.sm),
          topRight: Radius.circular(AppSpacing.sm),
        ),
      ),
      child: Row(
        children: columns.map((column) {
          return Expanded(
            flex: column.flex,
            child: Container(
              padding: AppSpacing.paddingHorizontalMD,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: sortable && column.sortable
                  ? GestureDetector(
                      onTap: () {
                        if (onSort != null) {
                          final ascending = sortColumn == column.key ? !(sortAscending ?? true) : true;
                          onSort!(column.key, ascending);
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              column.title,
                              style: headerStyle ?? AppTypography.labelMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            sortColumn == column.key
                                ? (sortAscending ?? true)
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down
                                : Icons.unfold_more,
                            size: AppSpacing.iconSm,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ],
                      ),
                    )
                  : Text(
                      column.title,
                      style: headerStyle ?? AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(
    Map<String, dynamic> row,
    int index,
    bool isDark,
    Color borderColor,
    double rowHeight,
    bool isStriped,
  ) {
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        color: isStriped
            ? (isDark ? AppColors.neutral900 : AppColors.neutral50)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRowTap != null ? () => onRowTap!(row) : null,
          onLongPress: onRowLongPress != null ? () => onRowLongPress!(row) : null,
          child: Row(
            children: columns.map((column) {
              return Expanded(
                flex: column.flex,
                child: Container(
                  padding: AppSpacing.paddingHorizontalMD,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: column.builder != null
                      ? column.builder!(row[column.key], row, index)
                      : Text(
                          row[column.key]?.toString() ?? '',
                          style: cellStyle ?? AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(bool isDark) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            AppSpacing.heightMD,
            Text(
              'Yükleniyor...',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(bool isDark) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: AppSpacing.iconXl,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            AppSpacing.heightMD,
            Text(
              'Veri bulunamadı',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProTableColumn {
  final String key;
  final String title;
  final int flex;
  final bool sortable;
  final Widget Function(dynamic value, Map<String, dynamic> row, int index)? builder;

  ProTableColumn({
    required this.key,
    required this.title,
    this.flex = 1,
    this.sortable = true,
    this.builder,
  });
}

class ProDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final bool showCheckboxColumn;
  final bool showFirstLastButtons;
  final int? rowsPerPage;
  final int? initialFirstRowIndex;
  final Function(int firstRowIndex, bool ascending)? onPageChanged;
  final Function(int? rowsPerPage)? onRowsPerPageChanged;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const ProDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.title,
    this.subtitle,
    this.action,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = true,
    this.rowsPerPage,
    this.initialFirstRowIndex,
    this.onPageChanged,
    this.onRowsPerPageChanged,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.borderRadius,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tablePadding = padding ?? AppSpacing.paddingAllLG;
    final tableBorderRadius = borderRadius ?? AppSpacing.cardRadius;
    final tableBackgroundColor = backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final tableBorderColor = borderColor ?? (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    return Container(
      padding: tablePadding,
      decoration: BoxDecoration(
        color: tableBackgroundColor,
        borderRadius: BorderRadius.circular(tableBorderRadius),
        border: Border.all(
          color: tableBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.elevationSm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null || action != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: titleStyle ?? AppTypography.headlineSmall.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (subtitle != null) ...[
                        AppSpacing.heightXS,
                        Text(
                          subtitle!,
                          style: subtitleStyle ?? AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            AppSpacing.heightMD,
          ],
          DataTable(
            columns: columns,
            rows: rows,
            showCheckboxColumn: showCheckboxColumn,
            showFirstLastButtons: showFirstLastButtons,
            rowsPerPage: rowsPerPage,
            initialFirstRowIndex: initialFirstRowIndex,
            onPageChanged: onPageChanged,
            onRowsPerPageChanged: onRowsPerPageChanged,
            headingRowColor: MaterialStateProperty.all(
              isDark ? AppColors.neutral800 : AppColors.neutral100,
            ),
            dataRowColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primary.withValues(alpha: 0.1);
              }
              return null;
            }),
            border: TableBorder.all(
              color: tableBorderColor,
              width: 1,
            ),
          ),
        ],
      ),
    );
  }
}
