// Implements the ProductRepository contract by delegating to the data source.

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
