import 'package:ragro_mobile/features/producer_orders/domain/entities/delivery_route.dart';

abstract class RouteRepository {
  Future<DeliveryRoute?> getTodayRoute();
}
