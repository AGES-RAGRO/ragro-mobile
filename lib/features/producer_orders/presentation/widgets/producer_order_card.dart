import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

class ProducerOrderCard extends StatelessWidget {
  const ProducerOrderCard({
    super.key,
    required this.order,
    required this.onDetailTap,
    required this.onActionTap,
  });

  final ProducerOrder order;
  final VoidCallback onDetailTap;
  final VoidCallback onActionTap;

  String get _actionLabel => switch (order.status) {
    ProducerOrderStatus.pending => 'Aceitar',
    ProducerOrderStatus.accepted => 'A caminho',
    ProducerOrderStatus.inDelivery => 'Entregue',
    ProducerOrderStatus.delivered => 'Ver',
    ProducerOrderStatus.cancelled => 'Ver',
  };

  String get _subtitleLabel => switch (order.status) {
    ProducerOrderStatus.pending => 'Pedido pendente',
    ProducerOrderStatus.accepted => 'Pedido aceito',
    ProducerOrderStatus.inDelivery => 'Pedido a caminho',
    ProducerOrderStatus.delivered => 'Pedido entregue',
    ProducerOrderStatus.cancelled => 'Pedido cancelado',
  };

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                backgroundColor: AppColors.darkGreen.withOpacity(0.1),
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
              // NOVO badge
              if (order.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(0.1),
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
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),

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
                  child: Text(
                    _actionLabel,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
