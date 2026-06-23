# RAGRO Architecture — Navigation with GoRouter

## AppRouter — Singleton with Auth Guard

`AppRouter` is registered as `@lazySingleton` and receives `AuthBloc` via dependency injection. This allows the router to automatically react to authentication state changes.

```dart
// lib/core/router/app_router.dart
@lazySingleton
class AppRouter {
  AppRouter(this._authBloc) {
    router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
      redirect: (context, state) { ... },
      routes: [ ... ],
    );
  }

  final AuthBloc _authBloc;
  late final GoRouter router;
}
```

---

## Auth Guard — Redirect Logic

The GoRouter `redirect` parameter is called before each navigation. It evaluates the current `AuthBloc` state and decides whether to redirect:

```dart
redirect: (context, state) {
  final authState = _authBloc.state;
  final loc = state.matchedLocation;
  final isAuthRoute = loc == '/login' || loc == '/register';

  // Awaiting session verification → do not redirect yet
  if (authState is AuthLoading || authState is AuthInitial) return null;

  // Unauthenticated trying to access a restricted area → go to login
  if (authState is AuthUnauthenticated && !isAuthRoute) {
    return '/login';
  }

  // Authenticated trying to access login/register → go to their role's landing
  if (authState is AuthAuthenticated && isAuthRoute) {
    return switch (authState.user.type) {
      UserType.customer => '/customer/impact',
      UserType.producer => '/producer/home',
      UserType.admin    => '/admin/producers',
    };
  }

  return null; // no redirect
},
```

---

## _GoRouterRefreshStream — BLoC Synchronization

GoRouter's `refreshListenable` requires a `ChangeNotifier`. The `_GoRouterRefreshStream` class bridges the `AuthBloc` stream and the `ChangeNotifier`:

```dart
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
```

Every time `AuthBloc` emits a new state (e.g., `AuthAuthenticated`), `notifyListeners()` is called, GoRouter re-evaluates the `redirect`, and navigates automatically.

---

## StatefulShellRoute — Tab Navigation

RAGRO uses `StatefulShellRoute.indexedStack` to implement tab navigation with a bottom navigation bar. Each tab (branch) maintains its own navigation stack, preserving scroll position and state when switching tabs.

### Customer Shell (5 tabs)

```
CustomerShell
├── Tab 0: /customer/home          → CustomerHomePage
│   ├── /customer/home/producer/:producerId          → ProducerPublicProfilePage
│   │   └── /customer/home/producer/:producerId/reviews → ReviewsPage
│   └── /customer/home/product/:productId            → ProductDetailPage
├── Tab 1: /customer/orders        → CustomerOrdersPage (observers: ordersRouteObserver)
│   └── /customer/orders/:orderId                    → OrderDetailPage
│       ├── /customer/orders/:orderId/tracking       → DeliveryTrackingPage
│       └── /customer/orders/:orderId/rate           → RateProducerPage
├── Tab 2: /customer/map           → MapPage
├── Tab 3: /customer/profile       → CustomerProfilePage (ShellRoute provides BlocProvider)
│   ├── /customer/profile/edit                       → CustomerEditProfilePage
│   └── /customer/profile/faq                        → FaqPage
└── Tab 4: /customer/search        → SearchPage
    └── /customer/search/results                     → SearchResultsPage
```

The orders branch attaches a custom `NavigatorObserver` (`observers: [ordersRouteObserver]`, see `lib/core/navigation/orders_route_observer.dart`).

Routes outside the shell (no bottom nav):
- `/customer/impact` → ImpactPage (post-login landing for customers)
- `/customer/impact/detail` → ImpactDetailPage
- `/customer/notifications` → NotificationsPage
- `/customer/notifications/detail` → NotificationDetailPage
- `/customer/producer/:producerId` → ProducerPublicProfilePage (fullscreen, used from the map)
- `/customer/producer/:producerId/reviews` → ReviewsPage
- `/customer/cart` → CartPage
- `/customer/checkout` → OrderConfirmationPage
- `/customer/edit-address` → CustomerEditAddressPage

### Producer Shell (3 tabs)

```
ProducerShell
├── Tab 0: /producer/home          → ProducerOrdersPage
│   ├── /producer/home/orders/:orderId → ProducerOrderDetailPage
│   └── /producer/home/route           → RouteCalculationPage
├── Tab 1: /producer/stock         → InventoryPage
│   ├── /producer/stock/new                → ProductFormPage
│   ├── /producer/stock/:productId/edit    → ProductFormPage(productId)
│   ├── /producer/stock/:productId/entry   → StockEntryPage
│   ├── /producer/stock/:productId/exit    → StockExitPage
│   └── /producer/stock/:productId/history → StockMovementsPage
└── Tab 2: /producer/profile       → ProducerProfilePage
    ├── /producer/profile/edit         → ProducerEditProfilePage
    ├── /producer/profile/settings     → ProducerSettingsPage
    ├── /producer/profile/faq          → FaqPage
    └── /producer/profile/reviews      → ReviewsPage
```

Routes outside the shell (no bottom nav):
- `/producer/notifications` → NotificationsPage
- `/producer/notifications/detail` → NotificationDetailPage

---

## Complete Route Table by Role

### Auth

