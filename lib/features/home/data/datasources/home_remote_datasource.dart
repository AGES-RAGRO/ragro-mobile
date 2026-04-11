import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/features/home/data/models/home_product_model.dart';
import 'package:ragro_mobile/features/home/data/models/producer_model.dart';

@lazySingleton
class HomeRemoteDataSource {
  const HomeRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Gets list of active producers for the home screen.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<List<ProducerModel>> getProducers({int page = 1, int limit = 10}) async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.producers,
  ///       queryParameters: {'page': page, 'limit': limit, 'active': true},
  ///     );
  ///     return (response.data!['data'] as List)
  ///         .map((e) => ProducerModel.fromJson(e as Map<String, dynamic>))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<ProducerModel>> getProducers({
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.generate(4, ProducerModel.mock);
  }

  /// Gets recommended products for the home screen.
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<List<HomeProductModel>> getRecommendedProducts() async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.recommendations,
  ///     );
  ///     return (response.data!['data'] as List)
  ///         .map((e) => HomeProductModel.fromJson(e as Map<String, dynamic>))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<HomeProductModel>> getRecommendedProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return HomeProductModel.mocks();
  }
}
