import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

class ProCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? header;
  final Widget? footer;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBorder;
  final bool showShadow;
  final ProCardVariant variant;

  const ProCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.isLoading = false,
    this.header,
    this.footer,
    this.title,
    this.subtitle,
    this.actions,
    this.showBorder = true,
    this.showShadow = true,
    this.variant = ProCardVariant.default_,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color cardBackground;
    Color cardBorder;
    double cardElevation;
    double cardBorderRadius;

    switch (variant) {
      case ProCardVariant.default_:
        cardBackground = backgroundColor ?? (isDark ? AppColors.neutral800 : AppColors.surface);
        cardBorder = borderColor ?? (isDark ? AppColors.neutral700 : AppColors.border);
        cardElevation = elevation ?? (showShadow ? AppSpacing.elevationSm : 0);
        cardBorderRadius = borderRadius ?? AppSpacing.cardRadius;
        break;
      case ProCardVariant.elevated:
        cardBackground = backgroundColor ?? (isDark ? AppColors.neutral800 : AppColors.surface);
        cardBorder = borderColor ?? Colors.transparent;
        cardElevation = elevation ?? AppSpacing.elevationMd;
        cardBorderRadius = borderRadius ?? AppSpacing.cardRadius;
        break;
      case ProCardVariant.outlined:
        cardBackground = backgroundColor ?? Colors.transparent;
        cardBorder = borderColor ?? (isDark ? AppColors.neutral700 : AppColors.border);
        cardElevation = 0;
        cardBorderRadius = borderRadius ?? AppSpacing.cardRadius;
        break;
      case ProCardVariant.filled:
        cardBackground = backgroundColor ?? (isDark ? AppColors.neutral700 : AppColors.surfaceContainer);
        cardBorder = borderColor ?? Colors.transparent;
        cardElevation = 0;
        cardBorderRadius = borderRadius ?? AppSpacing.cardRadius;
        break;
    }

    Widget cardContent = Container(
      padding: padding ?? AppSpacing.paddingAll(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: showBorder ? Border.all(color: cardBorder, width: 1) : null,
        boxShadow: cardElevation > 0 ? [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: cardElevation,
            offset: Offset(0, cardElevation / 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            header!,
            if (title != null || subtitle != null || actions != null) 
              SizedBox(height: AppSpacing.sm),
          ],
          if (title != null || subtitle != null || actions != null) ...[
            _buildHeader(context),
            SizedBox(height: AppSpacing.md),
          ],
          Expanded(child: child),
          if (footer != null) ...[
            SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );

    if (isLoading) {
      cardContent = Stack(
        children: [
          cardContent,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: cardBackground.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(cardBorderRadius),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    }

    Widget card = Container(
      margin: margin ?? AppSpacing.marginAll(AppSpacing.cardMargin),
      child: cardContent,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTypography.cardTitle.copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTypography.cardSubtitle.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actions != null) ...[
          SizedBox(width: AppSpacing.sm),
          ...actions!,
        ],
      ],
    );
  }
}

enum ProCardVariant {
  default_,
  elevated,
  outlined,
  filled,
}

class ProCardHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ProCardHeader({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
  }
}

class ProCardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ProCardFooter({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
  }
}

class ProCardActions extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;

  const ProCardActions({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: children,
    );
  }
}
