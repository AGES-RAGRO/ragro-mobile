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

This is the critical RAGRO pattern for BLoCs that need to be available in child routes. **Do not place the `BlocProvider` inside the child widget**, because when navigating to `/consumer/profile/edit` the parent widget `/consumer/profile` would be destroyed, killing the BLoC and causing a `ProviderNotFoundException`.

```dart
// lib/core/router/app_router.dart
GoRoute(
  path: '/consumer/profile',
  builder: (context, __) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    return BlocProvider(               // <-- provider HERE, in the route builder
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
        return BlocProvider(           // <-- separate instance for the edit route
          create: (_) => getIt<ConsumerProfileBloc>()
            ..add(ConsumerProfileStarted(userId)),
          child: const ConsumerEditProfilePage(),
        );
      },
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
  listenWhen: (_, current) => current is InventoryError,
  listener: (context, state) {
    if (state is InventoryError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    return switch (state) {
      InventoryLoading() => const InventoryShimmer(),
      InventoryLoaded(:final products) => ProductListView(products: products),
      InventoryEmpty() => const EmptyInventoryState(),
      InventoryError() => const RetryButton(),
      InventoryInitial() => const SizedBox.shrink(),
    };
  },
)
```

---

## AuthBloc — The Global BLoC

`AuthBloc` is the only BLoC registered as a **lazySingleton**. It manages the authentication state for the entire application and is provided at the top of the widget tree in `main.dart`:

```dart
// lib/main.dart (or app.dart)
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
    ),
  ],
  child: MaterialApp.router(
    routerConfig: getIt<AppRouter>().router,
  ),
)
```

All other BLoCs are registered as `@injectable` (factory), creating a new instance every time `getIt<XBloc>()` is called.

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
