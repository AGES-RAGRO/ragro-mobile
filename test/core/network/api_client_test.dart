import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';

class _MockAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late _MockAdapter adapter;
  late ApiClient apiClient;
  late List<RequestOptions> captured;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    captured = [];
    adapter = _MockAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    apiClient = ApiClient(dio);

    when(() => adapter.fetch(any(), any(), any())).thenAnswer((invocation) async {
      captured.add(invocation.positionalArguments[0] as RequestOptions);
      return ResponseBody.fromString(
        '{}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
  });

  String? authHeaderOf(RequestOptions options) {
    final value = options.headers['Authorization'];
    return value as String?;
  }

  group('ApiClient auth interceptor', () {
    test('attaches Bearer token to protected endpoints when set', () async {
      apiClient.setAuthToken('abc123');

      await apiClient.dio.get<dynamic>(ApiEndpoints.customerMe);

      expect(captured, hasLength(1));
      expect(authHeaderOf(captured.single), 'Bearer abc123');
    });

    test('does NOT attach token to public auth endpoints', () async {
      apiClient.setAuthToken('abc123');

      await apiClient.dio.get<dynamic>(ApiEndpoints.authConfig);
      await apiClient.dio.post<dynamic>(ApiEndpoints.registerCustomer, data: {});
      await apiClient.dio.post<dynamic>(ApiEndpoints.forgotPassword, data: {});

      expect(captured, hasLength(3));
      for (final options in captured) {
        expect(
          authHeaderOf(options),
          isNull,
          reason: '${options.uri.path} must not carry Authorization',
        );
      }
    });

    test('sends no Authorization on protected endpoints after clear', () async {
      apiClient
        ..setAuthToken('abc123')
        ..clearAuthToken();

      await apiClient.dio.get<dynamic>(ApiEndpoints.customerMe);

      expect(authHeaderOf(captured.single), isNull);
    });

    test('sends no Authorization when no token was ever set', () async {
      await apiClient.dio.get<dynamic>(ApiEndpoints.customerMe);

      expect(authHeaderOf(captured.single), isNull);
    });
  });
}
