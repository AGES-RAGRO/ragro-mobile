import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';

@lazySingleton
class DirectionsRepository {
  /// Dedicated client for the third-party Google call.
  ///
  /// We intentionally do NOT reuse the app's authenticated `ApiClient` here:
  /// its Dio carries the user's `Authorization: Bearer <token>` header and the
  /// RAGRO error interceptor, neither of which must ever be sent to
  /// `maps.googleapis.com`.
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Injected at build time via `--dart-define=MAPS_API_KEY=...` (or
  /// `--dart-define-from-file`). Never hardcoded/committed.
  static const String _mapsApiKey = String.fromEnvironment('MAPS_API_KEY');
  static const String _directionsUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  Future<Map<String, dynamic>> getRoute(
    String origin,
    String destination,
    List<String> waypoints,
  ) async {
    if (_mapsApiKey.isEmpty) {
      throw const UnknownApiException(
        'Chave da API do Google Maps não configurada (MAPS_API_KEY).',
      );
    }

    try {
      final waypointsStr = waypoints.isNotEmpty
          ? 'optimize:true|${waypoints.join('|')}'
          : '';

      final response = await _dio.get<Map<String, dynamic>>(
        _directionsUrl,
        queryParameters: {
          'origin': origin,
          'destination': destination,
          if (waypointsStr.isNotEmpty) 'waypoints': waypointsStr,
          'key': _mapsApiKey,
          'language': 'pt-BR',
        },
      );

      final data = response.data;
      if (data == null || data['status'] != 'OK') {
        throw const UnknownApiException(
          'Erro ao calcular rota real pelo Google Maps.',
        );
      }

      // Parse total distance and duration defensively: Google may omit
      // distance/duration objects in some edge responses.
      final routes = data['routes'] as List? ?? const [];
      if (routes.isEmpty) return {'distanceKm': 0.0, 'durationMins': 0};

      final firstRoute = routes.first as Map?;
      final legs = firstRoute?['legs'] as List? ?? const [];
      var totalDistanceMeters = 0;
      var totalDurationSeconds = 0;

      for (final leg in legs) {
        final legMap = leg as Map?;
        totalDistanceMeters +=
            ((legMap?['distance'] as Map?)?['value'] as num? ?? 0).toInt();
        totalDurationSeconds +=
            ((legMap?['duration'] as Map?)?['value'] as num? ?? 0).toInt();
      }

      return {
        'distanceKm': totalDistanceMeters / 1000.0,
        'durationMins': (totalDurationSeconds / 60.0).round(),
        'points': (firstRoute?['overview_polyline'] as Map?)?['points'],
      };
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
