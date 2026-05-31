import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
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
    final initial = event.initialOrder;
    if (initial != null) {
      emit(ProducerOrderDetailLoaded(initial));
      try {
        await getIt<ProducerOrdersRepository>().markAsSeen(event.orderId);
        emit(ProducerOrderDetailLoaded(initial.copyWith(isNew: false)));
      } catch (_) {}
      // Cancelled orders need a full fetch to load cancellationReason from API.
      if (initial.status != ProducerOrderStatus.cancelled) return;
    } else {
      emit(const ProducerOrderDetailLoading());
    }
    try {
      final order = await _getDetail(event.orderId);
      // Mark as seen after loading details and update view
      try {
        await getIt<ProducerOrdersRepository>().markAsSeen(event.orderId);
        final updated = order.copyWith(isNew: false);
        emit(ProducerOrderDetailLoaded(updated));
      } catch (_) {
        emit(ProducerOrderDetailLoaded(order));
      }
    } on Exception catch (e) {
      if (initial != null) return; // keep showing initial order on refresh failure
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
}