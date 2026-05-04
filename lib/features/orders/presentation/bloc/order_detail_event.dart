import 'package:equatable/equatable.dart';

sealed class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();
  @override
  List<Object?> get props => [];
}

class OrderDetailStarted extends OrderDetailEvent {
  const OrderDetailStarted(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class OrderDetailCancelled extends OrderDetailEvent {
  const OrderDetailCancelled(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class OrderDetailDeliveryConfirmed extends OrderDetailEvent {
  const OrderDetailDeliveryConfirmed(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}
