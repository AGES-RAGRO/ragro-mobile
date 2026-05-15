// Screen: Avaliar Produtor
// User Story: US-13 — Rate Producer
// Epic: EPIC 3 — Shopping & Orders
// Routes: POST /reviews

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
    required this.orderId,
    required this.farmName,
    required this.ownerName,
    this.isRated = false,
    super.key,
  });

  final String orderId;
  final String farmName;
  final String ownerName;
  final bool isRated;

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
          } else if (state is RateProducerFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
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
                  final selectedRating = state is RateProducerInitial
                      ? state.selectedRating
                      : state is RateProducerSubmitting
                      ? state.selectedRating
                      : state is RateProducerFailure
                      ? state.selectedRating
                      : 0;
                  final comment = state is RateProducerInitial
                      ? state.comment
                      : state is RateProducerSubmitting
                      ? state.comment
                      : state is RateProducerFailure
                      ? state.comment
                      : '';
                  final isSubmitting = state is RateProducerSubmitting;
                  final canSubmit = selectedRating > 0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Text(
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
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      const Text(
                        'Avalie o Produtor',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Avatar + producer info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.lightGreen.withValues(
                              alpha: 0.2,
                            ),
                            child: const Icon(
                              Icons.storefront,
                              size: 18,
                              color: AppColors.lightGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ownerName,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                farmName,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  color: AppColors.placeholder,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Icon(
                                starValue <= selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.darkGreen,
                                size: 36,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      // Comment
                      TextFormField(
                        initialValue: comment,
                        enabled: !isSubmitting,
                        maxLines: 3,
                        onChanged: (value) => context
                            .read<RateProducerBloc>()
                            .add(RateProducerCommentChanged(value)),
                        decoration: InputDecoration(
                          hintText: 'Comentario (opcional)',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Send button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (!canSubmit || isSubmitting)
                              ? null
                              : () => context.read<RateProducerBloc>().add(
                                  RateProducerSubmitted(
                                    orderId,
                                    selectedRating,
                                    comment.trim(),
                                  ),
                                ),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: canSubmit
                                  ? AppColors.darkGreen
                                  : AppColors.placeholder,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: isSubmitting
                                  ? const CircularProgressIndicator(
                                      color: AppColors.white,
                                    )
                                  : Text(
                                      canSubmit ? 'Enviar' : 'Fechar',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        color: AppColors.white,
                                      ),
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
