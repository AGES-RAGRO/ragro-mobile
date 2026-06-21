import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/data/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late NotificationsLocalDataSource dataSource;

  AppNotificationModel model(String id, {bool read = false}) =>
      AppNotificationModel(
        id: id,
        title: 'T$id',
        message: 'M$id',
        read: read,
        createdAt: DateTime(2026, 6, 18, 10),
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = NotificationsLocalDataSource(prefs);
  });

  test('round-trips a cached list', () async {
    await dataSource.cacheNotifications([model('1'), model('2', read: true)]);

    final cached = dataSource.getCachedNotifications();
    expect(cached, hasLength(2));
    expect(cached[0].id, '1');
    expect(cached[0].read, isFalse);
    expect(cached[1].read, isTrue);
    expect(cached[0].createdAt, DateTime(2026, 6, 18, 10));
  });

  test('empty cache returns []', () {
    expect(dataSource.getCachedNotifications(), isEmpty);
    expect(dataSource.getCachedUnreadCount(), 0);
  });

  test('markCachedAsRead flips the flag and decrements the count', () async {
    await dataSource.cacheNotifications([model('1'), model('2')]);
    await dataSource.cacheUnreadCount(2);

    await dataSource.markCachedAsRead('1');

    final cached = dataSource.getCachedNotifications();
    expect(cached.firstWhere((n) => n.id == '1').read, isTrue);
    expect(cached.firstWhere((n) => n.id == '2').read, isFalse);
    expect(dataSource.getCachedUnreadCount(), 1);
  });

  test('markAllCachedAsRead flips all and zeroes the count', () async {
    await dataSource.cacheNotifications([model('1'), model('2')]);
    await dataSource.cacheUnreadCount(2);

    await dataSource.markAllCachedAsRead();

    expect(
      dataSource.getCachedNotifications().every((n) => n.read),
      isTrue,
    );
    expect(dataSource.getCachedUnreadCount(), 0);
  });

  test('clear wipes cache and count', () async {
    await dataSource.cacheNotifications([model('1')]);
    await dataSource.cacheUnreadCount(1);

    await dataSource.clear();

    expect(dataSource.getCachedNotifications(), isEmpty);
    expect(dataSource.getCachedUnreadCount(), 0);
  });
}
