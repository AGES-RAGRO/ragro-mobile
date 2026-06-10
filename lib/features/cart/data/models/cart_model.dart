import 'package:ragro_mobile/features/cart/data/models/cart_item_model.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';

class CartModel extends Cart {
  const CartModel({
    required super.id,
    required super.producerId,
    required super.farmName,
    required super.items,
    required super.totalAmount,
    super.bankName,
    super.bankAgency,
    super.bankAccount,
    super.bankPixKey,
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

    final bankInfo =
        json['bankInfo'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return CartModel(
      id: json['id'] as String? ?? '',
      producerId:
          json['farmerId'] as String? ?? json['producerId'] as String? ?? '',
      farmName: json['farmName'] as String? ?? '',
      items: itemsJson.map(CartItemModel.fromJson).toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      bankName: bankInfo['bankName'] as String? ?? '',
      bankAgency: bankInfo['agency'] as String? ?? '',
      bankAccount: bankInfo['account'] as String? ?? '',
      bankPixKey: bankInfo['pixKey'] as String? ?? '',
    );
  }
}
