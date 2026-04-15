import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.darkGreen,
      secondary: AppColors.lightGreen,
      onSecondary: AppColors.white,
      onSurface: AppColors.black,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.white,
      surfaceContainer: AppColors.white,
      surfaceContainerHigh: AppColors.white,
      surfaceContainerHighest: AppColors.white,
      error: AppColors.red,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.title2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.placeholder),
      labelStyle: AppTextStyles.textfieldLabel,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: AppTextStyles.highlight.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.cream,
        ),
        elevation: 4,
        shadowColor: AppColors.darkGreen.withValues(alpha: 0.2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.darkGreen,
      unselectedItemColor: AppColors.placeholder,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.white,
      surfaceTintColor: AppColors.white,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: AppColors.white,
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
    ),
  );
}
