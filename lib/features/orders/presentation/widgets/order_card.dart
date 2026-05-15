import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_event.dart';
import 'package:ragro_mobile/features/orders/presentation/widgets/order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, super.key});

  final Order order;

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y, ${h}h$min';
  }

  String get _displayNumber {
    if (order.orderNumber.isNotEmpty) return 'Pedido ${order.orderNumber}';
    final short = order.id.length > 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id;
    return 'Pedido #$short';
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == OrderStatus.delivered;
    final isRated = order.avaliado;

    return GestureDetector(
      onTap: () => context.push('/customer/orders/${order.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEF2EE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _displayNumber,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGreen.withValues(alpha: 0.15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: order.farmAvatarUrl.isNotEmpty
                      ? Image.network(
                          order.farmAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.storefront,
                              size: 20,
                              color: AppColors.lightGreen,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.storefront,
                            size: 20,
                            color: AppColors.lightGreen,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.farmName,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (order.ownerName.isNotEmpty)
                        Text(
                          order.ownerName,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.placeholder,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OrderStatusBadge(status: order.status),
              ],
            ),
            if (order.shortItemsPreview.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                order.shortItemsPreview,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total do Pedido',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.placeholder,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'R\$ ${order.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                if (!isDelivered || !isRated)
                  _OrderActionButton(order: order, isDelivered: isDelivered),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({required this.order, required this.isDelivered});

  final Order order;
  final bool isDelivered;

  @override
  Widget build(BuildContext context) {
    final rateRoute = Uri(
      path: '/customer/orders/${order.id}/rate',
      queryParameters: {
        'farmName': order.farmName,
        'ownerName': order.ownerName,
        'isRated': order.avaliado.toString(),
      },
    ).toString();

    return GestureDetector(
      onTap: () async {
        final rated = await context.push<bool>(
          isDelivered ? rateRoute : '/customer/orders/${order.id}',
        );

        if (context.mounted && (rated ?? false)) {
          context.read<OrdersBloc>().add(const OrdersRefreshed());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkGreen,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          isDelivered ? 'Fazer Avaliacao' : 'Ver pedido',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
