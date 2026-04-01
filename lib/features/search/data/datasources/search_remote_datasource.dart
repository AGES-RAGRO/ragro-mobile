import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/features/search/data/models/search_result_model.dart';

@lazySingleton
class SearchRemoteDataSource {
  const SearchRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Searches for producers and products matching [query] and optional [category].
  ///
  /// === REAL IMPLEMENTATION (uncomment when backend is ready) ===
  ///
  /// Future<List<SearchResultModel>> search({
  ///   required String query,
  ///   String? category,
  /// }) async {
  ///   try {
  ///     final response = await _apiClient.dio.get<Map<String, dynamic>>(
  ///       ApiEndpoints.producers,
  ///       queryParameters: {
  ///         'search': query,
  ///         if (category != null) 'category': category,
  ///       },
  ///     );
  ///     return (response.data!['data'] as List)
  ///         .map((e) => SearchResultModel.fromJson(e as Map<String, dynamic>))
  ///         .toList();
  ///   } on DioException catch (e) {
  ///     throw e.error as ApiException? ?? const UnknownApiException();
  ///   }
  /// }
  ///
  /// === END REAL IMPLEMENTATION ===
  ///
  /// MOCK TEMPORÁRIO — remover quando backend estiver conectado:
  Future<List<SearchResultModel>> search({required String query, String? category}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return SearchResultModel.mocks(query);
  }
}
