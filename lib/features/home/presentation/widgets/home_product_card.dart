import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/formatters/currency.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/shared/utils/unity_type_label.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    this.isRecommended = false,
    this.aiRanked = false,
    this.aiScore,
    super.key,
  });

  final HomeProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isRecommended;

  /// `true` only when the AI reranker reordered this item (reason == LLM_RERANKED),
  /// so the "AI recommends" badge isn't shown for heuristic recommendations.
  final bool aiRanked;

  /// Relevance score (0-100) assigned by the AI, when available.
  final int? aiScore;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x00381717)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _ProductPlaceholder(),
                        )
                      : const _ProductPlaceholder(),
                ),
                if (isRecommended)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _RecommendationBadge(
                      aiRanked: aiRanked,
                      score: aiScore,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.farmName,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: formatCurrency(product.price),
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                            children: [
                              if (product.unityType.isNotEmpty)
                                TextSpan(
                                  text:
                                      ' /${localizeUnityType(product.unityType)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: AppColors.placeholder,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows "IA recomenda" + score only when the AI actually reordered the item;
/// otherwise shows a neutral "Para você" badge.
class _RecommendationBadge extends StatelessWidget {
  const _RecommendationBadge({required this.aiRanked, this.score});

  final bool aiRanked;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final label = aiRanked
        ? (score != null && score! > 0
              ? 'IA recomenda · $score%'
              : 'IA recomenda')
        : 'Para você';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: aiRanked ? const Color(0xFF98FFBD) : const Color(0xFFE2F0E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            aiRanked ? Icons.auto_awesome : Icons.favorite_border,
            color: AppColors.darkGreen,
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPlaceholder extends StatelessWidget {
  const _ProductPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.mintGreen.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.eco, size: 32, color: AppColors.darkGreen),
      ),
    );
  }
}
