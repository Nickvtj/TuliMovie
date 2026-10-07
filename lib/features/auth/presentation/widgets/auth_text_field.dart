import 'package:flutter/material.dart';

import 'auth_tokens.dart';

/// Campo de texto do mock de auth (E-MAIL / SENHA).
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.autofillHints,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: AuthTokens.fieldLabel.copyWith(
              color: hasError ? const Color(0xFFFF2E93) : AuthTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          obscureText: _obscured,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AuthTokens.textPrimary,
          ),
          cursorColor: AuthTokens.primaryYellow,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: AuthTokens.textMuted,
            ),
            filled: true,
            fillColor: AuthTokens.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AuthTokens.textMuted,
                      size: 22,
                    ),
                  )
                : null,
            errorText: widget.errorText,
            errorStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF2E93)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthTokens.inputRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthTokens.inputRadius),
              borderSide: const BorderSide(color: AuthTokens.inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthTokens.inputRadius),
              borderSide: const BorderSide(color: AuthTokens.primaryYellow, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthTokens.inputRadius),
              borderSide: const BorderSide(color: Color(0xFFFF0055), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AuthTokens.inputRadius),
              borderSide: const BorderSide(color: Color(0xFFFF2E93), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
