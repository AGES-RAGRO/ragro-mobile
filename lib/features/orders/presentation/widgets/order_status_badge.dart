import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key});

  final OrderStatus status;

  Color get _backgroundColor => switch (status) {
    OrderStatus.pending => const Color(0xFFFFB413),
    OrderStatus.accepted => AppColors.lightGreen,
    OrderStatus.inDelivery => AppColors.lightGreen,
    OrderStatus.delivered => const Color(0xFF3B82F6),
    OrderStatus.cancelled => AppColors.red,
  };

  IconData get _icon => switch (status) {
    OrderStatus.pending => Icons.schedule,
    OrderStatus.accepted => Icons.check_circle_outline,
    OrderStatus.inDelivery => Icons.local_shipping_outlined,
    OrderStatus.delivered => Icons.check_circle,
    OrderStatus.cancelled => Icons.cancel_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            status.label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
