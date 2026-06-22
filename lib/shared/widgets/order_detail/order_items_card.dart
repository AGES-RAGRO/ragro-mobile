import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// `ITENS DO PEDIDO` card: the item rows separated by dividers plus the
/// highlighted `Total` footer. [totalLabel] arrives formatted (currency).
class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({
    required this.items,
    required this.totalLabel,
    super.key,
  });

  final List<Widget> items;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                entry.value,
                if (!isLast)
                  Divider(
                    color: AppColors.lightGreen.withValues(alpha: 0.08),
                    height: 1,
                  ),
              ],
            );
          }),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  totalLabel,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
