import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.unityType,
    required this.quantity,
    required this.farmName,
    required this.farmLocation,
    required this.producerId,
  });

  final String productId;
  final String productName;
  final String imageUrl;
  final double unitPrice;
  final String unityType;
  final int quantity;
  final String farmName;
  final String farmLocation;
  final String producerId;

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
        unitPrice: unitPrice,
        unityType: unityType,
        quantity: quantity ?? this.quantity,
        farmName: farmName,
        farmLocation: farmLocation,
        producerId: producerId,
      );

  @override
  List<Object?> get props => [productId, productName, imageUrl, unitPrice, unityType, quantity, farmName, farmLocation, producerId];
}
