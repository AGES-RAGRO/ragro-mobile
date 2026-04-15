import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// Reusable confirmation dialog.
///
/// Renders a bold [title] with an optional inline [highlight] span
/// (commonly used to emphasize a resource name). Optionally accepts a
/// secondary [description] line, an [icon], and customizable confirm
/// and cancel actions.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.confirmLabel,
    required this.confirmColor,
    super.key,
    this.highlight,
    this.highlightColor,
    this.trailingTitle,
    this.description,
    this.icon,
    this.cancelLabel = 'Cancelar',
  });

  final String title;
  final String? highlight;
  final Color? highlightColor;
  final String? trailingTitle;
  final String? description;
  final IconData? icon;
  final String confirmLabel;
  final Color confirmColor;
  final String cancelLabel;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    required Color confirmColor,
    String? highlight,
    Color? highlightColor,
    String? trailingTitle,
    String? description,
    IconData? icon,
    String cancelLabel = 'Cancelar',
    bool barrierDismissible = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => ConfirmDialog(
        title: title,
        highlight: highlight,
        highlightColor: highlightColor,
        trailingTitle: trailingTitle,
        description: description,
        icon: icon,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const baseTitleStyle = TextStyle(
      fontFamily: 'Figtree',
      fontWeight: FontWeight.w600,
      fontSize: 17,
      color: AppColors.black,
      height: 1.4,
    );

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 40, color: confirmColor),
              const SizedBox(height: 12),
            ],
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: baseTitleStyle,
                children: [
                  TextSpan(text: title),
                  if (highlight != null)
                    TextSpan(
                      text: highlight,
                      style: baseTitleStyle.copyWith(
                        color: highlightColor ?? confirmColor,
                      ),
                    ),
                  if (trailingTitle != null) TextSpan(text: trailingTitle),
                ],
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: AppColors.placeholder,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _DialogButton(
              label: confirmLabel,
              semanticsLabel: '$confirmLabel — $title${highlight ?? ''}',
              color: confirmColor,
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            _DialogButton(
              label: cancelLabel,
              semanticsLabel: cancelLabel,
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
    required this.semanticsLabel,
    this.textColor = AppColors.white,
    this.border,
  });

  final String label;
  final String semanticsLabel;
  final Color color;
  final Color textColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
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
        ),
      ),
    );
  }
}
