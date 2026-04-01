import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  Cart getCart();
  Cart addItem(CartItem item);
  Cart updateQuantity(String productId, int quantity);
  Cart removeItem(String productId);
  Cart clear();
}
