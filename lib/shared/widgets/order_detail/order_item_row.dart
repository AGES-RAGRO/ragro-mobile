import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// One product row inside the `ITENS DO PEDIDO` card: photo, name, quantity,
/// unit price and subtotal. All labels arrive display-ready so the widget
/// stays agnostic of the customer/producer entities.
class OrderItemRow extends StatelessWidget {
  const OrderItemRow({
    required this.name,
    required this.photoUrl,
    required this.quantityLabel,
    required this.unitPriceLabel,
    required this.subtotalLabel,
    super.key,
  });

  final String name;
  final String photoUrl;
  final String quantityLabel;
  final String unitPriceLabel;
  final String subtotalLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.lightGreen.withValues(alpha: 0.05),
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.eco, color: AppColors.lightGreen),
                    )
                  : const Icon(Icons.eco, color: AppColors.lightGreen),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quantityLabel,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.placeholder,
                  ),
                ),
                Text(
                  unitPriceLabel,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtotalLabel,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
