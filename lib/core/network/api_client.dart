// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'api_exception.dart';

@lazySingleton
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_ErrorInterceptor());
  }

  late final Dio _dio;
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
    final exception = switch (err.response?.statusCode) {
      401 => const UnauthorizedException(),
      404 => const NotFoundException(),
      409 => const ConflictException(),
      429 => const RateLimitedException(),
      >= 500 => const ServerException(),
      _ => err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.receiveTimeout
          ? const TimeoutException()
          : err.type == DioExceptionType.connectionError
              ? const NetworkException()
              : const UnknownApiException(),
    };
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        message: exception.message,
      ),
    );
  }
}
