import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/cancel_customer_order.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/confirm_customer_delivery.dart';
import 'package:ragro_mobile/features/orders/domain/usecases/get_customer_order_by_id.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_state.dart';

@injectable
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc(
    this._getCustomerOrderById,
    this._cancelOrder,
    this._confirmDelivery,
  ) : super(const OrderDetailInitial()) {
    on<OrderDetailStarted>(_onStarted);
    on<OrderDetailCancelled>(_onCancelled);
    on<OrderDetailDeliveryConfirmed>(_onDeliveryConfirmed);
  }

  final GetCustomerOrderById _getCustomerOrderById;
  final CancelCustomerOrder _cancelOrder;
  final ConfirmCustomerDelivery _confirmDelivery;

  Future<void> _onStarted(
    OrderDetailStarted event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(const OrderDetailLoading());
    try {
      final order = await _getCustomerOrderById(event.orderId);
      emit(OrderDetailLoaded(order));
    } on Exception catch (e) {
      emit(OrderDetailFailure(e.toString()));
    }
  }

  Future<void> _onCancelled(
    OrderDetailCancelled event,
    Emitter<OrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! OrderDetailLoaded) return;
    emit(OrderDetailUpdating(current.order));
    try {
      await _cancelOrder(event.orderId, reason: event.reason, details: event.details);
      final cancelled = current.order.copyWith(
        status: 'CANCELLED',
        actions: const OrderDetailActions(
          canConfirmDelivery: false,
          canCancel: false,
          canContactProducer: false,
        ),
      );
      emit(
        OrderDetailActionSuccess(
          order: cancelled,
          message: 'Pedido cancelado com sucesso.',
        ),
      );
      emit(OrderDetailLoaded(cancelled));
    } on Exception catch (e) {
      emit(
        OrderDetailActionFailure(
          order: current.order,
          message: e.toString(),
        ),
      );
      emit(OrderDetailLoaded(current.order));
    }
  }

  Future<void> _onDeliveryConfirmed(
    OrderDetailDeliveryConfirmed event,
    Emitter<OrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! OrderDetailLoaded) return;
    emit(OrderDetailUpdating(current.order));
    try {
      final order = await _confirmDelivery(event.orderId);
      emit(
        OrderDetailActionSuccess(
          order: order,
          message: 'Entrega confirmada com sucesso.',
        ),
      );
      emit(OrderDetailLoaded(order));
    } on Exception catch (e) {
      emit(OrderDetailFailure(e.toString()));
    }
  }
}
