import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/co2_request_model.dart';
import 'package:ragro_mobile/features/producer_orders/data/models/co2_response_model.dart';

@lazySingleton
class Co2Repository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<Co2CalculationResponse> calculateCo2(Co2CalculationRequest request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.co2Calculate,
        data: request.toJson(),
      );
      
      final data = response.data;
      if (data == null) {
        throw const UnknownApiException('Resposta vazia do servidor.');
      }
      
      return Co2CalculationResponse.fromJson(data);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
