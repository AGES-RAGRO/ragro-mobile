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

  Future<List<SearchResultModel>> getProductsByCategory({
    required String category,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.recommendations,
        queryParameters: {
          if (category.isNotEmpty) 'category': category,
          'limit': 6,
        },
      );

      final data = response.data;
      if (data == null) throw const UnknownApiException();

      List<Map<String, dynamic>> readList(dynamic d) {
        if (d is List<dynamic>)
          return d.whereType<Map<String, dynamic>>().toList();
        if (d is Map<String, dynamic>) {
          for (final key in const [
            'data',
            'content',
            'items',
            'recommendations',
            'recommendedProducts',
            'result',
            'list',
          ]) {
            if (d[key] is List<dynamic>) {
              return (d[key] as List<dynamic>)
                  .whereType<Map<String, dynamic>>()
                  .toList();
            }
          }
        }
        return const [];
      }

      final list = readList(data);
      if (list.isEmpty) return const [];

      return list.map((e) {
        final map = Map<String, dynamic>.from(e);

        // Normalize to the shape expected by SearchResultModel
        map['type'] = 'product';

        // image handling: recommendation items use 'imageS3'
        if (map['imageS3'] is String && (map['imageS3'] as String).isNotEmpty) {
          map['image_url'] = ApiEndpoints.resolveMediaUrl(
            map['imageS3'] as String,
          );
        } else if (map['image_url'] is String &&
            (map['image_url'] as String).isNotEmpty) {
          map['image_url'] = ApiEndpoints.resolveMediaUrl(
            map['image_url'] as String,
          );
        } else {
          map['image_url'] = '';
        }

        // farm/farmer -> subtitle/producerId
        if (map['farmName'] is String && map['subtitle'] == null) {
          map['subtitle'] = map['farmName'];
        }
        if (map['farmerId'] is String && map['producerId'] == null) {
          map['producerId'] = map['farmerId'];
        }

        // unity/unit
        if (map['unityType'] is String && map['unit'] == null) {
          map['unit'] = map['unityType'];
        }

        // categories -> category (pick first)
        if (map['categoryNames'] is List &&
            (map['categoryNames'] as List).isNotEmpty) {
          final firstName = (map['categoryNames'] as List)
              .whereType<String>()
              .firstOrNull;
          if (firstName != null) map['category'] = firstName;
        }

        return SearchResultModel.fromJson(map);
      }).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
