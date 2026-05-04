import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/register_stock_exit.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_exit_state.dart';

@injectable
class StockExitBloc extends Bloc<StockExitEvent, StockExitState> {
  StockExitBloc(this._registerExit) : super(const StockExitInitial()) {
    on<StockExitSubmitted>(_onSubmitted);
  }

  final RegisterStockExit _registerExit;

  Future<void> _onSubmitted(
    StockExitSubmitted event,
    Emitter<StockExitState> emit,
  ) async {
    emit(const StockExitLoading());
    try {
      final movement = await _registerExit(
        productId: event.productId,
        quantity: event.quantity,
        reason: event.reason,
        notes: event.notes,
      );
      emit(StockExitSuccess(movement));
    } on Exception catch (e) {
      emit(StockExitFailure(e.toString()));
    }
  }
}
