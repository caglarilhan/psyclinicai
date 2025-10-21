import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

class ProLineChart extends StatelessWidget {
  final List<ProChartData> data;
  final String? title;
  final String? subtitle;
  final Color? lineColor;
  final Color? gradientColor;
  final bool showGrid;
  final bool showDots;
  final double? height;
  final EdgeInsets? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const ProLineChart({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.lineColor,
    this.gradientColor,
    this.showGrid = true,
    this.showDots = true,
    this.height,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chartHeight = height ?? 200.0;
    final chartPadding = padding ?? AppSpacing.paddingAll(AppSpacing.md);

    return Container(
      padding: chartPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null) ...[
            if (title != null)
              Text(
                title!,
                style: titleStyle ?? AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: subtitleStyle ?? AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                gridData: showGrid
                    ? FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                            strokeWidth: 1,
                          );
                        },
                      )
                    : FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.length) {
                          return Text(
                            data[value.toInt()].label,
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.value);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        lineColor ?? AppColors.primary,
                        gradientColor ?? (lineColor ?? AppColors.primary).withValues(alpha: 0.3),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: showDots,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor ?? AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          gradientColor ?? (lineColor ?? AppColors.primary).withValues(alpha: 0.3),
                          gradientColor ?? (lineColor ?? AppColors.primary).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProBarChart extends StatelessWidget {
  final List<ProChartData> data;
  final String? title;
  final String? subtitle;
  final Color? barColor;
  final Color? gradientColor;
  final bool showGrid;
  final double? height;
  final EdgeInsets? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const ProBarChart({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.barColor,
    this.gradientColor,
    this.showGrid = true,
    this.height,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chartHeight = height ?? 200.0;
    final chartPadding = padding ?? AppSpacing.paddingAll(AppSpacing.md);

    return Container(
      padding: chartPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null) ...[
            if (title != null)
              Text(
                title!,
                style: titleStyle ?? AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: subtitleStyle ?? AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            height: chartHeight,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.1,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${data[group.x].label}\n${data[group.x].value}',
                        AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < data.length) {
                          return Text(
                            data[value.toInt()].label,
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    width: 1,
                  ),
                ),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: barColor ?? AppColors.primary,
                        width: 20,
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        gradient: gradientColor != null
                            ? LinearGradient(
                                colors: [
                                  barColor ?? AppColors.primary,
                                  gradientColor!,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : null,
                      ),
                    ],
                  );
                }).toList(),
                gridData: showGrid
                    ? FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                            strokeWidth: 1,
                          );
                        },
                      )
                    : FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProPieChart extends StatelessWidget {
  final List<ProChartData> data;
  final String? title;
  final String? subtitle;
  final double? radius;
  final bool showPercentage;
  final EdgeInsets? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const ProPieChart({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.radius,
    this.showPercentage = true,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chartRadius = radius ?? 100.0;
    final chartPadding = padding ?? AppSpacing.paddingAll(AppSpacing.md);

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];

    return Container(
      padding: chartPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null) ...[
            if (title != null)
              Text(
                title!,
                style: titleStyle ?? AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: subtitleStyle ?? AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              SizedBox(
                width: chartRadius * 2,
                height: chartRadius * 2,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch events
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: data.asMap().entries.map((e) {
                      final percentage = (e.value.value / data.map((d) => d.value).reduce((a, b) => a + b)) * 100;
                      return PieChartSectionData(
                        color: colors[e.key % colors.length],
                        value: e.value.value,
                        title: showPercentage ? '${percentage.toStringAsFixed(1)}%' : '',
                        radius: chartRadius - 20,
                        titleStyle: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.asMap().entries.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[e.key % colors.length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              e.value.label,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          Text(
                            e.value.value.toString(),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProChartData {
  final String label;
  final double value;
  final Color? color;

  ProChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class ProChartCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showBorder;
  final Color? borderColor;

  const ProChartCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardPadding = padding ?? AppSpacing.paddingAll(AppSpacing.lg);
    final cardBorderRadius = borderRadius ?? AppSpacing.cardRadius;
    final cardBackgroundColor = backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? (isDark ? AppColors.dividerDark : AppColors.dividerLight),
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
                          style: AppTypography.headlineSmall.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
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
            SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}
