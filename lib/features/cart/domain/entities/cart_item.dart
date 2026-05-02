import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.unityType,
    required this.quantity,
    required this.subtotal,
  });

  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final double unitPrice;
  final String unityType;
  final double quantity;
  final double subtotal;

  double get totalPrice => subtotal;

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    imageUrl,
    unitPrice,
    unityType,
    quantity,
    subtotal,
  ];
}
