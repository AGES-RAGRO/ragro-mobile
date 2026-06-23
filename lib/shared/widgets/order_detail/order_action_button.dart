import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// Full-width pill action button for the order detail footers. Null [onTap]
/// disables it at half opacity. Supports an [isOutlined] variant (transparent
/// + colored border) and an SVG icon via [iconAsset] besides the default [icon].
class OrderActionButton extends StatelessWidget {
  const OrderActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.iconAsset,
    this.isOutlined = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final Color color;
  final bool isOutlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = onTap == null ? color.withValues(alpha: 0.5) : color;
    final contentColor = isOutlined ? effectiveColor : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isOutlined ? 48 : 52,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : effectiveColor,
          border:
              isOutlined ? Border.all(color: effectiveColor, width: 1.5) : null,
          borderRadius: BorderRadius.circular(isOutlined ? 36 : 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null)
              SvgPicture.asset(
                iconAsset!,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
              )
            else if (icon != null)
              Icon(icon, color: contentColor, size: 20),
            if (iconAsset != null || icon != null) const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: contentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
