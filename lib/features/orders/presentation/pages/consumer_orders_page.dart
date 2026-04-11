// Screen: Tela de Pedidos (Pendentes/Aceitos/Entregues/Cancelados)
// User Story: US-11 — View Orders
// Epic: EPIC 3 — Shopping & Orders
// Routes: GET /orders?status=...

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_state.dart';
import 'package:ragro_mobile/features/orders/presentation/widgets/order_card.dart';

class ConsumerOrdersPage extends StatelessWidget {
  const ConsumerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<OrdersBloc>()..add(const OrdersStarted(OrderStatus.pending)),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  static const _tabs = [
    (OrderStatus.accepted, 'Aceitos'),
    (OrderStatus.pending, 'Pendentes'),
    (OrderStatus.delivered, 'Entregues'),
    (OrderStatus.cancelled, 'Cancelados'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Text(
                'Pedidos',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            // Tab bar
            BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                final activeTab = state is OrdersLoading
                    ? state.activeTab
                    : state is OrdersLoaded
                    ? state.activeTab
                    : OrderStatus.pending;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: _tabs.map((tab) {
                      final isActive = activeTab == tab.$1;
                      return GestureDetector(
                        onTap: () => context.read<OrdersBloc>().add(
                          OrdersTabChanged(tab.$1),
                        ),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 17, 24, 18),
                          decoration: BoxDecoration(
                            border: isActive
                                ? const Border(
                                    bottom: BorderSide(
                                      color: AppColors.darkGreen,
                                      width: 3,
                                    ),
                                  )
                                : null,
                          ),
                          child: Text(
                            tab.$2,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 14,
                              color: isActive
                                  ? AppColors.darkGreen
                                  : AppColors.placeholder,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            // Content
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkGreen,
                      ),
                    );
                  }
                  if (state is OrdersFailure) {
                    return Center(child: Text(state.message));
                  }
                  if (state is! OrdersLoaded) return const SizedBox.shrink();
                  if (state.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: AppColors.placeholder,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum pedido ${state.activeTab.label.toLowerCase()}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              color: AppColors.placeholder,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 13),
                    itemBuilder: (context, index) =>
                        OrderCard(order: state.orders[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
