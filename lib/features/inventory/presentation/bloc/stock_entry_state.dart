import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';

abstract class StockEntryState extends Equatable {
  const StockEntryState();
  @override
  List<Object?> get props => [];
}

class StockEntryInitial extends StockEntryState {
  const StockEntryInitial();
}

class StockEntryLoading extends StockEntryState {
  const StockEntryLoading();
}

class StockEntrySuccess extends StockEntryState {
  const StockEntrySuccess(this.movement);

  final StockMovement movement;

  @override
  List<Object?> get props => [movement];
}

class StockEntryFailure extends StockEntryState {
  const StockEntryFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
