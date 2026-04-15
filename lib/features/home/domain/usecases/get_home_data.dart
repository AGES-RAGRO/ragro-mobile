import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/paginated_response.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';
import 'package:ragro_mobile/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetHomeData {
  const GetHomeData(this._repository);

  final HomeRepository _repository;

  Future<({List<Producer> producers, List<HomeProduct> products})>
  call() async {
    final results = await Future.wait([
      _repository.getProducers(),
      _repository.getRecommendedProducts(),
    ]);

    final producersResponse = results[0] as PaginatedResponse<Producer>;
    final products = results[1] as List<HomeProduct>;

    return (producers: producersResponse.content, products: products);
  }
}
