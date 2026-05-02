import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';

sealed class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  const CartLoaded(this.cart);
  final Cart cart;
  @override
  List<Object?> get props => [cart];
}

class CartUpdating extends CartState {
  const CartUpdating(this.cart);
  final Cart cart;
  @override
  List<Object?> get props => [cart];
}

class CartUpdateFailure extends CartState {
  const CartUpdateFailure(this.cart, this.message);
  final Cart cart;
  final String message;
  @override
  List<Object?> get props => [cart, message];
}

class CartFailure extends CartState {
  const CartFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
