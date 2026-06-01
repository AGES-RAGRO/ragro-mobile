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
  const ProducerOrderCancelled(
    this.orderId, {
    required this.reason,
    this.details,
  });

  final String orderId;
  final String reason;
  final String? details;

  @override
  List<Object?> get props => [orderId, reason, details];
}

class ProducerOrderLocallyRefused extends ProducerOrdersEvent {
  const ProducerOrderLocallyRefused(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

/// Marks a set of orders as "in delivery" at once (multi-select). Does a single
/// reload and feedback and reports partial failures, unlike firing N individual
/// events.
class ProducerOrdersBulkMarkedInDelivery extends ProducerOrdersEvent {
  const ProducerOrdersBulkMarkedInDelivery(this.orderIds);

  final Set<String> orderIds;

  @override
  List<Object?> get props => [orderIds];
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

class ProducerOrderLocallySeen extends ProducerOrdersEvent {
  const ProducerOrderLocallySeen(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
