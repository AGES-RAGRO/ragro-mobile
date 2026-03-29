import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@lazySingleton
class ClearCart {
  const ClearCart(this._repository);
  final CartRepository _repository;
  Cart call() => _repository.clear();
}
