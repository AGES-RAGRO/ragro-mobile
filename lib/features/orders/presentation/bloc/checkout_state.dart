import 'package:equatable/equatable.dart';
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
  const CheckoutReady(this.order);
  final Order order;
  @override
  List<Object?> get props => [order];
}

class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.order);
  final Order order;
  @override
  List<Object?> get props => [order];
}

class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
