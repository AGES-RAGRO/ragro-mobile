import 'package:equatable/equatable.dart';

abstract class StockMovementsEvent extends Equatable {
  const StockMovementsEvent();
  @override
  List<Object?> get props => [];
}

class StockMovementsStarted extends StockMovementsEvent {
  const StockMovementsStarted(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
