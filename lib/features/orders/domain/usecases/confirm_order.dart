import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class ConfirmOrder {
  const ConfirmOrder(this._repository);
  final OrdersRepository _repository;
  Future<Order> call([String? cartId]) => _repository.createOrderFromCart();
}
