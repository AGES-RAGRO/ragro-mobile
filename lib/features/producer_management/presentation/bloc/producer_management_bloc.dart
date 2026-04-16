import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_management/domain/usecases/get_producer_dashboard.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';

@injectable
class ProducerManagementBloc
    extends Bloc<ProducerManagementEvent, ProducerManagementState> {
  ProducerManagementBloc(this._getDashboard)
    : super(const ProducerManagementInitial()) {
    on<ProducerManagementStarted>(_onStarted);
    on<ProducerManagementRefreshed>(_onRefreshed);
  }

  final GetProducerDashboard _getDashboard;

  Future<void> _onStarted(
    ProducerManagementStarted event,
    Emitter<ProducerManagementState> emit,
  ) async {
    emit(const ProducerManagementLoading());
    try {
      final dashboard = await _getDashboard();
      emit(ProducerManagementLoaded(dashboard));
    } on Exception catch (e) {
      emit(ProducerManagementFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    ProducerManagementRefreshed event,
    Emitter<ProducerManagementState> emit,
  ) async {
    emit(const ProducerManagementLoading());
    try {
      final dashboard = await _getDashboard();
      emit(ProducerManagementLoaded(dashboard));
    } on Exception catch (e) {
      emit(ProducerManagementFailure(e.toString()));
    }
  }
}
