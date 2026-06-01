// Abstract repository contract; the implementation lives in data/repositories.

import 'package:ragro_mobile/features/learning/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
}
