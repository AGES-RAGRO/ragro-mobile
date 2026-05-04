import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

sealed class ProducerOrderDetailEvent extends Equatable {
  const ProducerOrderDetailEvent();
  @override
  List<Object?> get props => [];
}

class ProducerOrderDetailStarted extends ProducerOrderDetailEvent {
  const ProducerOrderDetailStarted(this.orderId, {this.initialOrder});
  final String orderId;
  final ProducerOrder? initialOrder;
  @override
  List<Object?> get props => [orderId, initialOrder];
}

class ProducerOrderDetailConfirmed extends ProducerOrderDetailEvent {
  const ProducerOrderDetailConfirmed(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderDetailRefused extends ProducerOrderDetailEvent {
  const ProducerOrderDetailRefused(this.orderId, {required this.reason, this.details});
  final String orderId;
  final String reason;
  final String? details;
  @override
  List<Object?> get props => [orderId, reason, details];
}

class ProducerOrderDetailStatusUpdated extends ProducerOrderDetailEvent {
  const ProducerOrderDetailStatusUpdated(this.orderId, this.status);
  final String orderId;
  final ProducerOrderStatus status;
  @override
  List<Object?> get props => [orderId, status];
}
