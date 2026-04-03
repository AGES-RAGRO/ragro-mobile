# RAGRO Architecture — The Layers in Detail

This document dives deeper into each Clean Architecture layer using the authentication (`auth`) flow as a concrete example.

---

## 1. Presentation Layer

The presentation layer is responsible for everything the user sees and interacts with. It is composed of three types of files:

### 1.1 Page (Screen)

The page is the entry point of a route. It is responsible for:
- Instantiating the BLoC via `BlocProvider` (or receiving a BLoC already provided by the router)
- Reacting to states with `BlocBuilder` / `BlocListener` / `BlocConsumer`
- Composing child widgets, passing data via constructors

```dart
// lib/features/auth/presentation/pages/login_page.dart
// Screen: Login
// User Story: US-01 — Log in to the platform
// Epic: EPIC 1 — Authentication
// Routes: GET /auth/config → POST Keycloak → GET /auth/session

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
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
        child: const Scaffold(body: LoginForm()),
      ),
    );
  }
}
```

### 1.2 BLoC

The BLoC receives events (user or system actions), processes them via UseCases, and emits new states. It never makes HTTP calls directly.

```dart
// lib/features/auth/presentation/bloc/login_bloc.dart
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUser) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUser _loginUser;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final result = await _loginUser(
        email: event.email,
        password: event.password,
      );
      emit(LoginSuccess(result.user));
    } on ApiException catch (e) {
      emit(LoginFailure(e.message));
    }
  }
}
```

### 1.3 Widgets

Widgets are reusable visual components. They receive data via constructors and do not access the BLoC directly.

```dart
// lib/features/auth/presentation/widgets/auth_text_field.dart
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) { ... }
}
```

---

## 2. Domain Layer

The domain is the heart of the application. It imports nothing from infrastructure — only pure Dart and optionally packages with no platform dependencies (such as `equatable`).

### 2.1 Entity

Represents a business object. Immutable, typed, with no serialization logic.

```dart
// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.active,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserType type;
  final bool active;

  @override
  List<Object?> get props => [id, name, email, type, active, phone];
}
```

### 2.2 Repository Contract

Defines what the repository must be able to do, without specifying how. It is an `abstract class`.

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<({User user, String token})> loginUser({
    required String email,
    required String password,
  });

  Future<User> registerConsumer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String zipCode,
    required String street,
    required String number,
    required String city,
    required String state,
    String? complement,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();
}
```

### 2.3 UseCase

Encapsulates a single business operation. Receives the repository via constructor and exposes a `call()` method.

```dart
// lib/features/auth/domain/usecases/login_user.dart
@lazySingleton
class LoginUser {
  const LoginUser(this._repository);
  final AuthRepository _repository;

  Future<({User user, String token})> call({
    required String email,
    required String password,
  }) =>
      _repository.loginUser(email: email, password: password);
}
```

---

## 3. Data Layer

The data layer knows how to communicate with the outside world (APIs, local databases) and how to convert raw data into entities that the domain understands.

### 3.1 Model

A Model **extends** the corresponding entity and adds serialization logic (`fromJson`/`toJson`). The extension pattern (rather than composition) allows the Model to be passed directly wherever an entity is expected.

```dart
// lib/features/auth/data/models/user_model.dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.type,
    required super.active,
    super.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      type: UserType.fromApiValue(json['type'] as String),
      active: json['active'] as bool,
    );
  }
}
```

### 3.2 RemoteDataSource

Performs HTTP calls using `ApiClient` (a Dio wrapper). Returns Models, throws `ApiException`.

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<LoginResponseModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const InvalidCredentialsApiException();
      }
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
```

### 3.3 LocalDataSource

Persists and retrieves local data (SharedPreferences, Hive, etc.).

```dart
// lib/features/auth/data/datasources/auth_local_datasource.dart
@lazySingleton
class AuthLocalDataSource {
  const AuthLocalDataSource(this._prefs);
  final SharedPreferences _prefs;

  Future<void> saveSession({
    required String token,
    required String userType,
    required String userId,
    // ...
  }) async {
    await _prefs.setString('auth_token', token);
    await _prefs.setString('user_type', userType);
    // ...
  }

  String? getToken() => _prefs.getString('auth_token');
  Future<void> clearSession() => _prefs.clear();
}
```

### 3.4 RepositoryImpl

Implements the contract defined in the domain. Coordinates `RemoteDataSource` and `LocalDataSource`. Uses `@LazySingleton(as: AuthRepository)` so that get_it registers this class as the implementation of the interface.

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local, this._apiClient);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final ApiClient _apiClient;

  @override
  Future<({User user, String token})> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await _remote.loginUser(email: email, password: password);
    await _local.saveSession(
      token: response.token,
      userType: response.user.type.name,
      userId: response.user.id,
      userName: response.user.name,
      userEmail: response.user.email,
      active: response.user.active,
      phone: response.user.phone,
    );
    _apiClient.setAuthToken(response.token);
    return (user: response.user, token: response.token);
  }
  // ...
}
```

---

## Entity vs Model — Why Two Files?

This is one of the most common questions in Clean Architecture projects.

| | Entity | Model |
|---|---|---|
| **Location** | `domain/entities/` | `data/models/` |
| **Responsibility** | Represent the business concept | Serialize/deserialize external data |
| **Dependencies** | Only `dart:core` and `equatable` | May import the entity and parsing packages |
| **Who uses it** | BLoC, UseCases, the entire screen | Only the `data/` layer |
| **fromJson** | No | Yes |

The pattern adopted in RAGRO is **extends**: `UserModel extends User`. This means a `UserModel` can be passed anywhere a `User` is expected, without conversion. The parsing responsibility is encapsulated in `data/`, invisible to the domain.

---

## Complete Walkthrough: User Logs In

```
1. User types email/password and taps "Sign In"
   └─ LoginForm fires context.read<LoginBloc>().add(LoginSubmitted(email, password))

2. LoginBloc.on<LoginSubmitted> is called
   └─ emits LoginLoading (the screen shows a spinner)
   └─ await _loginUser(email: e, password: p)

3. LoginUser.call() delegates to the repository
   └─ await _repository.loginUser(email: e, password: p)

4. AuthRepositoryImpl.loginUser() coordinates datasources
   └─ await _remote.loginUser(email: e, password: p)

5. AuthRemoteDataSource.loginUser() executes the three-step Keycloak flow
   └─ GET /auth/config → { tokenUrl, clientId, realm }
   └─ POST {tokenUrl} (form-urlencoded) → { access_token, refresh_token }
   └─ GET /auth/session → { id, name, email, type, active }

6. Models parse each response separately
   └─ AuthConfigModel.fromJson, KeycloakTokenModel.fromJson, UserModel.fromJson
   └─ Assembled into LoginResponseModel(accessToken, refreshToken, tokenUrl, clientId, user)

7. Data travels back up: LoginResponseModel → AuthRepositoryImpl
   └─ AuthRepositoryImpl saves token in SharedPreferences
   └─ AuthRepositoryImpl sets the token on Dio (AuthHeader)
   └─ Returns (user: userModel, token: "...")

8. LoginUser returns the record to LoginBloc
   └─ LoginBloc emits LoginSuccess(user)

9. BlocListener on LoginPage reacts to LoginSuccess
   └─ context.read<AuthBloc>().add(AuthLoggedIn(user))

10. AuthBloc emits AuthAuthenticated(user)
    └─ GoRouter detects the change via _GoRouterRefreshStream
    └─ redirect() evaluates the new state
    └─ Navigates to /consumer/home (or /producer/home, /admin/producers)

11. The destination screen is rendered with the authenticated user
```
