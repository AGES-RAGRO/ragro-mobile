import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.confirmColor,
    this.cancelLabel = 'Cancelar',
  });

  final Widget title;
  final String confirmLabel;
  final Color confirmColor;
  final String cancelLabel;

  static Future<bool?> show({
    required BuildContext context,
    required Widget title,
    required String confirmLabel,
    required Color confirmColor,
    String cancelLabel = 'Cancelar',
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => ConfirmDialog(
        title: title,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: AppColors.black,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              child: title,
            ),
            const SizedBox(height: 24),
            _DialogButton(
              label: confirmLabel,
              color: confirmColor,
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            _DialogButton(
              label: cancelLabel,
              color: AppColors.white,
              textColor: AppColors.black,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = AppColors.white,
    this.border,
  });

  final String label;
  final Color color;
  final Color textColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
