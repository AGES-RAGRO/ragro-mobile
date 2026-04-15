import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/get_producer_orders.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_state.dart';

@injectable
class ProducerOrdersBloc
    extends Bloc<ProducerOrdersEvent, ProducerOrdersState> {
  ProducerOrdersBloc(this._getProducerOrders)
    : super(const ProducerOrdersInitial()) {
    on<ProducerOrdersStarted>(_onStarted);
    on<ProducerOrdersTabChanged>(_onTabChanged);
    on<ProducerOrdersRefreshed>(_onRefreshed);
  }

  final GetProducerOrders _getProducerOrders;
  ProducerOrderStatus _activeTab = ProducerOrderStatus.pending;

  Future<void> _onStarted(
    ProducerOrdersStarted event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    _activeTab = event.tab;
    emit(ProducerOrdersLoading(_activeTab));
    try {
      final orders = await _getProducerOrders(status: _activeTab);
      emit(ProducerOrdersLoaded(orders: orders, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersFailure(e.toString()));
    }
  }

  Future<void> _onTabChanged(
    ProducerOrdersTabChanged event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    _activeTab = event.tab;
    emit(ProducerOrdersLoading(_activeTab));
    try {
      final orders = await _getProducerOrders(status: _activeTab);
      emit(ProducerOrdersLoaded(orders: orders, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    ProducerOrdersRefreshed event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    emit(ProducerOrdersLoading(_activeTab));
    try {
      final orders = await _getProducerOrders(status: _activeTab);
      emit(ProducerOrdersLoaded(orders: orders, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersFailure(e.toString()));
    }
  }
}
