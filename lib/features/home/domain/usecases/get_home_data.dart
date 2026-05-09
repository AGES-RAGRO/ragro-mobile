import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/paginated_response.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetHomeData {
  const GetHomeData(this._repository);

  final HomeRepository _repository;

  Future<({
    PaginatedResponse<Producer> producers,
    List<HomeProduct> products,
    bool hasMoreProducts,
  })>
  call() async {
    final (producersResponse, productsResult) = await (
      _repository.getProducers(),
      _repository.getRecommendedProducts(),
    ).wait;

    return (
      producers: producersResponse,
      products: productsResult.products,
      hasMoreProducts: productsResult.hasMore,
    );
  }
}
