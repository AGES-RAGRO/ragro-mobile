import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@lazySingleton
class RemoveFromCart {
  const RemoveFromCart(this._repository);
  final CartRepository _repository;
  Cart call(String productId) => _repository.removeItem(productId);
}
