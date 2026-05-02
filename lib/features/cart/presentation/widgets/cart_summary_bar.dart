import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    required this.itemCount,
    required this.totalAmount,
    super.key,
  });

  final int itemCount;
  final double totalAmount;

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/customer/cart'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        color: AppColors.darkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ver carrinho',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.white,
              ),
            ),
            Text(
              '${_formatPrice(totalAmount)} / $itemCount ${itemCount == 1 ? 'item' : 'itens'}',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
