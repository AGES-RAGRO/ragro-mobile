import 'package:flutter/material.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';
import 'package:ragro_mobile/features/search/presentation/widgets/producer_tile.dart';
import 'package:ragro_mobile/features/search/presentation/widgets/product_tile.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.result,
    required this.onTap,
    super.key,
  });

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return result.type == SearchResultType.producer
        ? ProducerTile(result: result, onTap: onTap)
        : ProductTile(result: result, onTap: onTap);
  }
}

class StarRating extends StatelessWidget {
  const StarRating({required this.rating, super.key});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, size: 13, color: Color(0xFFFBBF24));
        } else if (i < rating && rating - i >= 0.5) {
          return const Icon(
            Icons.star_half,
            size: 13,
            color: Color(0xFFFBBF24),
          );
        } else {
          return const Icon(
            Icons.star_border,
            size: 13,
            color: Color(0xFFFBBF24),
          );
        }
      }),
    );
  }
}
