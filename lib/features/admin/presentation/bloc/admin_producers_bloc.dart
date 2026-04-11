import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/activate_admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/deactivate_admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/get_admin_producers.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_state.dart';

@injectable
class AdminProducersBloc
    extends Bloc<AdminProducersEvent, AdminProducersState> {
  AdminProducersBloc(this._getProducers, this._deactivate, this._activate)
    : super(const AdminProducersInitial()) {
    on<AdminProducersStarted>(_onStarted);
    on<AdminProducerDeactivated>(_onDeactivated);
    on<AdminProducersRefreshed>(_onRefreshed);
    on<AdminProducerActivated>(_onActivated);
  }

  final GetAdminProducers _getProducers;
  final DeactivateAdminProducer _deactivate;
  final ActivateAdminProducer _activate;

  Future<void> _onStarted(
    AdminProducersStarted event,
    Emitter<AdminProducersState> emit,
  ) async {
    emit(const AdminProducersLoading());
    try {
      final producers = await _getProducers();
      emit(AdminProducersLoaded(producers));
    } on ApiException catch (e) {
      emit(AdminProducersFailure(e.message));
    }
  }

  Future<void> _onDeactivated(
    AdminProducerDeactivated event,
    Emitter<AdminProducersState> emit,
  ) => _mutate(emit, action: () => _deactivate(event.producerId));

  Future<void> _onActivated(
    AdminProducerActivated event,
    Emitter<AdminProducersState> emit,
  ) => _mutate(emit, action: () => _activate(event.producerId));

  Future<void> _mutate(
    Emitter<AdminProducersState> emit, {
    required Future<void> Function() action,
  }) async {
    final previous = _currentProducers();
    if (previous == null) return;

    emit(AdminProducersMutating(previous));
    try {
      await action();
      final refreshed = await _getProducers();
      emit(AdminProducersLoaded(refreshed));
    } on ApiException catch (e) {
      emit(
        AdminProducerMutationFailure(
          previousProducers: previous,
          message: e.message,
        ),
      );
      emit(AdminProducersLoaded(previous));
    }
  }

  Future<void> _onRefreshed(
    AdminProducersRefreshed event,
    Emitter<AdminProducersState> emit,
  ) async {
    emit(const AdminProducersLoading());
    try {
      final producers = await _getProducers();
      emit(AdminProducersLoaded(producers));
    } on ApiException catch (e) {
      emit(AdminProducersFailure(e.message));
    }
  }

  List<AdminProducer>? _currentProducers() {
    final current = state;
    if (current is AdminProducersLoaded) return current.producers;
    if (current is AdminProducersMutating) return current.previousProducers;
    if (current is AdminProducerMutationFailure) {
      return current.previousProducers;
    }
    return null;
  }
}
