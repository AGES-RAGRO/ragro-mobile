import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:ragro_mobile/features/notifications/data/models/notification_model.dart';
import 'package:ragro_mobile/features/notifications/data/repositories/notifications_repository_impl.dart';

class MockRemote extends Mock implements NotificationsRemoteDataSource {}

class MockLocal extends Mock implements NotificationsLocalDataSource {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late NotificationsRepositoryImpl repo;

  final tList = [
    AppNotificationModel(
      id: '1',
      title: 'T',
      message: 'M',
      read: false,
      createdAt: DateTime(2026, 6, 18),
    ),
  ];

  setUpAll(() => registerFallbackValue(<AppNotificationModel>[]));

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    repo = NotificationsRepositoryImpl(remote, local);
  });

  group('getNotifications', () {
    test('remote success caches and returns remote', () async {
      when(remote.getNotifications).thenAnswer((_) async => tList);
      when(() => local.cacheNotifications(any())).thenAnswer((_) async {});

      final result = await repo.getNotifications();

      expect(result, tList);
      verify(() => local.cacheNotifications(tList)).called(1);
    });

    test('remote failure falls back to cached list', () async {
      when(remote.getNotifications).thenThrow(const ServerException());
      when(local.getCachedNotifications).thenReturn(tList);

      final result = await repo.getNotifications();

      expect(result, tList);
    });

    test('remote failure with empty cache rethrows', () async {
      when(remote.getNotifications).thenThrow(const ServerException());
      when(local.getCachedNotifications).thenReturn(const []);

      expect(repo.getNotifications(), throwsA(isA<ServerException>()));
    });
  });

  group('getUnreadCount', () {
    test('remote success caches and returns', () async {
      when(remote.getUnreadCount).thenAnswer((_) async => 4);
      when(() => local.cacheUnreadCount(any())).thenAnswer((_) async {});

      expect(await repo.getUnreadCount(), 4);
      verify(() => local.cacheUnreadCount(4)).called(1);
    });

    test('remote failure returns cached count', () async {
      when(remote.getUnreadCount).thenThrow(const ServerException());
      when(local.getCachedUnreadCount).thenReturn(2);

      expect(await repo.getUnreadCount(), 2);
    });
  });

  test('markAsRead hits remote then local', () async {
    when(() => remote.markAsRead(any())).thenAnswer((_) async {});
    when(() => local.markCachedAsRead(any())).thenAnswer((_) async {});

    await repo.markAsRead('1');

    verify(() => remote.markAsRead('1')).called(1);
    verify(() => local.markCachedAsRead('1')).called(1);
  });

  test('markAllAsRead hits remote then local', () async {
    when(remote.markAllAsRead).thenAnswer((_) async {});
    when(local.markAllCachedAsRead).thenAnswer((_) async {});

    await repo.markAllAsRead();

    verify(remote.markAllAsRead).called(1);
    verify(local.markAllCachedAsRead).called(1);
  });
}
