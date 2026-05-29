import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';

@lazySingleton
class DirectionsRepository {
  final ApiClient _apiClient = getIt<ApiClient>();
  
  static const String _mapsApiKey = 'AIzaSyBCfYDs2n4Vr89flZMrGUs9dehMr1wFEMA';
  static const String _directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  Future<Map<String, dynamic>> getRoute(String origin, String destination, List<String> waypoints) async {
    try {
      final waypointsStr = waypoints.isNotEmpty ? 'optimize:true|${waypoints.join('|')}' : '';
      
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
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
        throw const UnknownApiException('Erro ao calcular rota real pelo Google Maps.');
      }

      // Parse total distance and duration
      final routes = data['routes'] as List;
      if (routes.isEmpty) return {'distanceKm': 0.0, 'durationMins': 0};

      final legs = routes[0]['legs'] as List;
      int totalDistanceMeters = 0;
      int totalDurationSeconds = 0;

      for (var leg in legs) {
        totalDistanceMeters += (leg['distance']['value'] as num).toInt();
        totalDurationSeconds += (leg['duration']['value'] as num).toInt();
      }

      return {
        'distanceKm': totalDistanceMeters / 1000.0,
        'durationMins': (totalDurationSeconds / 60.0).round(),
        'points': data['routes'][0]['overview_polyline']['points'],
      };
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
