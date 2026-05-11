import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetRecommendedProducts {
  const GetRecommendedProducts(this._repository);

  final HomeRepository _repository;

  Future<({List<HomeProduct> products, bool hasMore})> call({
    int producerPage = 0,
  }) => _repository.getRecommendedProducts(producerPage: producerPage);
}
