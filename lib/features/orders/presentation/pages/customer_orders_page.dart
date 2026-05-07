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

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<OrdersBloc>()..add(const OrdersStarted(OrderStatus.pending)),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    (OrderStatus.pending, 'Pendentes'),
    (OrderStatus.accepted, 'Aceitos'),
    (OrderStatus.inDelivery, 'A caminho'),
    (OrderStatus.delivered, 'Entregues'),
    (OrderStatus.cancelled, 'Cancelados'),
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 16),
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
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),
              indicatorColor: AppColors.darkGreen,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.darkGreen,
              unselectedLabelColor: AppColors.placeholder,
              labelStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: _tabs.map((tab) => Tab(text: tab.$2)).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs
                    .map((tab) => _OrderTabContent(status: tab.$1))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTabContent extends StatelessWidget {
  const _OrderTabContent({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoading || state is OrdersInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.darkGreen),
          );
        }

        if (state is OrdersFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: AppColors.placeholder,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<OrdersBloc>().add(
                    const OrdersRefreshed(),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (state is! OrdersLoaded) return const SizedBox.shrink();

        final orders = state.orders
            .where((order) => order.status == status)
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
                  'Nenhum pedido ${status.label.toLowerCase()}',
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 13),
          itemBuilder: (context, index) => OrderCard(order: orders[index]),
        );
      },
    );
  }
}
