// DATA/REPOSITORIES — A "cozinha real" que implementa o contrato.
// O domain/ define O QUE pode ser feito (ProductRepository abstrato).
// Este arquivo define COMO é feito (delega pro DataSource).
//
// @LazySingleton(as: ProductRepository): registra esta classe como a implementação
// de ProductRepository. Quando alguém pedir getIt<ProductRepository>(), recebe esta classe.

import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/learning/data/datasources/product_mock_datasource.dart';
import 'package:ragro_mobile/features/learning/domain/entities/product.dart';
import 'package:ragro_mobile/features/learning/domain/repositories/product_repository.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._dataSource);

  final ProductMockDataSource _dataSource;

  @override
  Future<List<Product>> getProducts() => _dataSource.getProducts();
}
