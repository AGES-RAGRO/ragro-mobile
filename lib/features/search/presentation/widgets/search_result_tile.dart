import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/search/domain/entities/search_result.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.mintGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          result.type == SearchResultType.producer
              ? Icons.storefront_outlined
              : Icons.eco_outlined,
          color: AppColors.darkGreen,
        ),
      ),
      title: Text(
        result.name,
        style: const TextStyle(
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.black,
        ),
      ),
      subtitle: Text(
        result.subtitle,
        style: const TextStyle(
          fontFamily: 'Figtree',
          fontSize: 13,
          color: AppColors.placeholder,
        ),
      ),
      trailing: result.price != null
          ? Text(
              'R\$ ${result.price!.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.darkGreen,
              ),
            )
          : null,
    );
  }
}
