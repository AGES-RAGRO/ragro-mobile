import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';

sealed class OrderDetailState extends Equatable {
  const OrderDetailState();
  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  const OrderDetailLoaded(this.order);
  final Order order;
  @override
  List<Object?> get props => [order];
}

class OrderDetailFailure extends OrderDetailState {
  const OrderDetailFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
