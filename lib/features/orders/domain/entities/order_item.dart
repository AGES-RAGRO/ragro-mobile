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
  final double quantity;
  final String unityType;
  final double totalPrice;

  String get quantityLabel {
    if (quantity == quantity.truncateToDouble()) {
      return quantity.toStringAsFixed(0);
    }
    return quantity
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

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
