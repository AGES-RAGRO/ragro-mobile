import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class OrdersStarted extends OrdersEvent {
  const OrdersStarted(this.status);
  final OrderStatus status;
  @override
  List<Object?> get props => [status];
}

class OrdersTabChanged extends OrdersEvent {
  const OrdersTabChanged(this.status);
  final OrderStatus status;
  @override
  List<Object?> get props => [status];
}

class OrdersRefreshed extends OrdersEvent {
  const OrdersRefreshed();
}
