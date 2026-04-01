import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

sealed class ProducerOrderDetailEvent extends Equatable {
  const ProducerOrderDetailEvent();
  @override
  List<Object?> get props => [];
}

class ProducerOrderDetailStarted extends ProducerOrderDetailEvent {
  const ProducerOrderDetailStarted(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderDetailConfirmed extends ProducerOrderDetailEvent {
  const ProducerOrderDetailConfirmed(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderDetailRefused extends ProducerOrderDetailEvent {
  const ProducerOrderDetailRefused(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderDetailStatusUpdated extends ProducerOrderDetailEvent {
  const ProducerOrderDetailStatusUpdated(this.orderId, this.status);
  final String orderId;
  final ProducerOrderStatus status;
  @override
  List<Object?> get props => [orderId, status];
}
