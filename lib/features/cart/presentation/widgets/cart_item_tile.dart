import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_event.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8FAFC)),
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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.imageUrl.isNotEmpty
                  ? Image.network(item.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.eco, color: AppColors.lightGreen),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatPrice(item.totalPrice),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatPrice(item.unitPrice)} / ${item.unityType}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: AppColors.placeholder,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Quantity selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.read<CartBloc>().add(
                                  CartItemQuantityUpdated(item.productId, item.quantity - 1),
                                ),
                            child: const Icon(Icons.remove, size: 14),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => context.read<CartBloc>().add(
                                  CartItemQuantityUpdated(item.productId, item.quantity + 1),
                                ),
                            child: const Icon(Icons.add, size: 14),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Delete
                    GestureDetector(
                      onTap: () => context.read<CartBloc>().add(
                            CartItemRemoved(item.productId),
                          ),
                      child: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
