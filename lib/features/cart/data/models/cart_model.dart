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

    final producer =
        json['producer'] as Map<String, dynamic>? ??
        json['farmer'] as Map<String, dynamic>?;
    final bankJson =
        json['bankInfo'] as Map<String, dynamic>? ??
        producer?['bankInfo'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    return CartModel(
      id: json['id'] as String? ?? '',
      producerId:
          json['farmerId'] as String? ?? json['producerId'] as String? ?? '',
      farmName: json['farmName'] as String? ?? '',
      items: itemsJson.map(CartItemModel.fromJson).toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      // Backend BankInfoResponse envia `bankName`. Fallback p/ `bank` mantém
      // compat com payloads antigos.
      bankName:
          bankJson['bankName'] as String? ??
          bankJson['bank'] as String? ??
          '',
      bankAgency: bankJson['agency'] as String? ?? '',
      bankAccount:
          bankJson['account'] as String? ??
          bankJson['accountNumber'] as String? ??
          '',
      bankPixKey:
          bankJson['pixKey'] as String? ?? bankJson['pix_key'] as String? ?? '',
    );
  }
}
