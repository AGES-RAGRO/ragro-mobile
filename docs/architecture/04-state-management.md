# RAGRO Architecture — State Management with BLoC

## What is BLoC

BLoC (Business Logic Component) is a stream-based state management pattern for Flutter. The core idea is to completely separate business logic from the UI:

- The **screen** dispatches **Events** (user or system actions)
- The **BLoC** processes events, executes logic (via UseCases), and emits **States**
- The **screen** reacts to states: rebuilds widgets, shows snackbars, navigates

RAGRO uses the `flutter_bloc` package, which simplifies BLoC with `Bloc<Event, State>`, `BlocBuilder`, `BlocListener`, and `BlocConsumer`.

---

## Events — sealed class

Events represent **intentions**: what happened or what the user wants to do.

```dart
// lib/features/auth/presentation/bloc/login_event.dart
import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
```

Using `sealed class` guarantees exhaustiveness checking in Dart: the compiler warns if a `switch` over events does not cover all subtypes.

---

## States — sealed class

States represent **what the screen should show** at any given moment.

```dart
// lib/features/auth/presentation/bloc/login_state.dart
import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';

sealed class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
```

**Mandatory 4-state pattern**: every BLoC must have (at least) one state for each phase: `Initial`, `Loading`, `Success`, and `Failure`.

---

## BlocProvider — How to Create and Where to Place It

`BlocProvider` creates a BLoC instance and makes it available to the widget subtree. There are two patterns in RAGRO:

### A) Page level (for temporary BLoCs)

Used for BLoCs that only exist while the page is active.

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(), // new instance each time
      child: const _LoginBody(),
    );
  }
}
```

### B) Route level in the router (for BLoCs that survive sub-routes)

This is the critical RAGRO pattern for BLoCs that need to be available in child routes. **Do not place the `BlocProvider` inside the child widget**, because when navigating to `/customer/profile/edit` the parent widget `/customer/profile` would be destroyed, killing the BLoC and causing a `ProviderNotFoundException`.

The customer profile uses a `ShellRoute` whose builder wraps **all** sub-routes (profile, edit, faq) in a single shared `CustomerProfileBloc`. The child `GoRoute`s have no `BlocProvider` of their own, so they reuse the one instance created at the shell.

```dart
// lib/core/router/app_router.dart
ShellRoute(
  builder: (_, __, child) {
    return BlocProvider(               // <-- one shared provider for the whole branch
      create: (_) => getIt<CustomerProfileBloc>()
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
          path: 'edit',                // <-- reuses the shell's CustomerProfileBloc
          builder: (_, __) => const CustomerEditProfilePage(),
        ),
        GoRoute(
          path: 'faq',
          builder: (_, __) => const FaqPage(),
        ),
      ],
    ),
  ],
),
```

---

## BlocBuilder — UI Rebuild

`BlocBuilder` rebuilds the widget every time the state changes. Use `buildWhen` to filter unnecessary rebuilds.

```dart
BlocBuilder<LoginBloc, LoginState>(
  buildWhen: (previous, current) => current is! LoginSuccess, // don't rebuild on success
  builder: (context, state) {
    return switch (state) {
      LoginInitial() => const SizedBox.shrink(),
      LoginLoading() => const CircularProgressIndicator(),
      LoginFailure(:final message) => Text(message, style: errorStyle),
      LoginSuccess() => const SizedBox.shrink(),
    };
  },
)
```

---

## BlocListener — Side Effects

`BlocListener` reacts to state changes without rebuilding the UI. Use for navigation, snackbars, dialogs.

```dart
BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {
    if (state is LoginSuccess) {
      context.read<AuthBloc>().add(AuthLoggedIn(state.user));
    }
    if (state is LoginFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: const LoginForm(),
)
```

---

## BlocConsumer — Listener + Builder Combined

Use when the same state change needs to both update the UI and trigger a side effect.

```dart
BlocConsumer<InventoryBloc, InventoryState>(
  listenWhen: (_, current) => current is InventoryFailure,
  listener: (context, state) {
    if (state is InventoryFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    return switch (state) {
      InventoryLoading() => const InventoryShimmer(),
      InventoryLoaded(:final products) => ProductListView(products: products),
      InventoryFailure() => const RetryButton(),
      InventoryInitial() => const SizedBox.shrink(),
    };
  },
)
```

---

## AuthBloc — The Global BLoC

`AuthBloc` is registered as a **lazySingleton**. It manages the authentication state for the entire application. It is one of two BLoCs provided at the top of the widget tree, alongside `NotificationsBloc` (the global bell-badge / notifications source of truth). `main.dart` only calls `runApp(const App())`; the global providers live in `lib/app.dart`, which builds both singletons as fields and exposes them with `BlocProvider.value`:

```dart
// lib/app.dart
final AuthBloc _authBloc = getIt<AuthBloc>()..add(const AuthStarted());
final NotificationsBloc _notificationsBloc = getIt<NotificationsBloc>();
// ...
MultiBlocProvider(
  providers: [
    BlocProvider.value(value: _authBloc),
    BlocProvider.value(value: _notificationsBloc),
  ],
  child: MaterialApp.router(
    routerConfig: getIt<AppRouter>().router,
  ),
)
```

Several other BLoCs are also `@lazySingleton` (e.g. `CartBloc`, `HomeBloc`, `ProducerManagementBloc`, `InventoryBloc`, and `ActiveDeliveryCubit`), so `getIt<XBloc>()` returns the same instance across the app. The remaining BLoCs are registered as `@injectable` (factory), creating a new instance every time `getIt<XBloc>()` is called.

### AuthBloc Events and States

```dart
// auth_event.dart
sealed class AuthEvent extends Equatable { ... }
class AuthStarted extends AuthEvent { ... }           // App started
class AuthLoggedIn extends AuthEvent {                // Successful login
  final User user;
}
class AuthLogoutRequested extends AuthEvent { ... }   // User requested logout

// auth_state.dart
sealed class AuthState extends Equatable { ... }
class AuthInitial extends AuthState { ... }            // Initial state (awaiting verification)
class AuthLoading extends AuthState { ... }            // Checking saved session
class AuthAuthenticated extends AuthState {            // Authenticated user
  final User user;
}
class AuthUnauthenticated extends AuthState { ... }   // No active session
```

### How to access the authenticated user from any screen

```dart
// In any widget below the BlocProvider<AuthBloc>:
final authState = context.read<AuthBloc>().state;
if (authState is AuthAuthenticated) {
  final user = authState.user;
  print(user.name); // Ricardo Aguiar
}
```
