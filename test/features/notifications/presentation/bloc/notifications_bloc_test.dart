import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/notifications/domain/entities/notification.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/get_notifications.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/get_unread_notifications_count.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:ragro_mobile/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';

class MockGetNotifications extends Mock implements GetNotifications {}

class MockGetUnreadNotificationsCount extends Mock
    implements GetUnreadNotificationsCount {}

class MockMarkAllNotificationsAsRead extends Mock
    implements MarkAllNotificationsAsRead {}

class MockMarkNotificationAsRead extends Mock
    implements MarkNotificationAsRead {}

void main() {
  late MockGetNotifications getNotifications;
  late MockGetUnreadNotificationsCount getUnreadCount;
  late MockMarkAllNotificationsAsRead markAll;
  late MockMarkNotificationAsRead markOne;

  NotificationsBloc buildBloc() =>
      NotificationsBloc(getNotifications, getUnreadCount, markAll, markOne);

  AppNotificationEntity notification({
    required String id,
    bool read = false,
  }) => AppNotificationEntity(
    id: id,
    title: 'Pedido $id',
    message: 'mensagem $id',
    read: read,
    createdAt: DateTime(2026),
  );

  setUp(() {
    getNotifications = MockGetNotifications();
    getUnreadCount = MockGetUnreadNotificationsCount();
    markAll = MockMarkAllNotificationsAsRead();
    markOne = MockMarkNotificationAsRead();
  });

  group('NotificationsStarted', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'emits [Loading, Loaded] with notifications and unread count',
      setUp: () {
        when(getNotifications.call).thenAnswer(
          (_) async => [notification(id: '1'), notification(id: '2', read: true)],
        );
        when(getUnreadCount.call).thenAnswer((_) async => 1);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const NotificationsStarted()),
      expect: () => [
        const NotificationsLoading(),
        isA<NotificationsLoaded>()
            .having((s) => s.notifications.length, 'count', 2)
            .having((s) => s.unreadCount, 'unreadCount', 1),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [Loading, Failure] when loading fails',
      setUp: () {
        when(getNotifications.call).thenThrow(const ServerException());
        when(getUnreadCount.call).thenAnswer((_) async => 0);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const NotificationsStarted()),
      expect: () => [
        const NotificationsLoading(),
        isA<NotificationsFailure>(),
      ],
    );
  });

  blocTest<NotificationsBloc, NotificationsState>(
    'NotificationsUnreadCountRequested emits Loaded with the count',
    setUp: () => when(getUnreadCount.call).thenAnswer((_) async => 5),
    build: buildBloc,
    act: (bloc) => bloc.add(const NotificationsUnreadCountRequested()),
    expect: () => [
      isA<NotificationsLoaded>().having((s) => s.unreadCount, 'unreadCount', 5),
    ],
    verify: (_) => verify(getUnreadCount.call).called(1),
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'NotificationMarkedAsRead flips read flag and decrements unread count',
    setUp: () {
      when(getNotifications.call).thenAnswer((_) async => [notification(id: '1')]);
      when(getUnreadCount.call).thenAnswer((_) async => 1);
      when(() => markOne('1')).thenAnswer((_) async {});
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const NotificationsStarted());
      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);
      bloc.add(const NotificationMarkedAsRead('1'));
    },
    expect: () => [
      const NotificationsLoading(),
      isA<NotificationsLoaded>().having((s) => s.unreadCount, 'unreadCount', 1),
      isA<NotificationsLoaded>()
          .having((s) => s.unreadCount, 'unreadCount', 0)
          .having((s) => s.notifications.first.read, 'read', true),
    ],
    verify: (_) => verify(() => markOne('1')).called(1),
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'NotificationsAllMarkedAsRead marks all read and zeroes the count',
    setUp: () {
      when(getNotifications.call).thenAnswer(
        (_) async => [notification(id: '1'), notification(id: '2')],
      );
      when(getUnreadCount.call).thenAnswer((_) async => 2);
      when(markAll.call).thenAnswer((_) async {});
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const NotificationsStarted());
      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);
      bloc.add(const NotificationsAllMarkedAsRead());
    },
    expect: () => [
      const NotificationsLoading(),
      isA<NotificationsLoaded>().having((s) => s.unreadCount, 'unreadCount', 2),
      isA<NotificationsLoaded>()
          .having((s) => s.unreadCount, 'unreadCount', 0)
          .having(
            (s) => s.notifications.every((n) => n.read),
            'all read',
            true,
          ),
    ],
    verify: (_) => verify(markAll.call).called(1),
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'NotificationsReset clears state back to initial (logout)',
    setUp: () {
      when(getUnreadCount.call).thenAnswer((_) async => 5);
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const NotificationsUnreadCountRequested());
      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);
      bloc.add(const NotificationsReset());
    },
    expect: () => [
      isA<NotificationsLoaded>().having((s) => s.unreadCount, 'unreadCount', 5),
      const NotificationsInitial(),
    ],
  );
}
