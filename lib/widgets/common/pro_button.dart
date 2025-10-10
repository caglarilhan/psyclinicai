import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

class ProButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ProButtonVariant variant;
  final ProButtonSize size;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;

  const ProButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ProButtonVariant.primary,
    this.size = ProButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = onPressed == null || isLoading;

    // Size configurations
    final sizeConfig = _getSizeConfig(size);
    final buttonHeight = sizeConfig.height;
    final buttonPadding = padding ?? sizeConfig.padding;
    final buttonTextStyle = textStyle ?? sizeConfig.textStyle;

    // Color configurations
    final colors = _getColorConfig(variant, isDark, isDisabled);
    final buttonBackgroundColor = backgroundColor ?? colors.backgroundColor;
    final buttonForegroundColor = foregroundColor ?? colors.foregroundColor;
    final buttonBorderColor = borderColor ?? colors.borderColor;

    // Border radius
    final buttonBorderRadius = borderRadius ?? AppSpacing.buttonRadius;

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: sizeConfig.iconSize,
            height: sizeConfig.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(buttonForegroundColor),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            text,
            style: buttonTextStyle.copyWith(color: buttonForegroundColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: AppSpacing.sm),
          trailingIcon!,
        ],
      ],
    );

    Widget button = Container(
      height: buttonHeight,
      padding: buttonPadding,
      decoration: BoxDecoration(
        color: buttonBackgroundColor,
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        border: variant == ProButtonVariant.outline || variant == ProButtonVariant.ghost
            ? Border.all(color: buttonBorderColor, width: 1)
            : null,
        boxShadow: variant == ProButtonVariant.primary || variant == ProButtonVariant.secondary
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: AppSpacing.elevationXs,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: buttonChild,
    );

    if (onPressed != null && !isLoading) {
      button = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          child: button,
        ),
      );
    }

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ProButtonSizeConfig _getSizeConfig(ProButtonSize size) {
    switch (size) {
      case ProButtonSize.small:
        return ProButtonSizeConfig(
          height: AppSpacing.buttonHeightSm,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.labelMedium,
          iconSize: AppSpacing.iconSm,
        );
      case ProButtonSize.medium:
        return ProButtonSizeConfig(
          height: AppSpacing.buttonHeightMd,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          textStyle: AppTypography.button,
          iconSize: AppSpacing.iconMd,
        );
      case ProButtonSize.large:
        return ProButtonSizeConfig(
          height: AppSpacing.buttonHeightLg,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          textStyle: AppTypography.labelLarge,
          iconSize: AppSpacing.iconLg,
        );
    }
  }

  ProButtonColorConfig _getColorConfig(ProButtonVariant variant, bool isDark, bool isDisabled) {
    if (isDisabled) {
      return ProButtonColorConfig(
        backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral200,
        foregroundColor: isDark ? AppColors.neutral500 : AppColors.neutral400,
        borderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
      );
    }

    switch (variant) {
      case ProButtonVariant.primary:
        return ProButtonColorConfig(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          borderColor: AppColors.primary,
        );
      case ProButtonVariant.secondary:
        return ProButtonColorConfig(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          borderColor: AppColors.secondary,
        );
      case ProButtonVariant.accent:
        return ProButtonColorConfig(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          borderColor: AppColors.accent,
        );
      case ProButtonVariant.outline:
        return ProButtonColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.neutral200 : AppColors.neutral700,
          borderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
        );
      case ProButtonVariant.ghost:
        return ProButtonColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.neutral200 : AppColors.neutral700,
          borderColor: Colors.transparent,
        );
      case ProButtonVariant.danger:
        return ProButtonColorConfig(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          borderColor: AppColors.error,
        );
      case ProButtonVariant.success:
        return ProButtonColorConfig(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          borderColor: AppColors.success,
        );
    }
  }
}

class ProButtonSizeConfig {
  final double height;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;

