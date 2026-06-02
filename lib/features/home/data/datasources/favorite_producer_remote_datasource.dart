import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/home/data/models/favorite_producer_model.dart';
import 'package:ragro_mobile/features/home/domain/entities/favorite_producer.dart';
import 'package:ragro_mobile/features/home/domain/repositories/favorite_producer_repository.dart';

@LazySingleton(as: FavoriteProducerRepository)
class FavoriteProducerRemoteDataSource implements FavoriteProducerRepository {
  const FavoriteProducerRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<FavoriteProducer>> getFavorites() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        ApiEndpoints.customerFavorites,
      );
      return (response.data ?? [])
          .map((e) => FavoriteProducerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  @override
  Future<void> favoriteProducer(String producerId) async {
    try {
      await _apiClient.dio.post<void>(
        ApiEndpoints.customerFavorite(producerId),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  @override
  Future<void> unfavoriteProducer(String producerId) async {
    try {
      await _apiClient.dio.delete<void>(
        ApiEndpoints.customerFavorite(producerId),
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
