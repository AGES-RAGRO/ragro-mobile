// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';

@lazySingleton
class ApiClient {
  ApiClient(this._dio) {
    _dio.options
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..sendTimeout = const Duration(seconds: 10)
      ..headers = {'Content-Type': 'application/json'};
    _dio.interceptors.add(_ErrorInterceptor());
  }

  final Dio _dio;
  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Backend retorna 401 em dois cenários distintos:
///   1. Credenciais inválidas (Keycloak / invalid_grant)
///   2. Usuário autenticado porém com `active=false` no banco,
///      via `FarmerAuthInterceptor` — body:
///      `{"error": "Produtor inativo", ...}`
/// Diferenciamos inspecionando o campo `error` da resposta.
ApiException _map401(dynamic data) {
  if (data is Map && data['error'] is String) {
    final error = (data['error'] as String).toLowerCase();
    if (error.contains('inativo') || error.contains('desativad')) {
      return const DeactivatedAccountException();
    }
  }
  return const UnauthorizedException();
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    final responseMessage = responseData is Map<String, dynamic>
        ? responseData['error'] as String?
        : null;
    final ApiException exception;
    if (statusCode != null) {
      exception = switch (statusCode) {
        400 => UnknownApiException(responseMessage ?? 'Dados invalidos'),
        401 => _map401(err.response?.data),
        403 => ForbiddenException(responseMessage ?? 'Sem permissao para esta acao'),
        404 => NotFoundException(responseMessage ?? 'Recurso nao encontrado'),
        409 => ConflictException(responseMessage ?? 'Recurso ja existe'),
        429 => const RateLimitedException(),
        >= 500 => ServerException(
          responseMessage ?? 'Erro interno do servidor',
        ),
        _ => const UnknownApiException(),
      };
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      exception = const ApiTimeoutException();
    } else if (err.type == DioExceptionType.connectionError) {
      exception = const NetworkException();
    } else {
      exception = const UnknownApiException();
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        message: exception.message,
      ),
    );
  }
}
