import 'package:injectable/injectable.dart' hide Order;
import 'package:ragro_mobile/features/orders/domain/entities/order.dart';
import 'package:ragro_mobile/features/orders/domain/entities/order_status.dart';
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart';

@lazySingleton
class GetOrders {
  const GetOrders(this._repository);
  final OrdersRepository _repository;
  Future<List<Order>> call({OrderStatus? status}) =>
      _repository.getOrders(status: status);
}
