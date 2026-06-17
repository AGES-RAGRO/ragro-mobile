import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/confirm_producer_delivery_with_code.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/confirm_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/get_producer_order_detail.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/refuse_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/usecases/update_producer_order_status.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';
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
    this._confirmDeliveryWithCode,
  ) : super(const ProducerOrderDetailInitial()) {
    on<ProducerOrderDetailStarted>(_onStarted);
    on<ProducerOrderDetailConfirmed>(_onConfirmed);
    on<ProducerOrderDetailRefused>(_onRefused);
    on<ProducerOrderDetailStatusUpdated>(_onStatusUpdated);
    on<ProducerOrderDetailDeliveryConfirmedWithCode>(_onDeliveryConfirmedWithCode);
  }

  final GetProducerOrderDetail _getDetail;
  final ConfirmProducerOrder _confirmOrder;
  final RefuseProducerOrder _refuseOrder;
  final UpdateProducerOrderStatus _updateStatus;
  final ConfirmProducerDeliveryWithCode _confirmDeliveryWithCode;

  Future<void> _onStarted(
    ProducerOrderDetailStarted event,
    Emitter<ProducerOrderDetailState> emit,
  ) async {
    final initial = event.initialOrder;
    if (initial != null) {
      emit(ProducerOrderDetailLoaded(initial));
      try {
        await getIt<ProducerOrdersRepository>().markAsSeen(event.orderId);
        emit(ProducerOrderDetailLoaded(initial.copyWith(isNew: false)));
      } catch (_) {}
      // The producer detail comes from the same list payload
      // (GET /orders/producer): a re-fetch brings no new fields and would wipe
      // the cancellationReason/Details that a refuse in this session already
      // set. Keep the order we received.
      return;
    }
    emit(const ProducerOrderDetailLoading());
    try {
      final order = await _getDetail(event.orderId);
      // Mark as seen after loading and refresh the view.
      try {
        await getIt<ProducerOrdersRepository>().markAsSeen(event.orderId);
        final updated = order.copyWith(isNew: false);
        emit(ProducerOrderDetailLoaded(updated));
      } catch (_) {
        emit(ProducerOrderDetailLoaded(order));
      }
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
      emit(ProducerOrderDetailActionError(current.order, e.toString()));
      emit(ProducerOrderDetailLoaded(current.order));
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
      await _refuseOrder(
        event.orderId,
        reason: event.reason,
        details: event.details,
      );
      final updated = current.order.copyWith(
        status: ProducerOrderStatus.cancelled,
        cancellationReason: event.reason,
        cancellationDetails: event.details,
      );
      emit(ProducerOrderDetailSuccess(order: updated, action: 'refused'));
      emit(ProducerOrderDetailLoaded(updated));
    } on Exception catch (e) {
      emit(ProducerOrderDetailActionError(current.order, e.toString()));
      emit(ProducerOrderDetailLoaded(current.order));
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

      try {
        await getIt<ProducerOrdersRepository>().markAsSeen(event.orderId);
        final updatedSeen = updated.copyWith(isNew: false);
        emit(ProducerOrderDetailLoaded(updatedSeen));
      } catch (_) {
        emit(ProducerOrderDetailLoaded(updated));
      }
    } on Exception catch (e) {
      emit(ProducerOrderDetailActionError(current.order, e.toString()));
      emit(ProducerOrderDetailLoaded(current.order));
    }
  }

  Future<void> _onDeliveryConfirmedWithCode(
    ProducerOrderDetailDeliveryConfirmedWithCode event,
    Emitter<ProducerOrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! ProducerOrderDetailLoaded) return;

    emit(ProducerOrderDetailUpdatingStatus(current.order));
    try {
      await _confirmDeliveryWithCode(event.orderId, event.code);
      final updated = current.order.copyWith(status: ProducerOrderStatus.delivered);
      emit(
        ProducerOrderDetailSuccess(order: updated, action: 'status_updated'),
      );

      try {
        await getIt<ProducerOrdersRepository>().markAsSeen(event.orderId);
        final updatedSeen = updated.copyWith(isNew: false);
        emit(ProducerOrderDetailLoaded(updatedSeen));
      } catch (_) {
        emit(ProducerOrderDetailLoaded(updated));
      }
    } on Exception catch (e) {
      emit(ProducerOrderDetailActionError(current.order, e.toString()));
      emit(ProducerOrderDetailLoaded(current.order));
    }
  }
}
