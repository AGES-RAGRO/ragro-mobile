import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/core/utils/api_date_time.dart';

/// Parada da rota persistida (`RouteStopResponse` do backend).
class DeliveryRouteStop {
  const DeliveryRouteStop({
    required this.id,
    required this.orderId,
    required this.sequence,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.customerName,
    this.legDurationSeconds,
    this.eta,
    this.completedAt,
  });

  factory DeliveryRouteStop.fromJson(Map<String, dynamic> json) {
    return DeliveryRouteStop(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      sequence: (json['sequence'] as num? ?? 0).toInt(),
      status: json['status'] as String? ?? 'PENDING',
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      addressText: json['addressText'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      legDurationSeconds: (json['legDurationSeconds'] as num?)?.toInt(),
      eta: parseApiDateTime(json['eta']),
      completedAt: parseApiDateTime(json['completedAt']),
    );
  }

  final String id;
  final String orderId;
  final int sequence;

  /// PENDING | ARRIVED | DELIVERED | FAILED.
  final String status;
  final double latitude;
  final double longitude;
  final String addressText;
  final String customerName;
  final int? legDurationSeconds;
  final DateTime? eta;
  final DateTime? completedAt;

  bool get isTerminal => status == 'DELIVERED' || status == 'FAILED';
}

/// Rota de entrega persistida do produtor (`RouteResponse` do backend).
class DeliveryRoute {
  const DeliveryRoute({
    required this.id,
    required this.status,
    required this.originLatitude,
    required this.originLongitude,
    required this.totalDistanceKm,
    required this.totalDurationSeconds,
    required this.stops,
    this.baselineDistanceKm,
    this.overviewPolyline,
  });

  factory DeliveryRoute.fromJson(Map<String, dynamic> json) {
    return DeliveryRoute(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      originLatitude: (json['originLatitude'] as num? ?? 0).toDouble(),
      originLongitude: (json['originLongitude'] as num? ?? 0).toDouble(),
      totalDistanceKm: (json['totalDistanceKm'] as num? ?? 0).toDouble(),
      totalDurationSeconds: (json['totalDurationSeconds'] as num? ?? 0).toInt(),
      baselineDistanceKm: (json['baselineDistanceKm'] as num?)?.toDouble(),
      overviewPolyline: json['overviewPolyline'] as String?,
      stops: (json['stops'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DeliveryRouteStop.fromJson)
          .toList(),
    );
  }

  final String id;

  /// ACTIVE | COMPLETED | CANCELLED.
  final String status;
  final double originLatitude;
  final double originLongitude;
  final double totalDistanceKm;
  final int totalDurationSeconds;

  /// Baseline do CO2 (ida-e-volta individual a cada parada), calculado no servidor.
  final double? baselineDistanceKm;
  final String? overviewPolyline;
  final List<DeliveryRouteStop> stops;
}

/// Rotas de entrega persistidas no backend (Google Routes API roda no servidor;
/// a key nunca fica no app). A rota é calculada UMA vez na criação; o progresso
/// é por parada, sem novas chamadas ao Google.
@lazySingleton
class RouteRepository {
  const RouteRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Cria (ou substitui) a rota ativa a partir dos pedidos CONFIRMED/IN_DELIVERY.
  Future<DeliveryRoute> createRoute({
    required double originLatitude,
    required double originLongitude,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.routes,
        data: {
          'originLatitude': originLatitude,
          'originLongitude': originLongitude,
        },
      );
      return DeliveryRoute.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Rota ativa do produtor; `null` quando não há (404).
  Future<DeliveryRoute?> getActiveRoute() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.activeRoute,
      );
      return DeliveryRoute.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      final error = e.error;
      if (error is NotFoundException) return null;
      throw error as ApiException? ?? const UnknownApiException();
    }
  }

  /// Atualiza uma parada (ARRIVED/DELIVERED/FAILED) e devolve a rota atualizada.
  /// O [code] (4 dígitos do consumidor) é OBRIGATÓRIO no backend quando o status
  /// é DELIVERED — sem ele, a API responde 400 "Código de confirmação
  /// obrigatório para concluir a entrega".
  Future<DeliveryRoute> updateStop({
    required String routeId,
    required String stopId,
    required String status,
    String? code,
  }) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.routeStop(routeId, stopId),
        data: {'status': status, if (code != null) 'code': code},
      );
      return DeliveryRoute.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
