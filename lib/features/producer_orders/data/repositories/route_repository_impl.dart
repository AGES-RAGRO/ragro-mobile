import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_orders/data/datasources/route_remote_datasource.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/delivery_route.dart';
import 'package:ragro_mobile/features/producer_orders/domain/repositories/route_repository.dart';

@LazySingleton(as: RouteRepository)
class RouteRepositoryImpl implements RouteRepository {
  const RouteRepositoryImpl(this._dataSource);

  final RouteRemoteDataSource _dataSource;

  @override
  Future<DeliveryRoute?> getTodayRoute() => _dataSource.getTodayRoute();
}
