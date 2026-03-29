import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/inventory/domain/entities/inventory_product.dart';

sealed class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventoryLoaded extends InventoryState {
  const InventoryLoaded({
    required this.products,
    required this.activeFilter,
    required this.totalItems,
    required this.totalValue,
  });

  final List<InventoryProduct> products;
  final String activeFilter;
  final int totalItems;
  final double totalValue;

  @override
  List<Object?> get props => [products, activeFilter, totalItems, totalValue];
}

class InventoryFailure extends InventoryState {
  const InventoryFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
