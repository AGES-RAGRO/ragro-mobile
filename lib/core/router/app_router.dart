import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/admin/presentation/pages/admin_create_producer_page.dart';
import 'package:ragro_mobile/features/admin/presentation/pages/admin_edit_producer_page.dart';
import 'package:ragro_mobile/features/admin/presentation/pages/admin_producers_page.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/customer_register_page.dart';
import 'package:ragro_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:ragro_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_bloc.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_event.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/pages/customer_edit_address_page.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/pages/customer_edit_profile_page.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/pages/customer_profile_page.dart';
import 'package:ragro_mobile/features/home/presentation/pages/customer_home_page.dart';
import 'package:ragro_mobile/features/inventory/presentation/pages/inventory_page.dart';
import 'package:ragro_mobile/features/inventory/presentation/pages/product_form_page.dart';
import 'package:ragro_mobile/features/inventory/presentation/pages/stock_entry_page.dart';
import 'package:ragro_mobile/features/inventory/presentation/pages/stock_exit_page.dart';
import 'package:ragro_mobile/features/inventory/presentation/pages/stock_movements_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/customer_orders_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/order_confirmation_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/order_detail_page.dart';
import 'package:ragro_mobile/features/orders/presentation/pages/rate_producer_page.dart';
import 'package:ragro_mobile/features/producer_management/presentation/pages/producer_edit_profile_page.dart';
import 'package:ragro_mobile/features/producer_management/presentation/pages/producer_profile_page.dart';
import 'package:ragro_mobile/features/producer_management/presentation/pages/producer_settings_page.dart';
import 'package:ragro_mobile/features/producer_orders/domain/entities/producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/pages/producer_order_detail_page.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/pages/producer_orders_page.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/pages/route_calculation_page.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/pages/producer_public_profile_page.dart';
import 'package:ragro_mobile/features/product_detail/presentation/pages/product_detail_page.dart';
import 'package:ragro_mobile/features/search/presentation/pages/search_page.dart';
import 'package:ragro_mobile/features/search/presentation/pages/search_result_page.dart';
import 'package:ragro_mobile/shared/widgets/customer_shell.dart';
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
            UserType.customer => '/customer/home',
            UserType.producer => '/producer/home',
            UserType.admin => '/admin/producers',
          };
        }
        return null;
      },
      routes: [
        // Auth routes
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (_, __) => const CustomerRegisterPage(),
        ),

        // Customer shell with bottom nav
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => CustomerShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/customer/home',
                  builder: (_, __) => const CustomerHomePage(),
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
                        producerId: state.extra as String? ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/customer/orders',
                  builder: (_, __) => const CustomerOrdersPage(),
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
                            farmName:
                                state.uri.queryParameters['farmName'] ?? '',
                            ownerName:
                                state.uri.queryParameters['ownerName'] ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                ShellRoute(
                  builder: (_, __, child) {
                    return BlocProvider(
                      create: (_) =>
                          getIt<CustomerProfileBloc>()
                            ..add(const CustomerProfileStarted()),
                      child: child,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: '/customer/profile',
                      builder: (_, __) => const CustomerProfilePage(),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, __) => const CustomerEditProfilePage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/customer/search',
                  builder: (_, __) => const SearchPage(),
                  routes: [
                    GoRoute(
                      path: 'results',
                      builder: (_, state) {
                        final params = state.extra! as SearchRouteParams;
                        return SearchResultsPage(
                          query: params.query,
                          category: params.category,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Cart & Checkout routes
        GoRoute(path: '/customer/cart', builder: (_, __) => const CartPage()),
        GoRoute(
          path: '/customer/checkout',
          builder: (_, __) => const OrderConfirmationPage(),
        ),
        GoRoute(
          path: '/customer/edit-address',
          builder: (_, __) => const CustomerEditAddressPage(),
        ),

        // Top-level producer profile (fullscreen) — used from outside the
        // customer shell (e.g. cart). The shell-nested version at
        // /customer/home/producer/:id keeps the bottom nav.
        GoRoute(
          path: '/customer/producer/:producerId',
          builder: (context, state) => ProducerPublicProfilePage(
            producerId: state.pathParameters['producerId']!,
          ),
        ),

        // Producer shell with 3 tabs
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => ProducerShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/producer/home',
                  builder: (_, __) => const ProducerOrdersPage(),
                  routes: [
                    GoRoute(
                      path: 'orders/:orderId',
                      builder: (context, state) => ProducerOrderDetailPage(
                        orderId: state.pathParameters['orderId']!,
                        initialOrder: state.extra as ProducerOrder?,
                      ),
                    ),
                    GoRoute(
                      path: 'route',
                      builder: (_, __) => const RouteCalculationPage(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
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
                    GoRoute(
                      path: ':productId/entry',
                      builder: (context, state) {
                        final extra =
                            state.extra as Map<String, dynamic>? ?? {};
                        return StockEntryPage(
                          productId: state.pathParameters['productId']!,
                          productName:
                              extra['productName'] as String? ?? '',
                          unit: extra['unit'] as String? ?? 'un',
                        );
                      },
                    ),
                    GoRoute(
                      path: ':productId/exit',
                      builder: (context, state) {
                        final extra =
                            state.extra as Map<String, dynamic>? ?? {};
                        return StockExitPage(
                          productId: state.pathParameters['productId']!,
                          productName: extra['productName'] as String? ?? '',
                          unit: extra['unit'] as String? ?? 'un',
                          currentStock:
                              (extra['currentStock'] as num?)?.toDouble() ?? 0.0,
                        );
                      },
                    ),
                    GoRoute(
                      path: ':productId/history',
                      builder: (context, state) {
                        final extra =
                            state.extra as Map<String, dynamic>? ?? {};
                        return StockMovementsPage(
                          productId: state.pathParameters['productId']!,
                          productName:
                              extra['productName'] as String? ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
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
              ],
            ),
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
        GoRoute(
          path: '/admin/producers/:id/edit',
          builder: (_, state) =>
              AdminEditProducerPage(producerId: state.pathParameters['id']!),
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
