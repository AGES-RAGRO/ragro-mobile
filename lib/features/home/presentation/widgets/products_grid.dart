import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/home_product_card.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({
    required this.products, required this.onProductTap, required this.onAddToCart, super.key,
  });

  final List<HomeProduct> products;
  final void Function(HomeProduct) onProductTap;
  final void Function(HomeProduct) onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Produtos para você',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: AppColors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => HomeProductCard(
              product: products[index],
              onTap: () => onProductTap(products[index]),
              onAddToCart: () => onAddToCart(products[index]),
            ),
          ),
        ),
      ],
    );
  }
}
