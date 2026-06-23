import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/router/app_router.dart';
import 'package:ragro_mobile/core/theme/app_theme.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ragro_mobile/features/notifications/data/services/notification_service.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:ragro_mobile/features/notifications/presentation/bloc/notifications_state.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  // Notifications bloc lives at app root so every bell badge and the pushed
  // notifications page share one source of truth across all shells/routes.
  final AuthBloc _authBloc = getIt<AuthBloc>()..add(const AuthStarted());
  final NotificationsBloc _notificationsBloc = getIt<NotificationsBloc>();
  final NotificationService _notificationService = getIt<NotificationService>();

  StreamSubscription<void>? _foregroundSub;
  bool _fcmInitialized = false;
  int? _lastAppliedBadgeCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A foreground push means the badge may have changed: refresh from backend.
    _foregroundSub = _notificationService.onForegroundMessage.listen((_) {
      _notificationsBloc.add(const NotificationsUnreadCountRequested());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _foregroundSub?.cancel();
    _notificationsBloc.close();
    _authBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    // Unread count may change while backgrounded or via pushes outside the
    // foreground FCM stream.
    _notificationsBloc.add(const NotificationsUnreadCountRequested());
  }

  void _onAuthChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _notificationsBloc.add(const NotificationsUnreadCountRequested());
      if (!_fcmInitialized) {
        _fcmInitialized = true;
        unawaited(_notificationService.initialize());
      } else {
        // Account switch on same device: re-bind token to the new user.
        // Backend upserts by unique `token`, so re-POST moves the device.
        unawaited(_notificationService.registerCurrentToken());
      }
    } else {
      _lastAppliedBadgeCount = null;
      unawaited(_applyAppIconBadge(0));
      _notificationsBloc.add(const NotificationsReset());
    }
  }

  Future<void> _syncAppIconBadge(NotificationsState state) async {
    final unreadCount = switch (state) {
      NotificationsInitial(:final unreadCount) => unreadCount,
      NotificationsLoading(:final unreadCount) => unreadCount,
      NotificationsLoaded(:final unreadCount) => unreadCount,
      NotificationsFailure(:final unreadCount) => unreadCount,
    };

    if (_lastAppliedBadgeCount == unreadCount) return;
    _lastAppliedBadgeCount = unreadCount;
    await _applyAppIconBadge(unreadCount);
  }

  Future<void> _applyAppIconBadge(int unreadCount) async {
    try {
      if (!await AppBadgePlus.isSupported()) return;
      // updateBadge(0) clears the badge; any positive count sets it.
      await AppBadgePlus.updateBadge(unreadCount);
    } on Object {
      // Badge sync is best-effort and should never disrupt app rendering.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _notificationsBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                (previous is AuthAuthenticated) !=
                (current is AuthAuthenticated),
            listener: (_, state) => _onAuthChanged(state),
          ),
          BlocListener<NotificationsBloc, NotificationsState>(
            listener: (_, state) => unawaited(_syncAppIconBadge(state)),
          ),
        ],
        child: MaterialApp.router(
          title: 'RAGRO',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: getIt<AppRouter>().router,
        ),
      ),
    );
  }
}
