import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/producer_order_model.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

@lazySingleton
class ProducerOrdersRemoteDataSource {
  const ProducerOrdersRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProducerOrder>> getOrders({ProducerOrderStatus? status}) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.producerOrders,
        queryParameters: {
          if (status != null) 'status': _statusQueryValue(status),
        },
      );

      return _readList(response.data).map(ProducerOrderModel.fromJson).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<ProducerOrder> getOrderById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producerOrder(id),
      );

      return ProducerOrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> confirmOrder(String id) async {
    try {
      await _apiClient.dio.patch<void>(ApiEndpoints.producerOrderConfirm(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> refuseOrder(String id) async {
    try {
      await _apiClient.dio.patch<void>(
        ApiEndpoints.producerOrderStatus(id),
        data: {'status': 'CANCELLED'},
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> updateStatus(String id, ProducerOrderStatus status) async {
    try {
      await _apiClient.dio.patch<void>(
        ApiEndpoints.producerOrderStatus(id),
        data: {'status': _statusQueryValue(status)},
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  List<Map<String, dynamic>> _readList(dynamic data) {
    final rawList = switch (data) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map when map['data'] is List<dynamic> =>
        map['data'] as List<dynamic>,
      final Map<String, dynamic> map when map['content'] is List<dynamic> =>
        map['content'] as List<dynamic>,
      final Map<String, dynamic> map when map['items'] is List<dynamic> =>
        map['items'] as List<dynamic>,
      _ => const <dynamic>[],
    };

    return rawList.whereType<Map<String, dynamic>>().toList();
  }

  String _statusQueryValue(ProducerOrderStatus status) {
    return switch (status) {
      ProducerOrderStatus.pending => 'pending',
      ProducerOrderStatus.accepted => 'confirmed',
      ProducerOrderStatus.inDelivery => 'IN_DELIVERY',
      ProducerOrderStatus.delivered => 'DELIVERED',
      ProducerOrderStatus.cancelled => 'cancelled',
    };
  }
}
