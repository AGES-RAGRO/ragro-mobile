import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';

/// Route optimization result from the backend (`POST /routes/optimize`), which
/// calls the Google Directions API with `optimizeWaypoints=true`.
class OptimizedRoute {
  const OptimizedRoute({
    required this.distanceKm,
    required this.durationMins,
    this.overviewPolyline,
    this.waypointOrder = const [],
  });

  final double distanceKm;
  final int durationMins;
  final String? overviewPolyline;

  /// Optimized order of the sent waypoints (indices into the original array).
  final List<int> waypointOrder;

  factory OptimizedRoute.fromJson(Map<String, dynamic> json) {
    return OptimizedRoute(
      distanceKm: (json['totalDistanceKm'] as num? ?? 0).toDouble(),
      durationMins: (json['totalDurationMins'] as num? ?? 0).toInt(),
      overviewPolyline: json['overviewPolyline'] as String?,
      waypointOrder:
          (json['waypointOrder'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );
  }
}

/// Calculates routes via the backend's authenticated endpoint, keeping the
/// Google Maps key on the server (not embedded in the app).
@lazySingleton
class RouteRepository {
  const RouteRepository(this._apiClient);

  final ApiClient _apiClient;

  /// [origin]/[destination] and each waypoint may be "lat,lng" or a textual
  /// address — the backend forwards them to Google, which geocodes text as needed.
  Future<OptimizedRoute> optimize({
    required String origin,
    required String destination,
    List<String> waypoints = const [],
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.routesOptimize,
        data: {
          'origin': origin,
          'destination': destination,
          if (waypoints.isNotEmpty) 'waypoints': waypoints,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const UnknownApiException('Resposta vazia ao calcular a rota.');
      }
      return OptimizedRoute.fromJson(data);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
