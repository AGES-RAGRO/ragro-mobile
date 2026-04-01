import 'package:equatable/equatable.dart';

class ProducerOrderItem extends Equatable {
  const ProducerOrderItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.totalPrice,
    required this.quantity,
    required this.unityType,
  });

  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final double totalPrice;
  final int quantity;
  final String unityType;

  @override
  List<Object?> get props => [productId, name, imageUrl, unitPrice, totalPrice, quantity, unityType];
}
