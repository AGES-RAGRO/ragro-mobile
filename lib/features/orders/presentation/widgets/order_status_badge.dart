import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  Color get _backgroundColor => switch (status) {
        OrderStatus.pending => const Color(0xFFFFB413),
        OrderStatus.accepted => AppColors.lightGreen,
        OrderStatus.delivered => const Color(0xFF3B82F6),
        OrderStatus.cancelled => AppColors.red,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != OrderStatus.cancelled) ...[
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
