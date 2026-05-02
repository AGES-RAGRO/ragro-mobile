import 'package:ragro_mobile/features/cart/data/models/cart_item_model.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';

class CartModel extends Cart {
  const CartModel({
    required super.id,
    required super.producerId,
    required super.farmName,
    required super.items,
    required super.totalAmount,
  });

  const CartModel.empty()
    : super(
        id: '',
        producerId: '',
        farmName: '',
        items: const [],
        totalAmount: 0,
      );

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return CartModel(
      id: json['id'] as String? ?? '',
      producerId: json['farmerId'] as String? ?? '',
      farmName: json['farmName'] as String? ?? '',
      items: itemsJson.map(CartItemModel.fromJson).toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
