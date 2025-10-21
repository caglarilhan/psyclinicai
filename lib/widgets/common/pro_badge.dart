import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

class ProBadge extends StatelessWidget {
  final String text;
  final ProBadgeVariant variant;
  final ProBadgeSize size;
  final ProBadgePosition position;
  final Widget? child;
  final bool showZero;
  final int? count;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? minSize;
  final String? tooltip;

  const ProBadge({
    super.key,
    required this.text,
    this.variant = ProBadgeVariant.primary,
    this.size = ProBadgeSize.medium,
    this.position = ProBadgePosition.topEnd,
    this.child,
    this.showZero = false,
    this.count,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final numericCount = count ?? int.tryParse(text) ?? 0;
    final shouldShow = showZero || numericCount > 0;

    if (!shouldShow && child == null) {
      return const SizedBox.shrink();
    }

    // Size configurations
    final sizeConfig = _getSizeConfig(size);
    final badgePadding = padding ?? sizeConfig.padding;
    final badgeTextStyle = textStyle ?? sizeConfig.textStyle;
    final badgeBorderRadius = borderRadius ?? sizeConfig.borderRadius;
    final badgeMinSize = minSize ?? sizeConfig.minSize;

    // Color configurations
    final colors = _getColorConfig(variant, isDark);
    final badgeBackgroundColor = backgroundColor ?? colors.backgroundColor;
    final badgeForegroundColor = foregroundColor ?? colors.foregroundColor;

    Widget badge = Container(
      constraints: BoxConstraints(
        minWidth: badgeMinSize,
        minHeight: badgeMinSize,
      ),
      padding: badgePadding,
      decoration: BoxDecoration(
        color: badgeBackgroundColor,
        borderRadius: BorderRadius.circular(badgeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.elevationXs,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: badgeTextStyle.copyWith(color: badgeForegroundColor),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (tooltip != null) {
      badge = Tooltip(
        message: tooltip!,
        child: badge,
      );
    }

    if (child != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child!,
          Positioned(
            top: _getTopOffset(position),
            right: _getRightOffset(position),
            bottom: _getBottomOffset(position),
            left: _getLeftOffset(position),
            child: badge,
          ),
        ],
      );
    }

    return badge;
  }

  ProBadgeSizeConfig _getSizeConfig(ProBadgeSize size) {
    switch (size) {
      case ProBadgeSize.small:
        return ProBadgeSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
          textStyle: AppTypography.caption,
          borderRadius: AppSpacing.radiusSm,
          minSize: AppSpacing.xs,
        );
      case ProBadgeSize.medium:
        return ProBadgeSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          textStyle: AppTypography.labelSmall,
          borderRadius: AppSpacing.radiusMd,
          minSize: AppSpacing.sm,
        );
      case ProBadgeSize.large:
        return ProBadgeSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.labelMedium,
          borderRadius: AppSpacing.radiusLg,
          minSize: AppSpacing.md,
        );
    }
  }

  ProBadgeColorConfig _getColorConfig(ProBadgeVariant variant, bool isDark) {
    switch (variant) {
      case ProBadgeVariant.primary:
        return ProBadgeColorConfig(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        );
      case ProBadgeVariant.secondary:
        return ProBadgeColorConfig(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
        );
      case ProBadgeVariant.accent:
        return ProBadgeColorConfig(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        );
      case ProBadgeVariant.success:
        return ProBadgeColorConfig(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
        );
      case ProBadgeVariant.warning:
        return ProBadgeColorConfig(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
        );
      case ProBadgeVariant.error:
        return ProBadgeColorConfig(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        );
      case ProBadgeVariant.info:
        return ProBadgeColorConfig(
          backgroundColor: AppColors.info,
          foregroundColor: Colors.white,
        );
      case ProBadgeVariant.neutral:
        return ProBadgeColorConfig(
          backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral300,
          foregroundColor: isDark ? AppColors.neutral200 : AppColors.neutral700,
        );
    }
  }

  double? _getTopOffset(ProBadgePosition position) {
    switch (position) {
      case ProBadgePosition.topStart:
      case ProBadgePosition.topEnd:
        return -AppSpacing.sm;
      case ProBadgePosition.bottomStart:
      case ProBadgePosition.bottomEnd:
        return null;
    }
  }

  double? _getRightOffset(ProBadgePosition position) {
    switch (position) {
      case ProBadgePosition.topEnd:
      case ProBadgePosition.bottomEnd:
        return -AppSpacing.sm;
      case ProBadgePosition.topStart:
      case ProBadgePosition.bottomStart:
        return null;
    }
  }

  double? _getBottomOffset(ProBadgePosition position) {
    switch (position) {
      case ProBadgePosition.topStart:
      case ProBadgePosition.topEnd:
        return null;
      case ProBadgePosition.bottomStart:
      case ProBadgePosition.bottomEnd:
        return -AppSpacing.sm;
    }
  }

  double? _getLeftOffset(ProBadgePosition position) {
    switch (position) {
      case ProBadgePosition.topStart:
      case ProBadgePosition.bottomStart:
        return -AppSpacing.sm;
      case ProBadgePosition.topEnd:
      case ProBadgePosition.bottomEnd:
        return null;
    }
  }
}

class ProBadgeSizeConfig {
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double borderRadius;
  final double minSize;

  ProBadgeSizeConfig({
    required this.padding,
    required this.textStyle,
    required this.borderRadius,
    required this.minSize,
  });
}

class ProBadgeColorConfig {
  final Color backgroundColor;
  final Color foregroundColor;

  ProBadgeColorConfig({
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

enum ProBadgeVariant {
  primary,
  secondary,
  accent,
  success,
  warning,
  error,
  info,
  neutral,
}

enum ProBadgeSize {
  small,
  medium,
  large,
}

enum ProBadgePosition {
  topStart,
  topEnd,
  bottomStart,
  bottomEnd,
}

class ProNotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final ProBadgeVariant variant;
  final ProBadgeSize size;
  final ProBadgePosition position;
  final bool showZero;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? minSize;
  final String? tooltip;

  const ProNotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.variant = ProBadgeVariant.error,
    this.size = ProBadgeSize.small,
    this.position = ProBadgePosition.topEnd,
    this.showZero = false,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ProBadge(
      text: count > 99 ? '99+' : count.toString(),
      variant: variant,
      size: size,
      position: position,
      child: child,
      showZero: showZero,
      count: count,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: textStyle,
      padding: padding,
      borderRadius: borderRadius,
      minSize: minSize,
      tooltip: tooltip,
    );
  }
}

class ProStatusBadge extends StatelessWidget {
  final String status;
  final ProBadgeVariant? variant;
  final ProBadgeSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final double? borderRadius;
  final String? tooltip;

  const ProStatusBadge({
    super.key,
    required this.status,
    this.variant,
    this.size = ProBadgeSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final badgeVariant = variant ?? _getVariantForStatus(status);
    
    return ProBadge(
      text: status,
      variant: badgeVariant,
      size: size,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: textStyle,
      padding: padding,
      borderRadius: borderRadius,
      tooltip: tooltip,
    );
  }

  ProBadgeVariant _getVariantForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
      case 'completed':
      case 'success':
        return ProBadgeVariant.success;
      case 'pending':
      case 'waiting':
      case 'processing':
        return ProBadgeVariant.warning;
      case 'inactive':
      case 'offline':
      case 'cancelled':
      case 'failed':
      case 'error':
        return ProBadgeVariant.error;
      case 'info':
      case 'information':
        return ProBadgeVariant.info;
      default:
        return ProBadgeVariant.neutral;
    }
  }
}
