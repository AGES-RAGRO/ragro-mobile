import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// Uppercase section header used by the order detail screens
/// (e.g. `ITENS DO PEDIDO`, `ENTREGA`).
class OrderSectionTitle extends StatelessWidget {
  const OrderSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.darkGreen,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
