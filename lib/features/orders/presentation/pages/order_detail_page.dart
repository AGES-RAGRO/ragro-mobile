// Screen: Detalhes do Pedido
// User Story: US-12 — View Order Details
// Epic: EPIC 3 — Shopping & Orders
// Routes: GET /orders/:id

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_state.dart';
import 'package:ragro_mobile/features/orders/presentation/widgets/order_item_row.dart';
import 'package:ragro_mobile/features/orders/presentation/widgets/order_status_badge.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({required this.orderId, super.key});

  final String orderId;

  String _formatPrice(double price) =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailBloc>()..add(OrderDetailStarted(orderId)),
      child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading || state is OrderDetailInitial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.darkGreen),
              ),
            );
          }
          if (state is OrderDetailFailure) {
            return Scaffold(body: Center(child: Text(state.message)));
          }
          if (state is! OrderDetailLoaded) return const Scaffold();

          final order = state.order;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  // Main scroll
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.arrow_back, size: 16),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Detalhes do Pedido\n#${order.id}',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              OrderStatusBadge(status: order.status),
                            ],
                          ),
                        ),

                        // ITENS DO PEDIDO
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Text(
                            'ITENS DO PEDIDO',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.darkGreen,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.lightGreen.withValues(alpha: 0.05),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ...order.items.asMap().entries.map((entry) {
                                final isLast =
                                    entry.key == order.items.length - 1;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: OrderItemRow(item: entry.value),
                                    ),
                                    if (!isLast)
                                      Divider(
                                        color: AppColors.lightGreen.withValues(
                                          alpha: 0.05,
                                        ),
                                        height: 1,
                                      ),
                                  ],
                                );
                              }),
                              // Total
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreen.withValues(alpha: 0.05),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(24),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.lightGreen.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  17,
                                  16,
                                  16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    Text(
                                      _formatPrice(order.totalAmount),
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ENTREGA
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            'ENTREGA',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.darkGreen,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.lightGreen.withValues(alpha: 0.05),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: AppColors.darkGreen,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Endereço',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    Text(
                                      order.deliveryAddress.fullAddress,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 16,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    Text(
                                      order.deliveryAddress.cityStateZip,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 16,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),

                  // WhatsApp button
                  Positioned(
                    left: 27,
                    right: 27,
                    bottom: 16,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Abrindo WhatsApp...'),
                            backgroundColor: Color(0xFF25D366),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Contatar Produtor',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
