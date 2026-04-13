import 'package:ragro_mobile/core/network/paginated_response.dart';
import 'package:ragro_mobile/features/home/domain/entities/home_product.dart';
import 'package:ragro_mobile/features/home/domain/entities/producer.dart';

abstract class HomeRepository {
  Future<PaginatedResponse<Producer>> getProducers({int page = 0, int size = 10});
  Future<List<HomeProduct>> getRecommendedProducts();
}
