import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/fcm_token_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient apiClient;
  late MockDio dio;
  late FcmTokenRemoteDataSource dataSource;

  setUp(() {
    apiClient = MockApiClient();
    dio = MockDio();
    when(() => apiClient.dio).thenReturn(dio);
    dataSource = FcmTokenRemoteDataSource(apiClient);
  });

  test('POSTs the token to the notification-token endpoint', () async {
    when(
      () => dio.post<void>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => Response<void>(requestOptions: RequestOptions()),
    );

    await dataSource.registerToken('device-token-1');

    final captured = verify(
      () => dio.post<void>(captureAny(), data: captureAny(named: 'data')),
    ).captured;
    expect(captured[0], ApiEndpoints.notificationToken);
    expect(captured[1], {'token': 'device-token-1'});
  });
}
