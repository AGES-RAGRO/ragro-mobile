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

  // Authenticated trying to access login/register → go to their role's home
  if (authState is AuthAuthenticated && isAuthRoute) {
    return switch (authState.user.type) {
      UserType.consumer => '/consumer/home',
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

### Consumer Shell (4 tabs)

```
ConsumerShell
├── Tab 0: /consumer/home          → ConsumerHomePage
│   ├── /consumer/home/producer/:producerId  → ProducerPublicProfilePage
│   └── /consumer/home/product/:productId   → ProductDetailPage
├── Tab 1: /consumer/orders        → ConsumerOrdersPage
│   └── /consumer/orders/:orderId           → OrderDetailPage
│       └── /consumer/orders/:orderId/rate  → RateProducerPage
├── Tab 2: /consumer/profile       → ConsumerProfilePage (BlocProvider here)
│   └── /consumer/profile/edit             → ConsumerEditProfilePage
└── Tab 3: /consumer/search        → SearchPage
```

Routes outside the shell (no bottom nav):
- `/consumer/cart` → CartPage
- `/consumer/checkout` → OrderConfirmationPage

### Producer Shell (3 tabs)

```
ProducerShell
├── Tab 0: /producer/home          → ProducerOrdersPage
│   ├── /producer/home/orders/:orderId → ProducerOrderDetailPage
│   └── /producer/home/route           → RouteCalculationPage
├── Tab 1: /producer/stock         → InventoryPage
│   ├── /producer/stock/new            → ProductFormPage
│   └── /producer/stock/:productId/edit → ProductFormPage(productId)
└── Tab 2: /producer/profile       → ProducerProfilePage
    ├── /producer/profile/edit         → ProducerEditProfilePage
    └── /producer/profile/settings     → ProducerSettingsPage
```

---

## Complete Route Table by Role

### Auth

| Route | Page | Description |
|-------|------|-------------|
| `/login` | `LoginPage` | Unified login screen |
| `/register` | `ConsumerRegisterPage` | New consumer registration |

### Consumer

| Route | Page | Description |
|-------|------|-------------|
| `/consumer/home` | `ConsumerHomePage` | Producer feed and recommendations |
| `/consumer/home/producer/:producerId` | `ProducerPublicProfilePage` | Public profile of a producer |
| `/consumer/home/product/:productId` | `ProductDetailPage` | Product detail |
| `/consumer/orders` | `ConsumerOrdersPage` | Consumer order list |
| `/consumer/orders/:orderId` | `OrderDetailPage` | Order detail |
| `/consumer/orders/:orderId/rate` | `RateProducerPage` | Post-order producer rating |
| `/consumer/profile` | `ConsumerProfilePage` | Consumer profile |
| `/consumer/profile/edit` | `ConsumerEditProfilePage` | Edit consumer data |
| `/consumer/search` | `SearchPage` | Search for producers and products |
| `/consumer/cart` | `CartPage` | Shopping cart |
| `/consumer/checkout` | `OrderConfirmationPage` | Order confirmation |

### Producer

| Route | Page | Description |
|-------|------|-------------|
| `/producer/home` | `ProducerOrdersPage` | List of received orders |
| `/producer/home/orders/:orderId` | `ProducerOrderDetailPage` | Detail of a received order |
| `/producer/home/route` | `RouteCalculationPage` | Delivery route calculation |
| `/producer/stock` | `InventoryPage` | Product inventory |
| `/producer/stock/new` | `ProductFormPage` | Create new product |
| `/producer/stock/:productId/edit` | `ProductFormPage(productId)` | Edit existing product |
| `/producer/profile` | `ProducerProfilePage` | Producer profile and dashboard |
| `/producer/profile/edit` | `ProducerEditProfilePage` | Edit producer data |
| `/producer/profile/settings` | `ProducerSettingsPage` | Account settings |

### Admin

| Route | Page | Description |
|-------|------|-------------|
| `/admin/producers` | `AdminProducersPage` | List of all producers |
| `/admin/producers/new` | `AdminCreateProducerPage` | Register a new producer |

---

## Navigation Methods

```dart
// Replaces the entire stack — use for tabs and after login/logout
context.go('/consumer/home');

// Pushes on top of the current screen — use for details and modals
context.push('/consumer/orders/order-123');

// Goes back to the previous screen
context.pop();

// Navigates with query parameters
context.push('/consumer/orders/order-123/rate?farmName=Sitio&ownerName=Joao');
// Read with: state.uri.queryParameters['farmName']

// Navigates with path parameters
context.go('/consumer/home/producer/$producerId');
// Read with: state.pathParameters['producerId']
```

---

## Important: BlocProvider at the Route Level

For BLoCs that need to survive sub-routes (such as `ConsumerProfileBloc`, which serves both `/consumer/profile` and `/consumer/profile/edit`), the `BlocProvider` must be placed in the parent route's `builder`, **not** inside the page widget.

See `lib/core/router/app_router.dart` — the `/consumer/profile` route creates a `BlocProvider` in its builder. The child route `/consumer/profile/edit` creates a separate BlocProvider with its own instance.

This avoids the `ProviderNotFoundException` error that would occur if the parent page were destroyed when navigating to the child route.