| Route | Page | Description |
|-------|------|-------------|
| `/login` | `LoginPage` | Unified login screen |
| `/register` | `CustomerRegisterPage` | New customer registration |

### Customer

| Route | Page | Description |
|-------|------|-------------|
| `/customer/impact` | `ImpactPage` | CO2 impact — post-login landing for customers |
| `/customer/impact/detail` | `ImpactDetailPage` | CO2 impact detail |
| `/customer/home` | `CustomerHomePage` | Producer feed and recommendations |
| `/customer/home/producer/:producerId` | `ProducerPublicProfilePage` | Public profile of a producer |
| `/customer/home/producer/:producerId/reviews` | `ReviewsPage` | Producer reviews |
| `/customer/home/product/:productId` | `ProductDetailPage` | Product detail |
| `/customer/orders` | `CustomerOrdersPage` | Customer order list |
| `/customer/orders/:orderId` | `OrderDetailPage` | Order detail |
| `/customer/orders/:orderId/tracking` | `DeliveryTrackingPage` | Real-time delivery GPS tracking |
| `/customer/orders/:orderId/rate` | `RateProducerPage` | Post-order producer rating |
| `/customer/map` | `MapPage` | Producers map |
| `/customer/profile` | `CustomerProfilePage` | Customer profile |
| `/customer/profile/edit` | `CustomerEditProfilePage` | Edit customer data |
| `/customer/profile/faq` | `FaqPage` | FAQ |
| `/customer/search` | `SearchPage` | Search for producers and products |
| `/customer/search/results` | `SearchResultsPage` | Search results |
| `/customer/notifications` | `NotificationsPage` | Notification list |
| `/customer/notifications/detail` | `NotificationDetailPage` | Notification detail (falls back to list without `extra`) |
| `/customer/producer/:producerId` | `ProducerPublicProfilePage` | Fullscreen producer profile (e.g. from the map) |
| `/customer/producer/:producerId/reviews` | `ReviewsPage` | Producer reviews |
| `/customer/cart` | `CartPage` | Shopping cart |
| `/customer/checkout` | `OrderConfirmationPage` | Order confirmation |
| `/customer/edit-address` | `CustomerEditAddressPage` | Edit delivery address |

### Producer

| Route | Page | Description |
|-------|------|-------------|
| `/producer/home` | `ProducerOrdersPage` | List of received orders |
| `/producer/home/orders/:orderId` | `ProducerOrderDetailPage` | Detail of a received order |
| `/producer/home/route` | `RouteCalculationPage` | Delivery route calculation |
| `/producer/stock` | `InventoryPage` | Product inventory |
| `/producer/stock/new` | `ProductFormPage` | Create new product |
| `/producer/stock/:productId/edit` | `ProductFormPage(productId)` | Edit existing product |
| `/producer/stock/:productId/entry` | `StockEntryPage` | Register stock entry |
| `/producer/stock/:productId/exit` | `StockExitPage` | Register stock exit |
| `/producer/stock/:productId/history` | `StockMovementsPage` | Stock movement history |
| `/producer/profile` | `ProducerProfilePage` | Producer profile and dashboard |
| `/producer/profile/edit` | `ProducerEditProfilePage` | Edit producer data |
| `/producer/profile/settings` | `ProducerSettingsPage` | Account settings |
| `/producer/profile/faq` | `FaqPage` | FAQ |
| `/producer/profile/reviews` | `ReviewsPage` | Producer reviews |
| `/producer/notifications` | `NotificationsPage` | Notification list |
| `/producer/notifications/detail` | `NotificationDetailPage` | Notification detail (falls back to list without `extra`) |

### Admin

| Route | Page | Description |
|-------|------|-------------|
| `/admin/producers` | `AdminProducersPage` | List of all producers |
| `/admin/producers/new` | `AdminCreateProducerPage` | Register a new producer |
| `/admin/producers/:id/edit` | `AdminEditProducerPage` | Edit an existing producer |

---

## Navigation Methods

```dart
// Replaces the entire stack — use for tabs and after login/logout
context.go('/customer/home');

// Pushes on top of the current screen — use for details and modals
context.push('/customer/orders/order-123');

// Goes back to the previous screen
context.pop();

// Navigates with query parameters
context.push('/customer/orders/order-123/rate?farmName=Sitio&ownerName=Joao&isRated=true');
// Read with: state.uri.queryParameters['farmName'] (also 'ownerName', 'isRated')

// Navigates with path parameters
context.go('/customer/home/producer/$producerId');
// Read with: state.pathParameters['producerId']
```

---

## Important: BlocProvider at the Route Level

For BLoCs that need to survive sub-routes (such as `CustomerProfileBloc`, which serves `/customer/profile`, `/customer/profile/edit` and `/customer/profile/faq`), the `BlocProvider` is placed above the routes, **not** inside the page widget.

See `lib/core/router/app_router.dart` — the `/customer/profile` GoRoute and its `edit`/`faq` children are wrapped in a `ShellRoute` whose `builder` provides a single shared `CustomerProfileBloc` (created with `getIt<CustomerProfileBloc>()..add(const CustomerProfileStarted())`). The child routes do **not** create their own instances — they reuse the one from the wrapping `ShellRoute`.

This avoids the `ProviderNotFoundException` error that would occur if the parent page were destroyed when navigating to the child route.
