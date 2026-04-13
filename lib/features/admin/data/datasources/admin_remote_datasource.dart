import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/admin/data/models/admin_producer_model.dart';
import 'package:ragro_mobile/features/admin/data/models/admin_producer_summary_model.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer_summary.dart';

@lazySingleton
class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<AdminProducerSummary>> getProducers() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.adminProducers,
      );
      final content = (response.data!['content'] as List<dynamic>);
      return content
          .map((e) => AdminProducerSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<AdminProducer> getProducerById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.adminProducer(id),
      );
      return AdminProducerModel.fromJson(response.data!);
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
            'paymentMethod': {
              'type': 'bank_account',
              ...producer.bankAccount!.toJson(),
            },
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

  Future<void> updateProducer(AdminProducer producer) async {
    try {
      final address = producer.producerAddress;
      await _apiClient.dio.put<void>(
        ApiEndpoints.adminProducer(producer.id),
        data: {
          'name': producer.name,
          'phone': producer.phone,
          'farmName': producer.farmName,
          if (address != null) 'address': address.toJson(),
          if (producer.bankAccount != null)
            'paymentMethod': {
              'type': 'bank_account',
              ...producer.bankAccount!.toJson(),
            },
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
