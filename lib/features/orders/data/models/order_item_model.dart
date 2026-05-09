import 'package:ragro_mobile/features/orders/domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    required super.name,
    required super.imageUrl,
    required super.quantity,
    required super.unityType,
    required super.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] as num? ?? 0;
    final subtotal =
        json['subtotal'] as num? ??
        json['totalPrice'] as num? ??
        json['total'] as num? ??
        0;

    return OrderItemModel(
      productId:
          json['productId'] as String? ?? json['product_id'] as String? ?? '',
      name: json['productName'] as String? ?? json['name'] as String? ?? '',
      imageUrl:
          json['imageUrl'] as String? ??
          json['imageS3'] as String? ??
          json['productPhoto'] as String? ??
          '',
      quantity: quantity.toInt(),
      unityType:
          json['unityType'] as String? ??
          json['unit'] as String? ??
          json['unity_type'] as String? ??
          '',
      totalPrice: subtotal.toDouble(),
    );
  }
}
