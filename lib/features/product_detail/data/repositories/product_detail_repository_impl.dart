import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/product_detail/data/datasources/product_detail_remote_datasource.dart';
import 'package:ragro_mobile/features/product_detail/domain/entities/product_detail.dart';
import 'package:ragro_mobile/features/product_detail/domain/repositories/product_detail_repository.dart';

@LazySingleton(as: ProductDetailRepository)
class ProductDetailRepositoryImpl implements ProductDetailRepository {
  const ProductDetailRepositoryImpl(this._dataSource);

  final ProductDetailRemoteDataSource _dataSource;

  @override
  Future<ProductDetail> getProduct(
    String productId, {
    String producerId = '',
  }) => _dataSource.getProduct(productId, producerId: producerId);
}
