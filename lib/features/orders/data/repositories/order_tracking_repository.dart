import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/core/utils/api_date_time.dart';

/// Order tracking snapshot (`GET /orders/{id}/tracking`).
class OrderTracking {
  const OrderTracking({
    required this.available,
    this.routeId,
    this.producerLatitude,
    this.producerLongitude,
    this.recordedAt,
    this.destinationLatitude,
    this.destinationLongitude,
    this.etaSeconds,
    this.stopsBefore = 0,
    this.stopStatus,
    this.overviewPolyline,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      available: json['available'] as bool? ?? false,
      routeId: json['routeId'] as String?,
      producerLatitude: (json['producerLatitude'] as num?)?.toDouble(),
      producerLongitude: (json['producerLongitude'] as num?)?.toDouble(),
      recordedAt: parseApiDateTime(json['recordedAt']),
      destinationLatitude: (json['destinationLatitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destinationLongitude'] as num?)?.toDouble(),
      etaSeconds: (json['etaSeconds'] as num?)?.toInt(),
      stopsBefore: (json['stopsBefore'] as num? ?? 0).toInt(),
      stopStatus: json['stopStatus'] as String?,
      overviewPolyline: json['overviewPolyline'] as String?,
    );
  }

  final bool available;
  final String? routeId;
  final double? producerLatitude;
  final double? producerLongitude;
  final DateTime? recordedAt;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final int? etaSeconds;
  final int stopsBefore;

  /// PENDING | ARRIVED | DELIVERED | FAILED.
  final String? stopStatus;

  /// Google-encoded polyline of the full route (drawn on the map).
  final String? overviewPolyline;
}

/// Initial snapshot + polling fallback for delivery tracking; live stream comes
/// from STOMP topic `/topic/routes/{routeId}`.
@lazySingleton
class OrderTrackingRepository {
  const OrderTrackingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<OrderTracking> getTracking(String orderId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.orderTracking(orderId),
      );
      return OrderTracking.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
