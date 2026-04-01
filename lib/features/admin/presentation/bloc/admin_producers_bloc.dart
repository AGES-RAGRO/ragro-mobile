import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/deactivate_admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/get_admin_producers.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_state.dart';

@injectable
class AdminProducersBloc
    extends Bloc<AdminProducersEvent, AdminProducersState> {
  AdminProducersBloc(this._getProducers, this._deactivate)
      : super(const AdminProducersInitial()) {
    on<AdminProducersStarted>(_onStarted);
    on<AdminProducerDeactivated>(_onDeactivated);
    on<AdminProducersRefreshed>(_onRefreshed);
  }

  final GetAdminProducers _getProducers;
  final DeactivateAdminProducer _deactivate;

  Future<void> _onStarted(
    AdminProducersStarted event,
    Emitter<AdminProducersState> emit,
  ) async {
    emit(const AdminProducersLoading());
    try {
      final producers = await _getProducers();
      emit(AdminProducersLoaded(producers));
    } catch (e) {
      emit(AdminProducersFailure(e.toString()));
    }
  }

  Future<void> _onDeactivated(
    AdminProducerDeactivated event,
    Emitter<AdminProducersState> emit,
  ) async {
    try {
      await _deactivate(event.producerId);
      final producers = await _getProducers();
      emit(AdminProducersLoaded(producers));
    } catch (e) {
      emit(AdminProducersFailure(e.toString()));
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
    } catch (e) {
      emit(AdminProducersFailure(e.toString()));
    }
  }
}
