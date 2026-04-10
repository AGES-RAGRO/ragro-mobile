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

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final ApiException exception;
    if (statusCode != null) {
      exception = switch (statusCode) {
        401 => const UnauthorizedException(),
        404 => const NotFoundException(),
        409 => const ConflictException(),
        429 => const RateLimitedException(),
        403 => const ForbiddenException(),
        >= 500 => const ServerException(),
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
