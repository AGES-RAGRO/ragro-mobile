import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/paginated_response.dart';
import 'package:ragro_mobile/features/home/data/datasources/home_remote_datasource.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._dataSource);

  final HomeRemoteDataSource _dataSource;

  @override
  Future<PaginatedResponse<Producer>> getProducers({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dataSource.getProducers(page: page, size: size);
    return response.map((model) => model as Producer);
  }

  @override
  Future<({List<HomeProduct> products, bool hasMore})> getRecommendedProducts({
    int producerPage = 0,
  }) async {
    final result = await _dataSource.getRecommendedProducts(
      producerPage: producerPage,
    );
    return (
      products: result.products.cast<HomeProduct>(),
      hasMore: result.hasMore,
    );
  }
}
