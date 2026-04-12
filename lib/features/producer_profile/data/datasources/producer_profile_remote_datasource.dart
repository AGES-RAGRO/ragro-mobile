import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/producer_update_request.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/public_producer_model.dart';

@lazySingleton
class ProducerProfileRemoteDataSource {
  const ProducerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PublicProducerModel> getProducer(String producerId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producer(producerId),
      );
      return PublicProducerModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> updateProducer(
    String producerId,
    ProducerUpdateRequest request,
  ) async {
    try {
      await _apiClient.dio.put<void>(
        ApiEndpoints.producer(producerId),
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
