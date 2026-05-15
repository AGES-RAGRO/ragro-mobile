import 'package:equatable/equatable.dart';

abstract class StockExitEvent extends Equatable {
  const StockExitEvent();
  @override
  List<Object?> get props => [];
}

class StockExitSubmitted extends StockExitEvent {
  const StockExitSubmitted({
    required this.productId,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  final String productId;
  final double quantity;
  final String reason;
  final String? notes;

  @override
  List<Object?> get props => [productId, quantity, reason, notes];
}
