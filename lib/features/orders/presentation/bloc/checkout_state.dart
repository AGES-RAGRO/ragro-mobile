import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutReady extends CheckoutState {
  const CheckoutReady(this.cart);
  final Cart cart;
  @override
  List<Object?> get props => [cart];
}

/// Cart loaded and order confirmation API call is in progress.
class CheckoutConfirming extends CheckoutState {
  const CheckoutConfirming(this.cart);
  final Cart cart;
  @override
  List<Object?> get props => [cart];
}

class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.order);
  final Order order;
  @override
  List<Object?> get props => [order];
}

class CheckoutFailure extends CheckoutState {
  const CheckoutFailure({required this.message, this.cart});
  final Cart? cart;
  final String message;
  @override
  List<Object?> get props => [cart, message];
}
