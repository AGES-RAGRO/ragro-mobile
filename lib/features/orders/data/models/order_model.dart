import 'package:ragro_mobile/features/orders/data/models/order_item_model.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.producerId,
    required super.producerPhone,
    required super.farmName,
    required super.farmAvatarUrl,
    required super.ownerName,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    required super.deliveryAddress,
    required super.bankInfo,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final producer = json['producer'] as Map<String, dynamic>?;
    final farmer = json['farmer'] as Map<String, dynamic>?;
    final producerJson = producer ?? farmer;
    final addressJson =
        json['deliveryAddress'] as Map<String, dynamic>? ??
        json['address'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final bankJson =
        json['bankInfo'] as Map<String, dynamic>? ??
        producerJson?['bankInfo'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final itemsJson = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return OrderModel(
      id: json['id'] as String? ?? '',
      producerPhone:
          json['producerPhone'] as String? ??
          json['phone'] as String? ??
          '',
      producerId:
          json['producerId'] as String? ??
          json['farmerId'] as String? ??
          producerJson?['id'] as String? ??
          '',
      farmName:
          json['producerName'] as String? ??
          json['farmName'] as String? ??
          producerJson?['name'] as String? ??
          '',
      farmAvatarUrl:
          json['producerPhoto'] as String? ??
          json['producerPhotoUrl'] as String? ??
          json['farmAvatarUrl'] as String? ??
          producerJson?['photoUrl'] as String? ??
          '',
      ownerName:
          json['ownerName'] as String? ??
          producerJson?['ownerName'] as String? ??
          '',
      items: itemsJson.map(OrderItemModel.fromJson).toList(),
      totalAmount:
          (json['total'] as num? ??
                  json['totalAmount'] as num? ??
                  json['totalPrice'] as num? ??
                  0)
              .toDouble(),
      status: _parseStatus(json['status'] as String?),
      createdAt: _parseDate(json['createdAt'] as String?),
      deliveryAddress: _parseAddress(addressJson),
      bankInfo: _parseBankInfo(bankJson),
    );
  }

  static OrderStatus _parseStatus(String? status) {
    return switch (status?.toLowerCase()) {
      'confirmed' || 'accepted' => OrderStatus.accepted,
      'in_delivery' || 'indelivery' => OrderStatus.inDelivery,
      'delivered' => OrderStatus.delivered,
      'cancelled' || 'canceled' => OrderStatus.cancelled,
      _ => OrderStatus.pending,
    };
  }

  static DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  static DeliveryAddress _parseAddress(Map<String, dynamic> json) {
    final number = json['number'] as String? ?? '';
    final street = json['street'] as String? ?? '';
    final streetWithNumber = number.isEmpty ? street : '$street, $number';

    return DeliveryAddress(
      street: streetWithNumber,
      neighborhood:
          json['neighborhood'] as String? ?? json['district'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? json['zip_code'] as String? ?? '',
    );
  }

  static ProducerBankInfo _parseBankInfo(Map<String, dynamic> json) {
    return ProducerBankInfo(
      bank: json['bank'] as String? ?? '',
      agency: json['agency'] as String? ?? '',
      account: json['account'] as String? ?? '',
      pixKey: json['pixKey'] as String? ?? json['pix_key'] as String? ?? '',
    );
  }
}
