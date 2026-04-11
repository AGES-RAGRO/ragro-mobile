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

String? _errorFieldFromResponse(Response<dynamic>? response) {
  final data = response?.data;
  if (data is Map<String, dynamic>) {
    final err = data['error'];
    if (err is String) return err;
  }
  return null;
}

ConflictException _conflictExceptionFromBody(String? errorField) {
  final lower = (errorField ?? '').toLowerCase();
  if (lower.contains('email')) {
    return const ConflictException('Este e-mail já está em uso.');
  }
  if (lower.contains('cpf') || lower.contains('fiscal')) {
    return const ConflictException('Este CPF já está cadastrado.');
  }
  return const ConflictException('E-mail ou CPF já cadastrado.');
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final ApiException exception;
    if (statusCode != null) {
      if (statusCode == 400) {
        final raw = _errorFieldFromResponse(err.response);
        exception = UnknownApiException(
          raw ?? 'Dados inválidos. Revise o formulário.',
        );
      } else if (statusCode == 409) {
        exception = _conflictExceptionFromBody(
          _errorFieldFromResponse(err.response),
        );
      } else {
        exception = switch (statusCode) {
          401 => const UnauthorizedException(),
          404 => const NotFoundException(),
          429 => const RateLimitedException(),
          >= 500 => const ServerException(),
          _ => const UnknownApiException(),
        };
      }
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
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }
}
