import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

// Typography — Figtree font family
// Sizes from Figma Styleguide
abstract final class AppTextStyles {
  static const TextStyle largeTitle = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle title4 = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const TextStyle highlight = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const TextStyle footnote2 = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle captionLight = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.black,
  );

  static const TextStyle textfieldLabel = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1E293B),
  );
}
