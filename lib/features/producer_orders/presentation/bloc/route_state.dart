import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/delivery_route.dart';

abstract class RouteState extends Equatable {
  const RouteState();

  @override
  List<Object?> get props => [];
}

class RouteInitial extends RouteState {
  const RouteInitial();
}

class RouteLoading extends RouteState {
  const RouteLoading();
}

class RouteLoaded extends RouteState {
  const RouteLoaded(this.route);

  final DeliveryRoute? route;

  @override
  List<Object?> get props => [route];
}

class RouteError extends RouteState {
  const RouteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
