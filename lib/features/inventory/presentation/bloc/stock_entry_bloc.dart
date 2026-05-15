import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/inventory/domain/usecases/register_stock_entry.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_entry_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/stock_entry_state.dart';

@injectable
class StockEntryBloc extends Bloc<StockEntryEvent, StockEntryState> {
  StockEntryBloc(this._registerEntry) : super(const StockEntryInitial()) {
    on<StockEntrySubmitted>(_onSubmitted);
  }

  final RegisterStockEntry _registerEntry;

  Future<void> _onSubmitted(
    StockEntrySubmitted event,
    Emitter<StockEntryState> emit,
  ) async {
    emit(const StockEntryLoading());
    try {
      final movement = await _registerEntry(
        productId: event.productId,
        quantity: event.quantity,
        notes: event.notes,
      );
      emit(StockEntrySuccess(movement));
    } on Exception catch (e) {
      emit(StockEntryFailure(e.toString()));
    }
  }
}
