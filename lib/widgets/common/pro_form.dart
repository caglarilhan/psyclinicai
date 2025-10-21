import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';
import 'pro_input.dart';
import 'pro_button.dart';
import 'pro_chip.dart';

class ProForm extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final List<ProFormField> fields;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final ProFormSubmitButton? submitButton;
  final List<ProFormAction>? actions;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool showBorder;
  final Color? borderColor;
  final Function(Map<String, dynamic>)? onSubmit;
  final Function()? onReset;
  final bool loading;
  final bool disabled;

  const ProForm({
    super.key,
    this.formKey,
    required this.fields,
    this.title,
    this.subtitle,
    this.headerAction,
    this.submitButton,
    this.actions,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.titleStyle,
    this.subtitleStyle,
    this.showBorder = true,
    this.borderColor,
    this.onSubmit,
    this.onReset,
    this.loading = false,
    this.disabled = false,
  });

  @override
  State<ProForm> createState() => _ProFormState();
}

class _ProFormState extends State<ProForm> {
  late GlobalKey<FormState> _formKey;
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _initializeForm();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  void _initializeForm() {
    for (final field in widget.fields) {
      _formData[field.key] = field.initialValue;
      
      if (field.controller == null) {
        _controllers[field.key] = TextEditingController(
          text: field.initialValue?.toString() ?? '',
        );
      }
      
      if (field.focusNode == null) {
        _focusNodes[field.key] = FocusNode();
      }
    }
  }

  void _updateFormData(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit?.call(_formData);
    }
  }

  void _handleReset() {
    _formKey.currentState!.reset();
    setState(() {
      _formData.clear();
      _initializeForm();
    });
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formPadding = widget.padding ?? AppSpacing.paddingAll(AppSpacing.lg);
    final formBorderRadius = widget.borderRadius ?? AppSpacing.cardRadius;
    final formBackgroundColor = widget.backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final formBorderColor = widget.borderColor ?? (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    return Container(
      padding: formPadding,
      decoration: BoxDecoration(
        color: formBackgroundColor,
        borderRadius: BorderRadius.circular(formBorderRadius),
        border: widget.showBorder
            ? Border.all(
                color: formBorderColor,
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null || widget.subtitle != null || widget.headerAction != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.title != null)
                          Text(
                            widget.title!,
                            style: widget.titleStyle ?? AppTypography.headlineSmall.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (widget.subtitle != null) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.subtitle!,
                            style: widget.subtitleStyle ?? AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.headerAction != null) widget.headerAction!,
                ],
              ),
              SizedBox(height: AppSpacing.lg),
            ],
            ...widget.fields.map((field) => _buildFormField(field, isDark)).toList(),
            if (widget.submitButton != null || (widget.actions != null && widget.actions!.isNotEmpty)) ...[
              SizedBox(height: AppSpacing.lg),
              _buildFormActions(isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(ProFormField field, bool isDark) {
    Widget fieldWidget;

    switch (field.type) {
      case ProFormFieldType.text:
        fieldWidget = ProInput(
          label: field.label,
          hintText: field.hintText,
          helperText: field.helperText,
          controller: field.controller ?? _controllers[field.key],
          focusNode: field.focusNode ?? _focusNodes[field.key],
          keyboardType: field.keyboardType,
          textInputAction: field.textInputAction,
          obscureText: field.obscureText,
          enabled: !widget.disabled,
          readOnly: field.readOnly,
          maxLines: field.maxLines,
          minLines: field.minLines,
          maxLength: field.maxLength,
          prefixIcon: field.prefixIcon,
          suffixIcon: field.suffixIcon,
          prefixText: field.prefixText,
          suffixText: field.suffixText,
          onChanged: (value) {
            _updateFormData(field.key, value);
            field.onChanged?.call(value);
          },
          validator: field.validator,
          variant: field.variant,
          size: field.size,
        );
        break;
      case ProFormFieldType.textArea:
        fieldWidget = ProTextArea(
          label: field.label,
          hintText: field.hintText,
          helperText: field.helperText,
          controller: field.controller ?? _controllers[field.key],
          focusNode: field.focusNode ?? _focusNodes[field.key],
          maxLines: field.maxLines,
          minLines: field.minLines,
          maxLength: field.maxLength,
          enabled: !widget.disabled,
          readOnly: field.readOnly,
          onChanged: (value) {
            _updateFormData(field.key, value);
            field.onChanged?.call(value);
          },
          validator: field.validator,
          variant: field.variant,
          size: field.size,
        );
        break;
      case ProFormFieldType.chipGroup:
        fieldWidget = ProChipGroup(
          options: field.options ?? [],
          selectedOptions: _formData[field.key] as List<String>?,
          onSelectionChanged: (selected) {
            _updateFormData(field.key, selected);
            field.onChanged?.call(selected);
          },
          variant: field.chipVariant,
          size: field.chipSize,
          multiSelect: field.multiSelect,
          disabled: widget.disabled,
        );
        break;
      case ProFormFieldType.custom:
        fieldWidget = field.customWidget ?? const SizedBox.shrink();
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: field.bottomPadding ?? AppSpacing.lg),
      child: fieldWidget,
    );
  }

  Widget _buildFormActions(bool isDark) {
    return Row(
      children: [
        if (widget.submitButton != null) ...[
          Expanded(
            child: ProButton(
              text: widget.submitButton!.text,
              onPressed: widget.disabled || widget.loading ? null : _handleSubmit,
              variant: widget.submitButton!.variant,
              size: widget.submitButton!.size,
              isLoading: widget.loading,
              icon: widget.submitButton!.icon,
              isFullWidth: widget.submitButton!.isFullWidth,
            ),
          ),
        ],
        if (widget.actions != null && widget.actions!.isNotEmpty) ...[
          SizedBox(width: AppSpacing.md),
          ...widget.actions!.map((action) => Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: ProButton(
                  text: action.text,
                  onPressed: widget.disabled ? null : action.onPressed,
                  variant: action.variant,
                  size: action.size,
                  icon: action.icon,
                ),
              )),
        ],
      ],
    );
  }
}

