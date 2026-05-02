import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@lazySingleton
class UpdateCartItemQuantity {
  const UpdateCartItemQuantity(this._repository);
  final CartRepository _repository;
  Future<Cart> call({required String cartItemId, required double quantity}) =>
      _repository.updateQuantity(cartItemId: cartItemId, quantity: quantity);
}
