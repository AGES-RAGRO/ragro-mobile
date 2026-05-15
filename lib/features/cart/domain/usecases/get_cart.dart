import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@lazySingleton
class GetCart {
  const GetCart(this._repository);
  final CartRepository _repository;
  Future<Cart> call() => _repository.getCart();
}
