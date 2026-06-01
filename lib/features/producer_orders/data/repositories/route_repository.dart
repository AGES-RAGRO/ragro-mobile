import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';

/// Resultado da otimização de rota retornado pelo backend (`POST /routes/optimize`),
/// que por sua vez chama o Google Directions API com `optimizeWaypoints=true`.
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

  /// Ordem otimizada dos waypoints enviados (índices no array original).
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

/// Calcula rotas chamando o endpoint autenticado do backend, mantendo a chave
/// do Google Maps no servidor (não embarcada no app).
@lazySingleton
class RouteRepository {
  const RouteRepository(this._apiClient);

  final ApiClient _apiClient;

  /// [origin]/[destination] e cada waypoint podem ser "lat,lng" ou um endereço
  /// textual — o backend repassa ao Google, que geocoda texto quando preciso.
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
