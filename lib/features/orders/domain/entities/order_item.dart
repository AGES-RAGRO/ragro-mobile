import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.unityType,
    required this.totalPrice,
  });

  final String productId;
  final String name;
  final String imageUrl;
  final int quantity;
  final String unityType;
  final double totalPrice;

  @override
  List<Object?> get props => [
    productId,
    name,
    imageUrl,
    quantity,
    unityType,
    totalPrice,
  ];
}
