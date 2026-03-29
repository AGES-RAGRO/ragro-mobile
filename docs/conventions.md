# RAGRO — Project Conventions

This document centralizes all naming, structure, and best practice conventions adopted in the RAGRO project. Following these conventions is mandatory to maintain consistency and traceability throughout the codebase.

---

## 1. Naming Conventions

### Files and Classes

| Type | File Pattern | Class Pattern | File Example | Class Example |
|------|-------------|---------------|-------------|---------------|
| Entity | `name.dart` | `PascalCase` | `user.dart` | `User` |
| Model | `name_model.dart` | `NameModel` | `user_model.dart` | `UserModel` |
| Repository (contract) | `name_repository.dart` | `NameRepository` | `auth_repository.dart` | `AuthRepository` |
| Repository (impl) | `name_repository_impl.dart` | `NameRepositoryImpl` | `auth_repository_impl.dart` | `AuthRepositoryImpl` |
| DataSource (remote) | `name_remote_datasource.dart` | `NameRemoteDataSource` | `auth_remote_datasource.dart` | `AuthRemoteDataSource` |
| DataSource (local) | `name_local_datasource.dart` | `NameLocalDataSource` | `auth_local_datasource.dart` | `AuthLocalDataSource` |
| UseCase | `verb_noun.dart` | `VerbNoun` | `login_user.dart` | `LoginUser` |
| BLoC | `name_bloc.dart` | `NameBloc` | `login_bloc.dart` | `LoginBloc` |
| Event | `name_event.dart` | `NameEvent` | `login_event.dart` | `LoginEvent` |
| State | `name_state.dart` | `NameState` | `login_state.dart` | `LoginState` |
| Page | `name_page.dart` | `NamePage` | `login_page.dart` | `LoginPage` |
| Widget | `name_widget.dart` or descriptive | `NameWidget` | `profile_info_row.dart` | `ProfileInfoRow` |
| Shell (bottom nav) | `role_shell.dart` | `RoleShell` | `consumer_shell.dart` | `ConsumerShell` |

### General Rules

- **Files**: always `snake_case`
- **Classes**: always `PascalCase`
- **Variables and methods**: always `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE` for literal values
- **Never** abbreviate names in a way that hurts readability (`remDs` → `remoteDataSource`)

---

## 2. Layer Boundary Rules

Clean Architecture defines strict rules about which layers may import which others. Violating these rules breaks the separation of concerns.

```
┌─────────────────────────────────────────────────────────┐
│  presentation/                                          │
│    MAY import:     domain/ (entities, usecases, repos)  │
│    MAY NOT import: data/ (models, impls, datasources)   │
├─────────────────────────────────────────────────────────┤
│  domain/                                                │
│    MAY import:     dart:core, equatable                 │
│    MAY NOT import: data/, presentation/, flutter        │
├─────────────────────────────────────────────────────────┤
│  data/                                                  │
│    MAY import:     domain/ (entities, repositories)     │
│    MAY NOT import: presentation/                        │
└─────────────────────────────────────────────────────────┘
```

**Practical summary:**
- If you are editing a file in `domain/` and find yourself needing to import something from `data/` or from `flutter`, something is wrong with the structure.
- If you are in `presentation/` and need to import a Model (e.g., `UserModel`), use the Entity (`User`) instead.

---

## 3. Widget Rules

- **StatelessWidget by default**: always start with `StatelessWidget`. Promote to `StatefulWidget` only when local UI state is strictly necessary (e.g., `TextEditingController`, `AnimationController`, `FocusNode`, internal checkbox).
- **Never** call `getIt<>()` or `context.read<>()` inside a widget that is not a Page.
- Widgets receive **ready-to-use data via constructors** — they never fetch data on their own.
- Each widget in `widgets/` must be a separate file — do not group unrelated widgets together.
- Widgets must support a loading state via an `isLoading` flag or via skeleton/shimmer.

---

## 4. Mandatory Screen Annotation

Every Page must begin with a traceability comment that links it back to the backlog:

```dart
// Screen: [Screen Name]
// User Story: US-XX — [User Story Title]
// Epic: EPIC X — [Epic Title]
// Routes: METHOD /endpoint
```

**Examples:**

```dart
// Screen: Login
// User Story: US-01 — Log in to the platform
// Epic: EPIC 1 — Authentication
// Routes: POST /auth/login
```

```dart
// Screen: Producer Profile (public view)
// User Story: US-14 — View a producer's profile
// Epic: EPIC 3 — Producer Profile
// Routes: GET /producers/:id
```

---

## 5. BLoC State Pattern

Every BLoC must have **at least** four states, reflecting the lifecycle of an asynchronous operation:

| State | When to use | What the UI should show |
|-------|------------|-------------------------|
| `NameInitial` | Initial state, before any action | Nothing or blank screen |
| `NameLoading` | Operation in progress | Skeleton, shimmer, or `CircularProgressIndicator` |
| `NameSuccess` / `NameLoaded` | Operation completed successfully | Populated data |
| `NameFailure` / `NameError` | Operation failed | Error message + retry button |
| `NameEmpty` | Operation succeeded but no data returned | Illustration or empty state message |

---

## 6. Dependency Injection — Annotations

| Situation | Annotation | When to use |
|-----------|-----------|-------------|
| BLoC (per page) | `@injectable` | Each page receives a new instance |
| Global BLoC | `@lazySingleton` | Only `AuthBloc` and `CartBloc` |
| Service, DataSource, UseCase | `@lazySingleton` | Shared, no mutable state |
| Repository impl (by interface) | `@LazySingleton(as: Interface)` | Contract implementations |
| External dependency without annotation | `@module` + annotated method | `Dio`, `SharedPreferences` |

---

## 7. Tech Stack

| Technology | Package | Purpose |
|------------|---------|---------|
| **Flutter** | `flutter` | Cross-platform UI framework |
| **Dart** | `dart` | Programming language |
| **State Management** | `flutter_bloc` | BLoC pattern |
| **Dependency Injection** | `get_it` + `injectable` | Service locator and code generation |
| **Navigation** | `go_router` | Declarative routing with deep linking |
| **HTTP Client** | `dio` | HTTP requests and interceptors |
| **Local Storage** | `shared_preferences` | Simple key-value persistence |
| **Equality** | `equatable` | Object comparison in entities and states |
| **Code Generation** | `build_runner` | Generates `injection.config.dart` |

---

## 8. Workflow — Mandatory Order

```
1. Read docs/backlog_ragro.md        → identify the user story and acceptance criteria
2. Read docs/term_of_opening_project.md → confirm project context and scope
3. Read docs/figma_screens.md        → locate the Figma node IDs
4. Read docs/architecture/           → confirm folder structure and patterns
5. Use Context7                      → fetch up-to-date docs for any required library
6. Use Figma MCP                     → get_design_context for the screen node ID
7. Plan components                   → break the screen into reusable widgets
8. Define Dart models                → based on API contracts from the backlog
9. Apply the frontend-design skill   → mobile-first, high-quality UI
10. Annotate the screen file         → link it to the corresponding user story
```

Never skip steps. Never implement based on assumptions.
