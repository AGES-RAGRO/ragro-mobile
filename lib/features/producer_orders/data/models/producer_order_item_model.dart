import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_item.dart';

class ProducerOrderItemModel extends ProducerOrderItem {
  const ProducerOrderItemModel({
    required super.productId,
    required super.name,
    required super.imageUrl,
    required super.unitPrice,
    required super.totalPrice,
    required super.quantity,
    required super.unityType,
  });

  factory ProducerOrderItemModel.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] as num? ?? 0;

    return ProducerOrderItemModel(
      productId:
          json['productId'] as String? ?? json['product_id'] as String? ?? '',
      name: json['productName'] as String? ?? json['name'] as String? ?? '',
      imageUrl:
          json['imageUrl'] as String? ??
          json['imageS3'] as String? ??
          json['productPhoto'] as String? ??
          '',
      unitPrice: (json['unitPrice'] as num? ?? json['unit_price'] as num? ?? 0)
          .toDouble(),
      totalPrice:
          (json['subtotal'] as num? ??
                  json['totalPrice'] as num? ??
                  json['total'] as num? ??
                  0)
              .toDouble(),
      quantity: quantity.toInt(),
      unityType:
          json['unityType'] as String? ??
          json['unit'] as String? ??
          json['unity_type'] as String? ??
          '',
    );
  }
}
