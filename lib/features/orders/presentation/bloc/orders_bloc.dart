import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/get_orders.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_state.dart';

@injectable
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc(this._getOrders) : super(const OrdersInitial()) {
    on<OrdersStarted>(_onStarted);
    on<OrdersTabChanged>(_onTabChanged);
    on<OrdersRefreshed>(_onRefreshed);
    on<OrdersMarkedAsRated>(_onMarkedAsRated);
  }

  final GetOrders _getOrders;
  OrderStatus _activeTab = OrderStatus.pending;
  final Map<OrderStatus, List<Order>> _ordersCache = {};

  Future<void> _onStarted(
    OrdersStarted event,
    Emitter<OrdersState> emit,
  ) async {
    _activeTab = event.status;
    await _loadOrdersForActiveTab(emit);
  }

  Future<void> _onTabChanged(
    OrdersTabChanged event,
    Emitter<OrdersState> emit,
  ) async {
    _activeTab = event.status;
    await _loadOrdersForActiveTab(emit);
  }

  Future<void> _onRefreshed(
    OrdersRefreshed event,
    Emitter<OrdersState> emit,
  ) async {
    await _loadOrdersForActiveTab(emit);
  }

  void _onMarkedAsRated(OrdersMarkedAsRated event, Emitter<OrdersState> emit) {
    var updated = false;

    for (final entry in _ordersCache.entries) {
      final nextOrders = entry.value.map((order) {
        if (order.id != event.orderId) return order;
        updated = true;
        return order.copyWith(avaliado: true);
      }).toList();
      _ordersCache[entry.key] = nextOrders;
    }

    if (!updated) return;

    final activeOrders = _ordersCache[_activeTab] ?? const <Order>[];
    emit(OrdersLoaded(orders: activeOrders, activeTab: _activeTab));
  }

  Future<void> _loadOrdersForActiveTab(Emitter<OrdersState> emit) async {
    final previousOrders = List<Order>.from(
      _ordersCache[_activeTab] ?? const <Order>[],
    );
    emit(OrdersLoading(_activeTab, previousOrders: previousOrders));

    try {
      final orders = await _getOrders(status: _activeTab);
      _ordersCache[_activeTab] = orders;
      emit(OrdersLoaded(orders: orders, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(
        OrdersFailure(
          e.toString(),
          activeTab: _activeTab,
          previousOrders: previousOrders,
        ),
      );
    }
  }
}
