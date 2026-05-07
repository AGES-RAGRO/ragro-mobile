import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';

abstract class CartRepository {
  Future<Cart> getCart();

  Future<Cart> addItem({required String productId, required double quantity});

  Future<Cart> updateQuantity({
    required String cartItemId,
    required double quantity,
  });

  Future<Cart> removeItem(String cartItemId);

  Future<Cart> clear();
}
