import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

class ProChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final ProChipVariant variant;
  final ProChipSize size;
  final Widget? avatar;
  final Widget? deleteIcon;
  final bool selected;
  final bool disabled;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;
  final Color? selectedBorderColor;
  final TextStyle? textStyle;
  final String? tooltip;

  const ProChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
    this.variant = ProChipVariant.filled,
    this.size = ProChipSize.medium,
    this.avatar,
    this.deleteIcon,
    this.selected = false,
    this.disabled = false,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.selectedBorderColor,
    this.textStyle,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isInteractive = onPressed != null || onDeleted != null;
    final isSelected = selected && !disabled;

    // Size configurations
    final sizeConfig = _getSizeConfig(size);
    final chipPadding = padding ?? sizeConfig.padding;
    final chipTextStyle = textStyle ?? sizeConfig.textStyle;
    final chipBorderRadius = borderRadius ?? sizeConfig.borderRadius;

    // Color configurations
    final colors = _getColorConfig(variant, isDark, isSelected, disabled);
    final chipBackgroundColor = isSelected
        ? (selectedBackgroundColor ?? colors.selectedBackgroundColor)
        : (backgroundColor ?? colors.backgroundColor);
    final chipForegroundColor = isSelected
        ? (selectedForegroundColor ?? colors.selectedForegroundColor)
        : (foregroundColor ?? colors.foregroundColor);
    final chipBorderColor = isSelected
        ? (selectedBorderColor ?? colors.selectedBorderColor)
        : (borderColor ?? colors.borderColor);

    Widget chipChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (avatar != null) ...[
          avatar!,
          SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: chipTextStyle.copyWith(color: chipForegroundColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onDeleted != null) ...[
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: disabled ? null : onDeleted,
            child: deleteIcon ??
                Icon(
                  Icons.close,
                  size: sizeConfig.iconSize,
                  color: chipForegroundColor.withValues(alpha: 0.7),
                ),
          ),
        ],
      ],
    );

    Widget chip = Container(
      padding: chipPadding,
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(chipBorderRadius),
        border: variant == ProChipVariant.outlined || variant == ProChipVariant.tonal
            ? Border.all(color: chipBorderColor, width: 1)
            : null,
        boxShadow: variant == ProChipVariant.filled && isSelected
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: AppSpacing.elevationXs,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: chipChild,
    );

    if (isInteractive && !disabled) {
      chip = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(chipBorderRadius),
          child: chip,
        ),
      );
    }

    if (tooltip != null) {
      chip = Tooltip(
        message: tooltip!,
        child: chip,
      );
    }

    return chip;
  }

  ProChipSizeConfig _getSizeConfig(ProChipSize size) {
    switch (size) {
      case ProChipSize.small:
        return ProChipSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          textStyle: AppTypography.labelSmall,
          borderRadius: AppSpacing.chipRadiusSm,
          iconSize: AppSpacing.iconXs,
        );
      case ProChipSize.medium:
        return ProChipSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.labelMedium,
          borderRadius: AppSpacing.chipRadiusMd,
          iconSize: AppSpacing.iconSm,
        );
      case ProChipSize.large:
        return ProChipSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          textStyle: AppTypography.labelLarge,
          borderRadius: AppSpacing.chipRadiusLg,
          iconSize: AppSpacing.iconMd,
        );
    }
  }

  ProChipColorConfig _getColorConfig(ProChipVariant variant, bool isDark, bool isSelected, bool disabled) {
    if (disabled) {
      return ProChipColorConfig(
        backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral200,
        foregroundColor: isDark ? AppColors.neutral500 : AppColors.neutral400,
        borderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
        selectedBackgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral200,
        selectedForegroundColor: isDark ? AppColors.neutral500 : AppColors.neutral400,
        selectedBorderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
      );
    }

    switch (variant) {
      case ProChipVariant.filled:
        return ProChipColorConfig(
          backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral200,
          foregroundColor: isDark ? AppColors.neutral200 : AppColors.neutral700,
          borderColor: Colors.transparent,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          selectedBorderColor: AppColors.primary,
        );
      case ProChipVariant.outlined:
        return ProChipColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? AppColors.neutral200 : AppColors.neutral700,
          borderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          selectedBorderColor: AppColors.primary,
        );
      case ProChipVariant.tonal:
        return ProChipColorConfig(
          backgroundColor: isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
          foregroundColor: AppColors.primary,
          borderColor: Colors.transparent,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          selectedBorderColor: AppColors.primary,
        );
    }
  }
}

class ProChipSizeConfig {
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double borderRadius;
  final double iconSize;

  ProChipSizeConfig({
    required this.padding,
    required this.textStyle,
    required this.borderRadius,
    required this.iconSize,
  });
}

class ProChipColorConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color selectedBackgroundColor;
  final Color selectedForegroundColor;
  final Color selectedBorderColor;

  ProChipColorConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.selectedBackgroundColor,
    required this.selectedForegroundColor,
    required this.selectedBorderColor,
  });
}

enum ProChipVariant {
  filled,
  outlined,
  tonal,
}

enum ProChipSize {
  small,
  medium,
  large,
}

class ProChipGroup extends StatefulWidget {
  final List<String> options;
  final List<String>? selectedOptions;
  final ValueChanged<List<String>>? onSelectionChanged;
  final ProChipVariant variant;
  final ProChipSize size;
  final bool multiSelect;
  final bool disabled;
  final EdgeInsets? padding;
  final double? spacing;
  final double? runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;
  final Color? selectedBorderColor;
  final TextStyle? textStyle;

  const ProChipGroup({
    super.key,
    required this.options,
    this.selectedOptions,
    this.onSelectionChanged,
    this.variant = ProChipVariant.filled,
    this.size = ProChipSize.medium,
    this.multiSelect = false,
    this.disabled = false,
    this.padding,
    this.spacing,
    this.runSpacing,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.selectedBorderColor,
    this.textStyle,
  });

  @override
  State<ProChipGroup> createState() => _ProChipGroupState();
}

class _ProChipGroupState extends State<ProChipGroup> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = widget.selectedOptions ?? [];
  }

  @override
  void didUpdateWidget(ProChipGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOptions != oldWidget.selectedOptions) {
      _selectedOptions = widget.selectedOptions ?? [];
    }
  }

  void _handleChipTap(String option) {
    if (widget.disabled) return;

    setState(() {
      if (widget.multiSelect) {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.remove(option);
        } else {
          _selectedOptions.add(option);
        }
      } else {
        _selectedOptions = _selectedOptions.contains(option) ? [] : [option];
      }
    });

    widget.onSelectionChanged?.call(_selectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: widget.spacing ?? AppSpacing.sm,
        runSpacing: widget.runSpacing ?? AppSpacing.sm,
        alignment: widget.alignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        runAlignment: widget.runAlignment,
        children: widget.options.map((option) {
          final isSelected = _selectedOptions.contains(option);
          return ProChip(
            label: option,
            onPressed: () => _handleChipTap(option),
            variant: widget.variant,
            size: widget.size,
            selected: isSelected,
            disabled: widget.disabled,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            borderColor: widget.borderColor,
            selectedBackgroundColor: widget.selectedBackgroundColor,
            selectedForegroundColor: widget.selectedForegroundColor,
            selectedBorderColor: widget.selectedBorderColor,
            textStyle: widget.textStyle,
          );
        }).toList(),
      ),
    );
  }
}
