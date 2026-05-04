import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/delivery_route_model.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/delivery_route.dart';

@lazySingleton
class RouteRemoteDataSource {
  const RouteRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<DeliveryRoute?> getTodayRoute() async {
    final response = await _apiClient.dio
        .get<Map<String, dynamic>>(ApiEndpoints.routesToday);

    final data = response.data;
    if (data == null) return null;

    // Backend returns empty route (routeId == null) when no in-delivery orders exist
    if (data['routeId'] == null) return null;

    return DeliveryRouteModel.fromJson(data);
  }
}
