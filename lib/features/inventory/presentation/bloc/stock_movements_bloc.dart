import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/get_product_movements.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_movements_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_movements_state.dart';

@injectable
class StockMovementsBloc
    extends Bloc<StockMovementsEvent, StockMovementsState> {
  StockMovementsBloc(this._getMovements) : super(const StockMovementsInitial()) {
    on<StockMovementsStarted>(_onStarted);
  }

  final GetProductMovements _getMovements;

  Future<void> _onStarted(
    StockMovementsStarted event,
    Emitter<StockMovementsState> emit,
  ) async {
    emit(const StockMovementsLoading());
    try {
      final movements = await _getMovements(event.productId);
      emit(StockMovementsLoaded(movements));
    } on Exception catch (e) {
      emit(StockMovementsFailure(e.toString()));
    }
  }
}
