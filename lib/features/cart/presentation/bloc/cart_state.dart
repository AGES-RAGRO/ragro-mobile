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

class CartLoaded extends CartState {
  const CartLoaded(this.cart);
  final Cart cart;
  @override
  List<Object?> get props => [cart];
}
