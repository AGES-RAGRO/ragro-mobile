import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/delivery_route.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/route_repository.dart';

@injectable
class GetTodayRoute {
  const GetTodayRoute(this._repository);

  final RouteRepository _repository;

  Future<DeliveryRoute?> call() => _repository.getTodayRoute();
}
