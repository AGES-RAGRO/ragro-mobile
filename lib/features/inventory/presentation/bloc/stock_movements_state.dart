import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';

abstract class StockMovementsState extends Equatable {
  const StockMovementsState();
  @override
  List<Object?> get props => [];
}

class StockMovementsInitial extends StockMovementsState {
  const StockMovementsInitial();
}

class StockMovementsLoading extends StockMovementsState {
  const StockMovementsLoading();
}

class StockMovementsLoaded extends StockMovementsState {
  const StockMovementsLoaded(this.movements);

  final List<StockMovement> movements;

  @override
  List<Object?> get props => [movements];
}

class StockMovementsFailure extends StockMovementsState {
  const StockMovementsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
