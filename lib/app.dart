import 'dart:async';

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

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // The notifications bloc lives at the app root (above MaterialApp.router) so
  // every screen's bell badge AND the pushed notifications page share a single
  // source of truth, regardless of which shell/route renders them.
  final AuthBloc _authBloc = getIt<AuthBloc>()..add(const AuthStarted());
  final NotificationsBloc _notificationsBloc = getIt<NotificationsBloc>();
  final NotificationService _notificationService = getIt<NotificationService>();

  StreamSubscription<void>? _foregroundSub;
  bool _fcmInitialized = false;

  @override
  void initState() {
    super.initState();
    // A foreground push means the badge may have changed: refresh from backend.
    _foregroundSub = _notificationService.onForegroundMessage.listen((_) {
      _notificationsBloc.add(const NotificationsUnreadCountRequested());
    });
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    _notificationsBloc.close();
    _authBloc.close();
    super.dispose();
  }

  void _onAuthChanged(AuthState state) {
    if (state is AuthAuthenticated) {
      _notificationsBloc.add(const NotificationsUnreadCountRequested());
      if (!_fcmInitialized) {
        _fcmInitialized = true;
        unawaited(_notificationService.initialize());
      }
    } else {
      _notificationsBloc.add(const NotificationsReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _notificationsBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            (previous is AuthAuthenticated) != (current is AuthAuthenticated),
        listener: (_, state) => _onAuthChanged(state),
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
