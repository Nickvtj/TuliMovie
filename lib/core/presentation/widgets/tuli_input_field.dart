import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Campo de texto padronizado — labels, erros, obscure e animação de foco.
class TuliInputField extends StatefulWidget {
  const TuliInputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
    this.maxLines = 1,
    this.enabled = true,
    this.inputFormatters,
    this.labelAllCaps = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final bool labelAllCaps;

  @override
  State<TuliInputField> createState() => _TuliInputFieldState();
}

class _TuliInputFieldState extends State<TuliInputField> {
  late final FocusNode _focusNode;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _obscured = widget.obscureText;
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final focused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AnimatedDefaultTextStyle(
            duration: AppDurations.fast,
            style: (widget.labelAllCaps
                    ? theme.textTheme.labelSmall!
                    : theme.textTheme.labelMedium!)
                .copyWith(
              color: hasError
                  ? AppColors.neonRed
                  : focused
                      ? AppColors.gold
                      : AppColors.textSecondary,
              letterSpacing: widget.labelAllCaps ? 1.1 : null,
              fontWeight: widget.labelAllCaps ? FontWeight.w600 : null,
            ),
            child: Text(widget.labelAllCaps ? widget.label!.toUpperCase() : widget.label!),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: AppDurations.normal,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: AppShape.borderRadiusMd,
            boxShadow: focused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: _obscured,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            autofillHints: widget.autofillHints,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            inputFormatters: widget.inputFormatters,
            style: theme.textTheme.bodyLarge,
            cursorColor: AppColors.gold,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      icon: Icon(
                        _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                    )
                  : widget.suffixIcon,
              errorText: widget.errorText,
            ),
          ),
        ),
        if (widget.helperText != null && !hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