class ProFormField {
  final String key;
  final ProFormFieldType type;
  final String? label;
  final String? hintText;
  final String? helperText;
  final dynamic initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final Function(dynamic)? onChanged;
  final String? Function(String?)? validator;
  final ProInputVariant variant;
  final ProInputSize size;
  final List<String>? options;
  final ProChipVariant chipVariant;
  final ProChipSize chipSize;
  final bool multiSelect;
  final Widget? customWidget;
  final double? bottomPadding;

  ProFormField({
    required this.key,
    required this.type,
    this.label,
    this.hintText,
    this.helperText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.onChanged,
    this.validator,
    this.variant = ProInputVariant.outlined,
    this.size = ProInputSize.medium,
    this.options,
    this.chipVariant = ProChipVariant.filled,
    this.chipSize = ProChipSize.medium,
    this.multiSelect = false,
    this.customWidget,
    this.bottomPadding,
  });
}

class ProFormSubmitButton {
  final String text;
  final ProButtonVariant variant;
  final ProButtonSize size;
  final Widget? icon;
  final bool isFullWidth;

  ProFormSubmitButton({
    required this.text,
    this.variant = ProButtonVariant.primary,
    this.size = ProButtonSize.medium,
    this.icon,
    this.isFullWidth = true,
  });
}

class ProFormAction {
  final String text;
  final VoidCallback? onPressed;
  final ProButtonVariant variant;
  final ProButtonSize size;
  final Widget? icon;

  ProFormAction({
    required this.text,
    this.onPressed,
    this.variant = ProButtonVariant.outline,
    this.size = ProButtonSize.medium,
    this.icon,
  });
}

enum ProFormFieldType {
  text,
  textArea,
  chipGroup,
  custom,
}

class ProFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ProFormField> fields;
  final Widget? headerAction;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool showBorder;
  final Color? borderColor;
  final bool collapsible;
  final bool initiallyExpanded;

  const ProFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.fields,
    this.headerAction,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.titleStyle,
    this.subtitleStyle,
    this.showBorder = true,
    this.borderColor,
    this.collapsible = false,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionPadding = padding ?? AppSpacing.paddingAll(AppSpacing.lg);
    final sectionBorderRadius = borderRadius ?? AppSpacing.cardRadius;
    final sectionBackgroundColor = backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final sectionBorderColor = borderColor ?? (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    Widget content = Container(
      padding: sectionPadding,
      decoration: BoxDecoration(
        color: sectionBackgroundColor,
        borderRadius: BorderRadius.circular(sectionBorderRadius),
        border: showBorder
            ? Border.all(
                color: sectionBorderColor,
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                  ],
                ),
              ),
              if (headerAction != null) headerAction!,
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ...fields.map((field) => _buildFormField(field, isDark)).toList(),
        ],
      ),
    );

    if (collapsible) {
      return ExpansionTile(
        title: Text(
          title,
          style: titleStyle ?? AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: subtitleStyle ?? AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              )
            : null,
        initiallyExpanded: initiallyExpanded,
        children: [
          Padding(
            padding: AppSpacing.paddingAll(AppSpacing.lg),
            child: Column(
              children: fields.map((field) => _buildFormField(field, isDark)).toList(),
            ),
          ),
        ],
      );
    }

    return content;
  }

  Widget _buildFormField(ProFormField field, bool isDark) {
    // This is a simplified version - in a real implementation,
    // you'd want to handle the form field rendering properly
    return Padding(
      padding: EdgeInsets.only(bottom: field.bottomPadding ?? AppSpacing.lg),
      child: ProInput(
        label: field.label,
        hintText: field.hintText,
        helperText: field.helperText,
        controller: field.controller,
        focusNode: field.focusNode,
        keyboardType: field.keyboardType,
        textInputAction: field.textInputAction,
        obscureText: field.obscureText,
        readOnly: field.readOnly,
        maxLines: field.maxLines,
        minLines: field.minLines,
        maxLength: field.maxLength,
        prefixIcon: field.prefixIcon,
        suffixIcon: field.suffixIcon,
        prefixText: field.prefixText,
        suffixText: field.suffixText,
        onChanged: field.onChanged,
        validator: field.validator,
        variant: field.variant,
        size: field.size,
      ),
    );
  }
}
