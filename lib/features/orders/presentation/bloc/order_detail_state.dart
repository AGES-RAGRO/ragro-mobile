import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';

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
  final OrderDetail order;
  @override
  List<Object?> get props => [order];
}

class OrderDetailUpdating extends OrderDetailState {
  const OrderDetailUpdating(this.order);
  final OrderDetail order;
  @override
  List<Object?> get props => [order];
}

class OrderDetailActionSuccess extends OrderDetailState {
  const OrderDetailActionSuccess({required this.order, required this.message});

  final OrderDetail order;
  final String message;

  @override
  List<Object?> get props => [order, message];
}

class OrderDetailActionFailure extends OrderDetailState {
  const OrderDetailActionFailure({required this.order, required this.message});
  final OrderDetail order;
  final String message;
  @override
  List<Object?> get props => [order, message];
}

class OrderDetailFailure extends OrderDetailState {
  const OrderDetailFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
