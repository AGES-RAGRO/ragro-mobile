import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? null : Border.all(color: AppColors.black),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? AppColors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
