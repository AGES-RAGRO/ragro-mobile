# RAGRO Architecture — Folder Structure

## Fully Annotated Overview

```
lib/
│
├── core/                                  # Infrastructure shared across all features
│   ├── di/
│   │   ├── injection.dart                 # Initializes GetIt and registers modules
│   │   ├── injection.config.dart          # GENERATED — do not edit manually
│   │   ├── network_module.dart            # Registers Dio as a lazySingleton
│   │   └── shared_preferences_module.dart # Registers SharedPreferences (async factory)
│   │
│   ├── network/
│   │   ├── api_client.dart                # Dio wrapper: manages Bearer token and interceptors
│   │   ├── api_endpoints.dart             # All API URLs as typed constants
│   │   └── api_exception.dart             # Network exception hierarchy (ApiException, InvalidCredentialsApiException, etc.)
│   │
│   ├── router/
│   │   └── app_router.dart                # GoRouter with auth guard, shells, and all routes
│   │
│   └── theme/
│       └── app_theme.dart                 # Global theme: RAGRO colors, typography, spacing
│
├── features/                              # Each feature is an isolated module with its own layers
│   │
│   ├── auth/                              # Authentication: login, consumer registration, session
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart   # Reads/saves session in SharedPreferences
│   │   │   │   └── auth_remote_datasource.dart  # Keycloak login flow (config → token → session) and registration
│   │   │   ├── models/
│   │   │   │   ├── auth_config_model.dart       # GET /auth/config response
│   │   │   │   ├── keycloak_token_model.dart    # Keycloak token response
│   │   │   │   ├── login_response_model.dart    # Assembled login result (tokens + user)
│   │   │   │   └── user_model.dart              # Extends User, adds fromJson
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart    # Implements AuthRepository
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user.dart                    # User entity (id, name, email, type, active)
│   │   │   │   └── user_type.dart               # Enum: consumer | producer | admin
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart         # Contract: loginUser, registerConsumer, logout, getCurrentUser
│   │   │   └── usecases/
│   │   │       ├── get_current_user.dart         # Restores session when the app opens
│   │   │       ├── login_user.dart               # Authenticates email + password
│   │   │       ├── logout.dart                   # Clears local session and token
│   │   │       └── register_consumer.dart        # Registers a new consumer
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart                # Global singleton: manages app-wide auth state
│   │       │   ├── auth_event.dart               # AuthStarted, AuthLoggedIn, AuthLogoutRequested
│   │       │   ├── auth_state.dart               # AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated
│   │       │   ├── login_bloc.dart               # Manages the login form
│   │       │   ├── login_event.dart              # LoginSubmitted(email, password)
│   │       │   ├── login_state.dart              # LoginInitial, LoginLoading, LoginSuccess, LoginFailure
│   │       │   ├── register_bloc.dart            # Manages the registration form
│   │       │   ├── register_event.dart           # RegisterSubmitted(...)
│   │       │   └── register_state.dart           # RegisterInitial, RegisterLoading, RegisterSuccess, RegisterFailure
│   │       ├── pages/
│   │       │   ├── login_page.dart               # Login screen (BlocProvider wraps LoginBloc)
│   │       │   └── consumer_register_page.dart   # Consumer registration screen
│   │       └── widgets/
│   │           ├── auth_text_field.dart          # Text field with RAGRO styles
│   │           ├── auth_submit_button.dart       # Submit button with loading state
│   │           ├── login_form.dart               # Composed login form
│   │           └── ragro_logo.dart               # RAGRO SVG logo
│   │
│   ├── home/                              # Consumer home: producer list and recommendations
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── cart/                              # Shopping cart (local storage)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── orders/                            # Consumer orders: listing, detail, rating
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── search/                            # Search for producers and products
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── consumer_profile/                  # Consumer profile and data editing
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── producer_profile/                  # Public producer profile (consumer's view)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── producer_management/               # Producer dashboard and private profile
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── producer_orders/                   # Orders received by the producer: confirmation and status
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── inventory/                         # Producer inventory: product CRUD
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── product_detail/                    # Product detail (consumer's view)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── admin/                             # Admin panel: producer management
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── shared/                                # Reusable components shared across features
    └── widgets/
        ├── consumer_shell.dart            # Consumer bottom navigation bar (4 tabs: home, orders, profile, search)
        └── producer_shell.dart            # Producer bottom navigation bar (3 tabs: orders, inventory, profile)
```

---

## Internal Structure of Each Feature

Every feature follows the same three-layer pattern:

```
features/feature_name/
├── data/
│   ├── datasources/
│   │   ├── name_remote_datasource.dart   # HTTP calls via ApiClient/Dio
│   │   └── name_local_datasource.dart    # Local read/write (SharedPreferences, Hive, etc.)
│   ├── models/
│   │   └── name_model.dart               # Extends the entity, adds fromJson/toJson
│   └── repositories/
│       └── name_repository_impl.dart     # Implements the domain/ contract
│
├── domain/
│   ├── entities/
│   │   └── name.dart                     # Pure Dart class, no infrastructure imports
│   ├── repositories/
│   │   └── name_repository.dart          # Interface/contract: defines available methods
│   └── usecases/
│       └── verb_noun.dart                # A single business operation per file
│
└── presentation/
    ├── bloc/
    │   ├── name_bloc.dart                # Extends Bloc<Event, State>
    │   ├── name_event.dart               # sealed class with possible actions
    │   └── name_state.dart               # sealed class with possible states
    ├── pages/
    │   └── name_page.dart                # Screen entry point, composes widgets
    └── widgets/
        └── component_widget.dart         # Reusable, isolated widget
```

---

## Folder Naming Conventions

| Type | Location |
|------|----------|
| Screen (page) | `features/<feature>/presentation/pages/` |
| Feature-specific reusable widget | `features/<feature>/presentation/widgets/` |
| Widget shared across features | `shared/widgets/` |
| BLoC (event/state/bloc) | `features/<feature>/presentation/bloc/` |
| UseCase | `features/<feature>/domain/usecases/` |
| Entity | `features/<feature>/domain/entities/` |
| Repository contract | `features/<feature>/domain/repositories/` |
| Model | `features/<feature>/data/models/` |
| DataSource | `features/<feature>/data/datasources/` |
| Repository impl | `features/<feature>/data/repositories/` |
