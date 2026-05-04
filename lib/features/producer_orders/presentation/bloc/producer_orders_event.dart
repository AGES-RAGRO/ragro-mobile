import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

sealed class ProducerOrdersEvent extends Equatable {
  const ProducerOrdersEvent();
  @override
  List<Object?> get props => [];
}

class ProducerOrdersStarted extends ProducerOrdersEvent {
  const ProducerOrdersStarted(this.tab);
  final ProducerOrderStatus tab;
  @override
  List<Object?> get props => [tab];
}

class ProducerOrdersTabChanged extends ProducerOrdersEvent {
  const ProducerOrdersTabChanged(this.tab);
  final ProducerOrderStatus tab;
  @override
  List<Object?> get props => [tab];
}

class ProducerOrdersRefreshed extends ProducerOrdersEvent {
  const ProducerOrdersRefreshed();
}

class ProducerOrderAccepted extends ProducerOrdersEvent {
  const ProducerOrderAccepted(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderCancelled extends ProducerOrdersEvent {
  const ProducerOrderCancelled(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderLocallyRefused extends ProducerOrdersEvent {
  const ProducerOrderLocallyRefused(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderMarkedInDelivery extends ProducerOrdersEvent {
  const ProducerOrderMarkedInDelivery(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderDeliveryConfirmed extends ProducerOrdersEvent {
  const ProducerOrderDeliveryConfirmed(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class ProducerOrderLocallyDelivered extends ProducerOrdersEvent {
  const ProducerOrderLocallyDelivered(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
