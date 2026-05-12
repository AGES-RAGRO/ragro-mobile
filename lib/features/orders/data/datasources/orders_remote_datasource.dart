import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/orders/data/models/create_review_request.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_item.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

@lazySingleton
class OrdersRemoteDatasource {
  const OrdersRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Order>> getOrders({OrderStatus? status}) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        ApiEndpoints.consumerOrders,
      );

      final orders = (response.data ?? const [])
          .map((json) => _mapOrder(json as Map<String, dynamic>))
          .toList();

      if (status == null) {
        return orders;
      }

      return orders.where((order) => order.status == status).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> getOrderById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.customerOrder(id),
      );
      return _mapOrder(response.data ?? const <String, dynamic>{});
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<Order> confirmOrder(String cartId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.orders,
      );
      return _mapProducerOrder(response.data ?? const <String, dynamic>{});
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> createReview(String orderId, int rating, String comment) async {
    try {
      final request = CreateReviewRequest(
        orderId: orderId,
        rating: rating,
        comment: comment,
      );
      await _apiClient.dio.post<void>(
        ApiEndpoints.reviews,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Order _mapOrder(Map<String, dynamic> json) {
    final producerName = (json['producerName'] as String? ?? '').trim();
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    final items = itemsJson
        .map((item) => _mapOrderItem(item as Map<String, dynamic>))
        .toList();

    return Order(
      id: (json['id'] ?? '').toString(),
      producerId: (json['producerId'] ?? '').toString(),
      farmName: producerName,
      farmAvatarUrl: (json['producerPicture'] as String? ?? '').trim(),
      ownerName: producerName,
      items: items,
      totalAmount: _asDouble(json['totalAmount'] ?? json['price']),
      status: _mapOrderStatus(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      deliveryAddress: _mapDeliveryAddress(
        json['deliveryAddress'] as Map<String, dynamic>?,
      ),
      bankInfo: const ProducerBankInfo(
        bank: '',
        agency: '',
        account: '',
        pixKey: '',
      ),
    );
  }

  Order _mapProducerOrder(Map<String, dynamic> json) {
    final farmerName = (json['farmerName'] as String? ?? '').trim();
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    final items = itemsJson
        .map((item) => _mapOrderItem(item as Map<String, dynamic>))
        .toList();

    return Order(
      id: (json['id'] ?? '').toString(),
      producerId: (json['farmerId'] ?? '').toString(),
      farmName: farmerName,
      farmAvatarUrl: '',
      ownerName: farmerName,
      items: items,
      totalAmount: _asDouble(json['totalAmount']),
      status: _mapOrderStatus(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      deliveryAddress: _mapDeliveryAddress(
        json['deliveryAddress'] as Map<String, dynamic>?,
      ),
      bankInfo: const ProducerBankInfo(
        bank: '',
        agency: '',
        account: '',
        pixKey: '',
      ),
    );
  }

  OrderItem _mapOrderItem(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] ?? '').toString(),
      name: (json['productName'] as String? ?? '').trim(),
      imageUrl: (json['productPhoto'] as String? ?? '').trim(),
      quantity: _asDouble(json['quantity']),
      unityType: (json['unityType'] as String? ?? '').trim(),
      totalPrice: _asDouble(json['subtotal']),
    );
  }

  DeliveryAddress _mapDeliveryAddress(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return DeliveryAddress(
      street: _joinNonBlank([
        data['street']?.toString(),
        data['number']?.toString(),
        data['complement']?.toString(),
      ]),
      neighborhood: (data['neighborhood'] as String? ?? '').trim(),
      city: (data['city'] as String? ?? '').trim(),
      state: (data['state'] as String? ?? '').trim(),
      zipCode: (data['zipCode'] as String? ?? '').trim(),
    );
  }

  OrderStatus _mapOrderStatus(String? rawStatus) {
    switch ((rawStatus ?? '').toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
      case 'IN_DELIVERY':
        return OrderStatus.accepted;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  String _joinNonBlank(List<String?> parts) {
    return parts
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(', ');
  }
}
