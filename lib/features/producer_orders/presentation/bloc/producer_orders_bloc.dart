import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/confirm_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/get_producer_orders.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/refuse_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/update_producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_state.dart';

@injectable
class ProducerOrdersBloc
    extends Bloc<ProducerOrdersEvent, ProducerOrdersState> {
  ProducerOrdersBloc(
    this._getProducerOrders,
    this._confirmProducerOrder,
    this._refuseProducerOrder,
    this._updateProducerOrderStatus,
  ) : super(const ProducerOrdersInitial()) {
    on<ProducerOrdersStarted>(_onStarted);
    on<ProducerOrdersTabChanged>(_onTabChanged);
    on<ProducerOrdersRefreshed>(_onRefreshed);
    on<ProducerOrderAccepted>(_onAccepted);
    on<ProducerOrderCancelled>(_onCancelled);
    on<ProducerOrderLocallyRefused>(_onLocallyRefused);
    on<ProducerOrderMarkedInDelivery>(_onMarkedInDelivery);
    on<ProducerOrderDeliveryConfirmed>(_onDeliveryConfirmed);
    on<ProducerOrderLocallyDelivered>(_onLocallyDelivered);
  }

  final GetProducerOrders _getProducerOrders;
  final ConfirmProducerOrder _confirmProducerOrder;
  final RefuseProducerOrder _refuseProducerOrder;
  final UpdateProducerOrderStatus _updateProducerOrderStatus;
  ProducerOrderStatus _activeTab = ProducerOrderStatus.pending;

  Future<void> _onStarted(
    ProducerOrdersStarted event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    _activeTab = event.tab;
    await _reload(emit);
  }

  Future<void> _onTabChanged(
    ProducerOrdersTabChanged event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    _activeTab = event.tab;
    final current = state;
    if (current is ProducerOrdersLoaded) {
      emit(ProducerOrdersLoaded(orders: current.orders, activeTab: _activeTab));
      return;
    }
    await _reload(emit);
  }

  Future<void> _onRefreshed(
    ProducerOrdersRefreshed event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    await _reload(emit);
  }

  Future<void> _onAccepted(
    ProducerOrderAccepted event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    emit(ProducerOrdersLoading(_activeTab));
    try {
      await _confirmProducerOrder(event.orderId);
      final orders = await _getProducerOrders();
      emit(ProducerOrdersActionSuccess(
        message: 'Pedido aceito com sucesso.',
        orders: orders,
        activeTab: _activeTab,
      ));
      emit(ProducerOrdersLoaded(orders: orders, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersFailure(e.toString()));
    }
  }

  Future<void> _onCancelled(
    ProducerOrderCancelled event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    final currentOrders = switch (state) {
      ProducerOrdersLoaded(:final orders) => orders,
      ProducerOrdersActionSuccess(:final orders) => orders,
      _ => null,
    };
    if (currentOrders == null) return;

    emit(ProducerOrdersLoading(_activeTab));
    try {
      await _refuseProducerOrder(event.orderId);
      final updated = currentOrders
          .map(
            (o) => o.id == event.orderId
                ? o.copyWith(status: ProducerOrderStatus.cancelled)
                : o,
          )
          .toList();
      emit(ProducerOrdersActionSuccess(
        message: 'Pedido recusado com sucesso.',
        orders: updated,
        activeTab: _activeTab,
      ));
      emit(ProducerOrdersLoaded(orders: updated, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersLoaded(orders: currentOrders, activeTab: _activeTab));
      emit(ProducerOrdersFailure(e.toString()));
    }
  }

  void _onLocallyRefused(
    ProducerOrderLocallyRefused event,
    Emitter<ProducerOrdersState> emit,
  ) {
    final currentOrders = switch (state) {
      ProducerOrdersLoaded(:final orders) => orders,
      ProducerOrdersActionSuccess(:final orders) => orders,
      _ => null,
    };
    if (currentOrders == null) return;

    final updated = currentOrders
        .map(
          (o) => o.id == event.orderId
              ? o.copyWith(status: ProducerOrderStatus.cancelled)
              : o,
        )
        .toList();
    emit(ProducerOrdersLoaded(orders: updated, activeTab: _activeTab));
  }

  Future<void> _onMarkedInDelivery(
    ProducerOrderMarkedInDelivery event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    emit(ProducerOrdersLoading(_activeTab));
    try {
      await _updateProducerOrderStatus(
        event.orderId,
        ProducerOrderStatus.inDelivery,
      );
      final orders = await _getProducerOrders();
      emit(ProducerOrdersActionSuccess(
        message: 'Entrega iniciada com sucesso.',
        orders: orders,
        activeTab: _activeTab,
      ));
      emit(ProducerOrdersLoaded(orders: orders, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersFailure(e.toString()));
    }
  }

  Future<void> _onDeliveryConfirmed(
    ProducerOrderDeliveryConfirmed event,
    Emitter<ProducerOrdersState> emit,
  ) async {
    final currentOrders = switch (state) {
      ProducerOrdersLoaded(:final orders) => orders,
      ProducerOrdersActionSuccess(:final orders) => orders,
      _ => null,
    };
    if (currentOrders == null) return;

    emit(ProducerOrdersLoading(_activeTab));
    try {
      await _updateProducerOrderStatus(
        event.orderId,
        ProducerOrderStatus.delivered,
      );
      final updated = currentOrders
          .map(
            (o) => o.id == event.orderId
                ? o.copyWith(status: ProducerOrderStatus.delivered)
                : o,
          )
          .toList();
      emit(ProducerOrdersActionSuccess(
        message: 'Entrega confirmada com sucesso.',
        orders: updated,
        activeTab: _activeTab,
      ));
      emit(ProducerOrdersLoaded(orders: updated, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersLoaded(orders: currentOrders, activeTab: _activeTab));
      emit(ProducerOrdersFailure(e.toString()));
    }
  }

  void _onLocallyDelivered(
    ProducerOrderLocallyDelivered event,
    Emitter<ProducerOrdersState> emit,
  ) {
    final currentOrders = switch (state) {
      ProducerOrdersLoaded(:final orders) => orders,
      ProducerOrdersActionSuccess(:final orders) => orders,
      _ => null,
    };
    if (currentOrders == null) return;

    final updated = currentOrders
        .map(
          (o) => o.id == event.orderId
              ? o.copyWith(status: ProducerOrderStatus.delivered)
              : o,
        )
        .toList();
    emit(ProducerOrdersLoaded(orders: updated, activeTab: _activeTab));
  }

  Future<void> _reload(Emitter<ProducerOrdersState> emit) async {
    emit(ProducerOrdersLoading(_activeTab));
    try {
      final orders = await _getProducerOrders();
      emit(ProducerOrdersLoaded(orders: orders, activeTab: _activeTab));
    } on Exception catch (e) {
      emit(ProducerOrdersFailure(e.toString()));
    }
  }
}
