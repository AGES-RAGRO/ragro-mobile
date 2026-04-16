import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';

/// Reusable rounded text field for auth screens.
///
/// Supports optional password visibility toggle when [isPassword] is true.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.label,
    required this.icon,
    super.key,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.isPassword;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: isPassword && _obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      style: AppTextStyles.body.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: AppTextStyles.textfieldLabel,
        prefixIcon: Icon(widget.icon, color: AppColors.darkGreen, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.placeholder,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
    );
  }
}
