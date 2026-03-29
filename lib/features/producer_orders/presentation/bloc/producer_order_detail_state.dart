import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';

sealed class ProducerOrderDetailState extends Equatable {
  const ProducerOrderDetailState();
  @override
  List<Object?> get props => [];
}

class ProducerOrderDetailInitial extends ProducerOrderDetailState {
  const ProducerOrderDetailInitial();
}

class ProducerOrderDetailLoading extends ProducerOrderDetailState {
  const ProducerOrderDetailLoading();
}

class ProducerOrderDetailLoaded extends ProducerOrderDetailState {
  const ProducerOrderDetailLoaded(this.order);
  final ProducerOrder order;
  @override
  List<Object?> get props => [order];
}

class ProducerOrderDetailConfirming extends ProducerOrderDetailState {
  const ProducerOrderDetailConfirming(this.order);
  final ProducerOrder order;
  @override
  List<Object?> get props => [order];
}

class ProducerOrderDetailRefusing extends ProducerOrderDetailState {
  const ProducerOrderDetailRefusing(this.order);
  final ProducerOrder order;
  @override
  List<Object?> get props => [order];
}

class ProducerOrderDetailUpdatingStatus extends ProducerOrderDetailState {
  const ProducerOrderDetailUpdatingStatus(this.order);
  final ProducerOrder order;
  @override
  List<Object?> get props => [order];
}

class ProducerOrderDetailSuccess extends ProducerOrderDetailState {
  const ProducerOrderDetailSuccess({required this.order, required this.action});
  final ProducerOrder order;
  final String action; // 'confirmed' | 'refused' | 'status_updated'
  @override
  List<Object?> get props => [order, action];
}

class ProducerOrderDetailFailure extends ProducerOrderDetailState {
  const ProducerOrderDetailFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
