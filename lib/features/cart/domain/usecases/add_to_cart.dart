import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@lazySingleton
class AddToCart {
  const AddToCart(this._repository);
  final CartRepository _repository;
  Cart call(CartItem item) => _repository.addItem(item);
}
