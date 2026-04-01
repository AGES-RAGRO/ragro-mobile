import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';

abstract class HomeRepository {
  Future<List<Producer>> getProducers({int page = 1, int limit = 10});
  Future<List<HomeProduct>> getRecommendedProducts();
}
