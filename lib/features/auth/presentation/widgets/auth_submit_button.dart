import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';

/// Full-width primary action button for auth screens.
///
/// Shows a [CircularProgressIndicator] when [isLoading] is true.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.darkGreen.withValues(alpha: 0.7),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: AppTextStyles.highlight.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label),
      ),
    );
  }
}
