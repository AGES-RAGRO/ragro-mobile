import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/map/domain/producer_location.dart';

@injectable
class MapRepository {
  MapRepository(this._apiClient);
  final ApiClient _apiClient;

  Future<List<ProducerLocation>> getProducerLocations() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        '${ApiEndpoints.producers}/locations',
      );
      final data = response.data as List;
      return data
          .map((e) => ProducerLocation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw Exception('Failed to get producers: $e');
    }
  }
}
