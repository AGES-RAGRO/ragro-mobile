import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/notifications_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

Response<dynamic> _response(dynamic data) =>
    Response<dynamic>(requestOptions: RequestOptions(), data: data);

DioException _notFound() => DioException(
  requestOptions: RequestOptions(),
  error: const NotFoundException(),
);

void main() {
  late MockApiClient apiClient;
  late MockDio dio;
  late MockAuthLocalDataSource authLocal;
  late NotificationsRemoteDataSource dataSource;

  setUp(() {
    apiClient = MockApiClient();
    dio = MockDio();
    authLocal = MockAuthLocalDataSource();
    when(() => apiClient.dio).thenReturn(dio);
    dataSource = NotificationsRemoteDataSource(apiClient, authLocal);
  });

  group('role-aware path selection', () {
    test('customer list hits the customer base path', () async {
      when(authLocal.getUserType).thenReturn('customer');
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _response({'content': <dynamic>[]}));

      await dataSource.getNotifications();

      final path =
          verify(() => dio.get<dynamic>(captureAny())).captured.single;
      expect(path, ApiEndpoints.customerNotifications);
    });

    test('producer list hits the producer base path', () async {
      when(authLocal.getUserType).thenReturn('producer');
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _response({'content': <dynamic>[]}));

      await dataSource.getNotifications();

      final path =
          verify(() => dio.get<dynamic>(captureAny())).captured.single;
      expect(path, ApiEndpoints.producerNotifications);
    });

    test('producer unread-count hits the producer unread-count path', () async {
      when(authLocal.getUserType).thenReturn('producer');
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _response({'count': 3}));

      final count = await dataSource.getUnreadCount();

      expect(count, 3);
      final path =
          verify(() => dio.get<dynamic>(captureAny())).captured.single;
      expect(path, ApiEndpoints.producerNotificationsUnreadCount);
    });

    test('producer mark-as-read PATCHes the producer read path', () async {
      when(authLocal.getUserType).thenReturn('producer');
      when(() => dio.patch<void>(any())).thenAnswer(
        (_) async => Response<void>(requestOptions: RequestOptions()),
      );

      await dataSource.markAsRead('abc');

      final path =
          verify(() => dio.patch<void>(captureAny())).captured.single;
      expect(path, ApiEndpoints.producerNotificationRead('abc'));
    });

    test('producer mark-all PATCHes the producer read-all path', () async {
      when(authLocal.getUserType).thenReturn('producer');
      when(() => dio.patch<void>(any())).thenAnswer(
        (_) async => Response<void>(requestOptions: RequestOptions()),
      );

      await dataSource.markAllAsRead();

      final path =
          verify(() => dio.patch<void>(captureAny())).captured.single;
      expect(path, ApiEndpoints.producerNotificationsReadAll);
    });

    test('unknown/null role falls back to the customer path', () async {
      when(authLocal.getUserType).thenReturn(null);
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _response({'content': <dynamic>[]}));

      await dataSource.getNotifications();

      final path =
          verify(() => dio.get<dynamic>(captureAny())).captured.single;
      expect(path, ApiEndpoints.customerNotifications);
    });
  });

  group('parsing and 404 handling', () {
    setUp(() => when(authLocal.getUserType).thenReturn('customer'));

    test('parses the PaginatedResponse content array', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _response({
          'content': [
            {
              'id': '1',
              'title': 'T',
              'message': 'M',
              'read': false,
              'createdAt': '2026-01-01T10:00:00Z',
            },
          ],
        }),
      );

      final result = await dataSource.getNotifications();

      expect(result, hasLength(1));
      expect(result.first.id, '1');
      expect(result.first.read, isFalse);
    });

    test('list returns empty on 404', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(_notFound());

      expect(await dataSource.getNotifications(), isEmpty);
    });

    test('unread-count reads the {count} object', () async {
      when(() => dio.get<dynamic>(any()))
          .thenAnswer((_) async => _response({'count': 7}));

      expect(await dataSource.getUnreadCount(), 7);
    });

    test('unread-count returns 0 on 404', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(_notFound());

      expect(await dataSource.getUnreadCount(), 0);
    });
  });
}
