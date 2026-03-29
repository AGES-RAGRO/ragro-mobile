import 'package:equatable/equatable.dart';

sealed class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class InventoryStarted extends InventoryEvent {
  const InventoryStarted();
}

class InventoryFilterChanged extends InventoryEvent {
  const InventoryFilterChanged(this.filter);
  final String filter; // 'all', 'active', 'unavailable'
  @override
  List<Object?> get props => [filter];
}

class InventoryProductDeleted extends InventoryEvent {
  const InventoryProductDeleted(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

class InventoryRefreshed extends InventoryEvent {
  const InventoryRefreshed();
}
