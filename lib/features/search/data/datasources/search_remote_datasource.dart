import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/search/data/models/search_result_model.dart';

@lazySingleton
class SearchRemoteDataSource {
  const SearchRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<SearchResultModel>> search({
    required String query,
    String? category,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.search,
        queryParameters: {
          'query': query,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );

      final data = response.data;
      if (data == null) throw const UnknownApiException();

      if (data is! List) throw const UnknownApiException();

      return data
          .map((e) => SearchResultModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
