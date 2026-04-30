import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/product_detail/domain/entities/product_detail.dart';
import 'package:ragro_mobile/features/product_detail/domain/repositories/product_detail_repository.dart';

@lazySingleton
class GetProductDetail {
  const GetProductDetail(this._repository);

  final ProductDetailRepository _repository;

  Future<ProductDetail> call(String productId, {String producerId = ''}) =>
      _repository.getProduct(productId, producerId: producerId);
}
