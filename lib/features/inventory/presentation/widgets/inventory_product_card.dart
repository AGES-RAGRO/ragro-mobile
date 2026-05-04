import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';

class InventoryProductCard extends StatelessWidget {
  const InventoryProductCard({
    required this.product,
    required this.onEditTap,
    required this.onExitTap,
    required this.onHistoryTap,
    required this.onDeleteTap,
    super.key,
  });

  final InventoryProduct product;
  final VoidCallback onEditTap;
  final VoidCallback onExitTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onDeleteTap;

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.active && product.stock > 0;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.eco_outlined,
              size: 40,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + status badge row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.lightGreen.withValues(alpha: 0.12)
                            : AppColors.placeholder.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAvailable ? 'ATIVO' : 'SEM ESTOQUE',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: isAvailable
                              ? AppColors.lightGreen
                              : AppColors.placeholder,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Stock
                Text(
                  '${product.stock} ${product.unit} em estoque',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.placeholder,
                  ),
                ),

                const SizedBox(height: 4),

                // Price + unit
                Text(
                  '${_formatPrice(product.price)} / ${product.unit}',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.darkGreen,
                  ),
                ),

                const SizedBox(height: 10),

                // Action buttons
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ActionChip(
                      label: 'Editar',
                      icon: Icons.edit_outlined,
                      color: AppColors.lightGreen,
                      onTap: onEditTap,
                    ),
                    _ActionChip(
                      label: 'Saída',
                      icon: Icons.remove_circle_outline,
                      color: AppColors.red,
                      onTap: onExitTap,
                    ),
                    _ActionChip(
                      label: 'Histórico',
                      icon: Icons.history,
                      color: AppColors.placeholder,
                      onTap: onHistoryTap,
                    ),
                    _ActionChip(
                      label: 'Excluir',
                      icon: Icons.delete_outline,
                      color: AppColors.red,
                      onTap: onDeleteTap,
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
