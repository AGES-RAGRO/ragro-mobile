import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading(this.activeTab);
  final OrderStatus activeTab;
  @override
  List<Object?> get props => [activeTab];
}

class OrdersLoaded extends OrdersState {
  const OrdersLoaded({required this.orders, required this.activeTab});
  final List<Order> orders;
  final OrderStatus activeTab;
  @override
  List<Object?> get props => [orders, activeTab];
}

class OrdersFailure extends OrdersState {
  const OrdersFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
