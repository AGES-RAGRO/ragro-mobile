import 'package:equatable/equatable.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted(this.cartId);
  final String cartId;
  @override
  List<Object?> get props => [cartId];
}

class CheckoutConfirmed extends CheckoutEvent {
  const CheckoutConfirmed(this.cartId);
  final String cartId;
  @override
  List<Object?> get props => [cartId];
}
