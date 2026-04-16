import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';

/// Shared logo widget used across all auth screens.
class RagroLogo extends StatelessWidget {
  const RagroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/logo_ragro.svg',
          height: 300,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
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
