import 'package:ragro_mobile/features/product_detail/domain/entities/product_detail.dart';

abstract class ProductDetailRepository {
  Future<ProductDetail> getProduct(String productId, {String producerId = ''});
}
