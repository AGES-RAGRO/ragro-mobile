import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';

class Cart extends Equatable {
  const Cart({
    required this.id,
    required this.producerId,
    required this.farmName,
    required this.items,
    required this.totalAmount,
  });

  const Cart.empty()
    : id = '',
      producerId = '',
      farmName = '',
      items = const [],
      totalAmount = 0;

  final String id;
  final String producerId;
  final String farmName;
  final List<CartItem> items;
  final double totalAmount;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.length;

  @override
  List<Object?> get props => [id, producerId, farmName, items, totalAmount];
}
