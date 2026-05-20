import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

class ProducerOrderCard extends StatelessWidget {
  const ProducerOrderCard({
    required this.order,
    required this.onDetailTap,
    this.onActionTap,
    this.onCancelTap,
    this.onDeliveryConfirmTap,
    this.isSelected,
    this.onSelect,
    super.key,
  });

  final ProducerOrder order;
  final VoidCallback onDetailTap;
  final VoidCallback? onActionTap;
  final VoidCallback? onCancelTap;
  final VoidCallback? onDeliveryConfirmTap;
  /// When non-null the card is in selection mode; tapping selects/deselects.
  final bool? isSelected;
  final VoidCallback? onSelect;

  static final _dateFormat = DateFormat('dd/MM/yyyy, HH:mm', 'pt_BR');

  String get _subtitleLabel => switch (order.status) {
    ProducerOrderStatus.pending => 'Pedido pendente',
    ProducerOrderStatus.accepted => 'Pedido aceito',
    ProducerOrderStatus.inDelivery => 'Pedido a caminho',
    ProducerOrderStatus.delivered => 'Pedido entregue',
    ProducerOrderStatus.cancelled => 'Pedido cancelado',
  };

  String _formatPrice(double price) =>
      r'R$ ' + price.toStringAsFixed(2).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final inSelectionMode = isSelected != null;
    final selected = isSelected ?? false;

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.darkGreen.withValues(alpha: 0.06)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.darkGreen : const Color(0xFFE2E8F0),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.darkGreen.withValues(alpha: 0.1),
                child: Text(
                  order.consumerName.isNotEmpty ? order.consumerName[0] : '?',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.consumerName,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      _subtitleLabel,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: AppColors.placeholder,
                      ),
                    ),
                  ],
                ),
              ),
              if (inSelectionMode)
                Checkbox(
                  value: selected,
                  onChanged: (_) => onSelect?.call(),
                  activeColor: AppColors.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )
              else ...[
                _StatusBadge(status: order.status),
                if (order.isNew &&
                    order.status != ProducerOrderStatus.accepted) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NOVO',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.darkGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),

          // Date
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.placeholder,
              ),
              const SizedBox(width: 4),
              Text(
                _dateFormat.format(order.createdAt),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: AppColors.placeholder,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total do pedido',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: AppColors.placeholder,
                ),
              ),
              Text(
                _formatPrice(order.totalPrice),
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),

          if (!inSelectionMode) ...[
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetailTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkGreen,
                      side: const BorderSide(color: AppColors.darkGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Detalhes',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (onActionTap != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onActionTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Aceitar',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
                if (order.status == ProducerOrderStatus.inDelivery &&
                    onDeliveryConfirmTap != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDeliveryConfirmTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Entregue',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    if (inSelectionMode) {
      return GestureDetector(onTap: onSelect, child: card);
    }
    return card;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProducerOrderStatus status;

  static Color _colorFor(ProducerOrderStatus s) => switch (s) {
    ProducerOrderStatus.pending => const Color(0xFFB45309),
    ProducerOrderStatus.accepted => AppColors.darkGreen,
    ProducerOrderStatus.inDelivery => const Color(0xFFEA580C),
    ProducerOrderStatus.delivered => AppColors.darkGreen,
    ProducerOrderStatus.cancelled => AppColors.red,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);

    if (status == ProducerOrderStatus.accepted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.darkGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.white, size: 12),
            SizedBox(width: 4),
            Text(
              'ACEITO',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
