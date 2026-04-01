import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/data/datasources/producer_orders_remote_datasource.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order_status.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart';

@LazySingleton(as: ProducerOrdersRepository)
class ProducerOrdersRepositoryImpl implements ProducerOrdersRepository {
  const ProducerOrdersRepositoryImpl(this._dataSource);

  final ProducerOrdersRemoteDataSource _dataSource;

  @override
  Future<List<ProducerOrder>> getOrders({ProducerOrderStatus? status}) =>
      _dataSource.getOrders(status: status);

  @override
  Future<ProducerOrder> getOrderById(String id) => _dataSource.getOrderById(id);

  @override
  Future<void> confirmOrder(String id) => _dataSource.confirmOrder(id);

  @override
  Future<void> refuseOrder(String id) => _dataSource.refuseOrder(id);

  @override
  Future<void> updateStatus(String id, ProducerOrderStatus status) =>
      _dataSource.updateStatus(id, status);
}
