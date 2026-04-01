import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';

class ProducerCard extends StatelessWidget {
  const ProducerCard({
    super.key,
    required this.producer,
    required this.onTap,
  });

  final Producer producer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 256,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.mintGreen,
                  child: producer.avatarUrl.isNotEmpty
                      ? Image.network(
                          producer.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                        )
                      : const _PlaceholderImage(),
                ),
                // Rating badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFC107), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          producer.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producer.name,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producer.description,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.mintGreen.withOpacity(0.3),
                        child: const Icon(Icons.person, size: 14, color: AppColors.darkGreen),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        producer.ownerName,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mintGreen.withOpacity(0.2),
      child: const Center(
        child: Icon(Icons.landscape, size: 48, color: AppColors.darkGreen),
      ),
    );
  }
}
