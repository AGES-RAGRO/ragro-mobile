import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class ProducerCartHeader extends StatelessWidget {
  const ProducerCartHeader({
    super.key,
    required this.farmName,
    required this.farmLocation,
    required this.producerId,
  });

  final String farmName;
  final String farmLocation;
  final String producerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            farmName,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            farmLocation,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: AppColors.placeholder,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/consumer/home/producer/$producerId'),
            child: const Row(
              children: [
                Text(
                  'Ver perfil do produtor',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.darkGreen,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: AppColors.darkGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
