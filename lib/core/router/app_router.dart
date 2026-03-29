import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/presentation/pages/admin_create_producer_page.dart';
import 'package:ragro_mobile/features/admin/presentation/pages/admin_producers_page.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/consumer_register_page.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:ragro_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_bloc.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_event.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/pages/consumer_edit_profile_page.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/pages/consumer_profile_page.dart';
import 'package:ragro_mobile/features/home/presentation/pages/consumer_home_page.dart';
import 'package:ragro_mobile/features/inventory/presentation/pages/inventory_page.dart';
import 'package:ragro_mobile/features/inventory/presentation/pages/product_form_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/consumer_orders_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/order_confirmation_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/order_detail_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/rate_producer_page.dart';
import 'package:ragro_mobile/features/producer_management/presentation/pages/producer_edit_profile_page.dart';
import 'package:ragro_mobile/features/producer_management/presentation/pages/producer_profile_page.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/pages/producer_order_detail_page.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/pages/producer_orders_page.dart';
import 'package:ragro_mobile/features/producer_management/presentation/pages/producer_settings_page.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/pages/route_calculation_page.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/pages/producer_public_profile_page.dart';
import 'package:ragro_mobile/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:ragro_mobile/features/search/presentation/pages/search_page.dart';
import 'package:ragro_mobile/shared/widgets/consumer_shell.dart';
import 'package:ragro_mobile/shared/widgets/producer_shell.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._authBloc) {
    router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
      redirect: (context, state) {
        final authState = _authBloc.state;
        final loc = state.matchedLocation;
        final isAuthRoute = loc == '/login' || loc == '/register';

        if (authState is AuthLoading || authState is AuthInitial) return null;
        if (authState is AuthUnauthenticated && !isAuthRoute) {
          return '/login';
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
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const ConsumerRegisterPage()),

        // Consumer shell with bottom nav
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => ConsumerShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/consumer/home',
                builder: (_, __) => const ConsumerHomePage(),
                routes: [
                  GoRoute(
                    path: 'producer/:producerId',
                    builder: (context, state) => ProducerPublicProfilePage(
                      producerId: state.pathParameters['producerId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'product/:productId',
                    builder: (context, state) => ProductDetailPage(
                      productId: state.pathParameters['productId']!,
                    ),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/consumer/orders',
                builder: (_, __) => const ConsumerOrdersPage(),
                routes: [
                  GoRoute(
                    path: ':orderId',
                    builder: (context, state) => OrderDetailPage(
                      orderId: state.pathParameters['orderId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'rate',
                        builder: (context, state) => RateProducerPage(
                          orderId: state.pathParameters['orderId']!,
                          farmName: state.uri.queryParameters['farmName'] ?? '',
                          ownerName: state.uri.queryParameters['ownerName'] ?? '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/consumer/profile',
                builder: (context, __) {
                  final authState = context.read<AuthBloc>().state;
                  final userId = authState is AuthAuthenticated ? authState.user.id : '';
                  return BlocProvider(
                    create: (_) => getIt<ConsumerProfileBloc>()
                      ..add(ConsumerProfileStarted(userId)),
                    child: const ConsumerProfilePage(),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, __) {
                      final authState = context.read<AuthBloc>().state;
                      final userId = authState is AuthAuthenticated ? authState.user.id : '';
                      return BlocProvider(
                        create: (_) => getIt<ConsumerProfileBloc>()
                          ..add(ConsumerProfileStarted(userId)),
                        child: const ConsumerEditProfilePage(),
                      );
                    },
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/consumer/search',
                builder: (_, __) => const SearchPage(),
              ),
            ]),
          ],
        ),

        // Cart & Checkout routes
        GoRoute(path: '/consumer/cart', builder: (_, __) => const CartPage()),
        GoRoute(path: '/consumer/checkout', builder: (_, __) => const OrderConfirmationPage()),

        // Producer shell with 3 tabs
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => ProducerShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/producer/home',
                builder: (_, __) => const ProducerOrdersPage(),
                routes: [
                  GoRoute(
                    path: 'orders/:orderId',
                    builder: (context, state) => ProducerOrderDetailPage(
                      orderId: state.pathParameters['orderId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'route',
                    builder: (_, __) => const RouteCalculationPage(),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/producer/stock',
                builder: (_, __) => const InventoryPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, __) => const ProductFormPage(),
                  ),
                  GoRoute(
                    path: ':productId/edit',
                    builder: (context, state) => ProductFormPage(
                      productId: state.pathParameters['productId'],
                    ),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/producer/profile',
                builder: (_, __) => const ProducerProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, __) => const ProducerEditProfilePage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, __) => const ProducerSettingsPage(),
                  ),
                ],
              ),
            ]),
          ],
        ),

        // Admin routes
        GoRoute(
          path: '/admin/producers',
          builder: (_, __) => const AdminProducersPage(),
        ),
        GoRoute(
          path: '/admin/producers/new',
          builder: (_, __) => const AdminCreateProducerPage(),
        ),
      ],
    );
  }

  final AuthBloc _authBloc;
  late final GoRouter router;
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
