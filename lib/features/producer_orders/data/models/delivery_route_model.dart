import 'package:ragro_mobile/features/producer_orders/domain/entities/delivery_route.dart';

class DeliveryRouteModel {
  static DeliveryRoute fromJson(Map<String, dynamic> json) {
    final stopsJson = (json['stops'] as List<dynamic>?) ?? [];
    final stops = stopsJson
        .map((s) => RouteStop(
              stopOrder: (s['stopOrder'] as num).toInt(),
              orderId: s['orderId'] as String,
              formattedAddress: s['formattedAddress'] as String,
              latitude: (s['latitude'] as num).toDouble(),
              longitude: (s['longitude'] as num).toDouble(),
            ))
        .toList();

    final List<List<double>> coords = [];
    final geometry = json['geometry'];
    if (geometry != null && geometry['coordinates'] is List) {
      for (final c in geometry['coordinates'] as List) {
        if (c is List && c.length >= 2) {
          coords.add([
            (c[0] as num).toDouble(),
            (c[1] as num).toDouble(),
          ]);
        }
      }
    }

    return DeliveryRoute(
      routeId: (json['routeId'] as String?) ?? '',
      totalDistanceMeters: (json['totalDistanceMeters'] as num?)?.toInt() ?? 0,
      totalDurationSeconds: (json['totalDurationSeconds'] as num?)?.toInt() ?? 0,
      stops: stops,
      geometryCoordinates: coords,
    );
  }
}
