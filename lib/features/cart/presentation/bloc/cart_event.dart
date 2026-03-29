import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartItemAdded extends CartEvent {
  const CartItemAdded(this.item);
  final CartItem item;
  @override
  List<Object?> get props => [item];
}

class CartItemQuantityUpdated extends CartEvent {
  const CartItemQuantityUpdated(this.productId, this.quantity);
  final String productId;
  final int quantity;
  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

class CartCleared extends CartEvent {
  const CartCleared();
}
