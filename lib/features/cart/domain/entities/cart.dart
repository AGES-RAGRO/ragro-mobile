import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';

class Cart extends Equatable {
  const Cart({
    required this.producerId,
    required this.farmName,
    required this.farmLocation,
    required this.items,
  });

  const Cart.empty()
      : producerId = '',
        farmName = '',
        farmLocation = '',
        items = const [];

  final String producerId;
  final String farmName;
  final String farmLocation;
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.length;
  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  Cart copyWith({List<CartItem>? items}) => Cart(
        producerId: producerId,
        farmName: farmName,
        farmLocation: farmLocation,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [producerId, farmName, farmLocation, items];
}