  ProButtonSizeConfig({
    required this.height,
    required this.padding,
    required this.textStyle,
    required this.iconSize,
  });
}

class ProButtonColorConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  ProButtonColorConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}

enum ProButtonVariant {
  primary,
  secondary,
  accent,
  outline,
  ghost,
  danger,
  success,
}

enum ProButtonSize {
  small,
  medium,
  large,
}

class ProIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ProButtonVariant variant;
  final ProButtonSize size;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final String? tooltip;

  const ProIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = ProButtonVariant.primary,
    this.size = ProButtonSize.medium,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = onPressed == null || isLoading;

    // Size configurations
    final sizeConfig = _getSizeConfig(size);
    final buttonSize = sizeConfig.size;
    final iconSize = sizeConfig.iconSize;

    // Color configurations
    final colors = _getColorConfig(variant, isDark, isDisabled);
    final buttonBackgroundColor = backgroundColor ?? colors.backgroundColor;
    final buttonForegroundColor = foregroundColor ?? colors.foregroundColor;
    final buttonBorderColor = borderColor ?? colors.borderColor;

    // Border radius
    final buttonBorderRadius = borderRadius ?? AppSpacing.buttonRadius;

    Widget buttonChild = SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: isLoading
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(buttonForegroundColor),
              ),
            )
          : Icon(
              icon,
              size: iconSize,
              color: buttonForegroundColor,
            ),
    );

    Widget button = Container(
      decoration: BoxDecoration(
        color: buttonBackgroundColor,
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        border: variant == ProButtonVariant.outline || variant == ProButtonVariant.ghost
            ? Border.all(color: buttonBorderColor, width: 1)
            : null,
        boxShadow: variant == ProButtonVariant.primary || variant == ProButtonVariant.secondary
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: AppSpacing.elevationXs,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: buttonChild,
    );

    if (onPressed != null && !isLoading) {
      button = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          child: button,
        ),
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  ProIconButtonSizeConfig _getSizeConfig(ProButtonSize size) {
    switch (size) {
      case ProButtonSize.small:
        return ProIconButtonSizeConfig(
          size: 32,
          iconSize: AppSpacing.iconSm,
        );
      case ProButtonSize.medium:
        return ProIconButtonSizeConfig(
          size: 40,
          iconSize: AppSpacing.iconMd,
        );
      case ProButtonSize.large:
        return ProIconButtonSizeConfig(
          size: 48,
          iconSize: AppSpacing.iconLg,
        );
    }
  }

  ProButtonColorConfig _getColorConfig(ProButtonVariant variant, bool isDark, bool isDisabled) {
    if (isDisabled) {
      return ProButtonColorConfig(
        backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral200,
        foregroundColor: isDark ? AppColors.neutral500 : AppColors.neutral400,
        borderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
      );
    }

    switch (variant) {
      case ProButtonVariant.primary:
        return ProButtonColorConfig(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          borderColor: AppColors.primary,
        );
      case ProButtonVariant.secondary:
        return ProButtonColorConfig(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          borderColor: AppColors.secondary,
        );
      case ProButtonVariant.accent:
        return ProButtonColorConfig(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          borderColor: AppColors.accent,
        );
      case ProButtonVariant.outline:
        return ProButtonColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.neutral200 : AppColors.neutral700,
          borderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
        );
      case ProButtonVariant.ghost:
        return ProButtonColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.neutral200 : AppColors.neutral700,
          borderColor: Colors.transparent,
        );
      case ProButtonVariant.danger:
        return ProButtonColorConfig(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          borderColor: AppColors.error,
        );
      case ProButtonVariant.success:
        return ProButtonColorConfig(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          borderColor: AppColors.success,
        );
    }
  }
}

class ProIconButtonSizeConfig {
  final double size;
  final double iconSize;

  ProIconButtonSizeConfig({
    required this.size,
    required this.iconSize,
  });
}
