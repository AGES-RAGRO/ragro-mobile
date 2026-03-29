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
