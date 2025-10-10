import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';

class ProInput extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final ProInputVariant variant;
  final ProInputSize size;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? errorBorderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;

  const ProInput({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.inputFormatters,
    this.focusNode,
    this.autovalidateMode,
    this.validator,
    this.variant = ProInputVariant.outlined,
    this.size = ProInputSize.medium,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.helperStyle,
    this.errorStyle,
  });

  @override
  State<ProInput> createState() => _ProInputState();
}

class _ProInputState extends State<ProInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Size configurations
    final sizeConfig = _getSizeConfig(widget.size);
    final inputPadding = widget.padding ?? sizeConfig.padding;
    final inputTextStyle = widget.textStyle ?? sizeConfig.textStyle;
    final inputLabelStyle = widget.labelStyle ?? sizeConfig.labelStyle;
    final inputHintStyle = widget.hintStyle ?? sizeConfig.hintStyle;
    final inputHelperStyle = widget.helperStyle ?? sizeConfig.helperStyle;
    final inputErrorStyle = widget.errorStyle ?? sizeConfig.errorStyle;

    // Color configurations
    final colors = _getColorConfig(widget.variant, isDark, hasError, _isFocused);
    final inputBackgroundColor = widget.backgroundColor ?? colors.backgroundColor;
    final inputBorderColor = widget.borderColor ?? colors.borderColor;
    final inputFocusBorderColor = widget.focusBorderColor ?? colors.focusBorderColor;
    final inputErrorBorderColor = widget.errorBorderColor ?? colors.errorBorderColor;

    // Border radius
    final inputBorderRadius = widget.borderRadius ?? AppSpacing.inputRadius;

    // Border configuration
    InputBorder inputBorder;
    switch (widget.variant) {
      case ProInputVariant.outlined:
        inputBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(
            color: hasError ? inputErrorBorderColor : inputBorderColor,
            width: 1,
          ),
        );
        break;
      case ProInputVariant.filled:
        inputBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide.none,
        );
        break;
      case ProInputVariant.underlined:
        inputBorder = UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? inputErrorBorderColor : inputBorderColor,
            width: 1,
          ),
        );
        break;
    }

    // Focus border
    InputBorder focusedBorder;
    switch (widget.variant) {
      case ProInputVariant.outlined:
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(
            color: inputFocusBorderColor,
            width: 2,
          ),
        );
        break;
      case ProInputVariant.filled:
        focusedBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(
            color: inputFocusBorderColor,
            width: 2,
          ),
        );
        break;
      case ProInputVariant.underlined:
        focusedBorder = UnderlineInputBorder(
          borderSide: BorderSide(
            color: inputFocusBorderColor,
            width: 2,
          ),
        );
        break;
    }

    // Error border
    InputBorder errorBorder;
    switch (widget.variant) {
      case ProInputVariant.outlined:
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(
            color: inputErrorBorderColor,
            width: 1,
          ),
        );
        break;
      case ProInputVariant.filled:
        errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(
            color: inputErrorBorderColor,
            width: 1,
          ),
        );
        break;
      case ProInputVariant.underlined:
        errorBorder = UnderlineInputBorder(
          borderSide: BorderSide(
            color: inputErrorBorderColor,
            width: 1,
          ),
        );
        break;
    }

    Widget inputField = TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      inputFormatters: widget.inputFormatters,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      style: inputTextStyle,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon ?? (widget.obscureText ? _buildObscureToggle() : null),
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        filled: widget.variant == ProInputVariant.filled,
        fillColor: inputBackgroundColor,
        contentPadding: inputPadding,
        border: inputBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        labelStyle: inputLabelStyle,
        hintStyle: inputHintStyle,
        helperStyle: inputHelperStyle,
        errorStyle: inputErrorStyle,
        counterStyle: inputHelperStyle,
      ),
    );

    return inputField;
  }

  Widget? _buildObscureToggle() {
    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        size: AppSpacing.iconSm,
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }

  ProInputSizeConfig _getSizeConfig(ProInputSize size) {
    switch (size) {
      case ProInputSize.small:
        return ProInputSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.bodySmall,
          labelStyle: AppTypography.labelSmall,
          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
          helperStyle: AppTypography.caption,
          errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        );
      case ProInputSize.medium:
        return ProInputSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          textStyle: AppTypography.bodyMedium,
          labelStyle: AppTypography.labelMedium,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500),
          helperStyle: AppTypography.caption,
          errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        );
      case ProInputSize.large:
        return ProInputSizeConfig(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          textStyle: AppTypography.bodyLarge,
          labelStyle: AppTypography.labelLarge,
          hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.neutral500),
          helperStyle: AppTypography.caption,
          errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        );
    }
  }

  ProInputColorConfig _getColorConfig(ProInputVariant variant, bool isDark, bool hasError, bool isFocused) {
    if (hasError) {
      return ProInputColorConfig(
        backgroundColor: variant == ProInputVariant.filled
            ? (isDark ? AppColors.error.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.05))
            : Colors.transparent,
        borderColor: AppColors.error,
        focusBorderColor: AppColors.error,
        errorBorderColor: AppColors.error,
      );
    }

    if (isFocused) {
      return ProInputColorConfig(
        backgroundColor: variant == ProInputVariant.filled
            ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.05))
            : Colors.transparent,
        borderColor: AppColors.primary,
        focusBorderColor: AppColors.primary,
        errorBorderColor: AppColors.error,
      );
    }

    return ProInputColorConfig(
      backgroundColor: variant == ProInputVariant.filled
          ? (isDark ? AppColors.neutral800 : AppColors.neutral100)
          : Colors.transparent,
      borderColor: isDark ? AppColors.neutral600 : AppColors.neutral300,
      focusBorderColor: AppColors.primary,
      errorBorderColor: AppColors.error,
    );
  }
}

class ProInputSizeConfig {
  final EdgeInsets padding;
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final TextStyle hintStyle;
  final TextStyle helperStyle;
  final TextStyle errorStyle;

  ProInputSizeConfig({
    required this.padding,
    required this.textStyle,
    required this.labelStyle,
    required this.hintStyle,
    required this.helperStyle,
    required this.errorStyle,
  });
}

class ProInputColorConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color focusBorderColor;
  final Color errorBorderColor;

  ProInputColorConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.focusBorderColor,
    required this.errorBorderColor,
  });
}

enum ProInputVariant {
  outlined,
  filled,
  underlined,
}

enum ProInputSize {
  small,
  medium,
  large,
}

class ProTextArea extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ProInputVariant variant;
  final ProInputSize size;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? errorBorderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;

  const ProTextArea({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.maxLines = 4,
    this.minLines = 3,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.validator,
    this.variant = ProInputVariant.outlined,
    this.size = ProInputSize.medium,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.helperStyle,
    this.errorStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ProInput(
      label: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      validator: validator,
      variant: variant,
      size: size,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      focusBorderColor: focusBorderColor,
      errorBorderColor: errorBorderColor,
      textStyle: textStyle,
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      helperStyle: helperStyle,
      errorStyle: errorStyle,
    );
  }
}
