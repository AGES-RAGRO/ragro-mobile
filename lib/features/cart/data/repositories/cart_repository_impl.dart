import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:ragro_mobile/features/cart/domain/entities/cart.dart';
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart';

@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._dataSource);

  final CartRemoteDataSource _dataSource;

  @override
  Future<Cart> getCart() => _dataSource.getCart();

  @override
  Future<Cart> addItem({required String productId, required double quantity}) =>
      _dataSource.addItem(productId: productId, quantity: quantity);

  @override
  Future<Cart> updateQuantity({
    required String cartItemId,
    required double quantity,
  }) => _dataSource.updateQuantity(cartItemId: cartItemId, quantity: quantity);

  @override
  Future<Cart> removeItem(String cartItemId) =>
      _dataSource.removeItem(cartItemId);

  @override
  Future<Cart> clear() => _dataSource.clear();
}
