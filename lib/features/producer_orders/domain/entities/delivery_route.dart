import 'package:equatable/equatable.dart';

class RouteStop extends Equatable {
  const RouteStop({
    required this.stopOrder,
    required this.orderId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  final int stopOrder;
  final String orderId;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props =>
      [stopOrder, orderId, formattedAddress, latitude, longitude];
}

class DeliveryRoute extends Equatable {
  const DeliveryRoute({
    required this.routeId,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.stops,
    required this.geometryCoordinates,
  });

  final String routeId;
  final int totalDistanceMeters;
  final int totalDurationSeconds;
  final List<RouteStop> stops;

  /// List of [longitude, latitude] pairs from the GeoJSON LineString.
  final List<List<double>> geometryCoordinates;

  String get formattedDistance {
    if (totalDistanceMeters >= 1000) {
      return '${(totalDistanceMeters / 1000).toStringAsFixed(1)}km';
    }
    return '${totalDistanceMeters}m';
  }

  String get formattedDuration {
    final minutes = (totalDurationSeconds / 60).round();
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}min' : '${h}h';
    }
    return '${minutes}min';
  }

  @override
  List<Object?> get props => [
        routeId,
        totalDistanceMeters,
        totalDurationSeconds,
        stops,
        geometryCoordinates,
      ];
}
