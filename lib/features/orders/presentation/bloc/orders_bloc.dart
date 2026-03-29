import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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
  }

  final GetOrders _getOrders;
  OrderStatus _activeTab = OrderStatus.pending;

  Future<void> _onStarted(OrdersStarted event, Emitter<OrdersState> emit) async {
    _activeTab = event.status;
    emit(OrdersLoading(_activeTab));
    try {
      final orders = await _getOrders(status: _activeTab);
      emit(OrdersLoaded(orders: orders, activeTab: _activeTab));
    } catch (e) {
      emit(OrdersFailure(e.toString()));
    }
  }

  Future<void> _onTabChanged(OrdersTabChanged event, Emitter<OrdersState> emit) async {
    _activeTab = event.status;
    emit(OrdersLoading(_activeTab));
    try {
      final orders = await _getOrders(status: _activeTab);
      emit(OrdersLoaded(orders: orders, activeTab: _activeTab));
    } catch (e) {
      emit(OrdersFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(OrdersRefreshed event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading(_activeTab));
    try {
      final orders = await _getOrders(status: _activeTab);
      emit(OrdersLoaded(orders: orders, activeTab: _activeTab));
    } catch (e) {
      emit(OrdersFailure(e.toString()));
    }
  }
}
