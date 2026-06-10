import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/domain/order_status.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

/// Visual flavors of [OrderStatusBadge].
enum OrderStatusBadgeVariant {
  /// Compact pill used in the order detail headers (no icon).
  detail,

  /// Rounded pill with a status icon, used in order list cards.
  list,
}

/// Single status badge shared by the customer and producer order screens.
///
/// Colors and icons come from the canonical [OrderStatus] (customer page
/// palette, the app-wide reference). Unknown statuses fall back to a neutral
/// placeholder color and show the raw value.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    required this.status,
    this.label,
    this.variant = OrderStatusBadgeVariant.detail,
    super.key,
  });

  /// Backend status value (e.g. `CONFIRMED`); parsed case-insensitively.
  final String status;

  /// Optional display label override (e.g. a backend-provided label).
  /// Defaults to the canonical pt-BR label for [status].
  final String? label;

  final OrderStatusBadgeVariant variant;

  static Color _colorFor(OrderStatus? status) => switch (status) {
    OrderStatus.pending => AppColors.yellow,
    OrderStatus.accepted => AppColors.lightGreen,
    OrderStatus.inDelivery => AppColors.orange,
    OrderStatus.delivered => AppColors.blue,
    OrderStatus.cancelled => AppColors.red,
    null => AppColors.placeholder,
  };

  static IconData? _iconFor(OrderStatus? status) => switch (status) {
    OrderStatus.pending => Icons.schedule,
    OrderStatus.accepted => Icons.check_circle_outline,
    OrderStatus.inDelivery => Icons.local_shipping_outlined,
    OrderStatus.delivered => Icons.check_circle,
    OrderStatus.cancelled => Icons.cancel_outlined,
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final parsed = OrderStatus.tryParse(status);
    final color = _colorFor(parsed);
    final text = (label ?? parsed?.label ?? status).toUpperCase();
    // Pick a foreground that contrasts with the badge color (dark on light
    // colors like yellow/orange, white on dark ones).
    final foreground =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? AppColors.white
        : AppColors.black;

    final isList = variant == OrderStatusBadgeVariant.list;
    final icon = isList ? _iconFor(parsed) : null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isList ? 10 : 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isList ? 20 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: isList ? 11 : 10,
              color: foreground,
              letterSpacing: isList ? 0.5 : 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
