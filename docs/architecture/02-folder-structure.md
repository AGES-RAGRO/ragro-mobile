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
│   │   ├── api_exception.dart             # Network exception hierarchy (ApiException, InvalidCredentialsApiException, etc.)
│   │   └── paginated_response.dart        # Generic wrapper for paginated API responses
│   │
│   ├── router/
│   │   └── app_router.dart                # GoRouter with auth guard, shells, and all routes
│   │
│   ├── theme/
│   │   ├── app_theme.dart                 # Global theme: RAGRO colors, typography, spacing
│   │   ├── app_colors.dart                # RAGRO color palette
│   │   └── app_text_styles.dart           # Typography text styles
│   │
│   ├── constants/
│   │   └── product_category.dart          # Product category constants
│   │
│   ├── domain/
│   │   └── order_status.dart              # Shared order status enum
│   │
│   ├── formatters/
│   │   ├── currency.dart                  # Currency formatting
│   │   └── input_masks.dart               # Input mask helpers
│   │
│   ├── logging/
│   │   └── app_logger.dart                # Application logger
│   │
│   ├── navigation/
│   │   └── orders_route_observer.dart     # Route observer for the orders flow
│   │
│   ├── services/
│   │   ├── cep_service.dart               # CEP (zip code) lookup service
│   │   └── tracking_socket.dart           # WebSocket/STOMP GPS tracking client
│   │
│   ├── utils/
│   │   ├── api_date_time.dart             # API date/time parsing helpers
│   │   ├── multipart_file_builder.dart    # Builds multipart file uploads
│   │   └── polyline_decoder.dart          # Decodes Google polyline geometry
│   │
│   └── validators/
│       ├── cpf_validator.dart             # CPF validation
│       └── cnpj_validator.dart            # CNPJ validation
│
├── features/                              # Each feature is an isolated module with its own layers
│   │
│   ├── auth/                              # Authentication: login, customer registration, password reset, session
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
│   │   │   │   └── user_type.dart               # Enum: customer | producer | admin
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart         # Contract: loginUser, registerCustomer, logout, requestPasswordReset, forgotPassword, getCurrentUser
│   │   │   └── usecases/
│   │   │       ├── forgot_password.dart          # Triggers password reset for an email
│   │   │       ├── get_current_user.dart         # Restores session when the app opens
│   │   │       ├── login_user.dart               # Authenticates email + password
│   │   │       ├── logout.dart                   # Clears local session and token
│   │   │       ├── register_customer.dart        # Registers a new customer
│   │   │       └── request_password_reset.dart   # Requests password reset for the current user
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
│   │       │   └── customer_register_page.dart   # Customer registration screen
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
│   ├── recommendations/                   # LLM-powered product recommendations
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── impact/                            # CO2 savings / environmental impact (presentation only)
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
│   ├── map/                               # Delivery map / customer Map tab (real-time GPS tracking)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── notifications/                     # In-app and FCM push notifications
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── customer_profile/                  # Customer profile and data editing
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
    ├── utils/
    │   └── unity_type_label.dart          # Maps unit-type values to display labels
    └── widgets/
        ├── customer_shell.dart            # Customer bottom navigation bar (5 tabs: Início, Pedidos, Mapa, Perfil, Pesquisa)
        ├── producer_shell.dart            # Producer bottom navigation bar (3 tabs: Início, Estoque, Perfil)
        ├── app_notification.dart          # In-app notification banner
        ├── cancel_order_dialog.dart       # Order cancellation dialog
        ├── confirm_delivery_code_dialog.dart # Delivery confirmation-code dialog
        ├── confirm_dialog.dart            # Generic confirmation dialog
        ├── notification_bell.dart         # Top-bar notification bell with badge
        ├── terms_of_use_dialog.dart       # Terms of use dialog
        ├── order_detail/                  # Order-detail cards, badges and action footer
        │   ├── cancellation_card.dart
        │   ├── delivery_address_card.dart
        │   ├── order_action_button.dart
        │   ├── order_action_footer.dart
        │   ├── order_item_row.dart
        │   ├── order_items_card.dart
        │   ├── order_section_title.dart
        │   ├── order_status_badge.dart
        │   └── order_success_dialog.dart
        └── producer_form/                 # Producer form fields, masks and sections
            ├── cep_lookup.dart
            ├── field_label.dart
            ├── pix_mask.dart
            ├── producer_form_controllers.dart
            ├── producer_form_sections.dart
            ├── producer_text_field.dart
            ├── uf_autocomplete.dart
            ├── uppercase_formatter.dart
            └── weekday_mapper.dart
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
