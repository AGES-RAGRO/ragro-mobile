import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/stock_movement.dart';

abstract class StockExitState extends Equatable {
  const StockExitState();
  @override
  List<Object?> get props => [];
}

class StockExitInitial extends StockExitState {
  const StockExitInitial();
}

class StockExitLoading extends StockExitState {
  const StockExitLoading();
}

class StockExitSuccess extends StockExitState {
  const StockExitSuccess(this.movement);

  final StockMovement movement;

  @override
  List<Object?> get props => [movement];
}

class StockExitFailure extends StockExitState {
  const StockExitFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
