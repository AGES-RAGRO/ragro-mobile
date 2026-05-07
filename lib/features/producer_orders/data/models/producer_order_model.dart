import 'package:ragro_mobile/features/producer_orders/data/models/producer_order_item_model.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';

class ProducerOrderModel extends ProducerOrder {
  const ProducerOrderModel({
    required super.id,
    required super.consumerName,
    required super.consumerAvatarUrl,
    required super.consumerSince,
    required super.status,
    required super.totalPrice,
    required super.deliveryAddress,
    required super.deliveryNeighborhood,
    required super.deliveryCityState,
    required super.deliveryComplement,
    required super.items,
    required super.createdAt,
    required super.isNew,
    required super.consumerPhone,
  });

  factory ProducerOrderModel.fromJson(Map<String, dynamic> json) {
    final consumer =
        json['consumer'] as Map<String, dynamic>? ??
        json['customer'] as Map<String, dynamic>?;
    final address =
        json['deliveryAddress'] as Map<String, dynamic>? ??
        json['address'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final itemsJson = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return ProducerOrderModel(
      id: json['id'] as String? ?? '',
      consumerName:
          json['consumerName'] as String? ??
          json['customerName'] as String? ??
          consumer?['name'] as String? ??
          '',
      consumerAvatarUrl:
          json['consumerAvatarUrl'] as String? ??
          json['customerPhoto'] as String? ??
          consumer?['photoUrl'] as String? ??
          '',
      consumerSince:
          json['consumerSince'] as String? ??
          consumer?['memberSince'] as String? ??
          '',
      status: _parseStatus(json['status'] as String?),
      totalPrice:
          (json['total'] as num? ??
                  json['totalPrice'] as num? ??
                  json['totalAmount'] as num? ??
                  0)
              .toDouble(),
      deliveryAddress: _street(address),
      deliveryNeighborhood:
          address['neighborhood'] as String? ??
          address['district'] as String? ??
          '',
      deliveryCityState: _cityState(address),
      deliveryComplement: address['complement'] as String? ?? '',
      items: itemsJson.map(ProducerOrderItemModel.fromJson).toList(),
      createdAt: _parseDate(json['createdAt'] as String?),
      isNew: json['isNew'] as bool? ?? _isNew(json['createdAt'] as String?),
      consumerPhone:
          json['consumerPhone'] as String? ??
          json['customerPhone'] as String? ??
          consumer?['phone'] as String? ??
          '',
    );
  }

  static ProducerOrderStatus _parseStatus(String? status) {
    return switch (status?.trim().toUpperCase()) {
      'CONFIRMED' || 'ACCEPTED' => ProducerOrderStatus.accepted,
      'OUT_FOR_DELIVERY' ||
      'INDELIVERY' ||
      'IN_DELIVERY' => ProducerOrderStatus.inDelivery,
      'DELIVERED' => ProducerOrderStatus.delivered,
      'CANCELLED' || 'CANCELED' => ProducerOrderStatus.cancelled,
      _ => ProducerOrderStatus.pending,
    };
  }

  static DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  static bool _isNew(String? value) {
    final createdAt = DateTime.tryParse(value ?? '')?.toLocal();
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt) < const Duration(hours: 2);
  }

  static String _street(Map<String, dynamic> json) {
    final street = json['street'] as String? ?? '';
    final number = json['number'] as String? ?? '';
    if (number.isEmpty) return street;
    return '$street, $number';
  }

  static String _cityState(Map<String, dynamic> json) {
    final city = json['city'] as String? ?? '';
    final state = json['state'] as String? ?? '';
    if (city.isEmpty) return state;
    if (state.isEmpty) return city;
    return '$city, $state';
  }
}
