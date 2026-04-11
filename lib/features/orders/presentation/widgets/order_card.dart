import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/presentation/widgets/order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y, ${h}h$min';
  }

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Order number (top-left)
          Positioned(
            top: 8,
            left: 8,
            child: Text(
              'Pedido #${order.id}',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: AppColors.placeholder,
              ),
            ),
          ),
          // Date (top-right)
          Positioned(
            top: 8,
            right: 8,
            child: Text(
              _formatDate(order.createdAt),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: AppColors.black,
              ),
            ),
          ),
          // Status badge
          Positioned(
            top: 28,
            right: 8,
            child: OrderStatusBadge(status: order.status),
          ),
          // Producer info
          Positioned(
            top: 27,
            left: 8,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.lightGreen.withOpacity(0.2),
                  backgroundImage: order.farmAvatarUrl.isNotEmpty
                      ? NetworkImage(order.farmAvatarUrl)
                      : null,
                  child: order.farmAvatarUrl.isEmpty
                      ? const Icon(
                          Icons.storefront,
                          size: 16,
                          color: AppColors.lightGreen,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.farmName,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      order.ownerName,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w200,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Items preview
          Positioned(
            top: 75,
            left: 8,
            right: 8,
            child: Text(
              order.shortItemsPreview,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: AppColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Bottom row: total + button
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total do Pedido',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatPrice(order.totalAmount),
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/consumer/orders/${order.id}'),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Ver pedido',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
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
