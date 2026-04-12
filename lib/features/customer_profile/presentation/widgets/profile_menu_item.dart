import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
    this.labelColor,
    this.backgroundColor,
    this.borderColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Color? labelColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor ?? const Color(0x0D2E5729)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? const Color(0x1A2E5729),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.darkGreen,
              ),
            ),
            const SizedBox(width: 17),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: labelColor ?? AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
