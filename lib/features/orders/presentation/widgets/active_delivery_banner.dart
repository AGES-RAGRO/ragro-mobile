import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/active_delivery_cubit.dart';

/// Banner atop the customer home (iFood/Uber Eats style): appears when an order
/// is on the way, showing the confirmation code the customer gives the
/// producer. Tap opens the order detail.
class ActiveDeliveryBanner extends StatelessWidget {
  const ActiveDeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveDeliveryCubit, ActiveDeliveryState>(
      builder: (context, state) {
        if (state is! ActiveDeliveryAvailable) return const SizedBox.shrink();
        final order = state.order;
        final code = order.confirmationCode ?? '';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push('/customer/orders/${order.id}'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Seu pedido está a caminho',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.farmName.isEmpty
                                ? 'Toque para acompanhar a entrega'
                                : '${order.farmName} • toque para acompanhar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Código de entrega',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppColors.placeholder,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    code,
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 3,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
