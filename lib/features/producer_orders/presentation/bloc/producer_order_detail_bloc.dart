import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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
    emit(const ProducerOrderDetailLoading());
    try {
      final order = await _getDetail(event.orderId);
      emit(ProducerOrderDetailLoaded(order));
    } catch (e) {
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
      final updated = await _getDetail(event.orderId);
      emit(ProducerOrderDetailSuccess(order: updated, action: 'confirmed'));
      emit(ProducerOrderDetailLoaded(updated));
    } catch (e) {
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
      await _refuseOrder(event.orderId);
      final updated = await _getDetail(event.orderId);
      emit(ProducerOrderDetailSuccess(order: updated, action: 'refused'));
      emit(ProducerOrderDetailLoaded(updated));
    } catch (e) {
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
      final updated = await _getDetail(event.orderId);
      emit(ProducerOrderDetailSuccess(order: updated, action: 'status_updated'));
      emit(ProducerOrderDetailLoaded(updated));
    } catch (e) {
      emit(ProducerOrderDetailFailure(e.toString()));
    }
  }
}
