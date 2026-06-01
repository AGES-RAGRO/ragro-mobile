// Use case: fetches the product list via the repository contract.

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/learning/domain/entities/product.dart';
import 'package:ragro_mobile/features/learning/domain/repositories/product_repository.dart';

@lazySingleton
class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() => _repository.getProducts();
}
