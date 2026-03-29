// Screen: Avaliar Produtor
// User Story: US-13 — Rate Producer
// Epic: EPIC 3 — Shopping & Orders
// Routes: POST /orders/:id/rating

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_state.dart';

class RateProducerPage extends StatelessWidget {
  const RateProducerPage({
    super.key,
    required this.orderId,
    required this.farmName,
    required this.ownerName,
  });

  final String orderId;
  final String farmName;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RateProducerBloc>(),
      child: BlocListener<RateProducerBloc, RateProducerState>(
        listener: (context, state) {
          if (state is RateProducerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avaliação enviada! Obrigado.'),
                backgroundColor: AppColors.lightGreen,
              ),
            );
            context.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: BlocBuilder<RateProducerBloc, RateProducerState>(
                builder: (context, state) {
                  final selectedRating = state is RateProducerInitial ? state.selectedRating : 0;
                  final isSubmitting = state is RateProducerSubmitting;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: const Text(
                            'Pular',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      const Text(
                        'Avalie o produtor',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.lightGreen.withOpacity(0.2),
                        child: const Icon(Icons.storefront, size: 40, color: AppColors.lightGreen),
                      ),
                      const SizedBox(height: 12),
                      // Farm name
                      Text(
                        farmName,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        ownerName,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return GestureDetector(
                            onTap: () => context.read<RateProducerBloc>().add(
                                  RateProducerStarSelected(starValue),
                                ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                starValue <= selectedRating ? Icons.star : Icons.star_border,
                                color: const Color(0xFFFFB413),
                                size: 36,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      // Send button
                      GestureDetector(
                        onTap: (isSubmitting || selectedRating == 0)
                            ? null
                            : () => context.read<RateProducerBloc>().add(
                                  RateProducerSubmitted(orderId, selectedRating),
                                ),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: selectedRating > 0 ? AppColors.darkGreen : AppColors.placeholder,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isSubmitting
                                ? const CircularProgressIndicator(color: AppColors.white)
                                : const Text(
                                    'Enviar',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'RAGRO Agronegócios',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          color: AppColors.placeholder,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
