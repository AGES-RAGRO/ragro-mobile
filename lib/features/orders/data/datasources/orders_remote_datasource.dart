import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/data/models/order_detail_model.dart';
import 'package:ragro_mobile/features/orders/data/models/order_model.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_detail.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

@lazySingleton
class OrdersRemoteDatasource {
  const OrdersRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Order>> getOrders({OrderStatus? status}) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.consumerOrders,
        queryParameters: {
          if (status != null) 'status': _statusQueryValue(status),
        },
      );

      return _readList(response.data).map(OrderModel.fromJson).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> getOrderById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.customerOrder(id),
      );

      return OrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<OrderDetail> getCustomerOrderById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.customerOrder(id),
      );

      return OrderDetailModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> createOrderFromCart() async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.orders,
      );

      return OrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> cancelOrder(String id) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.orderCancel(id),
      );

      return OrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> cancelCustomerOrder(String id, {required String reason, String? details}) async {
    try {
      await _apiClient.dio.patch<void>(
        ApiEndpoints.orderCancel(id),
        data: {'reason': reason, if (details != null) 'details': details},
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<OrderDetail> confirmCustomerDelivery(String id) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.customerOrderConfirmDelivery(id),
      );

      return OrderDetailModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> updateStatus(String id, OrderStatus status) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.orderStatus(id),
        data: {'status': _statusQueryValue(status)},
      );

      return OrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> confirmOrder(String id) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.orderConfirm(id),
      );

      return OrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> repeatOrder(String id) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.orderRepeat(id),
      );

      return OrderModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> rateProducer(String orderId, int rating) async {
    try {
      await _apiClient.dio.post<void>(
        ApiEndpoints.orderRating(orderId),
        data: {'rating': rating},
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  List<Map<String, dynamic>> _readList(dynamic data) {
    if (data is List<dynamic>) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      for (final key in const ['data', 'content', 'items', 'orders', 'result', 'list']) {
        if (data[key] is List<dynamic>) {
          return (data[key] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }
    }
    return const [];
  }

  String _statusQueryValue(OrderStatus status) {
    return switch (status) {
      OrderStatus.accepted => 'confirmed',
      OrderStatus.pending => 'pending',
      OrderStatus.inDelivery => 'in_delivery',
      OrderStatus.delivered => 'delivered',
      OrderStatus.cancelled => 'cancelled',
    };
  }
}
