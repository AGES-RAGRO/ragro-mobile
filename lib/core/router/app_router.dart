import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/admin_login_page.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/consumer_login_page.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/consumer_register_page.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/producer_login_page.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._authBloc) {
    router = GoRouter(
      initialLocation: '/login/consumer',
      refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
      redirect: (context, state) {
        final authState = _authBloc.state;
        final loc = state.matchedLocation;
        final isAuthRoute = loc.startsWith('/login') || loc == '/register';

        if (authState is AuthLoading || authState is AuthInitial) {
          return null; // let the splash/loading handle itself
        }
        if (authState is AuthUnauthenticated && !isAuthRoute) {
          return '/login/consumer';
        }
        if (authState is AuthAuthenticated && isAuthRoute) {
          return switch (authState.user.type) {
            UserType.consumer => '/consumer/home',
            UserType.producer => '/producer/home',
            UserType.admin => '/admin/producers',
          };
        }
        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: '/login/consumer',
          builder: (_, __) => const ConsumerLoginPage(),
        ),
        GoRoute(
          path: '/login/producer',
          builder: (_, __) => const ProducerLoginPage(),
        ),
        GoRoute(
          path: '/login/admin',
          builder: (_, __) => const AdminLoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const ConsumerRegisterPage(),
        ),

        // Placeholder home routes — will be replaced in EPIC 2+
        GoRoute(
          path: '/consumer/home',
          builder: (_, __) => const _PlaceholderPage('Home do Comprador'),
        ),
        GoRoute(
          path: '/producer/home',
          builder: (_, __) => const _PlaceholderPage('Home do Produtor'),
        ),
        GoRoute(
          path: '/admin/producers',
          builder: (_, __) => const _PlaceholderPage('Painel Admin'),
        ),
      ],
    );
  }

  final AuthBloc _authBloc;
  late final GoRouter router;
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — Em construção')),
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<Object?> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
