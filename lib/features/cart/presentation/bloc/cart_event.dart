import 'package:equatable/equatable.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartItemAdded extends CartEvent {
  const CartItemAdded({required this.productId, required this.quantity});
  final String productId;
  final double quantity;
  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemQuantityUpdated extends CartEvent {
  const CartItemQuantityUpdated({
    required this.cartItemId,
    required this.quantity,
  });
  final String cartItemId;
  final double quantity;
  @override
  List<Object?> get props => [cartItemId, quantity];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.cartItemId);
  final String cartItemId;
  @override
  List<Object?> get props => [cartItemId];
}

class CartCleared extends CartEvent {
  const CartCleared();
}
