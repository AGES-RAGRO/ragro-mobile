import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';

/// Shared logo widget used across all auth screens.
/// Displays "ragro" in large bold darkGreen and the tagline below.
class RagroLogo extends StatelessWidget {
  const RagroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ragro',
          style: AppTextStyles.largeTitle.copyWith(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Do campo à mesa',
          style: AppTextStyles.body.copyWith(
            color: AppColors.darkGreen.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
