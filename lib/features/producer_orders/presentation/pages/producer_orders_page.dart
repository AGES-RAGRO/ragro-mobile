// Screen: Producer Orders (Pedidos do Produtor)
// User Story: US-20 — Manage Received Orders
// Epic: EPIC 4 — Producer Features
// Routes: GET /orders/producer

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_bloc.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_state.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/widgets/producer_order_card.dart';

class ProducerOrdersPage extends StatelessWidget {
  const ProducerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProducerOrdersBloc>()
            ..add(const ProducerOrdersStarted(ProducerOrderStatus.pending)),
      child: const _ProducerOrdersView(),
    );
  }
}

class _ProducerOrdersView extends StatelessWidget {
  const _ProducerOrdersView();

  static const _tabs = [
    (ProducerOrderStatus.pending, 'Pendentes'),
    (ProducerOrderStatus.accepted, 'Aceitos'),
    (ProducerOrderStatus.inDelivery, 'A caminho'),
    (ProducerOrderStatus.delivered, 'Entregues'),
    (ProducerOrderStatus.cancelled, 'Cancelados'),
  ];

  String get _todayLabel {
    final now = DateTime.now();
    final months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return 'Hoje, ${now.day} de ${months[now.month - 1]}';
  }

  ProducerOrderStatus _activeTabFrom(ProducerOrdersState state) =>
      switch (state) {
        ProducerOrdersLoading(:final activeTab) => activeTab,
        ProducerOrdersLoaded(:final activeTab) => activeTab,
        ProducerOrdersActionSuccess(:final activeTab) => activeTab,
        _ => ProducerOrderStatus.pending,
      };

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProducerOrdersBloc, ProducerOrdersState>(
      listener: (context, state) {
        if (state is ProducerOrdersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.darkGreen,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
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
              // Date subtitle
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  _todayLabel,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: AppColors.placeholder,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tab bar
              BlocBuilder<ProducerOrdersBloc, ProducerOrdersState>(
                builder: (context, state) {
                  final activeTab = _activeTabFrom(state);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: _tabs.map((tab) {
                        final isActive = activeTab == tab.$1;
                        return GestureDetector(
                          onTap: () =>
                              context.read<ProducerOrdersBloc>().add(
                                ProducerOrdersTabChanged(tab.$1),
                              ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                child: BlocBuilder<ProducerOrdersBloc, ProducerOrdersState>(
                  builder: (context, state) {
                    if (state is ProducerOrdersLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkGreen,
                        ),
                      );
                    }
                    if (state is ProducerOrdersFailure) {
                      return Center(child: Text(state.message));
                    }

                    final List<ProducerOrder> allOrders;
                    final ProducerOrderStatus activeTab;
                    if (state is ProducerOrdersLoaded) {
                      allOrders = state.orders;
                      activeTab = state.activeTab;
                    } else if (state is ProducerOrdersActionSuccess) {
                      allOrders = state.orders;
                      activeTab = state.activeTab;
                    } else {
                      return const SizedBox.shrink();
                    }

                    final orders = allOrders
                        .where((o) => o.status == activeTab)
                        .toList();

                    if (orders.isEmpty) {
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
                              'Nenhum pedido ${activeTab.label.toLowerCase()}',
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
                    final newCount = orders.where((o) => o.isNew).length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activeTab == ProducerOrderStatus.inDelivery)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: GestureDetector(
                              onTap: () =>
                                  context.push('/producer/home/route'),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.darkGreen,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.route_outlined,
                                      color: AppColors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Calcular Rota',
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (newCount > 0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: Text(
                              '$newCount ${newCount == 1 ? 'pedido novo' : 'pedidos novos'}',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return ProducerOrderCard(
                                order: order,
                                onDetailTap: () async {
                                  final result =
                                      await context.push<String?>(
                                        '/producer/home/orders/${order.id}',
                                        extra: order,
                                      );
                                  if (!context.mounted) return;
                                  if (result == 'in_delivery') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Entrega iniciada com sucesso.',
                                        ),
                                        backgroundColor: AppColors.darkGreen,
                                      ),
                                    );
                                    context.read<ProducerOrdersBloc>().add(
                                      const ProducerOrdersStarted(
                                        ProducerOrderStatus.inDelivery,
                                      ),
                                    );
                                  } else if (result == 'cancelled') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pedido recusado com sucesso.',
                                        ),
                                        backgroundColor: AppColors.darkGreen,
                                      ),
                                    );
                                    context.read<ProducerOrdersBloc>().add(
                                      ProducerOrderLocallyRefused(order.id),
                                    );
                                  } else if (result == 'delivered') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Entrega confirmada com sucesso.',
                                        ),
                                        backgroundColor: AppColors.darkGreen,
                                      ),
                                    );
                                    context.read<ProducerOrdersBloc>().add(
                                      ProducerOrderLocallyDelivered(order.id),
                                    );
                                  }
                                },
                                onCancelTap:
                                    order.status == ProducerOrderStatus.pending
                                    ? () => _confirmCancel(context, order.id)
                                    : null,
                                onActionTap:
                                    order.status == ProducerOrderStatus.pending
                                    ? () =>
                                          context
                                              .read<ProducerOrdersBloc>()
                                              .add(
                                                ProducerOrderAccepted(order.id),
                                              )
                                    : null,
                                onDeliveryConfirmTap: order.status ==
                                        ProducerOrderStatus.inDelivery
                                    ? () => _confirmDelivery(
                                        context,
                                        order.id,
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recusar pedido'),
        content: const Text('Tem certeza que deseja recusar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Recusar pedido'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context.read<ProducerOrdersBloc>().add(ProducerOrderCancelled(orderId));
    }
  }

  Future<void> _confirmDelivery(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: const Text(
          'Tem certeza que deseja confirmar a entrega deste pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar entrega'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      context
          .read<ProducerOrdersBloc>()
          .add(ProducerOrderDeliveryConfirmed(orderId));
    }
  }
}
