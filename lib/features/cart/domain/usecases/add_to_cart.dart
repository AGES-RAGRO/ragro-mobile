import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@lazySingleton
class AddToCart {
  const AddToCart(this._repository);
  final CartRepository _repository;
  Future<Cart> call({required String productId, required double quantity}) =>
      _repository.addItem(productId: productId, quantity: quantity);
}
