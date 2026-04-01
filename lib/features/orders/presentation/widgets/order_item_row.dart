import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_item.dart';

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.item});

  final OrderItem item;

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.lightGreen.withOpacity(0.05),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(item.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.eco, color: AppColors.lightGreen),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qtd: ${item.quantity}${item.unityType}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatPrice(item.totalPrice),
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
