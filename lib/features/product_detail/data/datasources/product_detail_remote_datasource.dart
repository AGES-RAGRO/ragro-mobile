import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/product_detail/data/models/product_detail_model.dart';

@lazySingleton
class ProductDetailRemoteDataSource {
  const ProductDetailRemoteDataSource();

  /// Gets product detail by [productId].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future`<ProductDetailModel>` getProduct(String productId) async {
  ///   try {
  ///     final response = await _apiClient.dio.get`<Map<String, dynamic>>`(
  ///       ApiEndpoints.product(productId),
  ///     );
  ///     return ProductDetailModel.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<ProductDetailModel> getProduct(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const ProductDetailModel.mock();
  }
}
