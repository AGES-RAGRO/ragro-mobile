# RAGRO Architecture — Overview

## What is Flutter/Dart

Flutter is a cross-platform UI framework created by Google that compiles to native code on Android, iOS, Web, and Desktop from a single Dart codebase. Dart is a strongly-typed, object-oriented language with native `async/await` support and mandatory null safety (since Dart 2.12).

In RAGRO, Flutter is the sole presentation layer — all business logic, data access, and navigation are written in pure Dart, with no platform dependencies.

---

## Clean Architecture + BLoC

The project adopts **Clean Architecture** (proposed by Robert C. Martin) in combination with the **BLoC** (Business Logic Component) state management pattern. Together, they ensure:

- **Separation of concerns**: each file has a single, well-defined purpose
- **Testability**: any layer can be tested in isolation using mocks
- **Framework independence**: the business logic has no knowledge of Flutter
- **Maintainability**: replacing the API, local database, or UI library does not affect the domain

---

## The Restaurant Analogy

Think of the architecture as a restaurant:

| Layer | Analogy | Responsibility |
|-------|---------|----------------|
| **Presentation** | Dining Room | What the customer sees and interacts with (screens, buttons, forms) |
| **Domain** | Menu + House Rules | What the restaurant offers and its rules (entities, use cases, contracts) |
| **Data** | Kitchen + Suppliers | How dishes are prepared and where ingredients come from (APIs, local database) |

The waiter (BLoC) moves between the dining room and the kitchen, but the customer never enters the kitchen, and the kitchen has no knowledge of individual tables.

---

## Complete Request Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│                                                                 │
│   Screen (Widget)                                               │
│      │  dispatch(LoginSubmitted(email, password))               │
│      ▼                                                          │
│   BLoC                                                          │
│      │  await _loginUser(email: e, password: p)                 │
│      ▼                                                          │
├─────────────────────────────────────────────────────────────────┤
│                        DOMAIN LAYER                             │
│                                                                 │
│   UseCase (LoginUser)                                           │
│      │  await _repository.loginUser(email: e, password: p)      │
│      ▼                                                          │
│   Repository (AuthRepository — contract/interface)              │
│      │                                                          │
├─────────────────────────────────────────────────────────────────┤
│                         DATA LAYER                              │
│                                                                 │
│   RepositoryImpl (AuthRepositoryImpl)                           │
│      │  await _remote.loginUser(...)                            │
│      ▼                                                          │
│   RemoteDataSource (AuthRemoteDataSource)                       │
│      │  GET /auth/config → POST Keycloak → GET /auth/session    │
│      ▼                                                          │
│   Model (UserModel.fromJson(json))                              │
│      │  parsing JSON → typed object                             │
│      ▼                                                          │
│   Entity (User)  ← returned back up through the layers         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         │
         │ emit(LoginSuccess(user))
         ▼
      Screen reacts → navigates to /consumer/home
```

**Data travels back up the exact reverse path**: `DataSource → Model → Entity → Repository → UseCase → BLoC → Screen`.

---

## Dependency Rule

The most important rule of Clean Architecture: **inner layers never import outer layers**.

```
presentation/  →  may import domain/
domain/        →  does not import any project layer
data/          →  may import domain/ (to implement the interfaces)
data/          →  does not import presentation/
```

This means the `domain/` layer is completely agnostic with respect to Flutter, Dio, SharedPreferences, or any other external dependency. It only knows pure Dart.

Dependency inversion is implemented via interfaces (contracts): `AuthRepository` is defined in `domain/`, and `AuthRepositoryImpl` in `data/` implements that contract. The BLoC uses the contract, never the implementation directly — `get_it` handles the injection.
