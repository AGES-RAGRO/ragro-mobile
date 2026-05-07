import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

sealed class ProducerOrdersState extends Equatable {
  const ProducerOrdersState();
  @override
  List<Object?> get props => [];
}

class ProducerOrdersInitial extends ProducerOrdersState {
  const ProducerOrdersInitial();
}

class ProducerOrdersLoading extends ProducerOrdersState {
  const ProducerOrdersLoading(this.activeTab);
  final ProducerOrderStatus activeTab;
  @override
  List<Object?> get props => [activeTab];
}

class ProducerOrdersLoaded extends ProducerOrdersState {
  const ProducerOrdersLoaded({required this.orders, required this.activeTab});
  final List<ProducerOrder> orders;
  final ProducerOrderStatus activeTab;
  @override
  List<Object?> get props => [orders, activeTab];
}

class ProducerOrdersFailure extends ProducerOrdersState {
  const ProducerOrdersFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ProducerOrdersActionSuccess extends ProducerOrdersState {
  const ProducerOrdersActionSuccess({
    required this.message,
    required this.orders,
    required this.activeTab,
  });
  final String message;
  final List<ProducerOrder> orders;
  final ProducerOrderStatus activeTab;
  @override
  List<Object?> get props => [message, orders, activeTab];
}
