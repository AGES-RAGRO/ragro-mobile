import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/presentation/widgets/home_product_card.dart';
import 'package:ragro_mobile/features/recommendations/domain/entities/recommendation.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.recommendations = const [],
    this.isLoadingMore = false,
    super.key,
  });

  final List<HomeProduct> products;
  final List<Recommendation> recommendations;
  final void Function(HomeProduct) onProductTap;
  final void Function(HomeProduct) onAddToCart;
  final bool isLoadingMore;

  List<({HomeProduct product, bool isRecommended, bool aiRanked, int score})>
  _buildItems() {
    final recommended = recommendations
        .take(20)
        .map(
          (r) => (
            product: HomeProduct(
              id: r.id,
              name: r.name,
              price: r.price,
              unityType: r.unityType,
              imageUrl: r.imageS3 ?? '',
              farmName: r.farmName,
              category: r.categoryNames.isNotEmpty ? r.categoryNames.first : '',
              producerId: r.farmerId,
            ),
            isRecommended: true,
            // Only "AI recommends" when the LLM reranker reordered it
            // (LLM_RERANKED); other reasons are heuristic ("Para você" badge).
            aiRanked: r.reason == 'LLM_RERANKED',
            score: r.score,
          ),
        )
        .toList();

    final regular = products
        .map(
          (p) => (product: p, isRecommended: false, aiRanked: false, score: 0),
        )
        .toList();

    return [...recommended, ...regular];
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

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
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return HomeProductCard(
                product: item.product,
                isRecommended: item.isRecommended,
                aiRanked: item.aiRanked,
                aiScore: item.score,
                onTap: () => onProductTap(item.product),
                onAddToCart: () => onAddToCart(item.product),
              );
            },
          ),
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            ),
          ),
      ],
    );
  }
}
