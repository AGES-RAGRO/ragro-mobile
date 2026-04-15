import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';

@lazySingleton
class CartLocalDatasource {
  Cart _cart = const Cart.empty();

  Cart getCart() => _cart;

  Cart addItem(CartItem item) {
    if (_cart.isEmpty) {
      return _cart = Cart(
        producerId: item.producerId,
        farmName: item.farmName,
        farmLocation: item.farmLocation,
        items: [item],
      );
    }
    // same producer: add or increment
    if (_cart.producerId == item.producerId) {
      final existingIndex = _cart.items.indexWhere(
        (i) => i.productId == item.productId,
      );
      if (existingIndex >= 0) {
        final updated = List<CartItem>.from(_cart.items);
        updated[existingIndex] = updated[existingIndex].copyWith(
          quantity: updated[existingIndex].quantity + item.quantity,
        );
        _cart = _cart.copyWith(items: updated);
      } else {
        _cart = _cart.copyWith(items: [..._cart.items, item]);
      }
    }
    // different producer: replace cart
    else {
      _cart = Cart(
        producerId: item.producerId,
        farmName: item.farmName,
        farmLocation: item.farmLocation,
        items: [item],
      );
    }
    return _cart;
  }

  Cart updateQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeItem(productId);
    final updated = _cart.items.map((i) {
      return i.productId == productId ? i.copyWith(quantity: quantity) : i;
    }).toList();
    return _cart = _cart.copyWith(items: updated);
  }

  Cart removeItem(String productId) {
    final updated = _cart.items.where((i) => i.productId != productId).toList();
    return _cart = updated.isEmpty
        ? const Cart.empty()
        : _cart.copyWith(items: updated);
  }

  Cart clear() {
    return _cart = const Cart.empty();
  }
}
