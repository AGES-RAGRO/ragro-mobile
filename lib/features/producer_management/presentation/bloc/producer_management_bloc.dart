import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_management/domain/usecases/get_producer_dashboard.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';

// Singleton para que o shell do produtor possa disparar refresh ao abrir a aba
// Perfil (a página fica viva no IndexedStack e não re-inicializa sozinha).
@lazySingleton
class ProducerManagementBloc
    extends Bloc<ProducerManagementEvent, ProducerManagementState> {
  ProducerManagementBloc(this._getDashboard)
    : super(ProducerManagementInitial()) {
    on<ProducerManagementStarted>(_onStarted);
    on<ProducerManagementRefreshed>(_onRefreshed);
    on<ProducerDashboardPeriodChanged>(_onPeriodChanged);
  }

  final GetProducerDashboard _getDashboard;

  Future<void> _loadDashboard(
    Emitter<ProducerManagementState> emit, {
    required int month,
    required int year,
  }) async {
    emit(ProducerManagementLoading(selectedMonth: month, selectedYear: year));
    try {
      final dashboard = await _getDashboard(month: month, year: year);
      emit(
        ProducerManagementLoaded(
          dashboard,
          selectedMonth: month,
          selectedYear: year,
        ),
      );
    } on Exception catch (e) {
      emit(
        ProducerManagementFailure(
          e.toString(),
          selectedMonth: month,
          selectedYear: year,
        ),
      );
    }
  }

  Future<void> _onStarted(
    ProducerManagementStarted event,
    Emitter<ProducerManagementState> emit,
  ) async {
    final now = DateTime.now();
    await _loadDashboard(emit, month: now.month, year: now.year);
  }

  Future<void> _onRefreshed(
    ProducerManagementRefreshed event,
    Emitter<ProducerManagementState> emit,
  ) async {
    await _loadDashboard(
      emit,
      month: state.selectedMonth,
      year: state.selectedYear,
    );
  }

  Future<void> _onPeriodChanged(
    ProducerDashboardPeriodChanged event,
    Emitter<ProducerManagementState> emit,
  ) async {
    await _loadDashboard(emit, month: event.month, year: event.year);
  }
}
