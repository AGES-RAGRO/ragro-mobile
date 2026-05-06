import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.imageUrl,
    required super.unitPrice,
    required super.unityType,
    required super.quantity,
    required super.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'] as String,
    productId: json['productId'] as String,
    productName: json['productName'] as String? ?? '',
    imageUrl: ApiEndpoints.resolveMediaUrl(json['imageS3'] as String? ?? ''),
    unitPrice: (json['unitPrice'] as num).toDouble(),
    unityType: json['unityType'] as String? ?? '',
    quantity: (json['quantity'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
  );
}
