import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/confirm_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/get_producer_order_detail.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/refuse_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/update_producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_event.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_state.dart';

@injectable
class ProducerOrderDetailBloc
    extends Bloc<ProducerOrderDetailEvent, ProducerOrderDetailState> {
  ProducerOrderDetailBloc(
    this._getDetail,
    this._confirmOrder,
    this._refuseOrder,
    this._updateStatus,
  ) : super(const ProducerOrderDetailInitial()) {
    on<ProducerOrderDetailStarted>(_onStarted);
    on<ProducerOrderDetailConfirmed>(_onConfirmed);
    on<ProducerOrderDetailRefused>(_onRefused);
    on<ProducerOrderDetailStatusUpdated>(_onStatusUpdated);
  }

  final GetProducerOrderDetail _getDetail;
  final ConfirmProducerOrder _confirmOrder;
  final RefuseProducerOrder _refuseOrder;
  final UpdateProducerOrderStatus _updateStatus;

  Future<void> _onStarted(
    ProducerOrderDetailStarted event,
    Emitter<ProducerOrderDetailState> emit,
  ) async {
    if (event.initialOrder != null) {
      emit(ProducerOrderDetailLoaded(event.initialOrder!));
      return;
    }
    emit(const ProducerOrderDetailLoading());
    try {
      final order = await _getDetail(event.orderId);
      emit(ProducerOrderDetailLoaded(order));
    } on Exception catch (e) {
      emit(ProducerOrderDetailFailure(e.toString()));
    }
  }

  Future<void> _onConfirmed(
    ProducerOrderDetailConfirmed event,
    Emitter<ProducerOrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! ProducerOrderDetailLoaded) return;
    emit(ProducerOrderDetailConfirming(current.order));
    try {
      await _confirmOrder(event.orderId);
      final updated = current.order.copyWith(
        status: ProducerOrderStatus.accepted,
      );
      emit(ProducerOrderDetailSuccess(order: updated, action: 'confirmed'));
      emit(ProducerOrderDetailLoaded(updated));
    } on Exception catch (e) {
      emit(ProducerOrderDetailFailure(e.toString()));
    }
  }

  Future<void> _onRefused(
    ProducerOrderDetailRefused event,
    Emitter<ProducerOrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! ProducerOrderDetailLoaded) return;
    emit(ProducerOrderDetailRefusing(current.order));
    try {
      await _refuseOrder(event.orderId, reason: event.reason, details: event.details);
      final updated = current.order.copyWith(
        status: ProducerOrderStatus.cancelled,
      );
      emit(ProducerOrderDetailSuccess(order: updated, action: 'refused'));
      emit(ProducerOrderDetailLoaded(updated));
    } on Exception catch (e) {
      emit(ProducerOrderDetailFailure(e.toString()));
    }
  }

  Future<void> _onStatusUpdated(
    ProducerOrderDetailStatusUpdated event,
    Emitter<ProducerOrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! ProducerOrderDetailLoaded) return;
    emit(ProducerOrderDetailUpdatingStatus(current.order));
    try {
      await _updateStatus(event.orderId, event.status);
      final updated = current.order.copyWith(status: event.status);
      emit(
        ProducerOrderDetailSuccess(order: updated, action: 'status_updated'),
      );
      emit(ProducerOrderDetailLoaded(updated));
    } on Exception catch (e) {
      emit(ProducerOrderDetailFailure(e.toString()));
    }
  }
}
