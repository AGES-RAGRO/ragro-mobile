import 'package:equatable/equatable.dart';

abstract class StockEntryEvent extends Equatable {
  const StockEntryEvent();
  @override
  List<Object?> get props => [];
}

class StockEntrySubmitted extends StockEntryEvent {
  const StockEntrySubmitted({
    required this.productId,
    required this.quantity,
    this.notes,
  });

  final String productId;
  final double quantity;
  final String? notes;

  @override
  List<Object?> get props => [productId, quantity, notes];
}
