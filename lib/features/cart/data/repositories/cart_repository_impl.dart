import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart_item.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._datasource);
  final CartLocalDatasource _datasource;

  @override
  Cart getCart() => _datasource.getCart();

  @override
  Cart addItem(CartItem item) => _datasource.addItem(item);

  @override
  Cart updateQuantity(String productId, int quantity) =>
      _datasource.updateQuantity(productId, quantity);

  @override
  Cart removeItem(String productId) => _datasource.removeItem(productId);

  @override
  Cart clear() => _datasource.clear();
}
