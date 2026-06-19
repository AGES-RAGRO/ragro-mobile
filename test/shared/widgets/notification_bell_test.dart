import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:ragro_mobile/shared/widgets/notification_bell.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockNotificationsBloc bloc;
  late MockAuthLocalDataSource authLocal;

  setUp(() {
    bloc = MockNotificationsBloc();
    authLocal = MockAuthLocalDataSource();
    when(() => authLocal.getUserType()).thenReturn('customer');
    if (getIt.isRegistered<AuthLocalDataSource>()) {
      getIt.unregister<AuthLocalDataSource>();
    }
    getIt.registerSingleton<AuthLocalDataSource>(authLocal);
  });

  tearDown(getIt.reset);

  Widget harness() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            appBar: AppBar(actions: const [NotificationBell()]),
            body: const Text('HOME'),
          ),
        ),
        GoRoute(
          path: '/customer/notifications',
          builder: (context, __) => Scaffold(
            body: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: const Text('NOTIF PAGE'),
              ),
            ),
          ),
        ),
      ],
    );
    return BlocProvider<NotificationsBloc>.value(
      value: bloc,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders the unread badge from bloc state', (tester) async {
    whenListen(
      bloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsLoaded([], unreadCount: 3),
    );

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('tap pushes notifications and back returns to origin', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsLoaded([]),
    );

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);

    await tester.tap(find.byType(NotificationBell));
    await tester.pumpAndSettle();
    expect(find.text('NOTIF PAGE'), findsOneWidget);

    // Back button (maybePop) must return to the screen that opened it (R2).
    await tester.tap(find.text('NOTIF PAGE'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
