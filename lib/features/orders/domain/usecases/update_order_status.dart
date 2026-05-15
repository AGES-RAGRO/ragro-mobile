import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class UpdateOrderStatus {
  const UpdateOrderStatus(this._repository);

  final OrdersRepository _repository;

  Future<Order> call(String id, OrderStatus status) =>
      _repository.updateStatus(id, status);
}
