import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/core/utils/multipart_file_builder.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/producer_update_request.dart';
import 'package:ragro_mobile/features/producer_profile/data/models/public_producer_model.dart';

@lazySingleton
class ProducerProfileRemoteDataSource {
  const ProducerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // Public profile endpoint for customers to view producer details
  // GET /producers/{id}/profile - requires @PreAuthorize("hasRole('CUSTOMER')")
  Future<PublicProducerModel> getProducer(String producerId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.producerPublicProfile(producerId),
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

  Future<PublicProducerModel> uploadAvatar(
    String producerId,
    XFile file,
  ) async {
    return _uploadPhoto(ApiEndpoints.producerAvatar(producerId), file);
  }

  Future<PublicProducerModel> uploadCover(String producerId, XFile file) async {
    return _uploadPhoto(ApiEndpoints.producerCover(producerId), file);
  }

  Future<PublicProducerModel> _uploadPhoto(String url, XFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await multipartFromXFile(file),
      });
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        url,
        data: formData,
      );
      return PublicProducerModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
