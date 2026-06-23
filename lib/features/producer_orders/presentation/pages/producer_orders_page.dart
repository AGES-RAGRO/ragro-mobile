// Producer Orders screen (US-20). Route: GET /orders/producer.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/navigation/orders_route_observer.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/notifications/data/services/notification_service.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_bloc.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_state.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/widgets/producer_order_card.dart';
import 'package:ragro_mobile/shared/widgets/notification_bell.dart';

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

class _ProducerOrdersView extends StatefulWidget {
  const _ProducerOrdersView();

  @override
  State<_ProducerOrdersView> createState() => _ProducerOrdersViewState();
}

class _ProducerOrdersViewState extends State<_ProducerOrdersView>
    with WidgetsBindingObserver
    implements RouteAware {
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  StreamSubscription<void>? _foregroundSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Live auto-refresh: any foreground push (e.g. a new order) re-fetches.
    _foregroundSub = getIt<NotificationService>().onForegroundMessage.listen((
      _,
    ) {
      if (mounted) {
        context.read<ProducerOrdersBloc>().add(const ProducerOrdersRefreshed());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      producerRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reopened/foregrounded: pick up orders that arrived while away.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ProducerOrdersBloc>().add(const ProducerOrdersRefreshed());
    }
  }

  @override
  void dispose() {
    producerRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _foregroundSub?.cancel();
    super.dispose();
  }

  // Returning to this page (e.g. from the route screen) refreshes the list.
  @override
  void didPopNext() {
    if (mounted) {
      context.read<ProducerOrdersBloc>().add(const ProducerOrdersRefreshed());
    }
  }

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  void _enterSelectionMode() => setState(() {
    _selectionMode = true;
    _selectedIds.clear();
  });

  void _exitSelectionMode() => setState(() {
    _selectionMode = false;
    _selectedIds.clear();
  });

  void _toggleSelection(String id) => setState(() {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
  });

  void _saveSelection(BuildContext context) {
    context.read<ProducerOrdersBloc>().add(
      ProducerOrdersBulkMarkedInDelivery({..._selectedIds}),
    );
    _exitSelectionMode();
  }

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
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 6, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pedidos',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 34,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    NotificationBell(),
                  ],
                ),
              ),
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
                          onTap: () {
                            _exitSelectionMode();
                            context.read<ProducerOrdersBloc>().add(
                              ProducerOrdersTabChanged(tab.$1),
                            );
                          },
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
                      // Scrollable so pull-to-refresh works on an empty tab too
                      // (e.g. "Pendentes" empty → new order arrives → pull).
                      return RefreshIndicator(
                        color: AppColors.darkGreen,
                        onRefresh: () async => context
                            .read<ProducerOrdersBloc>()
                            .add(const ProducerOrdersRefreshed()),
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
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
                                          'Nenhum pedido '
                                          '${activeTab.label.toLowerCase()}',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 16,
                                            color: AppColors.placeholder,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      );
                    }
                    final newCount = orders.where((o) => o.isNew).length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          child: RefreshIndicator(
                            color: AppColors.darkGreen,
                            onRefresh: () async => context
                                .read<ProducerOrdersBloc>()
                                .add(const ProducerOrdersRefreshed()),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                              16,
                              12,
                              16,
                              (activeTab == ProducerOrderStatus.accepted ||
                                      activeTab ==
                                          ProducerOrderStatus.inDelivery)
                                  ? 80
                                  : 16,
                            ),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final inAcceptedSelection =
                                  activeTab == ProducerOrderStatus.accepted &&
                                  _selectionMode;
                              return ProducerOrderCard(
                                order: order,
                                onDetailTap: () async {
                                  if (inAcceptedSelection) return;
                                  final result = await context.push<String?>(
                                    '/producer/home/orders/${order.id}',
                                    extra: order,
                                  );
                                  if (!context.mounted) return;
                                  if (result == 'cancelled') {
                                    context.read<ProducerOrdersBloc>().add(
                                      ProducerOrderLocallyRefused(order.id),
                                    );
                                    context.read<ProducerOrdersBloc>().add(
                                      const ProducerOrdersTabChanged(
                                        ProducerOrderStatus.cancelled,
                                      ),
                                    );
                                  } else if (result == 'seen') {
                                    context.read<ProducerOrdersBloc>().add(
                                      ProducerOrderLocallySeen(order.id),
                                    );
                                  } else {
                                    final targetTab = switch (result) {
                                      'in_delivery' =>
                                        ProducerOrderStatus.inDelivery,
                                      'delivered' =>
                                        ProducerOrderStatus.delivered,
                                      _ => activeTab,
                                    };
                                    context.read<ProducerOrdersBloc>().add(
                                      ProducerOrdersStarted(targetTab),
                                    );
                                  }
                                },
                                onActionTap:
                                    order.status == ProducerOrderStatus.pending
                                    ? () => context
                                          .read<ProducerOrdersBloc>()
                                          .add(ProducerOrderAccepted(order.id))
                                    : null,
                                isSelected: inAcceptedSelection
                                    ? _selectedIds.contains(order.id)
                                    : null,
                                onSelect: inAcceptedSelection
                                    ? () => _toggleSelection(order.id)
                                    : null,
                              );
                            },
                          ),
                          ),
                        ),
                        if (activeTab == ProducerOrderStatus.inDelivery)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: GestureDetector(
                              onTap: () async {
                                final delivered = await context
                                    .push<List<String>?>(
                                      '/producer/home/route',
                                    );
                                if (!context.mounted) return;
                                final bloc = context
                                    .read<ProducerOrdersBloc>();
                                // Optimistic update: confirmed deliveries leave
                                // "A caminho" immediately.
                                for (final id
                                    in delivered ?? const <String>[]) {
                                  bloc.add(ProducerOrderLocallyDelivered(id));
                                }
                                // Resync with the backend.
                                bloc.add(const ProducerOrdersRefreshed());
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.darkGreen,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.route_outlined,
                                      color: AppColors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Calcular Melhor Rota',
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (activeTab == ProducerOrderStatus.accepted)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: _selectionMode
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _exitSelectionMode,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppColors.placeholder,
                                            side: const BorderSide(
                                              color: AppColors.placeholder,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _selectedIds.isEmpty
                                              ? null
                                              : () => _saveSelection(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.darkGreen,
                                            disabledBackgroundColor: AppColors
                                                .darkGreen
                                                .withValues(alpha: 0.4),
                                            foregroundColor: AppColors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text(
                                            _selectedIds.isEmpty
                                                ? 'Salvar'
                                                : 'Salvar (${_selectedIds.length})',
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : OutlinedButton(
                                    onPressed: _enterSelectionMode,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.darkGreen,
                                      side: const BorderSide(
                                        color: AppColors.darkGreen,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        48,
                                      ),
                                    ),
                                    child: const Text(
                                      'Selecionar entregas de hoje',
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
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
}
