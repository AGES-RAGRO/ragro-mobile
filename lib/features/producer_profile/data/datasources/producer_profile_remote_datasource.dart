import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/public_producer_model.dart';

@lazySingleton
class ProducerProfileRemoteDataSource {
  const ProducerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Gets public producer profile by [producerId].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<PublicProducerModel> getProducer(String producerId) async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.producer(producerId),
  ///     );
  ///     return PublicProducerModel.fromJson(response.data!);
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<PublicProducerModel> getProducer(String producerId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return PublicProducerModel.mock(producerId);
  }
}
