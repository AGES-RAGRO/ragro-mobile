import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/admin/data/models/admin_producer_model.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';

@lazySingleton
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<AdminProducer>> getProducers() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        ApiEndpoints.adminProducers,
      );
      return (response.data ?? [])
          .map((e) => AdminProducerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> createProducer(AdminProducer producer, String password) async {
    final address = producer.producerAddress;
    if (address == null) {
      throw const UnknownApiException('Endereço obrigatório para cadastro');
    }
    try {
      await _apiClient.dio.post<void>(
        ApiEndpoints.adminProducers,
        data: {
          'name': producer.name,
          'email': producer.email,
          'phone': producer.phone,
          'password': password,
          'fiscalNumber': producer.fiscalNumber,
          'fiscalNumberType': producer.fiscalNumberType,
          'farmName': producer.farmName,
          'address': address.toJson(),
          if (producer.bankAccount != null)
            'bankAccount': producer.bankAccount!.toJson(),
          if (producer.availability != null &&
              producer.availability!.isNotEmpty)
            'availability': producer.availability!
                .map((a) => a.toJson())
                .toList(),
        },
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> deactivateProducer(String id) async {
    try {
      await _apiClient.dio.patch<void>(
        '${ApiEndpoints.adminProducer(id)}/deactivate',
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<void> activateProducer(String id) async {
    try {
      await _apiClient.dio.patch<void>(
        '${ApiEndpoints.adminProducer(id)}/activate',
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
