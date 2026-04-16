import 'package:flutter/material.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class ProducerStatsRow extends StatelessWidget {
  const ProducerStatsRow({
    required this.productCount,
    required this.rating,
    required this.yearsOnPlatform,
    super.key,
  });

  final int productCount;
  final double rating;
  final int yearsOnPlatform;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(value: productCount.toString(), label: 'PRODUTOS'),
        const SizedBox(width: 16),
        _StatCard(value: rating.toStringAsFixed(1), label: 'AVALIAÇÃO'),
        const SizedBox(width: 16),
        _StatCard(
          value: '${yearsOnPlatform > 0 ? yearsOnPlatform : 1} anos',
          label: 'DE RAGRO',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.darkGreen,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 12,
                color: Color(0xFF64748B),
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
