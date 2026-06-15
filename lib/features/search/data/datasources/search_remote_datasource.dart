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
  double? minRating,
  String? sortBy,
}) async {
  try {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.producers,
      queryParameters: {
        if (query.isNotEmpty) 'query': query,
        if (minRating != null) 'minRating': minRating,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      },
    );

    final data = response.data;
    if (data == null) throw const UnknownApiException();

    final list = data is List ? data : (data['content'] as List);

    return list
        .map((e) => SearchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw e.error as ApiException? ?? const UnknownApiException();
  }
}

  // Future<List<SearchResultModel>> search({
  //   required String query,
  //   String? category,
  // }) async {
  //   await Future<void>.delayed(const Duration(milliseconds: 500));
  //   return SearchResultModel.mocks(query);
  // }
}
