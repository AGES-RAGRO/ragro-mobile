import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/home/data/datasources/home_remote_datasource.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._dataSource);

  final HomeRemoteDataSource _dataSource;

  @override
  Future<List<Producer>> getProducers({int page = 1, int limit = 10}) =>
      _dataSource.getProducers(page: page, limit: limit);

  @override
  Future<List<HomeProduct>> getRecommendedProducts() =>
      _dataSource.getRecommendedProducts();
}
